import 'package:flutter/material.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/gym/domain/gym_models.dart';

/// Status kelompok otot: hari sejak terakhir dilatih. >14 hari = peringatan,
/// >7 hari = waspada.
class GymMuscleStatus extends StatelessWidget {
  final Map<MuscleGroup, DateTime?> lastTrained;
  final DateTime now;
  const GymMuscleStatus({
    super.key,
    required this.lastTrained,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [for (final m in MuscleGroup.tracked) _cell(m, lastTrained[m])],
    );
  }

  Widget _cell(MuscleGroup m, DateTime? last) {
    final days = last == null ? null : now.difference(last).inDays;
    final Color c = days == null || days > 14
        ? FN.warn
        : days > 7
        ? FN.caution
        : FN.ok;
    final text = days == null
        ? 'BELUM'
        : days == 0
        ? 'HARI INI'
        : '$days HARI';
    return Container(
      width: 104,
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        color: FN.paper,
        border: Border(
          left: BorderSide(color: c, width: 4),
          top: BorderSide(color: FN.ink),
          right: BorderSide(color: FN.ink),
          bottom: BorderSide(color: FN.ink),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            m.label,
            style: FN
                .label(size: 10, color: FN.ink)
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(text, style: FN.label(size: 9, color: c)),
        ],
      ),
    );
  }
}
