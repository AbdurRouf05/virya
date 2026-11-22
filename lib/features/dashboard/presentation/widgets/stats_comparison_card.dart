import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/dashboard/domain/stats_math.dart';

/// Kartu perbandingan performa bulan ini terhadap bulan lalu.
class StatsComparisonCard extends StatelessWidget {
  final List<Activity> activities;
  final Fmt fmt;
  final DateTime now;

  const StatsComparisonCard({
    super.key,
    required this.activities,
    required this.fmt,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = thisMonthStart.subtract(const Duration(milliseconds: 1));

    final thisMonth = activities
        .where((a) => !a.startTime.isBefore(thisMonthStart))
        .fold(Totals.zero, (s, a) => s.add(a));

    final lastMonth = activities
        .where((a) =>
            !a.startTime.isBefore(lastMonthStart) &&
            !a.startTime.isAfter(lastMonthEnd))
        .fold(Totals.zero, (s, a) => s.add(a));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: FN.cardFill,
          border: FN.frame(width: 1.5),
          borderRadius: FN.boxRadius,
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.compare_arrows_outlined, size: 18, color: FN.ink),
                const SizedBox(width: 8),
                Text(
                  FN.caps('BULAN INI VS BULAN LALU'),
                  style: FN
                      .label(size: 11, color: FN.ink)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Jarak',
                    thisVal: fmt.distance(thisMonth.distanceM, decimals: 1),
                    unit: fmt.distUnit,
                    lastVal: fmt.distance(lastMonth.distanceM, decimals: 1),
                    diffPct: _pct(thisMonth.distanceM, lastMonth.distanceM),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricTile(
                    label: 'Waktu',
                    thisVal: Fmt.durationShort(thisMonth.movingS),
                    unit: '',
                    lastVal: Fmt.durationShort(lastMonth.movingS),
                    diffPct: _pct(
                      thisMonth.movingS.toDouble(),
                      lastMonth.movingS.toDouble(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Elevasi',
                    thisVal: fmt.elevation(thisMonth.elevationM),
                    unit: fmt.eleUnit,
                    lastVal: fmt.elevation(lastMonth.elevationM),
                    diffPct: _pct(thisMonth.elevationM, lastMonth.elevationM),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricTile(
                    label: 'Aktivitas',
                    thisVal: '${thisMonth.count}',
                    unit: 'sesi',
                    lastVal: '${lastMonth.count}',
                    diffPct: _pct(
                      thisMonth.count.toDouble(),
                      lastMonth.count.toDouble(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static double? _pct(double curr, double prev) {
    if (prev <= 0) return null;
    return ((curr - prev) / prev) * 100;
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String thisVal;
  final String unit;
  final String lastVal;
  final double? diffPct;

  const _MetricTile({
    required this.label,
    required this.thisVal,
    required this.unit,
    required this.lastVal,
    this.diffPct,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiff = diffPct != null;
    final isPos = (diffPct ?? 0) >= 0;
    final diffColor = isPos ? FN.ok : FN.warn;
    final diffText = hasDiff
        ? '${isPos ? '+' : ''}${diffPct!.round()}%'
        : 'Baru';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: FN.paper.withValues(alpha: 0.6),
        border: FN.frame(width: 1),
        borderRadius: FN.smallRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: FN.label(size: 9.5, color: FN.inkMuted),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: diffColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  diffText,
                  style: TextStyle(
                    fontFamily: FN.mono,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: diffColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                thisVal,
                style: TextStyle(
                  fontFamily: FN.mono,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: FN.ink,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 3),
                Text(
                  unit,
                  style: FN.label(size: 10, color: FN.inkMuted),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Lalu: $lastVal $unit'.trim(),
            style: FN.label(size: 9.5, color: FN.inkSoft),
          ),
        ],
      ),
    );
  }
}
