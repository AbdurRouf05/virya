import 'dart:ui';

import 'package:virya/app/theme/field_notes.dart';

/// Colors used by the recap video scenes.
class RecapPalette {
  final Color bg, ink, muted, line, contour, accent, panel;
  const RecapPalette(this.bg, this.ink, this.muted, this.line, this.contour,
      this.accent, this.panel);

  /// Night (dark scene) or paper palette with [accent]
  /// (defaults to `FN.acid` at night, `FN.signal` on paper).
  factory RecapPalette.of({required bool night, Color? accent}) {
    final a = accent ?? (night ? FN.acid : FN.signal);
    return night
        ? RecapPalette(FN.night, FN.paper, const Color(0xFF8C887D), FN.nightLine,
            const Color(0xFF24241F), a, FN.nightSurface)
        : RecapPalette(FN.paper, FN.ink, FN.inkMuted, FN.ink, FN.paperLine, a,
            FN.paperDeep);
  }
}
