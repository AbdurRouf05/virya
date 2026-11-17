import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/app/theme/app_theme.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/app/theme/native_style.dart';
import 'package:virya/app/theme/styles/styles.dart';
import 'package:virya/features/splash/presentation/entry_loading_screen.dart';
import 'package:virya/features/splash/presentation/look_gate.dart';

class ViryaApp extends ConsumerWidget {
  final Widget home;

  const ViryaApp({super.key, this.home = const EntryLoadingScreen()});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = resolveStyle(
      styleId: ref.watch(styleIdProvider),
      gaya: ref.watch(uiGayaProvider),
      mode: ref.watch(bersihModeProvider),
      platform: MediaQuery.platformBrightnessOf(context),
    );
    FN.use(style);
    pushNativeStyle(style);
    final icons = style.brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: icons,
        systemNavigationBarColor: FN.paper,
        systemNavigationBarIconBrightness: icons,
      ),
      // Banyak widget const membaca FN.*, jadi seluruh pohon harus dibangun
      // ulang saat style berganti. Kuncinya memaksa itu.
      child: MaterialApp(
        key: ValueKey(style.id),
        title: 'Virya',
        debugShowCheckedModeBanner: false,
        theme: FieldNotesTheme.paper,
        // Setelah gaya diganti dari layar pilih gaya, layar pembuka tidak
        // diputar ulang.
        home: ref.watch(skipEntryProvider) ? const LookGate() : home,
      ),
    );
  }
}
