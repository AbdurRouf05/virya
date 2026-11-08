import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/time/day_key.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/focus/data/focus_providers.dart';
import 'package:virya/features/focus/domain/focus_models.dart';

/// Pemakaian aplikasi pada [day], untuk detail hari di kalender.
/// Tidak menggambar apa pun bila tidak ada pemakaian.
class FocusDayUsage extends ConsumerWidget {
  final DateTime day;
  const FocusDayUsage({super.key, required this.day});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all =
        ref.watch(focusUsageOnProvider(dayKeyOf(day))).valueOrNull ?? const [];
    final rows = all.where((e) => e.minutes > 0).toList()
      ..sort((a, b) => b.minutes.compareTo(a.minutes));
    if (rows.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: FN.ink, width: 2)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Text(
                'FOKUS',
                style: FN
                    .label(size: 12, color: FN.ink)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Container(height: 2, color: FN.ink),
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) Container(height: 1, color: FN.paperLine),
              _Row(entry: rows[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final FocusDayEntry entry;
  const _Row({required this.entry});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
    child: Row(
      children: [
        Expanded(
          child: Text(
            entry.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontFamily: FN.sans, fontSize: 14, color: FN.ink),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${entry.minutes} / ${entry.limitMinutes} mnt',
          style: FN.label(size: 11, color: entry.isOver ? FN.warn : FN.ink),
        ),
      ],
    ),
  );
}
