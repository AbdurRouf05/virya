import 'package:flutter/material.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Buka lembar "MAU NGAPAIN?" dari tombol tengah.
Future<void> showStartSheet(
  BuildContext context, {
  required VoidCallback onRecordGps,
  VoidCallback? onStartGym,
  VoidCallback? onNewTask,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: FN.paper,
    shape: const RoundedRectangleBorder(),
    isScrollControlled: true,
    builder: (sheet) => StartSheet(
      onRecordGps: () {
        Navigator.of(sheet).pop();
        onRecordGps();
      },
      onStartGym: onStartGym == null
          ? null
          : () {
              Navigator.of(sheet).pop();
              onStartGym();
            },
      onNewTask: onNewTask == null
          ? null
          : () {
              Navigator.of(sheet).pop();
              onNewTask();
            },
    ),
  );
}

/// Lembar mulai cepat: 2×2 pilihan. Pilihan tanpa callback ditandai "SEGERA"
/// sampai modulnya ada.
class StartSheet extends StatelessWidget {
  final VoidCallback onRecordGps;
  final VoidCallback? onStartGym;
  final VoidCallback? onNewTask;
  const StartSheet({
    super.key,
    required this.onRecordGps,
    this.onStartGym,
    this.onNewTask,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final stamp = '${Fmt.daysShort[now.weekday - 1]} · ${Fmt.time(now)}';
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Container(width: 44, height: 4, color: FN.ink)),
            const SizedBox(height: 18),
            Text('MULAI CEPAT', style: FN.label(size: 11, color: FN.inkSoft)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    'MAU NGAPAIN?',
                    style: TextStyle(
                      fontFamily: FN.display,
                      fontSize: 40,
                      height: 1.05,
                      color: FN.ink,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(stamp, style: FN.label(size: 11)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _row(
              _StartTile(
                icon: Icons.gps_fixed,
                title: 'REKAM GPS',
                subtitle: 'SEPEDA · LARI · JALAN',
                highlight: true,
                onTap: onRecordGps,
              ),
              _StartTile(
                icon: Icons.fitness_center,
                title: 'MULAI GYM',
                subtitle: 'SESI KEKUATAN',
                onTap: onStartGym,
              ),
            ),
            const SizedBox(height: 12),
            _row(
              _StartTile(
                icon: Icons.add_task,
                title: 'TUGAS BARU',
                subtitle: 'CATAT CEPAT',
                onTap: onNewTask,
              ),
              const _StartTile(
                icon: Icons.photo_camera_outlined,
                title: 'FOTO TUBUH',
                subtitle: 'CHECK-IN MINGGUAN',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(Widget a, Widget b) => SizedBox(
    height: 132,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: a),
        const SizedBox(width: 12),
        Expanded(child: b),
      ],
    ),
  );
}

class _StartTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool highlight;

  /// `null` = belum tersedia (tampil redup dengan teks "SEGERA").
  final VoidCallback? onTap;

  const _StartTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.highlight = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final fg = enabled ? FN.ink : FN.inkMuted;
    return Semantics(
      button: true,
      enabled: enabled,
      label: enabled ? title : '$title, segera hadir',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          decoration: BoxDecoration(
            color: highlight ? FN.signal : FN.paper,
            border: Border.all(color: enabled ? FN.ink : FN.inkMuted, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 30, color: fg),
                  const Spacer(),
                  if (!enabled)
                    Text(
                      'SEGERA',
                      style: FN
                          .label(size: 10, color: FN.inkMuted)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                ],
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: FN.display,
                    fontSize: 30,
                    height: 1.0,
                    color: fg,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FN.label(size: 9.5, color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
