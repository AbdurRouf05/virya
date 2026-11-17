import 'package:flutter/material.dart';
import 'package:virya/core/sensors/ble_gateway.dart';
import 'package:virya/core/sensors/heart_rate_state.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Sensor name for display; some sensors advertise none.
String hrSensorLabel(String name) =>
    name.trim().isEmpty ? 'Sensor tanpa nama' : name;

/// Scan button and the sensors found so far, strongest signal first.
class HrScanList extends StatelessWidget {
  final HeartRateState state;
  final VoidCallback onScan;
  final ValueChanged<BleFoundDevice> onPick;

  const HrScanList({
    super.key,
    required this.state,
    required this.onScan,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkButton(
          label: state.scanning ? 'Mencari sensor' : 'Cari sensor',
          icon: Icons.bluetooth_searching,
          style: InkButtonStyle.primary,
          expand: true,
          busy: state.scanning,
          onPressed: state.scanning ? null : onScan,
        ),
        const SizedBox(height: 10),
        if (state.found.isEmpty)
          Text(
            'Pakai sensornya dulu supaya menyala, lalu tekan cari.',
            style: FN.label(size: 9.5),
          ),
        for (final device in state.found)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkBox(
              padding: const EdgeInsets.all(12),
              onTap: () => onPick(device),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      hrSensorLabel(device.name),
                      style: FN.label(size: 12, color: FN.ink),
                    ),
                  ),
                  Text('${device.rssi} dBm', style: FN.label(size: 9.5)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
