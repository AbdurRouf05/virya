/// Singkatan yang tetap kapital saat teks kapital diubah ke kapital kalimat.
const _keepUpper = {
  'GPS', 'HR', 'GAP', 'VAM', 'PR', 'BPM', 'FTP', 'TSS', 'CTL', 'ATL', 'TSB',
  'GPX', 'TCX', 'FIT', 'PDF', 'URL', 'ID', 'RPE', 'HRV', 'BMI', 'USB', 'ADB',
  'OK', 'MP4', 'PNG', 'KOM', 'QOM', 'BLE', 'RM', 'SOS', 'A', 'B', 'POI',
};

/// Mengubah teks yang seluruhnya kapital menjadi kapital kalimat
/// ("TERAKHIR · MIN 15 NOV" -> "Terakhir · min 15 nov"). Teks yang sudah
/// memuat huruf kecil dibiarkan apa adanya.
String sentenceCase(String s) {
  if (s.isEmpty || s != s.toUpperCase() || s == s.toLowerCase()) return s;
  final out = s.toLowerCase().replaceAllMapped(RegExp(r'[A-Za-z0-9-]+'), (m) {
    final w = m[0]!;
    final up = w.toUpperCase();
    final keep = _keepUpper.contains(up) ||
        (RegExp(r'\d').hasMatch(w) && RegExp(r'^[A-Za-z]\d+$').hasMatch(w));
    return keep ? up : w;
  });
  final i = out.indexOf(RegExp('[a-z]'));
  if (i < 0) return out;
  final j = out.indexOf(RegExp('[A-Za-z]'));
  if (j < i) return out; // diawali singkatan kapital
  return out.substring(0, i) + out[i].toUpperCase() + out.substring(i + 1);
}
