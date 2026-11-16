import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/features/home/presentation/home_shell.dart';
import 'package:virya/features/splash/presentation/style_picker_screen.dart';

/// Tujuan setelah layar pembuka: layar pilih gaya bila pengguna belum pernah
/// memilih tampilan, selain itu langsung Beranda.
class LookGate extends ConsumerWidget {
  final Widget home;
  const LookGate({super.key, this.home = const HomeShell()});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pick = ref.watch(needsLookChoiceProvider);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child:
          pick
              ? const StylePickerScreen(key: ValueKey('pick'))
              : KeyedSubtree(key: const ValueKey('home'), child: home),
    );
  }
}
