import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/tasks/domain/task_logic.dart';

/// Jam pengingat rutinitas. Setelah jam itu, pengingat diulang tiap jam
/// sampai rutinitas dicentang (paling lambat pukul 22.00).
class TaskRemindRow extends StatelessWidget {
  final int? minute;
  final ValueChanged<int?> onChanged;

  const TaskRemindRow({
    super.key,
    required this.minute,
    required this.onChanged,
  });

  Future<void> _pick(BuildContext context) async {
    final m = minute ?? 8 * 60;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: m ~/ 60, minute: m % 60),
      helpText: FN.caps('Jam pengingat'),
    );
    if (picked == null) return;
    if (Platform.isAndroid) await Permission.notification.request();
    onChanged(picked.hour * 60 + picked.minute);
  }

  @override
  Widget build(BuildContext context) {
    final m = minute;
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: InkButton(
                  label: m == null
                      ? 'Atur jam pengingat'
                      : 'Ingatkan ${formatRemindMinute(m)}',
                  icon: Icons.alarm,
                  height: 40,
                  onPressed: () => _pick(context),
                ),
              ),
              if (m != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Tanpa pengingat',
                  onPressed: () => onChanged(null),
                  icon: Icon(Icons.close, color: FN.ink),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            m == null
                ? 'Tanpa jam, rutinitas tetap muncul di Hari Ini, widget, '
                      'dan penghalang aplikasi di layar Fokus.'
                : 'Notifikasi muncul pukul ${formatRemindMinute(m)}, lalu '
                      'diulang tiap jam sampai dicentang (paling lambat '
                      'pukul 22.00).',
            style: TextStyle(
              fontFamily: FN.sans,
              fontSize: 12,
              color: FN.inkMuted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
