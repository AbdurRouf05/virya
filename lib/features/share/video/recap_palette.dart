import 'dart:ui';

import 'package:virya/app/theme/export_tokens.dart';

/// Colors used by the recap video scenes.
class RecapPalette {
  final Color bg, ink, muted, line, contour, accent, panel;
  const RecapPalette(this.bg, this.ink, this.muted, this.line, this.contour,
      this.accent, this.panel);

  /// Night (dark scene) or paper palette with [accent]
  /// (defaults to `FNExport.acid` at night, `FNExport.signal` on paper).
  factory RecapPalette.of({required bool night, Color? accent}) {
    final a = accent ?? (night ? FNExport.acid : FNExport.signal);
    return night
        ? RecapPalette(FNExport.night, FNExport.paper, const Color(0xFF8C887D), FNExport.nightLine,
            const Color(0xFF24241F), a, FNExport.nightSurface)
        : RecapPalette(FNExport.paper, FNExport.ink, FNExport.inkMuted, FNExport.ink, FNExport.paperLine, a,
            FNExport.paperDeep);
  }
}
