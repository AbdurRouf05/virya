import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tanggal lokal hari ini (jam 00:00). Berganti sendiri saat tengah malam
/// dan saat aplikasi kembali dibuka, sehingga layar "hari ini" tidak basi.
final currentDayProvider = StateNotifierProvider<CurrentDay, DateTime>(
  (ref) => CurrentDay(),
);

class CurrentDay extends StateNotifier<DateTime> with WidgetsBindingObserver {
  final DateTime Function() _clock;
  Timer? _timer;

  CurrentDay({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      super(_dayOf((clock ?? DateTime.now)())) {
    WidgetsBinding.instance.addObserver(this);
    _schedule();
  }

  static DateTime _dayOf(DateTime t) => DateTime(t.year, t.month, t.day);

  void _refresh() {
    final day = _dayOf(_clock());
    if (day != state) state = day;
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    final now = _clock();
    final next = DateTime(now.year, now.month, now.day + 1);
    _timer = Timer(next.difference(now) + const Duration(seconds: 1), _refresh);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
