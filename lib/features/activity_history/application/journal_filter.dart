import 'package:virya/app/sport_ui.dart';
import 'package:virya/core/constants/enums.dart';

/// Sport filter chips on the journal.
enum JournalFilter {
  all('SEMUA'),
  gravel('GRAVEL'),
  cycling('SEPEDA'),
  running('LARI'),
  foot('JALAN & HIKING'),
  gym('GYM');

  final String label;
  const JournalFilter(this.label);

  bool matches(SportType s) => switch (this) {
    JournalFilter.all => true,
    JournalFilter.gravel => s == SportType.gravelCycling,
    JournalFilter.cycling => s.isCycling,
    JournalFilter.running => s.isRunning,
    JournalFilter.foot => s.group == SportGroup.foot,
    JournalFilter.gym => !s.isGps,
  };
}
