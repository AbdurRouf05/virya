import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Field Notes ThemeData: paper (day) and night (recording).
class FieldNotesTheme {
  FieldNotesTheme._();

  static const _square = RoundedRectangleBorder(
    borderRadius: BorderRadius.zero,
  );

  static ThemeData get paper => _build(
    brightness: FN.palette.brightness,
    bg: FN.paper,
    surface: FN.paper,
    surfaceHigh: FN.paperDeep,
    fg: FN.ink,
    muted: FN.inkMuted,
    line: FN.ink,
    accent: FN.signal,
  );

  static ThemeData get night => _build(
    brightness: Brightness.dark,
    bg: FN.night,
    surface: FN.nightSurface,
    surfaceHigh: FN.nightLine,
    fg: FN.onNight,
    muted: FN.onNightMuted,
    line: FN.nightLine,
    accent: FN.acid,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color surfaceHigh,
    required Color fg,
    required Color muted,
    required Color line,
    required Color accent,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: fg,
      onPrimary: bg,
      secondary: accent,
      onSecondary: FN.onAccent,
      tertiary: FN.signal,
      onTertiary: FN.onAccent,
      error: FN.warn,
      onError: FN.onNight,
      surface: surface,
      onSurface: fg,
      onSurfaceVariant: muted,
      surfaceContainerHighest: surfaceHigh,
      outline: line,
      outlineVariant: muted,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: FN.sans,
    );
    final text = base.textTheme.apply(
      bodyColor: fg,
      displayColor: fg,
      fontFamily: FN.sans,
    );
    final mono = FN.label(size: 12, color: fg);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: fg, width: 1),
    );
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      splashFactory: InkRipple.splashFactory,
      splashColor: accent.withValues(alpha: 0.12),
      highlightColor: fg.withValues(alpha: 0.05),
      textTheme: text.copyWith(
        displayLarge: FN.bigNumber(64, color: fg),
        displayMedium: FN.bigNumber(48, color: fg),
        displaySmall: FN.bigNumber(36, color: fg),
        headlineMedium: FN.bigNumber(28, color: fg),
        titleLarge: TextStyle(
          fontFamily: FN.display,
          fontSize: 24,
          color: fg,
          height: 1.0,
        ),
        labelLarge: mono.copyWith(fontWeight: FontWeight.w700),
        labelMedium: FN.label(size: 11, color: muted),
        labelSmall: FN.label(size: 10, color: muted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: FN
            .label(size: 13, color: fg)
            .copyWith(fontWeight: FontWeight.w700, letterSpacing: 2),
        shape: Border(bottom: BorderSide(color: fg, width: 1)),
      ),
      dividerTheme: DividerThemeData(color: fg, thickness: 1, space: 1),
      iconTheme: IconThemeData(color: fg, size: 20),
      inputDecorationTheme: InputDecorationTheme(
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: accent, width: 2),
        ),
        labelStyle: FN.label(size: 11, color: muted),
        floatingLabelStyle: FN.label(size: 11, color: fg),
        isDense: true,
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: accent,
        selectionColor: accent.withValues(alpha: 0.3),
        selectionHandleColor: accent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: FN.ink,
        contentTextStyle: FN.label(size: 12, color: FN.paper),
        actionTextColor: FN.signal,
        shape: _square,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: fg, width: 2),
        ),
        titleTextStyle: TextStyle(
          fontFamily: FN.display,
          fontSize: 26,
          color: fg,
          height: 1.05,
        ),
        contentTextStyle: TextStyle(
          fontFamily: FN.sans,
          fontSize: 14,
          color: fg,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: Border(top: BorderSide(color: fg, width: 2)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: fg, width: 1),
        ),
        textStyle: mono,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: fg.withValues(alpha: 0.12),
        linearMinHeight: 3,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: fg,
        inactiveTrackColor: fg.withValues(alpha: 0.2),
        thumbColor: accent,
        overlayColor: accent.withValues(alpha: 0.15),
        trackHeight: 2,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        valueIndicatorColor: FN.ink,
        valueIndicatorTextStyle: FN.label(size: 11, color: FN.paper),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: fg,
          shape: _square,
          textStyle: mono.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
