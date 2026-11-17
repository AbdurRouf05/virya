import 'package:flutter/material.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/routes/domain/route_models.dart';

/// Pilihan tambahan: medan, utamakan jalan baru, hindari jalan raya.
class RouteOptionsCard extends StatelessWidget {
  const RouteOptionsCard({
    super.key,
    required this.prefs,
    required this.onTerrain,
    required this.onPreferNew,
    required this.onAvoidMain,
  });

  final RoutePrefs prefs;
  final ValueChanged<RouteTerrain> onTerrain;
  final ValueChanged<bool> onPreferNew;
  final ValueChanged<bool> onAvoidMain;

  Widget _row(String title, String hint, bool value, ValueChanged<bool> on) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: FN.heading(size: 14, color: FN.ink)),
                  const SizedBox(height: 2),
                  Text(hint, style: FN.body(size: 12, color: FN.inkMuted)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            InkToggle(value: value, onChanged: on),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return InkBox(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(FN.caps('Medan'),
              style: FN.label(size: 11, color: FN.inkMuted)),
          const SizedBox(height: 8),
          SegmentedPick<RouteTerrain>(
            options: [for (final t in RouteTerrain.values) (t, t.label)],
            value: prefs.terrain,
            onChanged: onTerrain,
          ),
          const SizedBox(height: 6),
          _row('Utamakan jalan baru', 'Hindari jalan yang sudah sering kamu lewati',
              prefs.preferNew, onPreferNew),
          const InkRule(),
          _row('Hindari jalan raya', 'Pilih jalan kecil yang lebih tenang',
              prefs.avoidMain, onAvoidMain),
        ],
      ),
    );
  }
}
