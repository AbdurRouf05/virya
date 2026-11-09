import 'dart:convert';

/// Metadata pembaruan aplikasi Virya.
class AppUpdateInfo {
  final int versionCode;
  final String versionName;
  final String downloadUrl;
  final String changelog;
  final bool mandatory;
  final String? releaseDate;
  final int? fileSize;

  const AppUpdateInfo({
    required this.versionCode,
    required this.versionName,
    required this.downloadUrl,
    required this.changelog,
    this.mandatory = false,
    this.releaseDate,
    this.fileSize,
  });

  /// Parse dari Map JSON (mendukung format Gist, Raw JSON, maupun GitHub Release API).
  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    // 1. Cek jika format adalah GitHub Gist API response
    if (json.containsKey('files') && json['files'] is Map) {
      final files = json['files'] as Map<String, dynamic>;
      for (final entry in files.values) {
        if (entry is Map && entry.containsKey('content')) {
          try {
            final innerJson = jsonDecode(entry['content'] as String);
            if (innerJson is Map<String, dynamic>) {
              return AppUpdateInfo.fromJson(innerJson);
            }
          } catch (_) {
            // Lanjut cari file lain jika ada
          }
        }
      }
    }

    // 2. Cek jika format adalah GitHub Release API response
    if (json.containsKey('tag_name') && json.containsKey('assets')) {
      final tagName = (json['tag_name'] as String? ?? '').replaceFirst('v', '');
      final body = json['body'] as String? ?? 'Pembaruan versi terbaru.';
      String? apkUrl;
      int? size;

      final assets = json['assets'] as List<dynamic>? ?? [];
      for (final a in assets) {
        if (a is Map) {
          final name = (a['name'] as String? ?? '').toLowerCase();
          if (name.endsWith('.apk')) {
            apkUrl = a['browser_download_url'] as String?;
            size = a['size'] as int?;
            break;
          }
        }
      }

      // Hitung kode versi dari tag_name semver (e.g. 1.0.1 -> 10001)
      final parts = tagName.split('.').map((p) => int.tryParse(p) ?? 0).toList();
      var code = 1;
      if (parts.length >= 3) {
        code = parts[0] * 10000 + parts[1] * 100 + parts[2];
      } else if (parts.isNotEmpty) {
        code = parts[0];
      }

      return AppUpdateInfo(
        versionCode: code,
        versionName: tagName.isNotEmpty ? tagName : 'Terbaru',
        downloadUrl: apkUrl ?? '',
        changelog: body,
        mandatory: false,
        releaseDate: json['published_at'] as String?,
        fileSize: size,
      );
    }

    // 3. Format standar Raw JSON / Gist
    final rawCode = json['versionCode'] ??
        json['version_code'] ??
        json['buildNumber'] ??
        json['build_number'];
    final int code;
    if (rawCode is int) {
      code = rawCode;
    } else if (rawCode is String) {
      code = int.tryParse(rawCode) ?? 1;
    } else {
      code = 1;
    }

    final name = (json['versionName'] ??
            json['version_name'] ??
            json['version'] ??
            '1.0.0')
        .toString();

    final url = (json['downloadUrl'] ??
            json['download_url'] ??
            json['apkUrl'] ??
            json['apk_url'] ??
            json['url'] ??
            '')
        .toString();

    final notes = (json['changelog'] ??
            json['notes'] ??
            json['description'] ??
            json['body'] ??
            'Pembaruan performa dan perbaikan bug.')
        .toString();

    final isMandatory = json['mandatory'] == true || json['force'] == true;

    final date = (json['releaseDate'] ?? json['release_date'] ?? json['date'])
        ?.toString();

    final size = json['fileSize'] is int ? json['fileSize'] as int : null;

    return AppUpdateInfo(
      versionCode: code,
      versionName: name,
      downloadUrl: url,
      changelog: notes,
      mandatory: isMandatory,
      releaseDate: date,
      fileSize: size,
    );
  }

  Map<String, dynamic> toJson() => {
        'versionCode': versionCode,
        'versionName': versionName,
        'downloadUrl': downloadUrl,
        'changelog': changelog,
        'mandatory': mandatory,
        if (releaseDate != null) 'releaseDate': releaseDate,
        if (fileSize != null) 'fileSize': fileSize,
      };
}

/// Progress unduhan APK.
class UpdateDownloadProgress {
  final int bytesReceived;
  final int totalBytes;
  final double fraction;

  const UpdateDownloadProgress({
    required this.bytesReceived,
    required this.totalBytes,
    required this.fraction,
  });

  int get percent => (fraction * 100).clamp(0, 100).toInt();

  String get receivedMb => (bytesReceived / (1024 * 1024)).toStringAsFixed(1);
  String get totalMb => totalBytes > 0
      ? (totalBytes / (1024 * 1024)).toStringAsFixed(1)
      : '?';
}

