/// Pose foto. Nama enum disimpan di database, jadi jangan diubah.
enum BodyPose {
  front('DEPAN'),
  side('SAMPING'),
  back('BELAKANG');

  final String label;
  const BodyPose(this.label);

  static BodyPose? parse(String name) {
    for (final p in values) {
      if (p.name == name) return p;
    }
    return null;
  }
}

/// Ukuran yang bisa dicatat, dengan batas wajar untuk validasi input.
enum BodyField {
  weightKg('Berat', 'kg', 20, 400),
  bodyFatPct('Lemak tubuh', '%', 1, 80),
  waistCm('Pinggang', 'cm', 30, 300),
  chestCm('Dada', 'cm', 30, 300),
  armCm('Lengan', 'cm', 10, 120);

  final String label;
  final String unit;
  final double min;
  final double max;
  const BodyField(this.label, this.unit, this.min, this.max);
}

/// Satu foto, dengan path absolut yang siap ditampilkan.
class BodyShot {
  final String id;
  final BodyPose pose;
  final String path;

  const BodyShot({required this.id, required this.pose, required this.path});
}

/// Satu check-in.
class BodyEntry {
  final String id;

  /// Tengah malam lokal.
  final DateTime day;
  final Map<BodyField, double> values;
  final String? note;
  final Map<BodyPose, BodyShot> shots;

  const BodyEntry({
    required this.id,
    required this.day,
    required this.values,
    required this.note,
    required this.shots,
  });

  double? get weightKg => values[BodyField.weightKg];
}

/// Titik pada grafik berat.
class BodyWeightPoint {
  final DateTime day;
  final double kg;

  const BodyWeightPoint(this.day, this.kg);
}

/// Satu frame timelapse: foto ke-[from] memudar menuju foto ke-[to].
class BodyTimelapseFrame {
  final int from;
  final int to;

  /// 0 = hanya foto [from], 1 = hanya foto [to].
  final double blend;

  const BodyTimelapseFrame(this.from, this.to, this.blend);
}
