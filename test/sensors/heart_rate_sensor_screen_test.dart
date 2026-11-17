import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/sensors/ble_gateway.dart';
import 'package:virya/core/sensors/heart_rate_manager.dart';
import 'package:virya/core/sensors/heart_rate_state.dart';
import 'package:virya/core/sensors/hr_sensor_store.dart';
import 'package:virya/features/sensors/presentation/heart_rate_sensor_screen.dart';

import 'fake_ble.dart';

void main() {
  late FakeGateway gateway;

  Future<HeartRateManager> pump(
    WidgetTester tester, {
    HrSensorRef? saved,
  }) async {
    gateway = FakeGateway();
    final manager = HeartRateManager(gateway: gateway, store: FakeStore(saved));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [heartRateManagerProvider.overrideWith((_) => manager)],
        child: const MaterialApp(home: HeartRateSensorScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();
    return manager;
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  }

  testWidgets('empty state offers a scan and connects nothing', (tester) async {
    await pump(tester);
    expect(find.text('Sensor tersimpan'.toUpperCase()), findsNothing);
    expect(find.byIcon(Icons.bluetooth_searching), findsOneWidget);
    expect(gateway.calls, 0);
    await close(tester);
  });

  testWidgets('saved sensor shows live bpm and can be forgotten', (tester) async {
    await pump(tester, saved: const HrSensorRef(id: 'AA', name: 'Tali dada'));
    expect(find.text('Tali dada'), findsOneWidget);
    expect(find.text('Tersambung'), findsOneWidget);
    gateway.lastLink.emit([0x00, 137]);
    await tester.pump();
    await tester.pump();
    expect(find.text('137'), findsOneWidget);

    await tester.ensureVisible(find.byIcon(Icons.link_off));
    await tester.tap(find.byIcon(Icons.link_off));
    await tester.pump();
    await tester.pump();
    expect(find.text('Tali dada'), findsNothing);
    await close(tester);
  });

  testWidgets('scan results can be picked', (tester) async {
    final manager = await pump(tester);
    gateway.scanResults = const [
      BleFoundDevice(id: 'BB', name: '', rssi: -60),
    ];
    await tester.tap(find.byIcon(Icons.bluetooth_searching));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.text('Sensor tanpa nama'), findsOneWidget);
    await tester.tap(find.text('Sensor tanpa nama'));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(gateway.connectIds, ['BB']);
    expect(manager.state.link, HrLink.connected);
    await close(tester);
  });

  testWidgets('blocked permission offers the settings shortcut', (tester) async {
    final manager = await pump(tester);
    gateway.granted = BlePermission.blocked;
    await manager.scan();
    await tester.pump();
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    await close(tester);
  });
}
