import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:virya/app/theme/app_theme.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/home/presentation/home_shell.dart';

class ViryaApp extends StatelessWidget {
  const ViryaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: FN.paper,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: MaterialApp(
        title: 'Virya',
        debugShowCheckedModeBanner: false,
        theme: FieldNotesTheme.paper,
        home: const HomeShell(),
      ),
    );
  }
}
