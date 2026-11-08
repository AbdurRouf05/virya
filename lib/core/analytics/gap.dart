/// Grade Adjusted Pace (Minetti et al. 2002 energy cost of running).
///
/// C(i) = 155.4i^5 - 30.4i^4 - 43.3i^3 + 46.3i^2 + 19.5i + 3.6  [J/kg/m]
/// with i = grade fraction. GAP speed = speed * C(i) / C(0).
/// Grades are clamped to [-0.30, 0.30]; the downhill factor is floored at
/// 0.65 because Minetti overstates the downhill benefit for real runners.
double minettiCost(double grade) {
  final i = grade;
  final i2 = i * i;
  return 155.4 * i2 * i2 * i -
      30.4 * i2 * i2 -
      43.3 * i2 * i +
      46.3 * i2 +
      19.5 * i +
      3.6;
}

double gapFactor(double grade) {
  final g = grade < -0.30 ? -0.30 : (grade > 0.30 ? 0.30 : grade);
  final f = minettiCost(g) / 3.6;
  return f < 0.65 ? 0.65 : f;
}
