import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/app/theme/app_theme.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/app/theme/native_style.dart';
import 'package:virya/app/theme/styles/styles.dart';
import 'package:virya/features/home/presentation/home_shell.dart';

class ViryaApp extends ConsumerWidget {
  final Widget home;

  const ViryaApp({super.key, this.home = const HomeShell()});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = styleById(ref.watch(styleIdProvider));
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
        home: home,
      ),
    );
  }
}
