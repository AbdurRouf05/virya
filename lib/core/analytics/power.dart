import 'dart:math' as math;

import 'package:stravo/core/constants/enums.dart';

/// Rolling resistance coefficient by surface.
double crrFor(SurfaceType s) => switch (s) {
      SurfaceType.asphalt => 0.005,
      SurfaceType.smoothGravel => 0.008,
      SurfaceType.roughGravel => 0.012,
      SurfaceType.dirt => 0.010,
      SurfaceType.cobblestone => 0.011,
      SurfaceType.unknown => 0.007,
    };

const double cdA = 0.40;
const double airDensity = 1.15;
const double drivetrainLoss = 0.03;
const double gravity = 9.80665;

/// Steady-state rider power (W) at [speed] m/s on [grade] (fraction):
/// P = (m·g·(sinθ + Crr·cosθ)·v + ½·ρ·CdA·v³) / (1 − loss), floored at 0.
double cyclingPowerW({
  required double speed,
  required double grade,
  required double massKg,
  required SurfaceType surface,
}) {
  if (speed <= 0) return 0;
  final theta = math.atan(grade);
  final fGrav = massKg * gravity * math.sin(theta);
  final fRoll = massKg * gravity * crrFor(surface) * math.cos(theta);
  final pAero = 0.5 * airDensity * cdA * speed * speed * speed;
  final p = ((fGrav + fRoll) * speed + pAero) / (1 - drivetrainLoss);
  return p < 0 ? 0 : p;
}
