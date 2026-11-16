import 'package:flutter/material.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/gym/domain/gym_math.dart';
import 'package:virya/features/gym/domain/session_draft.dart';
import 'package:virya/features/gym/presentation/widgets/gym_set_row.dart';

/// Callback per set: (indeks set).
typedef SetAction = void Function(int set);

/// Kartu satu gerakan: judul, info otot/alat/PR, tabel set, tombol + SET.
class GymExerciseCard extends StatefulWidget {
  final DraftExercise exercise;
  final ExercisePr? pr;
  final void Function(int set, DraftSet Function(DraftSet) f) onUpdate;
  final SetAction onToggleDone;
  final SetAction onRemoveSet;
  final VoidCallback onAddSet;
  final VoidCallback onRemove;
  final VoidCallback onHistory;

  const GymExerciseCard({
    super.key,
    required this.exercise,
    required this.pr,
    required this.onUpdate,
    required this.onToggleDone,
    required this.onRemoveSet,
    required this.onAddSet,
    required this.onRemove,
    required this.onHistory,
  });

  @override
  State<GymExerciseCard> createState() => _GymExerciseCardState();
}

class _GymExerciseCardState extends State<GymExerciseCard> {
  late bool _rpe = widget.exercise.sets.any((s) => s.rpe != null);

  @override
  Widget build(BuildContext context) {
    final e = widget.exercise;
    return Container(
      decoration: BoxDecoration(border: FN.frame(color: FN.ink, width: 2), borderRadius: FN.boxRadius,),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(e),
          Container(height: 2, color: FN.ink),
          _tableHeader(),
          for (final (i, s) in e.sets.indexed)
            GymSetRow(
              key: ValueKey(s.id),
              set: s,
              index: i,
              previous: e.previousAt(i),
              showRpe: _rpe,
              onWeight: (v) =>
                  widget.onUpdate(i, (d) => d.copyWith(weightKg: () => v)),
              onReps: (v) =>
                  widget.onUpdate(i, (d) => d.copyWith(reps: () => v)),
              onRpe: (v) => widget.onUpdate(i, (d) => d.copyWith(rpe: () => v)),
              onToggleDone: () => widget.onToggleDone(i),
              onToggleWarmup: () =>
                  widget.onUpdate(i, (d) => d.copyWith(isWarmup: !d.isWarmup)),
              onRemove: () => widget.onRemoveSet(i),
            ),
          InkWell(
            onTap: widget.onAddSet,
            child: Container(
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(top: FN.side(color: FN.paperLine)),
              ),
              child: Text(
                FN.caps('+ Set'),
                style: FN
                    .label(size: 11, color: FN.ink)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(DraftExercise e) {
    final pr = widget.pr;
    final info = [
      e.exercise.muscle.label,
      e.exercise.equipment.label,
      if (pr != null) FN.caps('PR ${fmtKg(pr.maxWeightKg)} kg'),
    ].join(' · ');
    final allDone = e.sets.isNotEmpty && e.doneCount == e.sets.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.exercise.name,
                  style: TextStyle(
                    fontFamily: FN.sans,
                    fontWeight: FontWeight.w700,
                    fontSize: 19,
                    color: FN.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(info, style: FN.label(size: 9.5, color: FN.inkSoft)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: allDone ? FN.ink : null,
              border: FN.frame(color: FN.ink, width: 1.5), borderRadius: FN.boxRadius,),
            child: Text(
              FN.caps('${e.doneCount}/${e.sets.length} set'),
              style: FN
                  .label(size: 10, color: allDone ? FN.paper : FN.ink)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: FN.ink),
            shape: RoundedRectangleBorder(borderRadius: FN.smallRadius),
            onSelected: (v) => switch (v) {
              'rpe' => setState(() => _rpe = !_rpe),
              'hist' => widget.onHistory(),
              _ => widget.onRemove(),
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'rpe',
                child: Text(_rpe ? 'Sembunyikan RPE' : 'Tampilkan RPE'),
              ),
              const PopupMenuItem(value: 'hist', child: Text('Riwayat & PR')),
              const PopupMenuItem(value: 'del', child: Text('Hapus gerakan')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    final st = FN
        .label(size: 9.5, color: FN.ink)
        .copyWith(fontWeight: FontWeight.w700);
    Widget cell(String t, double w) => SizedBox(
      width: w,
      child: Text(t, textAlign: TextAlign.center, style: st),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
      child: Row(
        children: [
          SizedBox(
            width: GymSetColumns.set,
            child: Text(FN.caps('Set'), style: st),
          ),
          Expanded(child: Text(FN.caps('Sebelumnya'), style: st)),
          cell('KG', GymSetColumns.field),
          const SizedBox(width: 6),
          cell(FN.caps('Reps'), GymSetColumns.field),
          if (_rpe) ...[
            const SizedBox(width: 6),
            cell('RPE', GymSetColumns.rpe),
          ],
          const SizedBox(width: 8),
          SizedBox(
            width: GymSetColumns.check,
            child: Icon(Icons.check, size: 16, color: FN.ink),
          ),
        ],
      ),
    );
  }
}
