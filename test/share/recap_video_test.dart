import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:virya/features/share/domain/share_data.dart';
import 'package:virya/features/share/video/recap_timeline.dart';
import 'package:virya/features/share/video/recap_video_renderer.dart';
import 'package:virya/features/share/video/video_encoder.dart';

import 'share_fixture.dart';

class FakeSink implements FrameSink {
  @override
  final int width;
  @override
  final int height;
  final frames = <int>[];
  var finished = false;
  var cancelled = false;
  final void Function(int count)? onFrame;
  FakeSink(this.width, this.height, {this.onFrame});

  @override
  Future<void> addFrameRgba(Uint8List rgba) async {
    expect(rgba.length, width * height * 4);
    frames.add(rgba.length);
    onFrame?.call(frames.length);
  }

  @override
  Future<String> finish() async {
    finished = true;
    return 'fake.mp4';
  }

  @override
  Future<void> cancel() async => cancelled = true;
}

void main() {
  group('RecapTimeline', () {
    const tl = RecapTimeline(); // 30 fps, 1.5 + 14 + 2.5 s

    test('frame counts', () {
      expect(tl.introFrames, 45);
      expect(tl.routeFrames, 420);
      expect(tl.outroFrames, 75);
      expect(tl.totalFrames, 540);
      expect(tl.durationS, 18);
    });

    test('scene boundaries', () {
      expect(tl.at(0).scene, RecapScene.intro);
      expect(tl.at(44).scene, RecapScene.intro);
      expect(tl.at(45).scene, RecapScene.route);
      expect(tl.at(45).progress, 0);
      expect(tl.at(464).scene, RecapScene.route);
      expect(tl.at(464).progress, 1);
      expect(tl.at(465).scene, RecapScene.outro);
      expect(tl.at(539).scene, RecapScene.outro);
      expect(tl.at(539).local, 1);
    });

    test('tracer is monotonic and finishes before the outro', () {
      var last = -1.0;
      for (var i = tl.routeStart; i < tl.outroStart; i++) {
        final p = tl.at(i).progress;
        expect(p, greaterThanOrEqualTo(last));
        last = p;
      }
      final finishFrame = tl.frameAtProgress(1);
      expect(finishFrame, lessThan(tl.outroStart - 20));
      final half = tl.frameAtProgress(0.5);
      expect(half, inInclusiveRange(tl.routeStart, tl.outroStart));
      expect(tl.at(half).progress, greaterThanOrEqualTo(0.5));
      expect(tl.at(half - 1).progress, lessThan(0.5));
    });
  });

  group('RecapVideoRenderer', () {
    const tl = RecapTimeline(fps: 4, introS: 0.5, routeS: 2, outroS: 0.5);
    final data = fakeShareData(photos: [
      SharePhoto(path: 'does/not/exist.jpg', distanceM: 5000, lat: 0, lon: 0),
    ]);

    testWidgets('streams every frame to the sink and finishes', (tester) async {
      late FakeSink sink;
      final r = RecapVideoRenderer(
        data: data,
        width: 72,
        height: 128,
        timeline: tl,
        sinkFactory: ({required outputPath, required width, required height, required fps, required bitrate}) async {
          expect(fps, 4);
          return sink = FakeSink(width, height);
        },
      );
      final progress = <double>[];
      r.progress.listen(progress.add);
      final path = await tester.runAsync(() => r.render(outputPath: 'x.mp4'));
      expect(path, 'fake.mp4');
      expect(sink.frames.length, tl.totalFrames);
      expect(sink.finished, isTrue);
      expect(progress.last, 1.0);
    });

    testWidgets('paper style renders too', (tester) async {
      late FakeSink sink;
      final r = RecapVideoRenderer(
        data: data,
        width: 72,
        height: 128,
        night: false,
        timeline: tl,
        sinkFactory: ({required outputPath, required width, required height, required fps, required bitrate}) async =>
            sink = FakeSink(width, height),
      );
      await tester.runAsync(() => r.render(outputPath: 'x.mp4'));
      expect(sink.frames.length, tl.totalFrames);
    });

    testWidgets('cancel stops rendering and cancels the sink', (tester) async {
      late FakeSink sink;
      late RecapVideoRenderer r;
      r = RecapVideoRenderer(
        data: data,
        width: 72,
        height: 128,
        timeline: tl,
        sinkFactory: ({required outputPath, required width, required height, required fps, required bitrate}) async =>
            sink = FakeSink(width, height, onFrame: (n) {
          if (n == 3) r.cancel();
        }),
      );
      Object? error;
      await tester.runAsync(() async {
        try {
          await r.render(outputPath: 'x.mp4');
        } catch (e) {
          error = e;
        }
      });
      expect(error, isA<RecapCancelled>());
      expect(sink.cancelled, isTrue);
      expect(sink.finished, isFalse);
      expect(sink.frames.length, 3);
    });
  });
}
