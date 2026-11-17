import 'dart:convert';

/// `[[lat, lon], ...]` dengan presisi 6 desimal (sekitar 10 cm).
String encodePolyline(List<(double lat, double lon)> points) => jsonEncode([
  for (final (lat, lon) in points)
    [
      double.parse(lat.toStringAsFixed(6)),
      double.parse(lon.toStringAsFixed(6)),
    ],
]);

/// Isi yang rusak menghasilkan daftar kosong, bukan error.
List<(double lat, double lon)> decodePolyline(String json) {
  try {
    final out = <(double, double)>[];
    for (final p in jsonDecode(json) as List<dynamic>) {
      final pair = p as List<dynamic>;
      out.add(((pair[0] as num).toDouble(), (pair[1] as num).toDouble()));
    }
    return out;
  } catch (_) {
    return const [];
  }
}

String encodeMarks(List<int> marks) => jsonEncode(marks);

List<int> decodeMarks(String json) {
  try {
    return [for (final m in jsonDecode(json) as List<dynamic>) (m as num).toInt()];
  } catch (_) {
    return const [];
  }
}
