import 'package:flutter_test/flutter_test.dart';
import 'package:stravo/features/share/domain/share_options.dart';
import 'package:stravo/features/share/video/recap_timeline.dart';

void main() {
  group('RecapLength', () {
    test('routeSeconds auto scales with distance correctly', () {
      expect(RecapLength.auto.routeSeconds(2000), closeTo(10.0, 1e-6));
      expect(RecapLength.auto.routeSeconds(50000), closeTo(27.5, 1e-6));
      expect(RecapLength.auto.routeSeconds(100000), closeTo(55.0, 1e-6));
      expect(RecapLength.auto.routeSeconds(500000), closeTo(55.0, 1e-6));
    });

    test('fixed presets give expected route seconds', () {
      expect(RecapLength.s15.routeSeconds(50000), 11.0);
      expect(RecapLength.s30.routeSeconds(50000), 26.0);
      expect(RecapLength.s60.routeSeconds(50000), 56.0);
    });

    test('totalSeconds adds 4s of intro and outro', () {
      expect(RecapLength.auto.totalSeconds(2000), 14.0);
      expect(RecapLength.s15.totalSeconds(1000), 15.0);
      expect(RecapLength.s30.totalSeconds(1000), 30.0);
      expect(RecapLength.s60.totalSeconds(1000), 60.0);
    });

    test('RecapTimeline frames correspond to total duration', () {
      for (final s in [10.0, 11.0, 26.0, 27.5, 55.0, 56.0]) {
        final timeline = RecapTimeline(routeS: s);
        final expected = ((1.5 + s + 2.5) * 30).round();
        expect((timeline.totalFrames - expected).abs(), lessThanOrEqualTo(1));
      }
    });
  });
}
