import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/today/data/today_providers.dart';

class FormConditionCard extends StatelessWidget {
  final double? tsb;
  const FormConditionCard({super.key, this.tsb});

  @override
  Widget build(BuildContext context) {
    String label;
    String desc;
    Color accent;

    if (tsb == null) {
      label = 'NETRAL';
      desc = 'Belum cukup sesi terekam untuk membaca kelelahan & kebugaran.';
      accent = FN.inkMuted;
    } else if (tsb! > 15) {
      label = 'SEGAR';
      desc = 'Kelelahan rendah, tubuh siap untuk intensitas tinggi atau tes performa.';
      accent = const Color(0xFF00C853);
    } else if (tsb! >= -10) {
      label = 'OPTIMAL';
      desc = 'Keseimbangan prima antara beban latihan dan adaptasi kebugaran.';
      accent = FN.signal;
    } else if (tsb! >= -30) {
      label = 'PRODUKTIF';
      desc = 'Akumulasi beban tinggi; fase membangun stamina.';
      accent = const Color(0xFFFFA000);
    } else {
      label = 'LELAH';
      desc = 'Beban sangat tinggi; pertimbangkan istirahat aktif atau tidur ekstra.';
      accent = const Color(0xFFD32F2F);
    }

    return InkBox(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(width: 5, height: 48, color: accent),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(label, style: FN.heading(size: 15, color: FN.ink)),
                      const Spacer(),
                      StampChip(text: tsb == null ? 'TSB –' : 'TSB ${tsb!.round()}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(desc, style: FN.body(size: 12, color: FN.inkSoft)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TodayActivitiesCard extends StatelessWidget {
  final List<dynamic> acts;
  final Fmt fmt;
  const TodayActivitiesCard({super.key, required this.acts, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final dist = acts.fold<double>(0, (s, a) => s + (a.totalDistanceMeters as double));
    final time = acts.fold<int>(0, (s, a) => s + (a.movingTimeSeconds as int));
    final ele = acts.fold<double>(0, (s, a) => s + (a.elevationGainMeters as double));

    return InkBox(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, size: 18, color: FN.signal),
                const SizedBox(width: 8),
                Text('SELESAI DILAKUKAN',
                    style: FN.label(size: 11, color: FN.signal).copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StatBlock(label: 'Jarak', value: fmt.distance(dist, decimals: 1), unit: fmt.distUnit, size: 28),
                StatBlock(label: 'Waktu', value: Fmt.durationShort(time), size: 24),
                StatBlock(label: 'Tanjakan', value: fmt.elevation(ele), unit: fmt.eleUnit, size: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NoActivityCard extends StatelessWidget {
  final VoidCallback onRecord;
  const NoActivityCard({super.key, required this.onRecord});

  @override
  Widget build(BuildContext context) {
    return InkBox(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Belum ada sesi olahraga hari ini', style: FN.heading(size: 15, color: FN.ink)),
            const SizedBox(height: 4),
            Text('Catat aktivitas untuk menjaga momentum konsistensi Anda.',
                textAlign: TextAlign.center, style: FN.body(size: 12, color: FN.inkMuted)),
            const SizedBox(height: 12),
            InkButton(label: 'MULAI REKAM SEKARANG', style: InkButtonStyle.primary, onPressed: onRecord),
          ],
        ),
      ),
    );
  }
}

class WeekStripCard extends StatelessWidget {
  final List<DayStatus> days;
  final Fmt fmt;
  const WeekStripCard({super.key, required this.days, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return InkBox(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final d in days)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: d.hasActivity ? FN.ink : (d.isToday ? FN.paperDeep : Colors.transparent),
                    border: Border.all(
                      color: d.isToday ? FN.signal : (d.hasActivity ? FN.ink : FN.paperLine),
                      width: d.isToday ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        d.dayName,
                        style: FN.label(size: 9, color: d.hasActivity ? FN.paper : (d.isToday ? FN.signal : FN.inkMuted))
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        d.hasActivity ? Icons.check : (d.isToday ? Icons.radio_button_unchecked : Icons.remove),
                        size: 14,
                        color: d.hasActivity ? FN.signal : (d.isToday ? FN.signal : FN.paperLine),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        d.hasActivity ? fmt.distance(d.distanceM, decimals: 0) : '–',
                        style: FN.monoStyle(size: 8.5, color: d.hasActivity ? FN.paper : FN.inkMuted),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AppLimitBar extends StatelessWidget {
  final String name;
  final int usedMinutes;
  final int maxMinutes;
  const AppLimitBar({super.key, required this.name, required this.usedMinutes, required this.maxMinutes});

  @override
  Widget build(BuildContext context) {
    final frac = (usedMinutes / maxMinutes).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: FN.body(size: 12, color: FN.ink)),
            Text('$usedMinutes / $maxMinutes mnt', style: FN.monoStyle(size: 10, color: FN.inkMuted)),
          ],
        ),
        const SizedBox(height: 3),
        LinearProgressIndicator(
          value: frac,
          backgroundColor: FN.paperLine,
          valueColor: AlwaysStoppedAnimation(frac > 0.8 ? const Color(0xFFD32F2F) : FN.signal),
          minHeight: 4,
        ),
      ],
    );
  }
}

