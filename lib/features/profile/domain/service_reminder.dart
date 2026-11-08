/// Service reminder stored in AppSettings as "intervalKm|lastServiceKm".
class ServiceReminder {
  final double intervalKm;
  final double lastServiceKm;
  const ServiceReminder(this.intervalKm, this.lastServiceKm);

  static ServiceReminder? parse(String? raw) {
    if (raw == null) return null;
    final p = raw.split('|');
    if (p.length != 2) return null;
    final i = double.tryParse(p[0]), l = double.tryParse(p[1]);
    if (i == null || l == null || i <= 0) return null;
    return ServiceReminder(i, l);
  }

  String encode() => '$intervalKm|$lastServiceKm';
  double remainingKm(double totalKm) => intervalKm - (totalKm - lastServiceKm);
}
