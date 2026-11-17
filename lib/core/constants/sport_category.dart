import 'package:virya/core/constants/enums.dart';

/// Kategori olahraga untuk kalender, filter, dan streak.
///
/// Satu kategori bisa berisi beberapa [SportType].
enum SportCategory {
  cycling('SEPEDA'),
  running('LARI'),
  walking('JALAN'),
  strength('GYM');

  final String label;
  const SportCategory(this.label);
}

/// Kategori dari jenis olahraga.
SportCategory categoryOf(SportType s) => switch (s) {
  SportType.gravelCycling ||
  SportType.roadCycling ||
  SportType.mountainBiking => SportCategory.cycling,
  SportType.roadRunning || SportType.trailRunning => SportCategory.running,
  SportType.hiking || SportType.walking => SportCategory.walking,
  SportType.strength => SportCategory.strength,
};
