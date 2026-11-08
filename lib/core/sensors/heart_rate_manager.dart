import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/sensors/ble_gateway.dart';
import 'package:virya/core/sensors/flutter_blue_gateway.dart';
import 'package:virya/core/sensors/heart_rate_parser.dart';
import 'package:virya/core/sensors/heart_rate_state.dart';
import 'package:virya/core/sensors/hr_sensor_store.dart';

/// Connection to the paired heart-rate sensor.
///
/// The link stays up only while someone holds it ([acquire]/[release]): a
/// recording or the pairing screen. Lost connections retry with backoff for
/// as long as it is held. Nothing touches Bluetooth without a paired sensor.
class HeartRateManager extends StateNotifier<HeartRateState> {
  final BleGateway gateway;
  final HrSensorStore store;
  final List<Duration> retryDelays;
  final Duration staleAfter;
  final Duration scanTimeout;

  HeartRateManager({
    required this.gateway,
    required this.store,
    this.retryDelays = const [
      Duration(seconds: 2),
      Duration(seconds: 4),
      Duration(seconds: 8),
      Duration(seconds: 16),
      Duration(seconds: 30),
    ],
    this.staleAfter = const Duration(seconds: 8),
    this.scanTimeout = const Duration(seconds: 15),
  }) : super(const HeartRateState());

  int _holds = 0;
  int _gen = 0; // bumped to invalidate in-flight connection attempts
  int _attempt = 0;
  bool _scanStarting = false;
  HrSensorRef? _sensor;
  BleHeartRateLink? _link;
  StreamSubscription<List<int>>? _valueSub;
  StreamSubscription<bool>? _adapterSub;
  Timer? _retry;
  Timer? _stale;

  Future<void> acquire() async {
    _holds++;
    if (_holds > 1) return;
    final gen = ++_gen;
    HrSensorRef? saved;
    try {
      saved = await store.load();
    } catch (_) {}
    if (!mounted || gen != _gen || _holds == 0 || saved == null) return;
    _sensor = saved;
    state = state.copyWith(sensor: saved);
    _watchAdapter();
    await _connect(retrying: false);
  }

  void release() {
    if (_holds == 0) return;
    _holds--;
    if (_holds > 0) return;
    _tearDown();
    _unwatchAdapter();
    if (mounted) {
      state = state.copyWith(
        link: HrLink.none,
        issue: HrIssue.none,
        clearBpm: true,
      );
    }
  }

  /// Saves [device] as the paired sensor and connects to it.
  Future<void> connectTo(BleFoundDevice device) async {
    await stopScan();
    final sensor = HrSensorRef(id: device.id, name: device.name);
    _sensor = sensor;
    try {
      await store.save(sensor);
    } catch (_) {}
    if (!mounted) return;
    state = state.copyWith(sensor: sensor);
    _watchAdapter();
    await _connect(retrying: false);
  }

  Future<void> forget() async {
    _sensor = null;
    _tearDown();
    _unwatchAdapter();
    if (mounted) {
      state = HeartRateState(found: state.found, scanning: state.scanning);
    }
    try {
      await store.clear();
    } catch (_) {}
  }

  Future<void> scan() async {
    if (state.scanning || _scanStarting) return;
    _scanStarting = true;
    try {
      final issue = await _scanBlocker();
      if (!mounted) return;
      if (issue != null) {
        state = state.copyWith(issue: issue);
        return;
      }
      state = state.copyWith(
        scanning: true,
        found: const [],
        issue: HrIssue.none,
      );
      await gateway.scan(
        timeout: scanTimeout,
        onResults: (results) {
          if (!mounted) return;
          final sorted = [...results]..sort((a, b) => b.rssi - a.rssi);
          state = state.copyWith(found: sorted);
        },
      );
    } catch (_) {
      if (mounted) state = state.copyWith(issue: HrIssue.scanFailed);
    } finally {
      _scanStarting = false;
      if (mounted) state = state.copyWith(scanning: false);
    }
  }

  Future<void> stopScan() async {
    try {
      await gateway.stopScan();
    } catch (_) {}
  }

  Future<void> openPermissionSettings() => gateway.openPermissionSettings();

  Future<HrIssue?> _scanBlocker() async {
    if (!await gateway.isSupported()) return HrIssue.unsupported;
    final blocked = _issueOf(await gateway.requestPermission());
    if (blocked != null) return blocked;
    return await gateway.isAdapterOn() ? null : HrIssue.adapterOff;
  }

  Future<HrIssue?> _connectBlocker() async {
    if (!await gateway.isSupported()) return HrIssue.unsupported;
    final blocked = _issueOf(await gateway.permission());
    if (blocked != null) return blocked;
    return await gateway.isAdapterOn() ? null : HrIssue.adapterOff;
  }

  static HrIssue? _issueOf(BlePermission p) => switch (p) {
    BlePermission.granted => null,
    BlePermission.denied => HrIssue.permissionDenied,
    BlePermission.blocked => HrIssue.permissionBlocked,
  };

  Future<void> _connect({required bool retrying}) async {
    final sensor = _sensor;
    if (sensor == null || _holds == 0 || !mounted) return;
    _tearDown();
    final gen = _gen;
    bool stale() => gen != _gen || !mounted;
    state = state.copyWith(
      link: retrying ? HrLink.reconnecting : HrLink.connecting,
      issue: HrIssue.none,
      clearBpm: true,
    );
    try {
      final blocked = await _connectBlocker();
      if (stale()) return;
      if (blocked != null) {
        state = state.copyWith(link: HrLink.none, issue: blocked);
        return;
      }
      final link = await gateway.connect(sensor.id);
      if (stale()) {
        unawaited(_closeQuietly(link));
        return;
      }
      _link = link;
      _attempt = 0;
      _valueSub = link.values.listen(_onValue, onError: (Object _) {});
      unawaited(
        link.lost.then((_) {
          if (!stale()) _onLost();
        }, onError: (Object _) {}),
      );
      state = state.copyWith(link: HrLink.connected);
    } on BleNoHeartRateService {
      if (!stale()) {
        state = state.copyWith(
          link: HrLink.none,
          issue: HrIssue.notHeartRate,
        );
      }
    } catch (_) {
      if (!stale()) _scheduleRetry();
    }
  }

  void _onValue(List<int> bytes) {
    final reading = parseHeartRateMeasurement(bytes);
    if (reading == null || !mounted) return;
    _stale?.cancel();
    _stale = Timer(staleAfter, () {
      if (mounted) state = state.copyWith(clearBpm: true);
    });
    state = reading.usable
        ? state.copyWith(bpm: reading.bpm, contactLost: false)
        : state.copyWith(clearBpm: true).copyWith(
            contactLost: reading.contact == false,
          );
  }

  void _onLost() {
    _tearDown();
    _scheduleRetry();
  }

  void _scheduleRetry() {
    state = state.copyWith(link: HrLink.reconnecting, clearBpm: true);
    final delay = retryDelays[math.min(_attempt, retryDelays.length - 1)];
    _attempt++;
    _retry?.cancel();
    _retry = Timer(delay, () => _connect(retrying: true));
  }

  void _watchAdapter() {
    _adapterSub ??= gateway.adapterChanges.listen(
      _onAdapter,
      onError: (Object _) {},
    );
  }

  void _unwatchAdapter() {
    _adapterSub?.cancel();
    _adapterSub = null;
  }

  void _onAdapter(bool on) {
    if (_sensor == null || _holds == 0 || !mounted) return;
    if (!on) {
      _tearDown();
      state = state.copyWith(
        link: HrLink.none,
        issue: HrIssue.adapterOff,
        clearBpm: true,
      );
    } else if (state.issue == HrIssue.adapterOff) {
      _attempt = 0;
      unawaited(_connect(retrying: false));
    }
  }

  /// Cancels any attempt, retry and live link. Never blocks the caller.
  void _tearDown() {
    _gen++;
    _retry?.cancel();
    _retry = null;
    _stale?.cancel();
    _stale = null;
    _valueSub?.cancel();
    _valueSub = null;
    final link = _link;
    _link = null;
    if (link != null) unawaited(_closeQuietly(link));
  }

  static Future<void> _closeQuietly(BleHeartRateLink link) async {
    try {
      await link.close();
    } catch (_) {}
  }

  @override
  void dispose() {
    _holds = 0;
    _tearDown();
    _unwatchAdapter();
    super.dispose();
  }
}

final heartRateManagerProvider =
    StateNotifierProvider<HeartRateManager, HeartRateState>(
      (ref) => HeartRateManager(
        gateway: const FlutterBlueGateway(),
        store: DbHrSensorStore(ref.watch(databaseProvider)),
      ),
    );
