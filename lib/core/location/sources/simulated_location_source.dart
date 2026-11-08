import 'dart:async';

import 'package:virya/core/data/demo_data.dart';
import 'package:virya/core/location/location_fix.dart';
import 'package:virya/core/location/location_source.dart';
import 'package:virya/core/models/track_sample.dart';

/// Replays a recorded track (default: [demoGravelRide]) as live fixes.
///
/// Fix timestamps advance by the original sample spacing starting at
/// [startTime] (default: now), so the pipeline sees real 1 Hz data while the
/// wall clock runs [speedUp] times faster.
class SimulatedLocationSource implements LocationSource {
  final List<TrackSample> samples;
  final double speedUp;
  final DateTime? startTime;

  Timer? _timer;
  StreamController<LocationFix>? _out;
  int _index = 0;

  SimulatedLocationSource({
    List<TrackSample>? samples,
    this.speedUp = 10,
    this.startTime,
  }) : samples = samples ?? demoGravelRide();

  @override
  bool get isSimulated => true;

  /// Index of the next sample to emit (also used by [SimulatedSensorFeed]).
  int get index => _index;

  /// Sample most recently emitted, if any.
  TrackSample? get current => _index == 0 ? null : samples[_index - 1];

  @override
  Stream<LocationFix> start() {
    _timer?.cancel();
    _out?.close();
    final out = StreamController<LocationFix>();
    _out = out;
    _index = 0;
    if (samples.isEmpty) {
      out.close();
      return out.stream;
    }
    final origin = samples.first.time;
    final base = startTime ?? DateTime.now();
    final periodMs = (1000 / speedUp).clamp(1, 60000).round();
    _timer = Timer.periodic(Duration(milliseconds: periodMs), (t) {
      if (_index >= samples.length) {
        t.cancel();
        out.close();
        return;
      }
      final s = samples[_index++];
      out.add(LocationFix(
        time: base.add(s.time.difference(origin)),
        lat: s.lat,
        lon: s.lon,
        altitude: s.ele,
        accuracy: s.accuracyM ?? 5,
        speed: s.speedMps,
        heartRate: s.heartRate,
        cadence: s.cadence,
      ));
    });
    return out.stream;
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    await _out?.close();
    _out = null;
  }
}
