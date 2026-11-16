/// Gaya tampilan aplikasi. Warna datang dari [Palette]; gaya menentukan
/// bentuk dan huruf (garis, sudut, bayangan, huruf kapital).
///
/// - [tegas]: garis tinta 2px, bayangan keras, judul Anton, label mono kapital.
/// - [bersih]: tenang, kartu putih bergaris tipis, sudut membulat, tanpa
///   bayangan, huruf Plex Sans dengan kapital biasa.
enum UiGaya {
  tegas('Tegas'),
  bersih('Bersih');

  final String label;
  const UiGaya(this.label);

  static UiGaya fromId(String? id) => id == bersih.name ? bersih : tegas;
}

/// Kecerahan untuk gaya Bersih.
enum BersihMode {
  terang('Terang'),
  gelap('Gelap'),
  sistem('Ikuti sistem');

  final String label;
  const BersihMode(this.label);

  static BersihMode fromId(String? id) =>
      values.firstWhere((m) => m.name == id, orElse: () => terang);
}
