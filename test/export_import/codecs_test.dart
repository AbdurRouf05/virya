import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stravo/core/constants/enums.dart';
import 'package:stravo/core/models/track_sample.dart';
import 'package:stravo/services/export_import/activity_importer.dart';
import 'package:stravo/services/export_import/fit_decoder.dart';
import 'package:stravo/services/export_import/gpx_codec.dart';
import 'package:stravo/services/export_import/strava_archive.dart';
import 'package:stravo/services/export_import/tcx_codec.dart';

import 'fit_test_encoder.dart';

List<TrackSample> sampleTrack(int n, {DateTime? start}) {
  final t0 = start ?? DateTime.utc(2026, 5, 3, 6, 30);
  return [
    for (var i = 0; i < n; i++)
      TrackSample(
        time: t0.add(Duration(seconds: i)),
        lat: -7.25 + i * 0.00005,
        lon: 112.75 + i * 0.00003,
        ele: 100 + i * 0.37 + (i.isEven ? 0.04 : 0),
        speedMps: 6.5,
        heartRate: 120 + i % 30,
        cadence: 80 + i % 10,
      ),
  ];
}

void main() {
  group('GPX / TCX round trip', () {
    final track = sampleTrack(150);

    test('GPX keeps points, times, elevation, HR', () {
      final xml = buildGpx(
          title: 'Pagi <Gravel> & kopi',
          sport: SportType.gravelCycling,
          samples: track);
      final parsed = parseGpx(xml);
      expect(parsed, hasLength(1));
      final a = parsed.single;
      expect(a.title, 'Pagi <Gravel> & kopi');
      expect(a.sport, SportType.gravelCycling);
      expect(a.samples, hasLength(track.length));
      for (var i = 0; i < track.length; i++) {
        final s = a.samples[i];
        expect(s.time, track[i].time);
        expect(s.ele!, closeTo(track[i].ele!, 0.1));
        expect(s.lat, closeTo(track[i].lat, 1e-6));
        expect(s.heartRate, track[i].heartRate);
        expect(s.cadence, track[i].cadence);
      }
    });

    test('TCX keeps points, times, elevation, HR, sport', () {
      final xml = buildTcx(
          title: 'Lari sore', sport: SportType.roadRunning, samples: track);
      final a = parseTcx(xml).single;
      expect(a.sport, SportType.roadRunning);
      expect(a.title, 'Lari sore');
      expect(a.samples, hasLength(track.length));
      for (var i = 0; i < track.length; i++) {
        expect(a.samples[i].time, track[i].time);
        expect(a.samples[i].ele!, closeTo(track[i].ele!, 0.1));
        expect(a.samples[i].heartRate, track[i].heartRate);
      }
    });

    test('GPX export drops paused points and parses multi-segment', () {
      final withPause = [
        for (var i = 0; i < track.length; i++)
          i >= 50 && i < 60 ? track[i].copyWith(paused: true) : track[i],
      ];
      final xml = buildGpx(
          title: 'x', sport: SportType.roadCycling, samples: withPause);
      expect('<trkseg>'.allMatches(xml).length, 2);
      expect(parseGpx(xml).single.samples, hasLength(140));
    });

    test('parseBytes sniffs content and handles gzip', () {
      final xml = buildGpx(
          title: 'gz', sport: SportType.hiking, samples: track);
      final gz = GZipEncoder().encodeBytes(utf8.encode(xml));
      final a = ActivityImporter.parseBytes(gz, 'ride.gpx.gz').single;
      expect(a.samples, hasLength(150));
      expect(a.sport, SportType.hiking);
      final b = ActivityImporter.parseBytes(
              Uint8List.fromList(utf8.encode(xml)), 'unknown.bin')
          .single;
      expect(b.format, 'gpx');
      expect(
          () => ActivityImporter.parseBytes(
              Uint8List.fromList(utf8.encode('hello')), 'x.txt'),
          throwsFormatException);
    });
  });

  group('FIT decoder', () {
    test('records, compressed timestamps, dev fields, session sport', () {
      final t0 = DateTime.utc(2026, 6, 1, 5, 0, 10);
      final bytes = buildTestFit(start: t0, fullRecords: 3, compressed: 40);
      expect(FitDecoder.looksLikeFit(bytes), isTrue);
      final a = FitDecoder().decode(bytes).single;
      expect(a.sport, SportType.gravelCycling);
      expect(a.samples, hasLength(43));
      for (var i = 0; i < 43; i++) {
        final s = a.samples[i];
        expect(s.time, t0.add(Duration(seconds: i)), reason: 'i=$i');
        expect(s.lat, closeTo(-7.25 + i * 1e-4, 1e-6));
        expect(s.lon, closeTo(112.75 + i * 1e-4, 1e-6));
      }
      // Full records carry alt/hr/speed.
      expect(a.samples[1].ele!, closeTo(101.2, 0.01));
      expect(a.samples[1].heartRate, 131);
      expect(a.samples[1].speedMps!, closeTo(7.25, 1e-9));
      // Compressed ones only position: alt invalid → null.
      expect(a.samples[10].ele, isNull);
    });

    test('truncated file keeps decoded part', () {
      final bytes = buildTestFit(
          start: DateTime.utc(2026, 1, 1), fullRecords: 20, compressed: 0);
      final cut = Uint8List.sublistView(bytes, 0, bytes.length - 40);
      final a = FitDecoder().decode(cut).single;
      expect(a.samples.length, inInclusiveRange(10, 19));
    });

    test('parseBytes routes .fit', () {
      final bytes = buildTestFit(
          start: DateTime.utc(2026, 1, 1), fullRecords: 5, compressed: 5);
      expect(ActivityImporter.parseBytes(bytes, 'a.FIT').single.samples,
          hasLength(10));
    });
  });

  group('Strava archive', () {
    test('zip with activities.csv, gz gpx and fit', () {
      final t1 = DateTime.utc(2026, 2, 1, 6);
      final gpx = buildGpx(
          title: 'from gpx',
          sport: SportType.roadCycling,
          samples: sampleTrack(30, start: t1));
      final fit = buildTestFit(
          start: DateTime.utc(2026, 2, 2, 6), fullRecords: 10, compressed: 0);
      const csv = 'Activity ID,Activity Date,Activity Name,Activity Type,'
          'Activity Description,Filename\n'
          '1,"Feb 1, 2026",Gowes "Bromo",Gravel Ride,,activities/1.gpx.gz\n'
          '2,"Feb 2, 2026",Jalan pagi,Walk,"multi\nline",activities/2.fit\n';
      final archive = Archive()
        ..addFile(ArchiveFile.string('activities.csv', csv))
        ..addFile(ArchiveFile.bytes('activities/1.gpx.gz',
            GZipEncoder().encodeBytes(utf8.encode(gpx))))
        ..addFile(ArchiveFile.bytes('activities/2.fit', fit))
        ..addFile(ArchiveFile.string('profile.csv', 'x'))
        ..addFile(ArchiveFile.string('activities/broken.gpx', '<gpx>'));
      final zip = ZipEncoder().encodeBytes(archive);
      final parsed = ActivityImporter.parseBytes(zip, 'export_123.zip');
      expect(parsed, hasLength(2));
      final byFormat = {for (final a in parsed) a.format: a};
      expect(byFormat['gpx']!.title, 'Gowes Bromo');
      expect(byFormat['gpx']!.sport, SportType.gravelCycling);
      expect(byFormat['gpx']!.samples, hasLength(30));
      expect(byFormat['fit']!.title, 'Jalan pagi');
      expect(byFormat['fit']!.sport, SportType.walking);
    });

    test('CSV parser handles quotes and newlines', () {
      final rows = parseCsv('a,"b,""c""",d\r\n1,"x\ny",3\n');
      expect(rows, [
        ['a', 'b,"c"', 'd'],
        ['1', 'x\ny', '3'],
      ]);
    });

    test('sport mapping', () {
      expect(sportFromString('GravelRide'), SportType.gravelCycling);
      expect(sportFromString('Mountain Bike Ride'), SportType.mountainBiking);
      expect(sportFromString('TrailRun'), SportType.trailRunning);
      expect(sportFromString('Run'), SportType.roadRunning);
      expect(sportFromString('Hike'), SportType.hiking);
      expect(sportFromString('Walk'), SportType.walking);
      expect(sportFromString('Ride'), SportType.roadCycling);
      expect(sportFromString('Biking'), SportType.roadCycling);
      expect(sportFromString('Swim'), isNull);
      expect(sportFromFit(2, 46), SportType.gravelCycling);
      expect(sportFromFit(2, 8), SportType.mountainBiking);
      expect(sportFromFit(1, 3), SportType.trailRunning);
      expect(sportFromFit(5, 0), isNull);
      for (final s in SportType.values) {
        expect(sportFromString(stravaTypeName(s)), s);
      }
    });
  });
}
