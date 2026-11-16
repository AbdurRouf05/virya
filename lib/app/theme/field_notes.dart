import 'package:flutter/material.dart';
import 'package:virya/app/theme/caps.dart';
import 'package:virya/app/theme/gaya.dart';
import 'package:virya/app/theme/palette.dart';
import 'package:virya/app/theme/styles/field_notes_style.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/constants/sport_category.dart';

/// Design tokens used by every widget. Values come from the active
/// [Palette] (see `styles/`), so tokens are NOT const — never use `FN.*`
/// inside a `const` expression. Change style with [FN.use].
class FN {
  FN._();

  static Palette _p = fieldNotesStyle;
  static Palette get palette => _p;

  /// Switch the active style. Caller must rebuild the app afterwards.
  static void use(Palette p) => _p = p;

  // Paper (day)
  static Color get paper => _p.paper;
  static Color get paperDeep => _p.paperDeep;
  static Color get paperLine => _p.paperLine; // grid / contour lines

  // Ink
  static Color get ink => _p.ink;
  static Color get inkSoft => _p.inkSoft;
  static Color get inkMuted => _p.inkMuted;

  // Night (recording, dark cards)
  static Color get night => _p.night;
  static Color get nightSurface => _p.nightSurface;
  static Color get nightLine => _p.nightLine;

  /// Teks/ikon di atas night, foto, atau peta. Jangan pakai [paper] di sana:
  /// pada style gelap [paper] ikut gelap.
  static Color get onNight => _p.onNight;
  static Color get onNightMuted => _p.onNightMuted;

  /// Teks/ikon gelap di atas [signal]/[acid], juga untuk bayangan dan scrim.
  /// Jangan pakai [ink] di sana: pada style gelap [ink] menjadi terang.
  static Color get onAccent => _p.onAccent;

  static bool get isDark => _p.brightness == Brightness.dark;

  /// Warna [accent] di atas blok berisi [ink]. Pada style gelap blok itu
  /// terang sehingga aksen tidak terbaca, jadi dipakai [paper].
  static Color onInk(Color accent) => isDark ? paper : accent;

  // Accents
  static Color get signal => _p.signal; // the one loud color
  static Color get acid => _p.acid; // highlight on night backgrounds only
  static Color get ok => _p.ok;
  static Color get warn => _p.warn;
  static Color get caution => _p.caution;
  static Color category(SportCategory c) => _p.category[c]!;

  static Map<SurfaceType, Color> get surface => _p.surface;

  /// Warna zona detak jantung Z1 sampai Z5.
  static List<Color> get hrZones => [..._p.hrZones, _p.signal];

  /// Color for a grade in percent (climb index).
  static Color grade(double pct) {
    final r = _p.gradeRamp;
    if (pct < 3) return r[0];
    if (pct < 5) return r[1];
    if (pct < 8) return r[2];
    if (pct < 11) return r[3];
    if (pct < 15) return r[4];
    return r[5];
  }

  // Font families (bundled in assets/fonts, fully offline)
  static String get display => _p.display; // poster numerals & titles
  static String get mono => _p.mono; // labels, units, data
  static String get sans => _p.sans; // body text

  // ---------------------------------------------------------------------
  // Gaya (bentuk & huruf). Tegas = nilai lama; Bersih = tenang & modern.
  // ---------------------------------------------------------------------

  static UiGaya get gaya => _p.gaya;

  /// `true` saat gaya Bersih aktif.
  static bool get isClean => _p.gaya == UiGaya.bersih;

  /// Tebal bingkai kartu utama: 2 (Tegas) atau 1 (Bersih).
  static double get stroke => isClean ? 1 : 2;

  /// Tebal garis untuk gaya ini: [tegas] apa adanya, Bersih selalu 1.
  static double line(double tegas) => isClean ? 1 : tegas;

  /// Warna bingkai kartu: tinta (Tegas) atau garis rambut (Bersih).
  static Color get cardLine => isClean ? _p.paperLine : ink;

  /// Garis pemisah di dalam kartu (baris daftar, sel tabel).
  static Color get divider => isClean ? _p.paperDeep : ink;

  /// Isi kartu: sama dengan halaman (Tegas) atau putih (Bersih).
  static Color get cardFill => _p.card ?? paper;

  /// Isi lembut: lintasan segmen, latar chip, titik minggu kosong.
  static Color get fill => isClean ? _p.paperDeep : paperDeep;

  /// Sudut kartu: 0 (Tegas) atau 14 (Bersih).
  static double get radius => isClean ? 14 : 0;

  /// Sudut kontrol kecil (tombol, input, chip): 0 atau 10.
  static double get radiusSmall => isClean ? 10 : 0;

  static BorderRadius get cardRadius => BorderRadius.circular(radius);
  static BorderRadius get smallRadius => BorderRadius.circular(radiusSmall);

  /// Bayangan keras ala cetakan (Tegas). Bersih: tanpa bayangan.
  static List<BoxShadow>? hardShadow({Color? color, double offset = 3}) =>
      isClean
      ? null
      : [BoxShadow(color: color ?? ink, offset: Offset(offset, offset))];

  /// Bingkai kartu. Tegas: tinta [width]. Bersih: garis rambut 1px, atau
  /// [color] tipis bila warna khusus diminta (mis. kartu terpilih).
  /// Di Bersih, [ink] dianggap warna bawaan sehingga tetap garis rambut.
  static Border frame({Color? color, double width = 2}) {
    if (!isClean) return Border.all(color: color ?? ink, width: width);
    final c = color == ink ? null : color;
    return Border.all(color: c ?? cardLine, width: c == null ? 1 : 1.5);
  }

  /// Sisi garis (garis atas/bawah/kiri). Tegas apa adanya; Bersih garis
  /// rambut 1px, warna khusus tetap dipakai.
  static BorderSide side({Color? color, double width = 1}) {
    if (!isClean) return BorderSide(color: color ?? ink, width: width);
    final c = color == ink ? null : color;
    return BorderSide(color: c ?? cardLine, width: 1);
  }

  /// Garis warna tebal di sisi kartu (penanda kategori). Bersih: tidak ada.
  static BorderSide stripe(Color color, {double width = 4}) =>
      isClean ? BorderSide.none : BorderSide(color: color, width: width);

  /// Sudut untuk kotak berbingkai: `null` di Tegas, [cardRadius] di Bersih.
  static BorderRadius? get boxRadius => isClean ? cardRadius : null;

  /// Dekorasi kartu lengkap: isi, bingkai, sudut, bayangan.
  static BoxDecoration card({
    Color? color,
    Color? borderColor,
    double width = 2,
    bool shadow = false,
    Color? shadowColor,
    double shadowOffset = 4,
  }) => BoxDecoration(
    color: color ?? cardFill,
    border: frame(color: borderColor, width: width),
    borderRadius: isClean ? cardRadius : null,
    boxShadow: shadow
        ? hardShadow(color: shadowColor, offset: shadowOffset)
        : null,
  );

  /// Teks label: kapital semua (Tegas) atau kapital kalimat (Bersih).
  /// Teks sumber sebaiknya ditulis kapital kalimat.
  static String caps(String s) => isClean ? sentenceCase(s) : s.toUpperCase();

  /// Jarak huruf khusus Tegas; Bersih `null` (memakai bawaan gaya).
  static double? track(double v) => isClean ? null : v;

  static const tabular = [FontFeature.tabularFigures()];

  /// Angka besar data olahraga. Tegas: Anton. Bersih: Plex Sans SemiBold
  /// rapat, sedikit lebih kecil karena hurufnya lebih lebar.
  static TextStyle bigNumber(double size, {Color? color}) => isClean
      ? TextStyle(
          fontFamily: sans,
          fontSize: size * 0.85,
          fontWeight: FontWeight.w600,
          letterSpacing: -size * 0.03,
          height: 1.0,
          color: color ?? ink,
          fontFeatures: tabular,
        )
      : TextStyle(
          fontFamily: display,
          fontSize: size,
          height: 0.95,
          color: color ?? ink,
          fontFeatures: tabular,
        );

  /// Judul besar (pengganti `fontFamily: FN.display`). Ukuran = ukuran Anton;
  /// Bersih mengecilkannya dan memakai Plex Sans SemiBold.
  static TextStyle title(double size, {Color? color, double? height}) =>
      isClean
      ? TextStyle(
          fontFamily: sans,
          fontSize: size * 0.62,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          height: 1.15,
          color: color ?? ink,
        )
      : TextStyle(
          fontFamily: display,
          fontSize: size,
          height: height,
          color: color ?? ink,
        );

  static TextStyle label({double size = 11, Color? color}) => isClean
      ? TextStyle(
          fontFamily: sans,
          fontSize: size + 1.5,
          letterSpacing: 0,
          fontWeight: FontWeight.w400,
          color: color ?? inkMuted,
        )
      : TextStyle(
          fontFamily: mono,
          fontSize: size,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w500,
          color: color ?? inkMuted,
        );

  /// Label tebal (judul kecil, tombol). Bersih: SemiBold tanpa jarak huruf.
  static TextStyle labelStrong({double size = 11, Color? color}) => label(
    size: size,
    color: color,
  ).copyWith(fontWeight: isClean ? FontWeight.w600 : FontWeight.w700);

  static TextStyle heading({double size = 16, Color? color, FontWeight? weight}) => TextStyle(
    fontFamily: sans,
    fontSize: size,
    fontWeight: weight ?? (isClean ? FontWeight.w600 : FontWeight.w700),
    height: 1.2,
    letterSpacing: isClean ? -0.2 : null,
    color: color ?? ink,
  );

  static TextStyle body({double size = 13, Color? color, FontWeight? weight}) => TextStyle(
    fontFamily: sans,
    fontSize: size,
    fontWeight: weight ?? FontWeight.normal,
    height: 1.35,
    color: color ?? ink,
  );

  /// Data kecil (waktu, angka tabel). Bersih: sans dengan angka tabular.
  static TextStyle monoStyle({double size = 11, Color? color, FontWeight? weight}) => TextStyle(
    fontFamily: isClean ? sans : mono,
    fontSize: isClean ? size + 1 : size,
    fontWeight: weight ?? (isClean ? FontWeight.w400 : FontWeight.w500),
    fontFeatures: tabular,
    color: color ?? inkMuted,
  );
}
