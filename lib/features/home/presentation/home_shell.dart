import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/integrations.dart';
import 'package:virya/app/theme/app_theme.dart';
import 'package:virya/features/activity_history/presentation/journal_screen.dart';
import 'package:virya/features/dashboard/presentation/stats_screen.dart';
import 'package:virya/features/home/presentation/widgets/home_nav_bar.dart';
import 'package:virya/features/profile/presentation/profile_screen.dart';

/// Root shell: JURNAL · STATISTIK · [REKAM] · PETA · PROFIL.
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
    Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => Theme(
        data: FieldNotesTheme.night,
        child: integ.recordingScreen(),
      ),
    ));
  }

  Widget _page(int i) {
    // Build lazily; keep alive once visited.
    if (!_built.contains(i)) return const SizedBox.shrink();
    return switch (i) {
      0 => const JournalScreen(),
      1 => const StatsScreen(),
      2 => ref.read(integrationsProvider).mapPacks(),
      _ => const ProfileScreen(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        onRecord: _openRecording,
      ),
    );
  }
}
