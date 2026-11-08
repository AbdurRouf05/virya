import 'package:stravo/core/constants/enums.dart';
import 'package:stravo/core/models/track_sample.dart';
import 'package:stravo/services/export_import/parsed_activity.dart';
import 'package:stravo/services/export_import/xml_util.dart';
import 'package:xml/xml.dart';

/// Parse GPX 1.0/1.1 tracks (all trk/trkseg merged into one activity).
/// Reads Garmin TrackPointExtension hr/cad and optional speed.
List<ParsedActivity> parseGpx(String text, {String? sourceName}) {
  final doc = XmlDocument.parse(text);
  final root = doc.rootElement;
  final samples = <TrackSample>[];
  String? title, type;
  for (final trk in root.childElements.where((e) => e.localName == 'trk')) {
    title ??= trk.childText('name');
    type ??= trk.childText('type');
    for (final pt in trk.descendantElements) {
      if (pt.localName != 'trkpt') continue;
      final s = _point(pt);
      if (s != null) samples.add(s);
    }
  }
  if (samples.isEmpty) {
    // Fallback: timed route points.
    for (final pt in root.descendantElements) {
      if (pt.localName != 'rtept') continue;
      final s = _point(pt);
      if (s != null) samples.add(s);
    }
  }
  if (samples.isEmpty) return const [];
  final meta = root.childElements.where((e) => e.localName == 'metadata');
  title ??= meta.isEmpty ? null : meta.first.childText('name');
  samples.sort((a, b) => a.time.compareTo(b.time));
  return [
    ParsedActivity(
      title: _clean(title),
      sport: sportFromString(type),
      samples: samples,
      format: 'gpx',
      sourceName: sourceName,
    )
  ];
}

String? _clean(String? s) {
  final t = s?.trim();
  return (t == null || t.isEmpty) ? null : t;
}

TrackSample? _point(XmlElement pt) {
  final lat = double.tryParse(pt.getAttribute('lat') ?? '');
  final lon = double.tryParse(pt.getAttribute('lon') ?? '');
  if (lat == null || lon == null) return null;
  DateTime? time;
  double? ele, speed;
  int? hr, cad;
  for (final c in pt.descendantElements) {
    switch (c.localName.toLowerCase()) {
      case 'time':
        time = DateTime.tryParse(c.innerText.trim())?.toUtc();
      case 'ele':
        ele = double.tryParse(c.innerText.trim());
      case 'hr':
      case 'heartrate':
        hr = double.tryParse(c.innerText.trim())?.round();
      case 'cad':
      case 'cadence':
        cad = double.tryParse(c.innerText.trim())?.round();
      case 'speed':
        speed = double.tryParse(c.innerText.trim());
    }
  }
  if (time == null) return null;
  return TrackSample(
    time: time,
    lat: lat,
    lon: lon,
    ele: ele,
    speedMps: speed,
    heartRate: hr,
    cadence: cad,
  );
}

/// GPX 1.1 with Garmin TrackPointExtension v1 (hr, cad). Paused samples are
/// dropped and each pause starts a new trkseg.
String buildGpx({
  required String title,
  required SportType sport,
  required List<TrackSample> samples,
  String? description,
}) {
  final b = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
    ..writeln('<gpx version="1.1" creator="Stravo Pro" '
        'xmlns="http://www.topografix.com/GPX/1/1" '
        'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
        'xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1" '
        'xsi:schemaLocation="http://www.topografix.com/GPX/1/1 '
        'http://www.topografix.com/GPX/1/1/gpx.xsd '
        'http://www.garmin.com/xmlschemas/TrackPointExtension/v1 '
        'http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd">')
    ..writeln(' <metadata>')
    ..writeln('  <name>${xmlEscape(title)}</name>');
  if (samples.isNotEmpty) {
    b.writeln('  <time>${isoUtc(samples.first.time)}</time>');
  }
  b
    ..writeln(' </metadata>')
    ..writeln(' <trk>')
    ..writeln('  <name>${xmlEscape(title)}</name>');
  if (description != null && description.isNotEmpty) {
    b.writeln('  <desc>${xmlEscape(description)}</desc>');
  }
  b.writeln('  <type>${stravaTypeName(sport)}</type>');
  var open = false;
  for (final s in samples) {
    if (s.paused) {
      if (open) {
        b.writeln('  </trkseg>');
        open = false;
      }
      continue;
    }
    if (!open) {
      b.writeln('  <trkseg>');
      open = true;
    }
    b.write('   <trkpt lat="${s.lat.toStringAsFixed(7)}" '
        'lon="${s.lon.toStringAsFixed(7)}">');
    if (s.ele != null) b.write('<ele>${s.ele!.toStringAsFixed(2)}</ele>');
    b.write('<time>${isoUtc(s.time)}</time>');
    if (s.heartRate != null || s.cadence != null) {
      b.write('<extensions><gpxtpx:TrackPointExtension>');
      if (s.heartRate != null) {
        b.write('<gpxtpx:hr>${s.heartRate}</gpxtpx:hr>');
      }
      if (s.cadence != null) b.write('<gpxtpx:cad>${s.cadence}</gpxtpx:cad>');
      b.write('</gpxtpx:TrackPointExtension></extensions>');
    }
    b.writeln('</trkpt>');
  }
  if (open) b.writeln('  </trkseg>');
  b
    ..writeln(' </trk>')
    ..writeln('</gpx>');
  return b.toString();
}
