import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/features/recording/presentation/widgets/recording_sport_icon.dart';

/// Asks to confirm discarding the current session. Returns true to discard.
Future<bool?> showDiscardRecordingDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: FN.nightSurface,
      shape: const RoundedRectangleBorder(),
      title: Text('BUANG AKTIVITAS?', style: FN.label(size: 14, color: FN.paper)),
      content: Text(
        'Seluruh rute, data, dan foto sesi ini akan dihapus permanen.',
        style: TextStyle(fontFamily: FN.sans, color: FN.paper),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text('BATAL', style: FN.label(color: FN.paperLine)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text('BUANG', style: FN.label(color: FN.warn)),
        ),
      ],
    ),
  );
}

/// Bottom sheet listing sports grouped by category (Cycling, Running & Walking).
Future<SportType?> showRecordingSportPicker(
  BuildContext context,
  SportType current,
) {
  const groups = [
    (
      'OLAHRAGA SEPEDA',
      [
        (
          SportType.gravelCycling,
          'Sepeda Gravel (Gravel)',
          'Jalur campuran aspal, makadam & kerikil',
        ),
        (
          SportType.roadCycling,
          'Sepeda Balap (Roadbike)',
          'Jalur aspal halus kecepatan tinggi',
        ),
        (
          SportType.mountainBiking,
          'Sepeda Gunung (MTB)',
          'Jalur hutan, tanah & trek off-road',
        ),
      ],
    ),
    (
      'OLAHRAGA LARI & JALAN',
      [
        (
          SportType.roadRunning,
          'Lari (Road Run)',
          'Lari jalan raya / trotoar perkotaan',
        ),
        (
          SportType.trailRunning,
          'Lari Trail (Trail Run)',
          'Lari lintas alam, elevasi & alam terbuka',
        ),
        (
          SportType.hiking,
          'Mendaki (Hiking)',
          'Pendakian gunung, bukit & jalan menanjak',
        ),
        (
          SportType.walking,
          'Jalan Kaki (Walking)',
          'Jalan santai, pemulihan harian & mobilitas',
        ),
      ],
    ),
  ];

  return showModalBottomSheet<SportType>(
    context: context,
    backgroundColor: FN.nightSurface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(),
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: FN.nightLine,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 14),
                child: Text(
                  'PILIH JENIS OLAHRAGA',
                  style: FN.label(size: 13, color: FN.signal).copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              for (final (groupTitle, items) in groups) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        color: FN.acid,
                        margin: const EdgeInsets.only(right: 8),
                      ),
                      Text(
                        groupTitle,
                        style: FN.label(size: 11, color: FN.paperLine).copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                for (final (sport, name, desc) in items)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: sport == current ? FN.night : Colors.transparent,
                      border: Border.all(
                        color: sport == current
                            ? FN.acid
                            : FN.nightLine.withValues(alpha: 0.7),
                        width: sport == current ? 1.5 : 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: sport == current
                              ? FN.acid.withValues(alpha: 0.15)
                              : FN.night,
                          border: Border.all(
                            color: sport == current ? FN.acid : FN.nightLine,
                          ),
                        ),
                        child: Icon(
                          sportIcon(sport),
                          color: sport == current ? FN.acid : FN.paper,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          fontFamily: FN.sans,
                          fontSize: 15,
                          fontWeight: sport == current
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: sport == current ? FN.acid : FN.paper,
                        ),
                      ),
                      subtitle: Text(
                        desc,
                        style: TextStyle(
                          fontFamily: FN.sans,
                          fontSize: 11.5,
                          color: FN.paperLine,
                        ),
                      ),
                      trailing: sport == current
                          ? Icon(Icons.check, color: FN.acid, size: 20)
                          : null,
                      onTap: () => Navigator.pop(ctx, sport),
                    ),
                  ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
