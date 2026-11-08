import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stravo/app/theme/app_theme.dart';
import 'package:stravo/app/theme/field_notes.dart';
import 'package:stravo/features/home/presentation/home_shell.dart';

class StravoApp extends StatelessWidget {
  const StravoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: FN.paper,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: MaterialApp(
        title: 'Stravo Pro',
        debugShowCheckedModeBanner: false,
        theme: FieldNotesTheme.paper,
        home: const HomeShell(),
      ),
    );
  }
}
