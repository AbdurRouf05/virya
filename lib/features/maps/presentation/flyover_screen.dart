import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/data/activity_repository.dart';
import 'package:virya/core/models/track_sample.dart';
import 'package:virya/core/offline_maps/local_tile_server.dart';
import 'package:virya/core/offline_maps/map_pack_repository.dart';
import 'package:virya/features/maps/application/flyover_exporter.dart';
import 'package:virya/features/maps/application/flyover_playback.dart';
import 'package:virya/features/maps/domain/flyover_plan.dart';
import 'package:virya/features/maps/presentation/widgets/flyover_controls.dart';
import 'package:virya/features/maps/presentation/widgets/flyover_export_overlay.dart';
import 'package:virya/features/maps/presentation/widgets/flyover_gradient.dart';
import 'package:virya/features/maps/presentation/widgets/flyover_hud.dart';
import 'package:virya/features/maps/presentation/widgets/flyover_message.dart';
import 'package:virya/features/maps/presentation/widgets/flyover_plan_error.dart';
import 'package:virya/features/maps/presentation/widgets/flyover_top_bar.dart';
import 'package:virya/features/maps/widgets/route_preview.dart';
import 'package:virya/features/maps/widgets/virya_map_controller.dart';
import 'package:virya/features/share/domain/share_options.dart';
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
  late final FlyoverPlayback _pb;

  // Export.
  bool _exporting = false;
  bool _cancel = false;
  double _exportProgress = 0;
  String _exportStage = '';

  @override
  void initState() {
    super.initState();
    _pb = FlyoverPlayback(this, baseDuration: _baseDuration)..addListener(_onPlayback);
  }

  void _onPlayback() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pb.dispose();
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

  void _togglePlay() {
    if (_plan == null || _exporting) return;
    _pb.togglePlay();
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
    final map = _pb.map;
    final base = LocalTileServer.instance.baseUri;
    if (map == null || !_pb.flyReady || base == null) {
      _toast('Ekspor video butuh peta WebView (Android).');
      return;
    }
    if (_pb.playing) _togglePlay();
    _pb.exporting = true;
    setState(() {
      _exporting = true;
      _cancel = false;
      _exportProgress = 0;
      _exportStage = 'MENYIAPKAN';
    });
    WakelockPlus.enable().catchError((_) {});

    String? outPath;
    try {
      outPath = await exportFlyoverVideo(
        map: map,
        base: base,
        width: _videoW,
        height: _videoH,
        fps: _fps,
        seconds: _exportLength.totalSeconds(bundle.analysis.distanceM),
        title: bundle.activity.title,
        subtitle: flyoverSubtitle(bundle, _plan?.totalDistM ?? 0),
        pace: bundle.sport.isRunning,
        isCancelled: () => _cancel,
        onStage: (s) {
          if (mounted) setState(() => _exportStage = s);
        },
        onFrame: (done, total) {
          if (!mounted) return;
          setState(() {
            _exportProgress = done / total;
            _exportStage = 'FRAME $done/$total';
          });
        },
      );
    } catch (e) {
      _toast('Ekspor gagal: $e');
    } finally {
      WakelockPlus.disable().catchError((_) {});
      _pb.exporting = false;
      if (mounted) setState(() => _exporting = false);
    }
    if (outPath != null && mounted) {
      try {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(outPath, mimeType: 'video/mp4')],
            text: '${bundle.activity.title} · Virya Flyover',
          ),
        );
      } catch (e) {
        _toast('Video tersimpan: $outPath');
      }
    }
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
      if (cfg != null && bundle != null) _pb.ensureMap(cfg, plan, bundle);
    }

    Widget body;
    if (bundleAsync.hasError) {
      body = FlyoverMessage('Gagal memuat aktivitas:\n${bundleAsync.error}');
    } else if (bundleAsync.hasValue && bundle == null) {
      body = const FlyoverMessage('Aktivitas tidak ditemukan.');
    } else if (_planError != null) {
      body = FlyoverPlanError(
        error: _planError!,
        onRetry: () => setState(() {
          _planError = null;
          _planFuture = null;
        }),
      );
    } else if (plan == null) {
      body = const FlyoverMessage('MENYIAPKAN JALUR KAMERA…', loading: true);
    } else if (plan.isEmpty) {
      body = const FlyoverMessage('RUTE TERLALU PENDEK UNTUK FLYOVER');
    } else {
      body = _player(bundle!, plan);
    }
    return Scaffold(backgroundColor: FN.night, body: body);
  }

  Widget _player(ActivityBundle bundle, FlyoverPlan plan) {
    final k = plan.at(_pb.u);
    final map = _pb.map;
    final mapView = map != null
        ? ViryaMapWebView(controller: map, interactive: false)
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
        if (map != null && !_pb.flyReady)
          Positioned.fill(
            child: ColoredBox(
              color: FN.paper,
              child: Center(child: CircularProgressIndicator(color: FN.ink)),
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: FlyoverTopBar(
            title: bundle.activity.title,
            is3d: _pb.is3d,
            busy: _exporting,
            onToggle3d: _pb.toggle3d,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: FlyoverGradient(
            top: false,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FlyoverHud(k: k, pace: bundle.sport.isRunning),
                    const SizedBox(height: 8),
                    _controls(bundle),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_exporting)
          FlyoverExportOverlay(
            progress: _exportProgress,
            stage: _exportStage,
            cancelling: _cancel,
            onCancel: () => setState(() => _cancel = true),
          ),
      ],
    );
  }

  Widget _controls(ActivityBundle bundle) => FlyoverControls(
        u: _pb.u,
        playing: _pb.playing,
        speed: _pb.speed,
        speeds: _speeds,
        exportLength: _exportLength,
        exportHd: _exportHd,
        videoW: _videoW,
        videoH: _videoH,
        disabled: _exporting,
        onSeek: _pb.seek,
        onTogglePlay: _togglePlay,
        onSpeed: _pb.setSpeed,
        onLength: (l) => setState(() => _exportLength = l),
        onHd: (hd) => setState(() => _exportHd = hd),
        onExport: () => _export(bundle),
      );
}

/// Top-level so the isolate closure captures only [samples] — a closure
/// created inside a State method can drag the whole widget tree along.
Future<FlyoverPlan> _planInIsolate(List<TrackSample> samples) =>
    Isolate.run(() => buildFlyoverPlan(samples));
