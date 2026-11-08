import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/tasks/data/task_bridge.dart';

/// Pengaturan catat cepat di luar aplikasi (khusus Android).
class TaskOutsideSection extends ConsumerStatefulWidget {
  const TaskOutsideSection({super.key});

  @override
  ConsumerState<TaskOutsideSection> createState() => _State();
}

class _State extends ConsumerState<TaskOutsideSection> {
  bool _quickOn = false;
  bool _canPin = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) _load();
  }

  Future<void> _load() async {
    final bridge = ref.read(taskBridgeProvider);
    final quickOn = await bridge.isQuickCaptureOn();
    final canPin = await bridge.canPinWidget();
    if (!mounted) return;
    setState(() {
      _quickOn = quickOn;
      _canPin = canPin;
    });
  }

  Future<void> _setQuick(bool on) async {
    if (on && !(await Permission.notification.request()).isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Izin notifikasi belum diberikan')),
        );
      return;
    }
    await ref.read(taskBridgeProvider).setQuickCapture(on);
    if (mounted) setState(() => _quickOn = on);
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) return const SizedBox.shrink();
    final hint = TextStyle(
      fontFamily: FN.sans,
      fontSize: 13,
      color: FN.inkMuted,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Di luar aplikasi'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'CATAT CEPAT DI NOTIFIKASI',
                      style: FN.label(size: 12, color: FN.ink),
                    ),
                  ),
                  InkToggle(value: _quickOn, onChanged: _setQuick),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Bisa juga lewat ubin "Catat tugas" di Quick Settings, atau '
                'tekan lama ikon Virya.',
                style: hint,
              ),
              if (_canPin) ...[
                const SizedBox(height: 14),
                InkButton(
                  label: 'Pasang widget',
                  icon: Icons.widgets_outlined,
                  expand: true,
                  onPressed: () =>
                      ref.read(taskBridgeProvider).requestPinWidget(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
