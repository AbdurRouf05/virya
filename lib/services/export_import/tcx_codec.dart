import 'package:virya/core/analytics/geo.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/models/track_sample.dart';
import 'package:virya/services/export_import/parsed_activity.dart';
import 'package:virya/services/export_import/xml_util.dart';
import 'package:xml/xml.dart';

/// Parse Garmin TCX v2. One [ParsedActivity] per `Activity` element.
/// Trackpoints without a position are skipped.
List<ParsedActivity> parseTcx(String text, {String? sourceName}) {
  if (text.contains('<!DOCTYPE') || text.contains('<!ENTITY')) {
    throw const FormatException('XML dengan DTD/entitas eksternal tidak diizinkan');
  }
  final doc = XmlDocument.parse(text);
  final out = <ParsedActivity>[];
  for (final act in doc.rootElement.descendantElements) {
    if (act.localName != 'Activity') continue;
    final samples = <TrackSample>[];
    for (final tp in act.descendantElements) {
      if (tp.localName != 'Trackpoint') continue;
      final s = _trackpoint(tp);
      if (s != null) samples.add(s);
    }
    if (samples.isEmpty) continue;
    samples.sort((a, b) => a.time.compareTo(b.time));
    final notes = act.childText('Notes')?.trim();
    out.add(ParsedActivity(
      title: (notes == null || notes.isEmpty) ? null : notes,
      sport: sportFromString(act.getAttribute('Sport')),
      samples: samples,
      format: 'tcx',
      sourceName: sourceName,
    ));
  }
  return out;
}

TrackSample? _trackpoint(XmlElement tp) {
  DateTime? time;
  double? lat, lon, ele, speed;
  int? hr, cad;
  for (final c in tp.descendantElements) {
    final txt = c.childElements.isEmpty ? c.innerText.trim() : null;
    switch (c.localName) {
      case 'Time':
        time = DateTime.tryParse(txt ?? '')?.toUtc();
      case 'LatitudeDegrees':
        lat = double.tryParse(txt ?? '');
      case 'LongitudeDegrees':
        lon = double.tryParse(txt ?? '');
      case 'AltitudeMeters':
        ele = double.tryParse(txt ?? '');
      case 'Value':
        if (c.parentElement?.localName == 'HeartRateBpm') {
          hr = double.tryParse(txt ?? '')?.round();
        }
      case 'Cadence':
      case 'RunCadence':
        cad = double.tryParse(txt ?? '')?.round();
      case 'Speed':
        speed = double.tryParse(txt ?? '');
    }
  }
  if (time == null || lat == null || lon == null) return null;
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

String tcxSport(SportType s) {
  if (s.isCycling) return 'Biking';
  if (s.isRunning) return 'Running';
  return 'Other';
}

/// TCX v2 with a single lap; paused samples are dropped.
String buildTcx({
  required String title,
  required SportType sport,
  required List<TrackSample> samples,
}) {
  final pts = samples.where((s) => !s.paused).toList();
  final dist = List<double>.filled(pts.length, 0);
  var maxSpeed = 0.0;
  for (var i = 1; i < pts.length; i++) {
    dist[i] = dist[i - 1] +
        haversineM(pts[i - 1].lat, pts[i - 1].lon, pts[i].lat, pts[i].lon);
  }
  for (final p in pts) {
    if ((p.speedMps ?? 0) > maxSpeed) maxSpeed = p.speedMps!;
  }
  final start = samples.isEmpty ? DateTime.now() : samples.first.time;
  final total = samples.isEmpty
      ? 0
      : samples.last.time.difference(samples.first.time).inSeconds;
  final running = sport.isRunning;
  final b = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
    ..writeln('<TrainingCenterDatabase '
        'xmlns="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2" '
        'xmlns:ns3="http://www.garmin.com/xmlschemas/ActivityExtension/v2" '
        'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
        'xsi:schemaLocation="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2 '
        'http://www.garmin.com/xmlschemas/TrainingCenterDatabasev2.xsd">')
    ..writeln(' <Activities>')
    ..writeln('  <Activity Sport="${tcxSport(sport)}">')
    ..writeln('   <Id>${isoUtc(start)}</Id>')
    ..writeln('   <Lap StartTime="${isoUtc(start)}">')
    ..writeln('    <TotalTimeSeconds>$total</TotalTimeSeconds>')
    ..writeln('    <DistanceMeters>'
        '${(dist.isEmpty ? 0 : dist.last).toStringAsFixed(1)}</DistanceMeters>')
    ..writeln('    <MaximumSpeed>${maxSpeed.toStringAsFixed(2)}</MaximumSpeed>')
    ..writeln('    <Calories>0</Calories>')
    ..writeln('    <Intensity>Active</Intensity>')
    ..writeln('    <TriggerMethod>Manual</TriggerMethod>')
    ..writeln('    <Track>');
  for (var i = 0; i < pts.length; i++) {
    final s = pts[i];
    b.write('     <Trackpoint><Time>${isoUtc(s.time)}</Time>'
        '<Position><LatitudeDegrees>${s.lat.toStringAsFixed(7)}</LatitudeDegrees>'
        '<LongitudeDegrees>${s.lon.toStringAsFixed(7)}</LongitudeDegrees></Position>');
    if (s.ele != null) {
      b.write('<AltitudeMeters>${s.ele!.toStringAsFixed(2)}</AltitudeMeters>');
    }
    b.write('<DistanceMeters>${dist[i].toStringAsFixed(2)}</DistanceMeters>');
    if (s.heartRate != null) {
      b.write('<HeartRateBpm><Value>${s.heartRate}</Value></HeartRateBpm>');
    }
    if (s.cadence != null && !running) b.write('<Cadence>${s.cadence}</Cadence>');
    if (s.speedMps != null || (s.cadence != null && running)) {
      b.write('<Extensions><ns3:TPX>');
      if (s.speedMps != null) {
        b.write('<ns3:Speed>${s.speedMps!.toStringAsFixed(2)}</ns3:Speed>');
      }
      if (s.cadence != null && running) {
        b.write('<ns3:RunCadence>${s.cadence}</ns3:RunCadence>');
      }
      b.write('</ns3:TPX></Extensions>');
    }
    b.writeln('</Trackpoint>');
  }
  b
    ..writeln('    </Track>')
    ..writeln('   </Lap>')
    ..writeln('   <Notes>${xmlEscape(title)}</Notes>')
    ..writeln('   <Creator xsi:type="Device_t"><Name>Virya</Name>'
        '<UnitId>0</UnitId><ProductID>0</ProductID>'
        '<Version><VersionMajor>2</VersionMajor><VersionMinor>0</VersionMinor>'
        '</Version></Creator>')
    ..writeln('  </Activity>')
    ..writeln(' </Activities>')
    ..writeln('</TrainingCenterDatabase>');
  return b.toString();
}
