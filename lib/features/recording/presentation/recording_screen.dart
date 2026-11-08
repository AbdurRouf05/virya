import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stravo/app/theme/field_notes.dart';
import 'package:stravo/core/constants/enums.dart';
import 'package:stravo/core/database/app_database.dart';
import 'package:stravo/core/location/models/telemetry_snapshot.dart';
import 'package:stravo/core/permissions/tracking_permissions.dart';
import 'package:stravo/features/activity_history/presentation/activity_detail_screen.dart';
import 'package:stravo/features/maps/widgets/route_map_view.dart';
import 'package:stravo/features/recording/application/recording_controller.dart';
import 'package:stravo/features/recording/domain/recording_state.dart';
import 'package:stravo/features/recording/presentation/recording_format.dart';
import 'package:stravo/features/recording/presentation/widgets/hold_to_confirm_button.dart';

/// Live recording screen (night palette, glove-friendly controls).
class RecordingScreen extends ConsumerStatefulWidget {
  const RecordingScreen({super.key});

  @override
  ConsumerState<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends ConsumerState<RecordingScreen> {
  late final RecordingController _ctrl =
      ref.read(recordingControllerProvider.notifier);
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepare());
  }

  Future<void> _prepare() async {
    if (!ref.read(recordingControllerProvider).isActive) {
      await _ctrl.loadSettings();
    }
    if (!mounted) return;
    final s = ref.read(recordingControllerProvider);
    if (s.phase != RecordingPhase.idle || s.simulated) return;
    final ok = await TrackingPermissions.ensureForRecording(
      context,
      db: ref.read(databaseProvider),
    );
    if (ok && mounted) await _ctrl.warmUp();
  }

  @override
  void dispose() {
    _ctrl.coolDown();
    super.dispose();
  }

  Future<void> _start() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final s = ref.read(recordingControllerProvider);
      final ok = await TrackingPermissions.ensureForRecording(
        context,
        db: ref.read(databaseProvider),
        simulated: s.simulated,
      );
      if (!ok || !mounted) return;
      HapticFeedback.mediumImpact();
      await _ctrl.start();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _stop() async {
    final id = await _ctrl.stop();
    if (!mounted) return;
    if (id != null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ActivityDetailScreen(activityId: id),
      ));
    }
  }

  Future<void> _discard() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: FN.nightSurface,
        shape: const RoundedRectangleBorder(),
        title: Text('BUANG AKTIVITAS?',
            style: FN.label(size: 14, color: FN.paper)),
        content: const Text(
          'Seluruh rute, data, dan foto sesi ini akan dihapus permanen.',
          style: TextStyle(fontFamily: FN.sans, color: FN.paper),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('BATAL', style: FN.label(color: FN.paperLine)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('BUANG', style: FN.label(color: FN.warn)),
          ),
        ],
      ),
    );
    if (yes != true) return;
    await _ctrl.discard();
    if (mounted) Navigator.of(context).maybePop();
  }

  Future<void> _photo() async {
    try {
      final x = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 2560,
      );
      if (x == null) return;
      final ok = await _ctrl.addPhoto(x.path);
      if (ok && mounted) _snack('Foto tersimpan di rute');
    } catch (e) {
      if (mounted) _snack('Kamera tidak tersedia');
    }
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(text, style: const TextStyle(fontFamily: FN.sans)),
        backgroundColor: FN.nightSurface,
        behavior: SnackBarBehavior.floating,
      ));
  }

  Future<void> _pickSport(SportType current) async {
    final picked = await showModalBottomSheet<SportType>(
      context: context,
      backgroundColor: FN.nightSurface,
      shape: const RoundedRectangleBorder(),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Text('PILIH OLAHRAGA',
                  style: FN.label(size: 12, color: FN.signal)),
            ),
            for (final s in SportType.values)
              ListTile(
                minTileHeight: 56,
                leading: Icon(sportIcon(s),
                    color: s == current ? FN.acid : FN.paperLine),
                title: Text(
                  s.displayName.toUpperCase(),
                  style: TextStyle(
                    fontFamily: FN.display,
                    fontSize: 20,
                    color: s == current ? FN.acid : FN.paper,
                  ),
                ),
                onTap: () => Navigator.pop(ctx, s),
              ),
          ],
        ),
      ),
    );
    if (picked != null) _ctrl.selectSport(picked);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(recordingControllerProvider);
    ref.listen<String?>(
      recordingControllerProvider.select((v) => v.message),
      (_, msg) {
        if (msg == null) return;
        _snack(msg);
        _ctrl.clearMessage();
      },
    );
    final fmt = RecFormat(imperial: s.imperial);

    return PopScope(
      canPop: !s.isActive,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && s.isActive) {
          _snack('Rekaman berjalan. Jeda lalu tahan SELESAI untuk menyimpan.');
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: FN.night,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _TopBar(
                      state: s,
                      onClose: () => Navigator.of(context).maybePop(),
                      onSport: () => _pickSport(s.sport),
                    ),
                    Expanded(flex: 5, child: _MapPanel(state: s)),
                    _PrimaryMetric(state: s, fmt: fmt),
                    _MetricGrid(state: s, fmt: fmt),
                    const SizedBox(height: 10),
                    if (s.phase == RecordingPhase.idle)
                      _SportStrip(
                        selected: s.sport,
                        onSelect: _ctrl.selectSport,
                      ),
                    _Controls(
                      state: s,
                      busy: _busy,
                      onStart: _start,
                      onPause: _ctrl.pause,
                      onResume: _ctrl.resume,
                      onStop: _stop,
                      onDiscard: _discard,
                      onPhoto: _photo,
                      onToggleSim: (v) => _ctrl.setSimulated(v),
                    ),
                  ],
                ),
                if (s.phase == RecordingPhase.saving) const _SavingOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

IconData sportIcon(SportType s) => switch (s) {
      SportType.gravelCycling ||
      SportType.roadCycling ||
      SportType.mountainBiking =>
        Icons.directions_bike,
      SportType.roadRunning || SportType.trailRunning => Icons.directions_run,
      SportType.hiking => Icons.hiking,
      SportType.walking => Icons.directions_walk,
    };

class _SportStrip extends StatelessWidget {
  final SportType selected;
  final ValueChanged<SportType> onSelect;

  const _SportStrip({
    required this.selected,
    required this.onSelect,
  });

  static const _items = [
    (SportType.gravelCycling, 'GRAVEL'),
    (SportType.roadCycling, 'ROAD'),
    (SportType.mountainBiking, 'MTB'),
    (SportType.roadRunning, 'LARI'),
    (SportType.trailRunning, 'TRAIL'),
    (SportType.hiking, 'HIKING'),
    (SportType.walking, 'JALAN'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (sport, label) = _items[index];
          final isSel = sport == selected;
          final fg = isSel ? FN.ink : FN.paper;
          return Semantics(
            button: true,
            selected: isSel,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelect(sport),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isSel ? FN.acid : Colors.transparent,
                  border: isSel
                      ? null
                      : Border.all(color: FN.paperLine, width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(sportIcon(sport), size: 20, color: fg),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: FN.label(size: 12, color: fg)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ------------------------------------------------------------------ top bar

class _TopBar extends StatelessWidget {
  final RecordingState state;
  final VoidCallback onClose;
  final VoidCallback onSport;

  const _TopBar({
    required this.state,
    required this.onClose,
    required this.onSport,
  });

  @override
  Widget build(BuildContext context) {
    final idle = state.phase == RecordingPhase.idle;
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          if (idle)
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, color: FN.paper),
              tooltip: 'Tutup',
            )
          else
            const SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: idle ? onSport : null,
              child: Row(
                children: [
                  Icon(sportIcon(state.sport), color: FN.signal, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      state.sport.displayName.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontFamily: FN.display,
                          fontSize: 20,
                          color: FN.paper,
                          letterSpacing: 0.5),
                    ),
                  ),
                  if (idle)
                    const Icon(Icons.expand_more, color: FN.paperLine),
                ],
              ),
            ),
          ),
          _GpsChip(status: state.gps, accuracy: state.snapshot.accuracyMeters),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _GpsChip extends StatelessWidget {
  final GpsStatus status;
  final double accuracy;
  const _GpsChip({required this.status, required this.accuracy});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      GpsStatus.good => ('GPS ±${accuracy.round()}M', FN.acid),
      GpsStatus.weak => ('GPS LEMAH', const Color(0xFFE8B23A)),
      GpsStatus.searching => ('MENCARI GPS', FN.signal),
      GpsStatus.off => ('GPS MATI', FN.inkMuted),
      GpsStatus.simulated => ('SIMULASI', FN.acid),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(border: Border.all(color: color)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Blink(active: status == GpsStatus.searching, color: color),
          const SizedBox(width: 6),
          Text(label, style: FN.label(size: 10, color: color)),
        ],
      ),
    );
  }
}

class _Blink extends StatefulWidget {
  final bool active;
  final Color color;
  const _Blink({required this.active, required this.color});

  @override
  State<_Blink> createState() => _BlinkState();
}

class _BlinkState extends State<_Blink> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(_Blink old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.active && !_c.isAnimating) {
      _c.repeat(reverse: true);
    } else if (!widget.active) {
      _c.value = 1;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _c,
        child: Container(width: 8, height: 8, color: widget.color),
      );
}

// ---------------------------------------------------------------------- map

class _MapPanel extends StatelessWidget {
  final RecordingState state;
  const _MapPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final snap = state.snapshot;
    final pos = snap.hasFix ? (snap.latitude, snap.longitude) : null;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: FN.nightSurface,
        border: Border.all(color: FN.nightLine),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Placeholder grid shows if the map renders blank / offline.
          const CustomPaint(painter: _GridPainter()),
          ClipRect(
            child: RepaintBoundary(
              child: RouteMapView(
                points: state.route,
                live: true,
                currentPosition: pos,
                bearing: snap.bearingDegrees,
              ),
            ),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: _SurfaceChip(surface: snap.currentSurface),
          ),
          if (state.photoCount > 0)
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: FN.night.withValues(alpha: 0.85),
                child: Row(children: [
                  const Icon(Icons.photo_camera, size: 14, color: FN.paper),
                  const SizedBox(width: 4),
                  Text('${state.photoCount}',
                      style: FN.label(size: 11, color: FN.paper)),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = FN.nightLine
      ..strokeWidth = 1;
    const step = 32.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SurfaceChip extends StatelessWidget {
  final SurfaceType surface;
  const _SurfaceChip({required this.surface});

  @override
  Widget build(BuildContext context) {
    final color = FN.surface[surface] ?? FN.inkMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      color: FN.night.withValues(alpha: 0.85),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 12, height: 12, color: color),
          const SizedBox(width: 6),
          Text(surface.label.toUpperCase(),
              style: FN.label(size: 10, color: FN.paper)),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ metrics

class _PrimaryMetric extends StatelessWidget {
  final RecordingState state;
  final RecFormat fmt;
  const _PrimaryMetric({required this.state, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final snap = state.snapshot;
    final cycling = state.sport.isCycling;
    final value =
        cycling ? fmt.speed(snap.currentSpeedKmh) : fmt.pace(snap.currentSpeedKmh);
    final label = cycling ? 'KECEPATAN · ${fmt.speedUnit}' : 'PACE · ${fmt.paceUnit}';
    final size = (MediaQuery.sizeOf(context).width * 0.30).clamp(72.0, 132.0);

    String? ribbon;
    Color ribbonColor = FN.acid;
    if (state.phase == RecordingPhase.paused) {
      ribbon = 'DIJEDA';
      ribbonColor = FN.signal;
    } else if (snap.isAutoPaused) {
      ribbon = 'AUTO-PAUSE';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: FN.label(color: FN.paperLine)),
              if (ribbon != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  color: ribbonColor,
                  child: Text(ribbon, style: FN.label(size: 10, color: FN.ink)),
                ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: FN.bigNumber(
                size,
                color: state.isActive && !snap.isPaused
                    ? FN.paper
                    : FN.paper.withValues(alpha: 0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final RecordingState state;
  final RecFormat fmt;
  const _MetricGrid({required this.state, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final LiveTelemetrySnapshot s = state.snapshot;
    final cycling = state.sport.isCycling;
    final tiles = <_Tile>[
      _Tile('JARAK', fmt.distance(s.totalDistanceMeters), fmt.distanceUnit),
      _Tile('WAKTU GERAK', RecFormat.duration(s.movingTimeSeconds), ''),
      _Tile('ELEV NAIK', fmt.elevation(s.totalElevationGainMeters),
          fmt.elevationUnit),
      _Tile('TANJAKAN', RecFormat.grade(s.currentGradePct), '%',
          accent: s.currentGradePct >= 3 ? FN.grade(s.currentGradePct) : null),
      cycling
          ? _Tile('RATA-RATA', fmt.speed(s.averageSpeedKmh), fmt.speedUnit)
          : _Tile('PACE RATA²', fmt.pace(s.averageSpeedKmh), fmt.paceUnit),
      s.heartRate != null
          ? _Tile('DETAK JANTUNG', '${s.heartRate}', 'BPM', accent: FN.signal)
          : _Tile('TOTAL WAKTU', RecFormat.duration(s.elapsedTimeSeconds), ''),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          for (var r = 0; r < 2; r++)
            Row(
              children: [
                for (var c = 0; c < 3; c++)
                  Expanded(child: _TileView(tile: tiles[r * 3 + c])),
              ],
            ),
        ],
      ),
    );
  }
}

class _Tile {
  final String label;
  final String value;
  final String unit;
  final Color? accent;
  const _Tile(this.label, this.value, this.unit, {this.accent});
}

class _TileView extends StatelessWidget {
  final _Tile tile;
  const _TileView({required this.tile});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: FN.nightSurface,
        border: Border(
          left: BorderSide(color: tile.accent ?? FN.nightLine, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tile.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FN.label(size: 9, color: FN.paperLine)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(tile.value, style: FN.bigNumber(30, color: FN.paper)),
                if (tile.unit.isNotEmpty) ...[
                  const SizedBox(width: 3),
                  Text(tile.unit, style: FN.label(size: 9, color: FN.paperLine)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------- controls

class _Controls extends StatelessWidget {
  final RecordingState state;
  final bool busy;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;
  final VoidCallback onDiscard;
  final VoidCallback onPhoto;
  final ValueChanged<bool> onToggleSim;

  const _Controls({
    required this.state,
    required this.busy,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    required this.onDiscard,
    required this.onPhoto,
    required this.onToggleSim,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: switch (state.phase) {
        RecordingPhase.idle => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BigButton(
                label: 'MULAI',
                icon: Icons.play_arrow,
                color: FN.signal,
                onTap: busy ? null : onStart,
              ),
              _SimToggle(value: state.simulated, onChanged: onToggleSim),
            ],
          ),
        RecordingPhase.recording => Row(
            children: [
              _SquareButton(icon: Icons.photo_camera, onTap: onPhoto),
              const SizedBox(width: 8),
              Expanded(
                child: _BigButton(
                  label: 'JEDA',
                  icon: Icons.pause,
                  color: FN.paper,
                  onTap: onPause,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 88,
                child: HoldToConfirmButton(
                  label: 'SELESAI',
                  icon: Icons.stop,
                  onConfirmed: onStop,
                ),
              ),
            ],
          ),
        RecordingPhase.paused => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _BigButton(
                      label: 'LANJUT',
                      icon: Icons.play_arrow,
                      color: FN.acid,
                      onTap: onResume,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: HoldToConfirmButton(
                      label: 'TAHAN · SELESAI',
                      icon: Icons.stop,
                      onConfirmed: onStop,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: onDiscard,
                child: Text('BUANG AKTIVITAS',
                    style: FN.label(size: 11, color: FN.warn)),
              ),
            ],
          ),
        RecordingPhase.saving => const SizedBox(height: 88),
      },
    );
  }
}

class _BigButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _BigButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap == null ? color.withValues(alpha: 0.4) : color,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.mediumImpact();
                onTap!();
              },
        child: SizedBox(
          height: 88,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: FN.ink),
              const SizedBox(width: 10),
              Text(label,
                  style: const TextStyle(
                      fontFamily: FN.display,
                      fontSize: 32,
                      color: FN.ink,
                      letterSpacing: 1)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SquareButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FN.nightSurface,
      shape: const RoundedRectangleBorder(
          side: BorderSide(color: FN.nightLine, width: 2)),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 72,
          height: 88,
          child: Icon(icon, color: FN.paper, size: 30),
        ),
      ),
    );
  }
}

class _SimToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SimToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('GPS SIMULASI (DEV)', style: FN.label(size: 10, color: FN.inkMuted)),
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: FN.acid,
            inactiveThumbColor: FN.inkMuted,
            inactiveTrackColor: FN.nightSurface,
          ),
        ),
      ],
    );
  }
}

class _SavingOverlay extends StatelessWidget {
  const _SavingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: FN.night.withValues(alpha: 0.92),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(color: FN.signal, strokeWidth: 3),
            ),
            const SizedBox(height: 16),
            Text('MENYIMPAN & MENGANALISIS…',
                style: FN.label(size: 12, color: FN.paper)),
          ],
        ),
      ),
    );
  }
}
