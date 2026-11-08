import 'package:flutter/material.dart';
import 'package:virya/core/sensors/heart_rate_state.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/sensors/presentation/widgets/hr_scan_list.dart';

/// The saved sensor: name, link status, live pulse and forget action.
class HrSensorCard extends StatelessWidget {
  final HeartRateState state;
  final VoidCallback onForget;

  const HrSensorCard({super.key, required this.state, required this.onForget});

  String get _status {
    if (state.contactLost) return 'Sensor tidak menempel di kulit';
    return switch (state.link) {
      HrLink.none => 'Tidak tersambung',
      HrLink.connecting => 'Menyambung',
      HrLink.connected => 'Tersambung',
      HrLink.reconnecting => 'Sambungan putus, mencoba lagi',
    };
  }

  @override
  Widget build(BuildContext context) {
    final bpm = state.bpm;
    final live = state.link == HrLink.connected && !state.contactLost;
    return InkBox(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            hrSensorLabel(state.sensor?.name ?? ''),
            style: FN.label(size: 12, color: FN.ink),
          ),
          const SizedBox(height: 4),
          Text(
            _status,
            style: FN.label(size: 10, color: live ? FN.signal : FN.warn),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(bpm == null ? '--' : '$bpm', style: FN.bigNumber(44)),
              const SizedBox(width: 6),
              Text('BPM', style: FN.label(size: 11)),
            ],
          ),
          const SizedBox(height: 12),
          InkButton(
            label: 'Lupakan sensor',
            icon: Icons.link_off,
            style: InkButtonStyle.danger,
            expand: true,
            onPressed: onForget,
          ),
        ],
      ),
    );
  }
}
