import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/features/focus/data/focus_providers.dart';
import 'package:virya/features/focus/domain/focus_models.dart';

/// Menjaga data Fokus tetap baru selama shell hidup: mengirim batas ke
/// Android dan menyalin pemakaian ke riwayat, setiap menit saat aplikasi aktif.
class FocusHost extends ConsumerStatefulWidget {
  final Widget child;
  const FocusHost({super.key, required this.child});

  @override
  ConsumerState<FocusHost> createState() => _FocusHostState();
}

class _FocusHostState extends ConsumerState<FocusHost>
    with WidgetsBindingObserver {
  static const _interval = Duration(seconds: 60);

  late final bool _supported = ref.read(focusSupportedProvider);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (!_supported) return;
    WidgetsBinding.instance.addObserver(this);
    final state = WidgetsBinding.instance.lifecycleState;
    if (state == null || state == AppLifecycleState.resumed) _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _sync();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_supported) WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        ref.invalidate(focusPermissionsProvider);
        _sync();
        _startTimer();
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _timer?.cancel();
        _timer = null;
      case AppLifecycleState.inactive:
        break;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) => _sync());
  }

  Future<void> _sync() async {
    try {
      final bonus = await ref.read(focusRepositoryProvider).sync();
      if (mounted) ref.read(focusBonusProvider.notifier).state = bonus;
    } catch (e) {
      debugPrint('Sinkron fokus gagal: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_supported) return widget.child;
    // sync() sudah mengirim batas ke Android sebelum membaca pemakaian.
    ref.listen<AsyncValue<List<FocusLimit>>>(focusLimitsProvider, (_, next) {
      if (next.hasValue) _sync();
    });
    return widget.child;
  }
}
