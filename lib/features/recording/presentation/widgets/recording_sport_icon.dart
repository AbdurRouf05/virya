import 'package:flutter/material.dart';
import 'package:virya/core/constants/enums.dart';

/// Icon used for a sport on the recording screen.
IconData sportIcon(SportType s) => switch (s) {
      SportType.gravelCycling ||
      SportType.roadCycling ||
      SportType.mountainBiking =>
        Icons.directions_bike,
      SportType.roadRunning || SportType.trailRunning => Icons.directions_run,
      SportType.hiking => Icons.hiking,
      SportType.walking => Icons.directions_walk,
      SportType.strength => Icons.fitness_center,
    };
