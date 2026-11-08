import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Detak 1 detik untuk durasi sesi & timer istirahat.
final gymClockProvider = StreamProvider.autoDispose<DateTime>(
  (ref) => Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
);
