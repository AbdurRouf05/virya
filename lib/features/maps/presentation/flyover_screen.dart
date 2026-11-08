import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stravo/app/theme/field_notes.dart';
import 'package:stravo/core/data/activity_repository.dart';
import 'package:stravo/core/offline_maps/local_tile_server.dart';
import 'package:stravo/core/offline_maps/map_pack_repository.dart';
import 'package:stravo/features/maps/domain/flyover_plan.dart';
import 'package:stravo/core/models/track_sample.dart';
import 'package:stravo/core/widgets/stamp_chip.dart';
import 'package:stravo/features/maps/widgets/route_preview.dart';
import 'package:stravo/features/maps/widgets/stravo_map_controller.dart';
import 'package:stravo/features/share/domain/share_options.dart';
import 'package:stravo/features/share/video/video_encoder.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Cinematic 3D flyover of an activity + deterministic MP4 export.
class FlyoverScreen extends ConsumerStatefulWidget {
  const FlyoverScreen({super.key, required this.activityId});
  final String activityId;

  @override
  ConsumerState<FlyoverScreen> createState() => _FlyoverScreenState();
}

class _FlyoverScreenState extends ConsumerState<FlyoverScreen>
    with SingleTickerProviderStateMixin {
  static const _baseDuration = 30.0; // seconds at 1×
  static const _fps = 30;
  static const _speeds = [1.0, 2.0, 4.0, 8.0];

  RecapLength _exportLength = RecapLength.auto;
  bool _exportHd = false; // 720p default vs 1080p
  int get _videoW => _exportHd ? 1080 : 720;
  int get _videoH => _exportHd ? 1920 : 1280;

  Future<FlyoverPlan>? _planFuture;
  FlyoverPlan? _plan;
  String? _planError;
  StravoMapController? _map;
  StreamSubscription<Map<String, dynamic>>? _sub;
  bool _flyReady = false;

  double _u = 0;
  bool _playing = false;
  double _speed = 1;
  bool _is3d = true;

  // Fallback (no WebView) playback.
  late final Ticker _ticker = createTicker(_onTick);
  Duration _lastTick = Duration.zero;

  // Export.
  bool _exporting = false;
  bool _cancel = false;
  double _exportProgress = 0;
  String _exportStage = '';

  @override
  void dispose() {
    _ticker.dispose();
    _sub?.cancel();
    _map?.dispose();
    WakelockPlus.disable().catchError((_) {});
    super.dispose();
  }

  void _ensurePlan(ActivityBundle b) {
    if (_planFuture != null) return;
    final sw = Stopwatch()..start();
    _planFuture = _planInIsolate(b.samples)
        .timeout(const Duration(seconds: 20))
        .then((plan) {
      debugPrint('[flyover-perf] plan ${b.samples.length} titik: ${sw.elapsedMilliseconds} ms');
      if (mounted) setState(() => _plan = plan);
      return plan;
    }).catchError((Object e) {
      if (mounted) setState(() => _planError = '$e');
      throw e;
    });
    _planFuture!.ignore(); // cegah "unhandled exception"
  }

  void _ensureMap(MapConfig cfg, FlyoverPlan plan, ActivityBundle b) {
    if (_map != null || !mapWebViewSupported || plan.isEmpty) return;
    final m = StravoMapController.create(
      config: cfg,
      interactive: false,
      enable3d: _is3d,
      extra: {
        'center': [plan.frames.first.lon, plan.frames.first.lat],
        'zoom': plan.frames.first.zoom,
      },
    );
    _map = m;
    _sub = m.events.listen(_onEvent);
    m.call('flySetDuration', [_baseDuration]);
    m.call('flySetSpeed', [_speed]);
    m.call('flyLoad', [plan.toJson()]);
    if (b.photos.isNotEmpty) {
      m.call('setPhotos', [
        for (final ph in b.photos) {'lat': ph.latitude, 'lon': ph.longitude},
      ]);
    }
  }

  void _onEvent(Map<String, dynamic> e) {
    if (!mounted) return;
    switch (e['type']) {
      case 'flyLoaded':
        setState(() => _flyReady = true);
      case 'progress':
        if (_exporting) return;
        setState(() {
          _u = (e['u'] as num).toDouble();
          _playing = e['playing'] == true;
        });
      case 'ended':
        setState(() {
          _playing = false;
          _u = 1;
        });
    }
  }

  // ---------- controls ----------
  void _togglePlay() {
    if (_plan == null || _exporting) return;
    final play = !_playing;
    setState(() {
      _playing = play;
      if (play && _u >= 1) _u = 0;
    });
    if (_map != null) {
      _map!.call(play ? 'flyPlay' : 'flyPause');
    } else if (play) {
      _lastTick = Duration.zero;
      if (!_ticker.isActive) _ticker.start();
    } else {
      _ticker.stop();
    }
  }

  void _onTick(Duration elapsed) {
    final dt = _lastTick == Duration.zero
        ? 0.0
        : (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    final u = (_u + dt * _speed / _baseDuration).clamp(0.0, 1.0);
    setState(() {
      _u = u;
      if (u >= 1) {
        _playing = false;
        _ticker.stop();
      }
    });
  }

  void _seek(double u) {
    setState(() => _u = u);
    _map?.call('flySeek', [u]);
  }

  void _setSpeed(double s) {
    setState(() => _speed = s);
    _map?.call('flySetSpeed', [s]);
  }

  void _toggle3d() {
    setState(() => _is3d = !_is3d);
    _map?.call('set3d', [_is3d]);
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: FN.nightSurface,
        content: Text(m, style: FN.label(size: 12, color: FN.paper)),
      ),
    );
  }

  // ---------- export ----------
  Future<void> _export(ActivityBundle bundle) async {
    final map = _map;
    final base = LocalTileServer.instance.baseUri;
    if (map == null || !_flyReady || base == null) {
      _toast('Ekspor video butuh peta WebView (Android).');
      return;
    }
    if (_playing) _togglePlay();
    setState(() {
      _exporting = true;
      _cancel = false;
      _exportProgress = 0;
      _exportStage = 'MENYIAPKAN';
    });
    WakelockPlus.enable().catchError((_) {});

    final waiters = <int, Completer<Uint8List>>{};
    final chunks = <int, List<String?>>{};
    final token = LocalTileServer.instance.registerCaptureSink((i, bytes) {
      final c = waiters[i];
      if (c != null && !c.isCompleted) c.complete(bytes);
    });
    final readyC = Completer<void>();
    final warmupC = Completer<void>();
    final sub = map.events.listen((e) {
      switch (e['type']) {
        case 'exportReady':
          if (!readyC.isCompleted) readyC.complete();
        case 'warmupDone':
          if (!warmupC.isCompleted) warmupC.complete();
        case 'frameChunk':
          final i = (e['i'] as num).toInt();
          final n = (e['n'] as num).toInt();
          final buf = chunks.putIfAbsent(
            i,
            () => List<String?>.filled(n, null),
          );
          buf[(e['seq'] as num).toInt()] = e['data'] as String;
          if (buf.every((s) => s != null)) {
            chunks.remove(i);
            final c = waiters[i];
            if (c != null && !c.isCompleted) {
              c.complete(base64Decode(buf.join()));
            }
          }
        case 'frameError':
          final c = waiters[(e['i'] as num).toInt()];
          if (c != null && !c.isCompleted) {
            c.completeError(StateError('${e['msg']}'));
          }
      }
    });

    VideoEncoder? enc;
    String? outPath;
    try {
      final dir = await getTemporaryDirectory();
      final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final path = p.join(dir.path, 'stravo_flyover_$stamp.mp4');
      enc = await VideoEncoder.start(
        outputPath: path,
        width: _videoW,
        height: _videoH,
        fps: _fps,
      );
      await map.call('exportBegin', [
        {
          'w': _videoW,
          'h': _videoH,
          'quality': 0.85,
          'captureUrl': '$base/capture/$token',
          'title': bundle.activity.title,
          'subtitle': _subtitle(bundle),
          'pace': bundle.sport.isRunning,
        },
      ]);
      await readyC.future.timeout(const Duration(seconds: 15));
      setState(() => _exportStage = 'MEMUAT PETA');
      await map.call('exportWarmup', [24]);
      await warmupC.future.timeout(const Duration(seconds: 60));

      final seconds = _exportLength.totalSeconds(bundle.analysis.distanceM);
      final total = (_fps * seconds).round();
      final swTotal = Stopwatch()..start();
      var waitMs = 0, encMs = 0;

      waiters[0] = Completer<Uint8List>();
      await map.call('renderFrame', [0.0, 0]);

      for (var i = 0; i < total; i++) {
        if (_cancel) break;
        final swWait = Stopwatch()..start();
        final bytes = await waiters[i]!.future.timeout(const Duration(seconds: 30));
        waiters.remove(i);
        waitMs += swWait.elapsedMilliseconds;

        if (i + 1 < total && !_cancel) {
          waiters[i + 1] = Completer<Uint8List>();
          final nextT = (i + 1) / (total - 1);
          await map.call('renderFrame', [nextT, i + 1]);
        }

        final swEnc = Stopwatch()..start();
        await enc.addFramePng(bytes);
        encMs += swEnc.elapsedMilliseconds;

        if (mounted) {
          setState(() {
            _exportProgress = (i + 1) / total;
            _exportStage = 'FRAME ${i + 1}/$total';
          });
        }

        if ((i + 1) % 60 == 0 || i == total - 1) {
          final count = (i % 60) + 1;
          debugPrint(
              '[flyover-perf] frame ${i + 1}/$total wait=${(waitMs / count).round()}ms encode=${(encMs / count).round()}ms');
          waitMs = 0;
          encMs = 0;
        }
      }
      debugPrint('[flyover-perf] TOTAL ${swTotal.elapsedMilliseconds} ms untuk $total frame ($_videoW×$_videoH)');
      if (_cancel) {
        await enc.cancel();
        enc = null;
      } else {
        setState(() => _exportStage = 'MENYIMPAN MP4');
        outPath = await enc.finish();
        enc = null;
      }
    } catch (e) {
      _toast('Ekspor gagal: $e');
      try {
        await enc?.cancel();
      } catch (_) {}
    } finally {
      await sub.cancel();
      LocalTileServer.instance.unregisterCaptureSink(token);
      await map.call('exportEnd');
      WakelockPlus.disable().catchError((_) {});
      if (mounted) setState(() => _exporting = false);
    }
    if (outPath != null && mounted) {
      try {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(outPath, mimeType: 'video/mp4')],
            text: '${bundle.activity.title} · Stravo Flyover',
          ),
        );
      } catch (e) {
        _toast('Video tersimpan: $outPath');
      }
    }
  }

  String _subtitle(ActivityBundle b) {
    final a = b.analysis;
    final km =
        (a.distanceM > 0 ? a.distanceM : (_plan?.totalDistM ?? 0)) / 1000;
    final gain = a.elevationGainM > 0
        ? a.elevationGainM
        : b.activity.elevationGainMeters;
    final date = DateFormat('d MMM yyyy').format(b.activity.startTime);
    return '$date · ${km.toStringAsFixed(1)} KM · +${gain.round()} M';
  }

  // ---------- build ----------
  @override
  Widget build(BuildContext context) {
    final bundleAsync = ref.watch(activityBundleProvider(widget.activityId));
    final bundle = bundleAsync.valueOrNull;
    if (bundle != null) _ensurePlan(bundle);
    final plan = _plan;
    if (plan != null && mapWebViewSupported) {
      final cfg = ref.watch(mapConfigProvider).valueOrNull;
      if (cfg != null && bundle != null) _ensureMap(cfg, plan, bundle);
    }

    Widget body;
    if (bundleAsync.hasError) {
      body = _message('Gagal memuat aktivitas:\n${bundleAsync.error}');
    } else if (bundleAsync.hasValue && bundle == null) {
      body = _message('Aktivitas tidak ditemukan.');
    } else if (_planError != null) {
      body = _errorPlan(_planError!);
    } else if (plan == null) {
      body = _message('MENYIAPKAN JALUR KAMERA…', loading: true);
    } else if (plan.isEmpty) {
      body = _message('RUTE TERLALU PENDEK UNTUK FLYOVER');
    } else {
      body = _player(bundle!, plan);
    }
    return Scaffold(backgroundColor: FN.night, body: body);
  }

  Widget _errorPlan(String error) => SafeArea(
    child: Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'GAGAL MENYIAPKAN FLYOVER',
                  textAlign: TextAlign.center,
                  style: FN.label(size: 13, color: FN.paper)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: FN.label(size: 10, color: FN.inkSoft),
                ),
                const SizedBox(height: 16),
                StampChip(
                  text: 'COBA LAGI',
                  color: FN.acid,
                  onTap: () {
                    setState(() {
                      _planError = null;
                      _planFuture = null;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        const Positioned(left: 4, top: 4, child: BackButton(color: FN.paper)),
      ],
    ),
  );

  Widget _message(String m, {bool loading = false}) => SafeArea(
    child: Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading) const CircularProgressIndicator(color: FN.acid),
              if (loading) const SizedBox(height: 16),
              Text(
                m,
                textAlign: TextAlign.center,
                style: FN.label(size: 12, color: FN.paper),
              ),
            ],
          ),
        ),
        const Positioned(left: 4, top: 4, child: BackButton(color: FN.paper)),
      ],
    ),
  );

  Widget _player(ActivityBundle bundle, FlyoverPlan plan) {
    final k = plan.at(_u);
    final map = _map;
    final mapView = map != null
        ? StravoMapWebView(controller: map, interactive: false)
        : RoutePreview(
            points: plan.route,
            progress: k.progress,
            currentPosition: (k.lat, k.lon),
            caption: mapWebViewSupported
                ? null
                : 'PRATINJAU 2D · peta 3D butuh Android',
          );
    return Stack(
      children: [
        Positioned.fill(child: mapView),
        if (map != null && !_flyReady)
          const Positioned.fill(
            child: ColoredBox(
              color: FN.paper,
              child: Center(child: CircularProgressIndicator(color: FN.ink)),
            ),
          ),
        // Top bar.
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: _gradient(
            top: true,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 16, 18),
                child: Row(
                  children: [
                    BackButton(
                      color: FN.paper,
                      onPressed: _exporting
                          ? null
                          : () => Navigator.maybePop(context),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STRAVO // FLYOVER',
                            style: FN.label(size: 10, color: FN.acid),
                          ),
                          Text(
                            bundle.activity.title.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FN.bigNumber(22, color: FN.paper),
                          ),
                        ],
                      ),
                    ),
                    _chip(
                      _is3d ? '3D' : '2D',
                      true,
                      _exporting ? null : _toggle3d,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // HUD + controls.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _gradient(
            top: false,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _hud(k, bundle.sport.isRunning),
                    const SizedBox(height: 8),
                    _controls(bundle),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_exporting) _exportOverlay(),
      ],
    );
  }

  Widget _gradient({required bool top, required Widget child}) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: top ? Alignment.topCenter : Alignment.bottomCenter,
        end: top ? Alignment.bottomCenter : Alignment.topCenter,
        colors: [
          FN.night.withValues(alpha: .94),
          FN.night.withValues(alpha: top ? 0 : .80),
          if (!top) FN.night.withValues(alpha: 0),
        ],
      ),
    ),
    child: child,
  );

  Widget _hud(FlyKeyframe k, bool pace) {
    String paceStr(double kmh) {
      if (kmh < 1) return '--:--';
      final s = (3600 / kmh).round();
      return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
    }

    final gradeCol = k.gradePct < 3 ? FN.paper : FN.grade(k.gradePct);
    Widget cell(
      String label,
      String value,
      String unit, {
      Color color = FN.paper,
    }) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: FN.label(size: 9, color: FN.inkMuted)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: FN.bigNumber(30, color: color),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: FN.label(size: 10, color: FN.paperLine),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    return Column(
      children: [
        Row(
          children: [
            cell('JARAK', (k.distM / 1000).toStringAsFixed(2), 'KM'),
            cell('ELEVASI', '${k.eleM.round()}', 'M'),
            pace
                ? cell('TEMPO', paceStr(k.speedKmh), '/KM')
                : cell('KECEPATAN', k.speedKmh.toStringAsFixed(1), 'KM/J'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            cell(
              'TANJAKAN',
              '${k.gradePct >= 0 ? '+' : ''}${k.gradePct.toStringAsFixed(1)}',
              '%',
              color: gradeCol,
            ),
            cell('WAKTU', _fmtTime(k.elapsedS), ''),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  static String _fmtTime(double s) {
    final t = s.round();
    final h = t ~/ 3600, m = (t % 3600) ~/ 60, x = t % 60;
    final mm = m.toString().padLeft(2, '0'), xx = x.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$xx' : '$m:$xx';
  }

  Widget _controls(ActivityBundle bundle) {
    final disabled = _exporting;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            activeTrackColor: FN.signal,
            inactiveTrackColor: FN.nightLine,
            thumbColor: FN.acid,
            overlayColor: FN.acid.withValues(alpha: .15),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            value: _u.clamp(0.0, 1.0),
            onChanged: disabled ? null : _seek,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text('DURASI: ', style: FN.label(size: 9, color: FN.paperLine)),
                for (final l in RecapLength.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _chip(
                      l.label,
                      _exportLength == l,
                      disabled ? null : () => setState(() => _exportLength = l),
                    ),
                  ),
                const SizedBox(width: 8),
                Text('RESOLUSI: ', style: FN.label(size: 9, color: FN.paperLine)),
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _chip(
                    '720P',
                    !_exportHd,
                    disabled ? null : () => setState(() => _exportHd = false),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _chip(
                    '1080P',
                    _exportHd,
                    disabled ? null : () => setState(() => _exportHd = true),
                  ),
                ),
              ],
            ),
          ),
        ),
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(color: FN.signal),
              child: IconButton(
                color: FN.night,
                iconSize: 30,
                onPressed: disabled ? null : _togglePlay,
                icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
              ),
            ),
            const SizedBox(width: 10),
            for (final s in _speeds)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _chip(
                  '${s.toInt()}×',
                  _speed == s,
                  disabled ? null : () => _setSpeed(s),
                ),
              ),
            const Spacer(),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: FN.acid,
                side: const BorderSide(color: FN.acid, width: 1.5),
                shape: const RoundedRectangleBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 14,
                ),
              ),
              onPressed: disabled ? null : () => _export(bundle),
              child: Text(
                'EKSPOR $_videoW×$_videoH',
                style: FN.label(size: 10, color: FN.acid),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _chip(String label, bool selected, VoidCallback? onTap) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? FN.paper : Colors.transparent,
        border: Border.all(color: FN.paper, width: 1.2),
      ),
      child: Text(
        label,
        style: FN.label(size: 11, color: selected ? FN.night : FN.paper),
      ),
    ),
  );

  Widget _exportOverlay() => Positioned.fill(
    child: ColoredBox(
      color: FN.night.withValues(alpha: .72),
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: FN.nightSurface,
            border: Border.all(color: FN.acid, width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EKSPOR VIDEO 1080×1920',
                style: FN.label(size: 10, color: FN.acid),
              ),
              const SizedBox(height: 8),
              Text(
                '${(_exportProgress * 100).toStringAsFixed(0)}%',
                style: FN.bigNumber(56, color: FN.paper),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _exportProgress,
                minHeight: 5,
                color: FN.signal,
                backgroundColor: FN.nightLine,
              ),
              const SizedBox(height: 8),
              Text(
                _exportStage,
                style: FN.label(size: 10, color: FN.paperLine),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _cancel
                      ? null
                      : () => setState(() => _cancel = true),
                  child: Text(
                    _cancel ? 'MEMBATALKAN…' : 'BATAL',
                    style: FN.label(size: 11, color: FN.warn),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Top-level so the isolate closure captures only [samples] — a closure
/// created inside a State method can drag the whole widget tree along.
Future<FlyoverPlan> _planInIsolate(List<TrackSample> samples) =>
    Isolate.run(() => buildFlyoverPlan(samples));
