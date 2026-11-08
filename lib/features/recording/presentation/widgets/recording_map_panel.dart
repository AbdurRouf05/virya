import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/features/maps/widgets/route_map_view.dart';
import 'package:virya/features/recording/domain/recording_state.dart';

/// Live route map with surface chip and photo counter overlays.
class RecordingMapPanel extends StatelessWidget {
  final RecordingState state;
  const RecordingMapPanel({super.key, required this.state});

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
              child: _PhotoCount(count: state.photoCount),
            ),
        ],
      ),
    );
  }
}

class _PhotoCount extends StatelessWidget {
  final int count;
  const _PhotoCount({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: FN.night.withValues(alpha: 0.85),
      child: Row(children: [
        Icon(Icons.photo_camera, size: 14, color: FN.paper),
        const SizedBox(width: 4),
        Text('$count', style: FN.label(size: 11, color: FN.paper)),
      ]),
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
