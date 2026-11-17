import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:virya/core/updater/update_model.dart';

/// Layanan pemeriksaan dan pengunduhan pembaruan aplikasi Virya.
class UpdateService {
  static const MethodChannel _channel =
      MethodChannel('com.abdurrouf.virya/updater');

  /// URL default untuk memeriksa pembaruan (raw JSON di repo Virya).
  static const String defaultUpdateUrl =
      'https://raw.githubusercontent.com/AbdurRouf05/virya/main/version.json';

  /// Informasi aplikasi yang terpasang saat ini.
  static Future<({String versionName, int versionCode, String packageName})>
      getLocalAppInfo() async {
    if (!Platform.isAndroid) {
      return (versionName: '1.0.0', versionCode: 1, packageName: 'com.abdurrouf.virya');
    }
    try {
      final info = await _channel.invokeMapMethod<String, dynamic>('getAppInfo');
      if (info != null) {
        final vName = (info['versionName'] ?? '1.0.0').toString();
        final rawCode = info['versionCode'];
        final vCode = rawCode is int
            ? rawCode
            : (int.tryParse(rawCode?.toString() ?? '') ?? 1);
        final pkg = (info['packageName'] ?? 'com.abdurrouf.virya').toString();
        return (versionName: vName, versionCode: vCode, packageName: pkg);
      }
    } catch (e) {
      debugPrint('UpdateService: Gagal mendapatkan info aplikasi lokal: $e');
    }
    return (versionName: '1.0.0', versionCode: 1, packageName: 'com.abdurrouf.virya');
  }

  /// Normalisasi URL jika pengguna memasukkan link web Gist biasa.
  static Uri normalizeUpdateUri(String inputUrl) {
    var trimmed = inputUrl.trim();
    if (trimmed.isEmpty) trimmed = defaultUpdateUrl;

    final uri = Uri.parse(trimmed);

    // Jika format https://gist.github.com/{user}/{gist_id} tanpa /raw/
    if (uri.host == 'gist.github.com' && !uri.path.contains('/raw')) {
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.isNotEmpty) {
        final gistId = segments.last;
        return Uri.parse('https://api.github.com/gists/$gistId');
      }
    }

    return uri;
  }

  /// Memeriksa apakah ada versi baru yang tersedia.
  /// Mengembalikan [AppUpdateInfo] jika ada versi baru, atau `null` jika sudah terbaru.
  static Future<AppUpdateInfo?> checkForUpdate({String? updateUrl}) async {
    final targetUri = normalizeUpdateUri(updateUrl ?? defaultUpdateUrl);
    final localInfo = await getLocalAppInfo();

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 12);
    try {
      final request = await client.getUrl(targetUri);
      request.headers.set(HttpHeaders.userAgentHeader, 'ViryaApp/AutoUpdater');
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'Gagal memeriksa pembaruan: HTTP ${response.statusCode}',
          uri: targetUri,
        );
      }

      final body = await response.transform(utf8.decoder).join();
      final dynamic decoded = jsonDecode(body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Format respons pembaruan tidak valid');
      }

      final remoteInfo = AppUpdateInfo.fromJson(decoded);

      debugPrint(
        'UpdateService: Versi lokal=${localInfo.versionCode} (${localInfo.versionName}), '
        'Remote=${remoteInfo.versionCode} (${remoteInfo.versionName})',
      );

      if (remoteInfo.versionCode > localInfo.versionCode) {
        return remoteInfo;
      }

      return null;
    } finally {
      client.close();
    }
  }

  /// Memeriksa izin install paket dari sumber tak dikenal (Android 8.0+).
  static Future<bool> canRequestPackageInstalls() async {
    if (!Platform.isAndroid) return false;
    try {
      final granted =
          await _channel.invokeMethod<bool>('canRequestPackageInstalls');
      return granted ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Membuka halaman pengaturan sistem untuk mengizinkan instalasi APK Virya.
  static Future<void> openInstallPermissionSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('openInstallPermissionSettings');
    } catch (e) {
      debugPrint('UpdateService: Gagal membuka pengaturan izin install: $e');
    }
  }

  /// Mengunduh APK pembaruan dengan streaming progress.
  static Stream<UpdateDownloadProgress> downloadApk(
    String downloadUrl, {
    required void Function(String filePath) onComplete,
    void Function(Object error)? onError,
  }) {
    final controller = StreamController<UpdateDownloadProgress>();

    () async {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 15)
        ..idleTimeout = const Duration(seconds: 30);

      IOSink? fileSink;
      try {
        final tempDir = await getTemporaryDirectory();
        final updateDir = Directory(p.join(tempDir.path, 'updates'));
        if (!updateDir.existsSync()) {
          updateDir.createSync(recursive: true);
        }

        final targetFile = File(p.join(updateDir.path, 'virya_update.apk'));
        if (targetFile.existsSync()) {
          try {
            targetFile.deleteSync();
          } catch (_) {}
        }

        var currentUri = Uri.parse(downloadUrl.trim());
        HttpClientResponse? response;
        var redirects = 0;

        // Tangani redirect HTTP (e.g. GitHub Releases -> AWS/CDN)
        while (redirects < 6) {
          final request = await client.getUrl(currentUri);
          request.followRedirects = false;
          request.headers.set(HttpHeaders.userAgentHeader, 'ViryaApp/AutoUpdater');

          response = await request.close();

          if (response.isRedirect) {
            final location = response.headers.value(HttpHeaders.locationHeader);
            if (location == null) {
              throw const HttpException('Redirect tanpa header Location');
            }
            currentUri = currentUri.resolve(location);
            redirects++;
            continue;
          }
          break;
        }

        if (response == null || response.statusCode != HttpStatus.ok) {
          throw HttpException(
            'Gagal mengunduh APK: HTTP ${response?.statusCode}',
            uri: currentUri,
          );
        }

        final totalBytes = response.contentLength;
        var receivedBytes = 0;

        fileSink = targetFile.openWrite();

        await for (final chunk in response) {
          fileSink.add(chunk);
          receivedBytes += chunk.length;

          final fraction = totalBytes > 0
              ? (receivedBytes / totalBytes).clamp(0.0, 1.0)
              : 0.0;

          controller.add(UpdateDownloadProgress(
            bytesReceived: receivedBytes,
            totalBytes: totalBytes,
            fraction: fraction,
          ));
        }

        await fileSink.flush();
        await fileSink.close();
        fileSink = null;

        await controller.close();
        onComplete(targetFile.path);
      } catch (e) {
        await fileSink?.close();
        if (!controller.isClosed) {
          controller.addError(e);
          await controller.close();
        }
        onError?.call(e);
      } finally {
        client.close();
      }
    }();

    return controller.stream;
  }

  /// Menjalankan PackageInstaller bawaan Android untuk memasang APK yang telah diunduh.
  static Future<bool> installApk(String filePath) async {
    if (!Platform.isAndroid) return false;
    try {
      final success = await _channel.invokeMethod<bool>('installApk', {
        'filePath': filePath,
      });
      return success ?? false;
    } catch (e) {
      debugPrint('UpdateService: Gagal memicu install APK: $e');
      rethrow;
    }
  }
}

