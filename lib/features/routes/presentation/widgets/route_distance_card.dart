import 'package:flutter/material.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/routes/domain/route_models.dart';
import 'package:virya/features/routes/presentation/widgets/route_dialogs.dart';

/// Kartu target jarak: geser untuk kira-kira, ketuk angkanya untuk tepat.
class RouteDistanceCard extends StatelessWidget {
  const RouteDistanceCard({
    super.key,
    required this.sport,
    required this.km,
    required this.onChanged,
  });

  final RouteSport sport;
  final double km;
  final ValueChanged<double> onChanged;

  Future<void> _exact(BuildContext context) async {
    final t = await routePrompt(
      context,
      title: 'Jarak target',
      initial: km.round().toString(),
      label: 'Km (${_n(sport.minKm)}–${_n(sport.maxKm)})',
      action: 'Pakai',
      number: true,
    );
    final v = double.tryParse(t?.replaceAll(',', '.') ?? '');
    if (v != null) onChanged(v.clamp(sport.minKm, sport.maxKm));
  }

  static String _n(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final mid = (sport.minKm + sport.maxKm) / 2;
    return InkBox(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(FN.caps('Jarak'),
                    style: FN.label(size: 11, color: FN.inkMuted)),
              ),
              Semantics(
                button: true,
                label: 'Ubah jarak tepat',
                child: GestureDetector(
                  onTap: () => _exact(context),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(_n(km), style: FN.bigNumber(30, color: FN.ink)),
                      const SizedBox(width: 4),
                      Text('km', style: FN.label(size: 12, color: FN.inkMuted)),
                      const SizedBox(width: 6),
                      Icon(Icons.edit_outlined, size: 14, color: FN.inkMuted),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: km.clamp(sport.minKm, sport.maxKm),
            min: sport.minKm,
            max: sport.maxKm,
            divisions: (sport.maxKm - sport.minKm).round(),
            activeColor: FN.signal,
            inactiveColor: FN.fill,
            label: '${_n(km)} km',
            onChanged: (v) => onChanged(v.roundToDouble()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final v in [sport.minKm, mid.roundToDouble(), sport.maxKm])
                Text(_n(v), style: FN.label(size: 10, color: FN.inkMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
