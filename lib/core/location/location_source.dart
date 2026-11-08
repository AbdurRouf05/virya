import 'package:stravo/core/location/location_fix.dart';

/// Abstraction over GNSS so the pipeline is testable and simulatable.
abstract class LocationSource {
  /// Starts producing fixes. A source can be listened to once per start.
  Stream<LocationFix> start();

  Future<void> stop();

  /// True for replay/demo sources (UI shows a "SIMULASI" badge).
  bool get isSimulated;
}
