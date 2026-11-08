import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stravo/app/sport_ui.dart';
import 'package:stravo/core/constants/enums.dart';
import 'package:stravo/core/data/activity_finalizer.dart';
import 'package:stravo/core/data/activity_repository.dart';
import 'package:stravo/core/database/app_database.dart';
import 'package:stravo/core/widgets/field_kit.dart';
import 'package:stravo/features/profile/data/gear_providers.dart';
import 'package:stravo/features/settings/data/data_actions.dart';

Future<void> showEditActivitySheet(
    BuildContext context, Activity activity) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => EditActivitySheet(activity: activity),
  );
}

/// Edit title / description / sport / gear, then re-finalize.
class EditActivitySheet extends ConsumerStatefulWidget {
  final Activity activity;
  const EditActivitySheet({super.key, required this.activity});

  @override
  ConsumerState<EditActivitySheet> createState() => _EditActivitySheetState();
}

class _EditActivitySheetState extends ConsumerState<EditActivitySheet> {
  late final _title = TextEditingController(text: widget.activity.title);
  late final _desc =
      TextEditingController(text: widget.activity.description ?? '');
  late SportType _sport = sportFromName(widget.activity.sportType);
  late String? _gearId = widget.activity.gearId;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final db = ref.read(databaseProvider);
    final id = widget.activity.id;
    try {
      await (db.update(db.activities)..where((t) => t.id.equals(id)))
          .write(ActivitiesCompanion(
        title: Value(_title.text.trim().isEmpty
            ? widget.activity.title
            : _title.text.trim()),
        description:
            Value(_desc.text.trim().isEmpty ? null : _desc.text.trim()),
        sportType: Value(_sport.name),
        gearId: Value(_gearId),
        updatedAt: Value(DateTime.now()),
      ));
      final fin = ActivityFinalizer(db);
      await fin.finalize(id);
      final oldGear = widget.activity.gearId;
      if (oldGear != null && oldGear != _gearId) {
        await fin.syncGearDistance(oldGear);
      }
      ref.invalidate(activityBundleProvider(id));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) DataActions.toast(context, 'Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gears = ref.watch(allGearsProvider).valueOrNull ?? const [];
    final usable = gears
        .where((g) =>
            !g.isRetired &&
            (gearIsShoe(g.gearType) != _sport.isCycling) ||
            g.id == _gearId)
        .toList();
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('UBAH CATATAN',
                style: FN.label(size: 11, color: FN.signal)
                    .copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'JUDUL'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _desc,
              minLines: 2,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'CATATAN'),
            ),
            const SizedBox(height: 18),
            Text('OLAHRAGA', style: FN.label(size: 10)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final s in SportType.values)
                StampChip(
                  text: s.label,
                  icon: s.icon,
                  selected: _sport == s,
                  onTap: () => setState(() => _sport = s),
                ),
            ]),
            const SizedBox(height: 18),
            Text('PERLENGKAPAN', style: FN.label(size: 10)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              StampChip(
                text: 'TANPA',
                selected: _gearId == null,
                onTap: () => setState(() => _gearId = null),
              ),
              for (final g in usable)
                StampChip(
                  text: g.name,
                  selected: _gearId == g.id,
                  onTap: () => setState(() => _gearId = g.id),
                ),
            ]),
            const SizedBox(height: 24),
            InkButton(
              label: 'Simpan & hitung ulang',
              icon: Icons.check,
              style: InkButtonStyle.primary,
              expand: true,
              busy: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
