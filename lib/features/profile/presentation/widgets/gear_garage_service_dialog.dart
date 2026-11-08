import 'package:flutter/material.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Asks for a service interval in km. Returns 0 to switch the reminder off,
/// null when dismissed or the input is not a number.
Future<double?> showServiceIntervalDialog(
  BuildContext context,
  double initialKm,
) async {
  final ctrl = TextEditingController(text: initialKm.toStringAsFixed(0));
  final km = await showDialog<double>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('PENGINGAT SERVIS'),
      content: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'INTERVAL (KM)',
          suffixText: 'km',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, 0.0),
          child: const Text('MATIKAN'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(c, double.tryParse(ctrl.text)),
          style: TextButton.styleFrom(foregroundColor: FN.signal),
          child: const Text('SIMPAN'),
        ),
      ],
    ),
  );
  ctrl.dispose();
  return km;
}
