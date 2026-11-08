import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/integrations.dart';
import 'package:virya/app/theme/app_theme.dart';
import 'package:virya/features/calendar/presentation/calendar_screen.dart';
import 'package:virya/features/home/presentation/widgets/home_nav_bar.dart';
import 'package:virya/features/home/presentation/widgets/start_sheet.dart';
import 'package:virya/features/profile/presentation/profile_screen.dart';
import 'package:virya/features/today/presentation/today_screen.dart';
import 'package:virya/features/training/presentation/training_screen.dart';

/// Root shell: HARI INI · KALENDER · [REKAM] · LATIHAN · PROFIL.
///
/// The centre button opens the quick-start sheet ("MAU NGAPAIN?"); from there
/// REKAM GPS opens the recording screen and MULAI GYM a strength session.
class HomeShell extends ConsumerStatefulWidget {
  final bool checkRecovery;
  const HomeShell({super.key, this.checkRecovery = true});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _tab = 0;
  final _built = <int>{0};

  @override
  void initState() {
    super.initState();
    if (widget.checkRecovery) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(integrationsProvider).checkRecovery(context, ref);
        }
      });
    }
  }

  void _openRecording() {
    final integ = ref.read(integrationsProvider);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) =>
            Theme(data: FieldNotesTheme.night, child: integ.recordingScreen()),
      ),
    );
  }

  void _openStartSheet() => showStartSheet(
    context,
    onRecordGps: _openRecording,
    onStartGym: () => ref.read(integrationsProvider).startGym(context, ref),
    onNewTask: () => ref.read(integrationsProvider).showQuickTask(context),
    onBodyCheckin: () =>
        ref.read(integrationsProvider).startBodyCheckin(context),
  );

  Widget _page(int i) {
    // Build lazily; keep alive once visited.
    if (!_built.contains(i)) return const SizedBox.shrink();
    return switch (i) {
      0 => TodayScreen(onStart: _openStartSheet),
      1 => const CalendarScreen(),
      2 => const TrainingScreen(),
      _ => const ProfileScreen(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final integ = ref.read(integrationsProvider);
    return integ.focusHost(
      child: integ.taskHost(
        child: Scaffold(
          body: IndexedStack(
            index: _tab,
            children: [for (var i = 0; i < 4; i++) _page(i)],
          ),
          bottomNavigationBar: FieldNotesNavBar(
            index: _tab,
            onTab: (i) => setState(() {
              _tab = i;
              _built.add(i);
            }),
            onRecord: _openStartSheet,
          ),
        ),
      ),
    );
  }
}
