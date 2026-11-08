// Virya - Shared Enums
// Enum domain bersama untuk seluruh modul.

/// Jenis aktivitas olahraga yang didukung Virya. Semua GPS kecuali [strength]
/// (sesi gym; data set ada di tabel `workout_sets`).
enum SportType {
  gravelCycling,
  roadCycling,
  mountainBiking,
  roadRunning,
  trailRunning,
  hiking,
  walking,
  strength;

  /// Olahraga yang direkam lewat GPS (semua kecuali gym).
  static List<SportType> get gps =>
      values.where((s) => s.isGps).toList(growable: false);

  String get displayName {
    switch (this) {
      case SportType.gravelCycling:
        return 'Gravel Ride';
      case SportType.roadCycling:
        return 'Road Cycling';
      case SportType.mountainBiking:
        return 'Mountain Bike (MTB)';
      case SportType.roadRunning:
        return 'Road Run';
      case SportType.trailRunning:
        return 'Trail Run';
      case SportType.hiking:
        return 'Hike';
      case SportType.walking:
        return 'Walk';
      case SportType.strength:
        return 'Gym';
    }
  }

  bool get isCycling =>
      this == gravelCycling ||
      this == roadCycling ||
      this == mountainBiking;

  bool get isRunning => this == roadRunning || this == trailRunning;

  /// `false` untuk gym: tanpa rute, jarak, atau peta.
  bool get isGps => this != strength;
}

/// Klasifikasi getaran permukaan jalan (Deteksi Accelerometer & Sensor Fusion)
enum SurfaceType {
  asphalt,
  smoothGravel,
  roughGravel,
  dirt,
  cobblestone,
  unknown;

  String get label {
    switch (this) {
      case SurfaceType.asphalt:
        return 'Aspal Mulus';
      case SurfaceType.smoothGravel:
        return 'Gravel Halus';
      case SurfaceType.roughGravel:
        return 'Gravel Kasar / Makadam';
      case SurfaceType.dirt:
        return 'Tanah / Singletrack';
      case SurfaceType.cobblestone:
        return 'Batu Bata / Paving';
      case SurfaceType.unknown:
        return 'Tidak Teridentifikasi';
    }
  }
}

/// Kategori Tanjakan (Climb Gradient Index)
enum ClimbCategory {
  flat, // < 3%
  cat4, // 3% - 5%
  cat3, // 5% - 8%
  cat2, // 8% - 11%
  cat1, // 11% - 15%
  hc; // Hors Catégorie (> 15% atau tanjakan ekstrem)

  String get label {
    switch (this) {
      case ClimbCategory.flat:
        return 'Datar';
      case ClimbCategory.cat4:
        return 'Cat 4 (Ringan)';
      case ClimbCategory.cat3:
        return 'Cat 3 (Sedang)';
      case ClimbCategory.cat2:
        return 'Cat 2 (Berat)';
      case ClimbCategory.cat1:
        return 'Cat 1 (Sangat Berat)';
      case ClimbCategory.hc:
        return 'Hors Catégorie (Ekstrem)';
    }
  }
}
