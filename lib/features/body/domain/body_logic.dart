import 'package:virya/features/body/domain/body_models.dart';

/// Jarak antar check-in yang dianjurkan.
const bodyCheckinIntervalDays = 7;

/// Selisih hari kalender, kebal terhadap pergantian jam musim panas.
int bodyDaysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

/// Pengingat muncul bila check-in terakhir sudah lewat jadwalnya. Belum pernah
/// check-in berarti belum ada jadwal, jadi tidak diingatkan.
bool isBodyCheckinDue(Iterable<BodyEntry> entries, DateTime today) {
  if (entries.isEmpty) return false;
  final last = entries
      .map((e) => e.day)
      .reduce((a, b) => a.isAfter(b) ? a : b);
  return bodyDaysBetween(last, today) >= bodyCheckinIntervalDays;
}

/// Angka dari input pengguna. Koma diterima sebagai pemisah desimal.
/// Null bila kosong, tidak valid, atau di luar batas wajar [field].
double? parseBodyValue(BodyField field, String raw) {
  final v = double.tryParse(raw.trim().replaceAll(',', '.'));
  if (v == null || v.isNaN || v < field.min || v > field.max) return null;
  return v;
}

/// Berat dari yang terlama ke yang terbaru.
List<BodyWeightPoint> bodyWeightSeries(Iterable<BodyEntry> entries) {
  final out = [
    for (final e in entries)
      if (e.weightKg != null) BodyWeightPoint(e.day, e.weightKg!),
  ];
  out.sort((a, b) => a.day.compareTo(b.day));
  return out;
}

/// Check-in yang punya foto [pose], dari yang terlama ke yang terbaru.
List<BodyEntry> bodyEntriesWithPose(
  Iterable<BodyEntry> entries,
  BodyPose pose,
) {
  final out = entries.where((e) => e.shots.containsKey(pose)).toList();
  out.sort((a, b) => a.day.compareTo(b.day));
  return out;
}

/// Foto [pose] paling baru sebelum [day], untuk bayangan di kamera.
BodyShot? bodyPreviousShot(
  Iterable<BodyEntry> entries,
  BodyPose pose,
  DateTime day,
) {
  final earlier = bodyEntriesWithPose(
    entries,
    pose,
  ).where((e) => e.day.isBefore(day));
  return earlier.isEmpty ? null : earlier.last.shots[pose];
}

/// Path relatif berkas foto. Id foto ikut di nama berkas supaya foto yang
/// diambil ulang tidak tertukar dengan versi lama di cache gambar.
String bodyPhotoRelPath(String checkinId, BodyPose pose, String photoId) =>
    'photos/body/$checkinId/${pose.name}_$photoId.jpg';

/// Urutan frame: tiap foto ditahan [hold] frame, lalu memudar [fade] frame
/// menuju foto berikutnya. Foto terakhir ditahan dua kali lebih lama.
List<BodyTimelapseFrame> bodyTimelapseFrames(
  int photos, {
  int hold = 12,
  int fade = 4,
}) {
  if (photos <= 0) return const [];
  final out = <BodyTimelapseFrame>[];
  for (var i = 0; i < photos - 1; i++) {
    for (var h = 0; h < hold; h++) {
      out.add(BodyTimelapseFrame(i, i, 0));
    }
    for (var f = 1; f <= fade; f++) {
      out.add(BodyTimelapseFrame(i, i + 1, f / (fade + 1)));
    }
  }
  for (var h = 0; h < hold * 2; h++) {
    out.add(BodyTimelapseFrame(photos - 1, photos - 1, 0));
  }
  return out;
}
