import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/body/data/body_providers.dart';
import 'package:virya/features/body/domain/body_logic.dart';
import 'package:virya/features/body/domain/body_models.dart';
import 'package:virya/features/body/presentation/widgets/body_compare_slider.dart';
import 'package:virya/features/body/presentation/widgets/body_weight_chart.dart';

/// Bandingkan foto dua check-in pada pose yang sama.
class BodyCompareScreen extends ConsumerStatefulWidget {
  const BodyCompareScreen({super.key});

  @override
  ConsumerState<BodyCompareScreen> createState() => _BodyCompareScreenState();
}

class _BodyCompareScreenState extends ConsumerState<BodyCompareScreen> {
  BodyPose _pose = BodyPose.front;
  String? _beforeId;
  String? _afterId;

  void _selectPose(BodyPose pose) => setState(() {
    _pose = pose;
    _beforeId = null;
    _afterId = null;
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaperBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 48),
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Kembali',
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ],
              ),
              const Masthead(kicker: 'Sebelum dan sesudah', title: 'Banding'),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final pose in BodyPose.values)
                      Semantics(
                        selected: pose == _pose,
                        child: InkButton(
                          label: pose.label,
                          height: 40,
                          style: pose == _pose
                              ? InkButtonStyle.ink
                              : InkButtonStyle.outline,
                          onPressed: () => _selectPose(pose),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _content(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content() {
    final async = ref.watch(bodyEntriesProvider);
    if (!async.hasValue) {
      if (async.hasError) return _message('Check-in gagal dimuat.');
      return const Center(child: CircularProgressIndicator());
    }
    final list = bodyEntriesWithPose(async.requireValue, _pose);
    if (list.length < 2) {
      return _message(
        'Butuh minimal 2 foto ${_pose.label.toLowerCase()} untuk dibandingkan.',
      );
    }
    var b = list.indexWhere((e) => e.id == _beforeId);
    var a = list.indexWhere((e) => e.id == _afterId);
    if (b < 0) b = 0;
    if (a < 0) a = list.length - 1;
    if (b >= a) {
      b = 0;
      a = list.length - 1;
    }
    final before = list[b];
    final after = list[a];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _DayPicker(
                title: 'SEBELUM',
                selected: before,
                options: list.sublist(0, a),
                onChanged: (id) => setState(() {
                  _beforeId = id;
                  _afterId = after.id;
                }),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DayPicker(
                title: 'SESUDAH',
                selected: after,
                options: list.sublist(b + 1),
                onChanged: (id) => setState(() {
                  _afterId = id;
                  _beforeId = before.id;
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BodyCompareSlider(
          beforePath: before.shots[_pose]!.path,
          afterPath: after.shots[_pose]!.path,
          beforeLabel: bodyShortDate(before.day),
          afterLabel: bodyShortDate(after.day),
        ),
        const SizedBox(height: 16),
        if (before.weightKg != null && after.weightKg != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SELISIH BERAT · ${bodyDaysBetween(before.day, after.day)} HARI',
                style: FN.label(size: 11),
              ),
              Text(
                bodyKgDelta(after.weightKg! - before.weightKg!),
                style: FN.label(size: 13, color: FN.ink),
              ),
            ],
          ),
      ],
    );
  }

  Widget _message(String text) => Text(
    text,
    style: TextStyle(fontFamily: FN.sans, fontSize: 14, color: FN.inkMuted),
  );
}

class _DayPicker extends StatelessWidget {
  final String title;
  final BodyEntry selected;
  final List<BodyEntry> options;
  final ValueChanged<String> onChanged;

  const _DayPicker({
    required this.title,
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: FN.label(size: 10)),
        DropdownButton<String>(
          value: selected.id,
          isExpanded: true,
          dropdownColor: FN.paper,
          style: FN.label(size: 12, color: FN.ink),
          underline: Container(height: 1.5, color: FN.ink),
          items: [
            for (final e in options)
              DropdownMenuItem(
                value: e.id,
                child: Text(
                  bodyShortDate(e.day),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (id) {
            if (id != null) onChanged(id);
          },
        ),
      ],
    );
  }
}
