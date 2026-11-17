import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/sensors/heart_rate_manager.dart';

/// Pulse (bpm) for a recording; emits null when the value is unavailable.
abstract class HeartRateSource {
  Stream<int?> start();
  Future<void> stop();
}

/// Holds the paired sensor's connection for the length of a recording.
class ManagedHeartRateSource implements HeartRateSource {
  final HeartRateManager manager;
  ManagedHeartRateSource(this.manager);

  StreamSubscription<int?>? _sub;
  StreamController<int?>? _out;

  @override
  Stream<int?> start() {
    final out = StreamController<int?>();
    _out = out;
    _sub = manager.stream.map((s) => s.bpm).distinct().listen(out.add);
    unawaited(manager.acquire());
    return out.stream;
  }

  @override
  Future<void> stop() async {
    final out = _out;
    if (out == null) return;
    _out = null;
    await _sub?.cancel();
    _sub = null;
    manager.release();
    await out.close();
  }
}

final heartRateSourceProvider = Provider.autoDispose<HeartRateSource>(
  (ref) => ManagedHeartRateSource(ref.read(heartRateManagerProvider.notifier)),
);
