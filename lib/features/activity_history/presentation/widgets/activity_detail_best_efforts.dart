import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/core/analytics/analysis_models.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/activity_history/presentation/widgets/activity_detail_table_styles.dart';

/// Best efforts ledger.
class BestEffortsTable extends StatelessWidget {
  final List<BestEffort> efforts;
  final SportType sport;
  final Fmt fmt;
  const BestEffortsTable({
    super.key,
    required this.efforts,
    required this.sport,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < efforts.length; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                SizedBox(
                  width: 72,
                  child: Text(
                    efforts[i].label.toUpperCase(),
                    style: detailTd(bold: true),
                  ),
                ),
                Expanded(
                  child: Text(
                    Fmt.duration(efforts[i].timeS),
                    style: FN.bigNumber(22),
                  ),
                ),
                Builder(
                  builder: (_) {
                    final e = efforts[i];
                    final mps = e.timeS == 0 ? 0.0 : e.distanceM / e.timeS;
                    final (v, u) = fmt.speedOrPace(mps, sport);
                    return Text('$v ${u.toLowerCase()}', style: detailTd());
                  },
                ),
              ],
            ),
          ),
          if (i < efforts.length - 1)
            InkRule(dashed: true, color: FN.paperLine),
        ],
      ],
    );
  }
}
