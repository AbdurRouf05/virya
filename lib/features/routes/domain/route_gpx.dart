import 'package:virya/features/routes/domain/route_models.dart';
import 'package:virya/services/export_import/xml_util.dart';

/// GPX 1.1 berisi satu `<trk>` (rute rencana, tanpa waktu).
String routeToGpx(SavedRoute r) {
  final b = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
    ..writeln('<gpx version="1.1" creator="Virya" '
        'xmlns="http://www.topografix.com/GPX/1/1">')
    ..writeln('  <metadata>')
    ..writeln('    <name>${xmlEscape(r.name)}</name>')
    ..writeln('    <time>${isoUtc(r.createdAt)}</time>')
    ..writeln('  </metadata>')
    ..writeln('  <trk>')
    ..writeln('    <name>${xmlEscape(r.name)}</name>')
    ..writeln('    <type>${r.sport.name}</type>')
    ..writeln('    <trkseg>');
  final p = r.path;
  for (var i = 0; i < p.points.length; i++) {
    final (lat, lon) = p.points[i];
    final e = i < p.ele.length ? p.ele[i] : double.nan;
    b.write('      <trkpt lat="${lat.toStringAsFixed(6)}" '
        'lon="${lon.toStringAsFixed(6)}"');
    if (e.isFinite) {
      b.writeln('><ele>${e.toStringAsFixed(1)}</ele></trkpt>');
    } else {
      b.writeln('/>');
    }
  }
  b
    ..writeln('    </trkseg>')
    ..writeln('  </trk>')
    ..writeln('</gpx>');
  return b.toString();
}

/// Nama file aman dari nama rute.
String gpxFileName(String name) {
  final s = name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return '${s.isEmpty ? 'rute' : s}.gpx';
}
