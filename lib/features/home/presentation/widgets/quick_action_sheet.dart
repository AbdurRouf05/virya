import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/today/data/today_providers.dart';

void showQuickActionSheet(BuildContext context, {required VoidCallback onRecordGps}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _QuickActionSheet(onRecordGps: onRecordGps),
  );
}

class _QuickActionSheet extends ConsumerStatefulWidget {
  final VoidCallback onRecordGps;
  const _QuickActionSheet({required this.onRecordGps});

  @override
  ConsumerState<_QuickActionSheet> createState() => _QuickActionSheetState();
}

class _QuickActionSheetState extends ConsumerState<_QuickActionSheet> {
  final _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _showTaskDialog() {
    Navigator.of(context).pop();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: FN.paper,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text('CATAT TUGAS BARU', style: FN.heading(size: 15, color: FN.ink)),
        content: TextField(
          controller: _taskController,
          autofocus: true,
          style: FN.body(size: 13, color: FN.ink),
          decoration: InputDecoration(
            hintText: 'Tulis tugas atau prioritas hari ini...',
            hintStyle: FN.body(size: 13, color: FN.inkMuted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: FN.ink, width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('BATAL', style: FN.label(size: 12, color: FN.inkMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: FN.ink,
              foregroundColor: FN.paper,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            onPressed: () {
              final text = _taskController.text.trim();
              if (text.isNotEmpty) {
                ref.read(todayTasksProvider.notifier).addTask(text);
              }
              Navigator.of(ctx).pop();
            },
            child: Text('SIMPAN', style: FN.label(size: 12, color: FN.paper)),
          ),
        ],
      ),
    );
  }

  void _showPlaceholder(String title, String desc) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: FN.ink,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        content: Text('$title: $desc', style: FN.monoStyle(size: 12, color: FN.paper)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FN.paper,
        border: Border(top: BorderSide(color: FN.ink, width: 2.5)),
      ),
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.paddingOf(context).bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('AKSI CEPAT // VIRYA', style: FN.label(size: 11, color: FN.signal).copyWith(fontWeight: FontWeight.w700)),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                color: FN.ink,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ActionTile(
            icon: Icons.fiber_manual_record,
            iconColor: FN.signal,
            title: 'REKAM GPS OUTDOOR',
            subtitle: 'Gravel, Road, MTB, Lari, Trail, Mendaki dengan telemetri 1 Hz',
            onTap: () {
              Navigator.of(context).pop();
              widget.onRecordGps();
            },
          ),
          const SizedBox(height: 8),
          _ActionTile(
            icon: Icons.fitness_center,
            iconColor: FN.ink,
            title: 'MULAI SESI GYM',
            subtitle: 'Catat set, repetisi kg, RPE & timer istirahat (Fase 4)',
            onTap: () => _showPlaceholder('GYM', 'Pencatatan sesi latihan beban siap di Fase 4.'),
          ),
          const SizedBox(height: 8),
          _ActionTile(
            icon: Icons.check_box_outlined,
            iconColor: FN.ink,
            title: 'CATAT TUGAS BARU',
            subtitle: 'Tulis hal yang harus diselesaikan untuk hari ini',
            onTap: _showTaskDialog,
          ),
          const SizedBox(height: 8),
          _ActionTile(
            icon: Icons.camera_alt_outlined,
            iconColor: FN.ink,
            title: 'CHECK-IN PROGRES TUBUH',
            subtitle: 'Foto mingguan dengan panduan siluet & timbang berat (Fase 7)',
            onTap: () => _showPlaceholder('PROGRES TUBUH', 'Check-in foto & berat siap di Fase 7.'),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: FN.paper,
          border: Border.all(color: FN.ink, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: FN.paper,
                border: Border.all(color: FN.ink, width: 1.2),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: FN.heading(size: 13, color: FN.ink)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: FN.body(size: 11, color: FN.inkMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: FN.inkMuted),
          ],
        ),
      ),
    );
  }
}

