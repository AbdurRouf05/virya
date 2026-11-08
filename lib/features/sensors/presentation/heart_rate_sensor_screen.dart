import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/sensors/heart_rate_manager.dart';
import 'package:virya/core/sensors/heart_rate_state.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/sensors/presentation/widgets/hr_issue_note.dart';
import 'package:virya/features/sensors/presentation/widgets/hr_scan_list.dart';
import 'package:virya/features/sensors/presentation/widgets/hr_sensor_card.dart';

/// Pair, watch and forget the heart-rate sensor (from Pengaturan).
/// Scanning only starts on request; the saved sensor connects while open.
class HeartRateSensorScreen extends ConsumerStatefulWidget {
  const HeartRateSensorScreen({super.key});

  @override
  ConsumerState<HeartRateSensorScreen> createState() =>
      _HeartRateSensorScreenState();
}

class _HeartRateSensorScreenState extends ConsumerState<HeartRateSensorScreen> {
  late final HeartRateManager _manager;

  @override
  void initState() {
    super.initState();
    _manager = ref.read(heartRateManagerProvider.notifier);
    unawaited(_manager.acquire());
  }

  @override
  void dispose() {
    final manager = _manager;
    // Providers must not change while the widget tree is finalizing.
    scheduleMicrotask(() {
      unawaited(manager.stopScan());
      manager.release();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(heartRateManagerProvider);
    final sec = SectionCounter();
    return Scaffold(
      body: PaperBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 48),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ],
              ),
              const Masthead(
                kicker: 'Sensor',
                title: 'Detak jantung',
                subtitle: 'Sensor Bluetooth, tersambung saat merekam',
              ),
              if (s.issue != HrIssue.none)
                _pad(
                  HrIssueNote(
                    issue: s.issue,
                    onOpenSettings: _manager.openPermissionSettings,
                  ),
                ),
              if (s.sensor != null) ...[
                SectionHeader(number: sec.next(), title: 'Sensor tersimpan'),
                _pad(HrSensorCard(state: s, onForget: _manager.forget)),
              ],
              SectionHeader(number: sec.next(), title: 'Cari sensor'),
              _pad(
                HrScanList(
                  state: s,
                  onScan: _manager.scan,
                  onPick: _manager.connectTo,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _pad(Widget child) =>
      Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: child);
}
