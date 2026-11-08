/// Batas harian satu aplikasi.
class FocusLimit {
  final String packageName;
  final String label;
  final int dailyMinutes;
  final bool enabled;
  final DateTime createdAt;

  const FocusLimit({
    required this.packageName,
    required this.label,
    required this.dailyMinutes,
    required this.enabled,
    required this.createdAt,
  });

  /// Bentuk yang disimpan sisi Android untuk menegakkan batas.
  Map<String, Object?> toNative() => {
    'packageName': packageName,
    'label': label,
    'dailyMinutes': dailyMinutes,
    'enabled': enabled,
  };
}

/// Aplikasi terpasang yang bisa dipilih.
class FocusInstalledApp {
  final String packageName;
  final String label;

  const FocusInstalledApp({required this.packageName, required this.label});

  factory FocusInstalledApp.fromJson(Map<String, dynamic> j) =>
      FocusInstalledApp(
        packageName: j['packageName'] as String,
        label: j['label'] as String,
      );
}

/// Dua izin khusus yang dibutuhkan modul Fokus.
class FocusPermissions {
  final bool usageAccess;
  final bool accessibility;

  const FocusPermissions({
    required this.usageAccess,
    required this.accessibility,
  });

  static const none = FocusPermissions(
    usageAccess: false,
    accessibility: false,
  );

  bool get ready => usageAccess && accessibility;
}

/// Menit pemakaian satu aplikasi pada satu hari, hasil baca dari Android.
class FocusUsageRow {
  final String day;
  final String packageName;
  final int minutes;

  const FocusUsageRow({
    required this.day,
    required this.packageName,
    required this.minutes,
  });

  factory FocusUsageRow.fromJson(Map<String, dynamic> j) => FocusUsageRow(
    day: j['day'] as String,
    packageName: j['packageName'] as String,
    minutes: (j['minutes'] as num).toInt(),
  );
}

/// Hasil `readUsage`: riwayat pemakaian dan tambahan menit hari ini.
class FocusUsageRead {
  final List<FocusUsageRow> rows;

  /// packageName → menit tambahan yang sudah diambil hari ini.
  final Map<String, int> bonus;

  const FocusUsageRead({required this.rows, required this.bonus});

  static const empty = FocusUsageRead(rows: [], bonus: {});

  factory FocusUsageRead.fromJson(Map<String, dynamic> j) => FocusUsageRead(
    rows: [
      for (final e in j['rows'] as List<dynamic>)
        FocusUsageRow.fromJson(e as Map<String, dynamic>),
    ],
    bonus: {
      for (final e in (j['bonus'] as Map<String, dynamic>).entries)
        e.key: (e.value as num).toInt(),
    },
  );
}

/// Pemakaian satu aplikasi pada satu hari, dengan batas yang berlaku saat itu.
class FocusDayEntry {
  final String day;
  final String packageName;
  final String label;
  final int minutes;
  final int limitMinutes;

  const FocusDayEntry({
    required this.day,
    required this.packageName,
    required this.label,
    required this.minutes,
    required this.limitMinutes,
  });

  bool get isOver => minutes >= limitMinutes;
}

/// Status hari ini untuk kartu dan layar Fokus.
class FocusAppStatus {
  final FocusLimit limit;
  final int usedMinutes;
  final int bonusMinutes;

  const FocusAppStatus({
    required this.limit,
    required this.usedMinutes,
    required this.bonusMinutes,
  });

  int get allowedMinutes => limit.dailyMinutes + bonusMinutes;

  int get remainingMinutes =>
      usedMinutes >= allowedMinutes ? 0 : allowedMinutes - usedMinutes;

  bool get isOver => remainingMinutes == 0;

  /// Bagian kuota yang sudah terpakai, 0 sampai 1.
  double get fraction =>
      allowedMinutes <= 0 ? 1 : (usedMinutes / allowedMinutes).clamp(0.0, 1.0);
}
