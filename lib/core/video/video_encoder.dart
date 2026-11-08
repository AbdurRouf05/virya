import 'package:flutter/services.dart';

/// Anything that accepts video frames (real encoder or a test fake).
abstract class FrameSink {
  int get width;
  int get height;
  Future<void> addFrameRgba(Uint8List rgba);
  Future<String> finish();
  Future<void> cancel();
}

/// Creates a sink; injectable for tests.
typedef FrameSinkFactory = Future<FrameSink> Function({
  required String outputPath,
  required int width,
  required int height,
  required int fps,
  required int bitrate,
});

/// H.264 MP4 encoder backed by Android MediaCodec + MediaMuxer
/// (channel `virya/video_encoder`). Frames are given at the requested size;
/// the native side center-crops to a multiple of 16 when needed.
class VideoEncoder implements FrameSink {
  static const _ch = MethodChannel('virya/video_encoder');

  final int _id;
  final String outputPath;
  @override
  final int width;
  @override
  final int height;
  final int fps;

  /// Actual encoded dimensions (multiples of 16).
  final int encodedWidth;
  final int encodedHeight;

  bool _closed = false;
  int _frames = 0;

  VideoEncoder._(this._id, this.outputPath, this.width, this.height, this.fps,
      this.encodedWidth, this.encodedHeight);

  int get frameCount => _frames;

  static Future<VideoEncoder> start({
    required String outputPath,
    required int width,
    required int height,
    int fps = 30,
    int bitrate = 8000000,
  }) async {
    final r = await _ch.invokeMapMethod<String, dynamic>('start', {
      'outputPath': outputPath,
      'width': width,
      'height': height,
      'fps': fps,
      'bitrate': bitrate,
    });
    if (r == null) {
      throw PlatformException(code: 'start_failed', message: 'Encoder tidak merespons');
    }
    return VideoEncoder._(
      r['id'] as int,
      outputPath,
      width,
      height,
      fps,
      (r['width'] as int?) ?? width,
      (r['height'] as int?) ?? height,
    );
  }

  /// Factory matching [FrameSinkFactory].
  static Future<FrameSink> create({
    required String outputPath,
    required int width,
    required int height,
    required int fps,
    required int bitrate,
  }) =>
      start(
        outputPath: outputPath,
        width: width,
        height: height,
        fps: fps,
        bitrate: bitrate,
      );

  void _check() {
    if (_closed) throw StateError('VideoEncoder sudah ditutup');
  }

  /// Straight RGBA, exactly width*height*4 bytes.
  @override
  Future<void> addFrameRgba(Uint8List rgba) async {
    _check();
    if (rgba.length != width * height * 4) {
      throw ArgumentError(
          'Frame RGBA harus ${width * height * 4} byte, dapat ${rgba.length}');
    }
    await _ch.invokeMethod<void>('addFrameRgba', {
      'id': _id,
      'bytes': rgba,
      'width': width,
      'height': height,
    });
    _frames++;
  }

  /// PNG or JPEG bytes (decoded natively; scaled to width×height if needed).
  Future<void> addFramePng(Uint8List png) async {
    _check();
    await _ch.invokeMethod<void>('addFrameImage', {
      'id': _id,
      'bytes': png,
      'width': width,
      'height': height,
    });
    _frames++;
  }

  @override
  Future<String> finish() async {
    _check();
    _closed = true;
    final path = await _ch.invokeMethod<String>('finish', {'id': _id});
    return path ?? outputPath;
  }

  @override
  Future<void> cancel() async {
    if (_closed) return;
    _closed = true;
    await _ch.invokeMethod<void>('cancel', {'id': _id});
  }
}
