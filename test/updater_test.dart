import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/updater/update_model.dart';
import 'package:virya/core/updater/update_service.dart';

void main() {
  group('AppUpdateInfo & UpdateService Tests', () {
    test('Parse format Raw JSON Gist standar', () {
      final json = {
        'versionCode': 3,
        'versionName': '1.0.2',
        'downloadUrl': 'https://github.com/AbdurRouf05/virya/releases/download/v1.0.2/app-release.apk',
        'changelog': '• Perbaikan audio tts\n• Optimasi performa UI',
        'mandatory': true,
        'releaseDate': '2026-11-10',
        'fileSize': 65000000,
      };

      final info = AppUpdateInfo.fromJson(json);

      expect(info.versionCode, 3);
      expect(info.versionName, '1.0.2');
      expect(info.downloadUrl, contains('v1.0.2/app-release.apk'));
      expect(info.changelog, contains('audio tts'));
      expect(info.mandatory, isTrue);
      expect(info.releaseDate, '2026-11-10');
      expect(info.fileSize, 65000000);
    });

    test('Parse format alternatif (snake_case dan alias field)', () {
      final json = {
        'version_code': '4',
        'version_name': '1.1.0',
        'apk_url': 'https://example.com/virya.apk',
        'notes': 'Fitur auto backup cloud',
        'force': true,
      };

      final info = AppUpdateInfo.fromJson(json);

      expect(info.versionCode, 4);
      expect(info.versionName, '1.1.0');
      expect(info.downloadUrl, 'https://example.com/virya.apk');
      expect(info.changelog, 'Fitur auto backup cloud');
      expect(info.mandatory, isTrue);
    });

    test('Parse format GitHub Gist API dengan embedded files content', () {
      final innerContent = jsonEncode({
        'versionCode': 5,
        'versionName': '1.2.0',
        'downloadUrl': 'https://gist.github.com/download/app.apk',
        'changelog': 'Pembaruan dari Gist',
      });

      final gistApiResponse = {
        'files': {
          'version.json': {
            'content': innerContent,
          }
        }
      };

      final info = AppUpdateInfo.fromJson(gistApiResponse);

      expect(info.versionCode, 5);
      expect(info.versionName, '1.2.0');
      expect(info.downloadUrl, 'https://gist.github.com/download/app.apk');
      expect(info.changelog, 'Pembaruan dari Gist');
    });

    test('Parse format GitHub Releases API response', () {
      final releaseApiResponse = {
        'tag_name': 'v1.0.3',
        'body': 'Catatan rilis langsung dari tag GitHub Releases.',
        'published_at': '2026-11-09T18:00:00Z',
        'assets': [
          {
            'name': 'source_code.zip',
            'browser_download_url': 'https://github.com/src.zip',
          },
          {
            'name': 'virya-release.apk',
            'size': 68500000,
            'browser_download_url': 'https://github.com/virya-release.apk',
          }
        ]
      };

      final info = AppUpdateInfo.fromJson(releaseApiResponse);

      expect(info.versionName, '1.0.3');
      expect(info.versionCode, 10003);
      expect(info.downloadUrl, 'https://github.com/virya-release.apk');
      expect(info.changelog, contains('Catatan rilis'));
      expect(info.fileSize, 68500000);
    });

    test('UpdateDownloadProgress menghitung persentase dan format MB dengan tepat', () {
      const p1 = UpdateDownloadProgress(
        bytesReceived: 35 * 1024 * 1024,
        totalBytes: 70 * 1024 * 1024,
        fraction: 0.5,
      );

      expect(p1.percent, 50);
      expect(p1.receivedMb, '35.0');
      expect(p1.totalMb, '70.0');

      const p2 = UpdateDownloadProgress(
        bytesReceived: 10 * 1024 * 1024,
        totalBytes: -1,
        fraction: 0.0,
      );

      expect(p2.percent, 0);
      expect(p2.receivedMb, '10.0');
      expect(p2.totalMb, '?');
    });

    test('normalizeUpdateUri mengubah URL web Gist ke URL Gist API', () {
      final webGist = 'https://gist.github.com/AbdurRouf05/9a8b7c6d5e4f3a2b1';
      final normalized = UpdateService.normalizeUpdateUri(webGist);

      expect(
        normalized.toString(),
        'https://api.github.com/gists/9a8b7c6d5e4f3a2b1',
      );

      final rawGist = 'https://gist.githubusercontent.com/raw/9a8b/version.json';
      expect(
        UpdateService.normalizeUpdateUri(rawGist).toString(),
        rawGist,
      );
    });
  });
}
