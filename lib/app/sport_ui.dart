import 'package:flutter/material.dart';
import 'package:virya/core/constants/enums.dart';

/// Indonesian labels and grouping for sports.
extension SportUi on SportType {
  String get label => switch (this) {
    SportType.gravelCycling => 'GRAVEL',
    SportType.roadCycling => 'SEPEDA JALAN',
    SportType.mountainBiking => 'MTB',
    SportType.roadRunning => 'LARI',
    SportType.trailRunning => 'LARI TRAIL',
    SportType.hiking => 'HIKING',
    SportType.walking => 'JALAN KAKI',
    SportType.strength => 'GYM',
  };

  IconData get icon => switch (this) {
    SportType.gravelCycling => Icons.pedal_bike,
    SportType.roadCycling => Icons.directions_bike,
    SportType.mountainBiking => Icons.terrain,
    SportType.roadRunning => Icons.directions_run,
    SportType.trailRunning => Icons.landscape,
    SportType.hiking => Icons.hiking,
    SportType.walking => Icons.directions_walk,
    SportType.strength => Icons.fitness_center,
  };

  SportGroup get group => isCycling
      ? SportGroup.cycling
      : isRunning
      ? SportGroup.running
      : isGps
      ? SportGroup.foot
      : SportGroup.strength;
}

enum SportGroup {
  cycling('SEPEDA'),
  running('LARI'),
  foot('JALAN & HIKING'),
  strength('GYM');

  final String label;
  const SportGroup(this.label);
}

SportType sportFromName(String name) => SportType.values.firstWhere(
  (s) => s.name == name,
  orElse: () => SportType.gravelCycling,
);

String climbCategoryShort(ClimbCategory c) => switch (c) {
  ClimbCategory.flat => '—',
  ClimbCategory.cat4 => '4',
  ClimbCategory.cat3 => '3',
  ClimbCategory.cat2 => '2',
  ClimbCategory.cat1 => '1',
  ClimbCategory.hc => 'HC',
};

String surfaceShort(SurfaceType s) => switch (s) {
  SurfaceType.asphalt => 'ASPAL',
  SurfaceType.smoothGravel => 'GRAVEL HALUS',
  SurfaceType.roughGravel => 'GRAVEL KASAR',
  SurfaceType.dirt => 'TANAH',
  SurfaceType.cobblestone => 'BATU',
  SurfaceType.unknown => '?',
};
