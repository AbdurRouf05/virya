import 'package:flutter/material.dart';
import 'package:virya/app/theme/export_tokens.dart';
import 'package:virya/features/share/domain/share_data.dart';
import 'package:virya/features/share/domain/share_format.dart';
import 'package:virya/features/share/domain/share_options.dart';
import 'package:virya/features/share/templates/card_parts.dart';

/// STICKER — transparent overlay for IG Stories: route + 3 stats with an
/// ink outline and soft shadow so it reads on any photo.
class StickerCard extends StatelessWidget {
  final ShareData data;
  final ShareOptions options;
  const StickerCard({super.key, required this.data, required this.options});

  static const _shadows = [
    Shadow(color: Color(0xCC141414), blurRadius: 0, offset: Offset(1.2, 1.2)),
    Shadow(color: Color(0x88000000), blurRadius: 8),
  ];

  @override
  Widget build(BuildContext context) {
    final f = options.format;
    final accent = options.accent.resolve(dark: true);
    final routeColor = options.accent == AccentChoice.ink ? FNExport.ink : FNExport.paper;
    final outline = routeColor == FNExport.ink ? FNExport.paper : FNExport.ink;
    final rest = statValues(data, options.stats).take(2).toList();
    final stats = [StatValue('JARAK', SF.km(data.distanceM), 'KM'), ...rest];
    final valueSize = f == CardFormat.square ? 34.0 : 40.0;

    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              painter: RouteMapPainter(
                data: data,
                ink: routeColor,
                accent: accent,
                width: 3.2,
                bleed: false,
                outline: outline,
                outlineWidth: 1.4,
                shadow: const Shadow(
                  color: Color(0x66000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
                markFill: outline,
                padding: 12,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final s in stats)
                Expanded(
                  child: Column(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: s.value,
                                style: FNExport
                                    .bigNumber(valueSize, color: routeColor)
                                    .copyWith(shadows: _shadows),
                              ),
                              if (s.unit.isNotEmpty)
                                TextSpan(
                                  text: ' ${s.unit}',
                                  style: FNExport
                                      .label(size: 9, color: accent)
                                      .copyWith(
                                        fontWeight: FontWeight.w700,
                                        shadows: _shadows,
                                      ),
                                ),
                            ],
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.label,
                        style: FNExport
                            .label(size: 8, color: routeColor)
                            .copyWith(
                              fontWeight: FontWeight.w700,
                              shadows: _shadows,
                            ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'VIRYA · ${SF.sport(data.sport)} · ${SF.date(data.start)}',
            style: FNExport
                .label(size: 7, color: routeColor)
                .copyWith(letterSpacing: 2, shadows: _shadows),
          ),
        ],
      ),
    );
  }
}
