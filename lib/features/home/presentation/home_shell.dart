import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stravo/app/integrations.dart';
import 'package:stravo/app/theme/app_theme.dart';
import 'package:stravo/app/theme/field_notes.dart';
import 'package:stravo/features/activity_history/presentation/journal_screen.dart';
import 'package:stravo/features/dashboard/presentation/stats_screen.dart';
import 'package:stravo/features/profile/presentation/profile_screen.dart';

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

class FieldNotesNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTab;
  final VoidCallback onRecord;

  const FieldNotesNavBar({
    super.key,
    required this.index,
    required this.onTab,
    required this.onRecord,
  });

  static const _tabs = ['JURNAL', 'STATISTIK', 'PETA', 'PROFIL'];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    Widget tab(int i) => Expanded(
          child: _NavTab(
            number: (i + 1).toString().padLeft(2, '0'),
            label: _tabs[i],
            selected: index == i,
            onTap: () => onTab(i),
          ),
        );
    return Container(
      decoration: const BoxDecoration(
        color: FN.paper,
        border: Border(top: BorderSide(color: FN.ink, width: 2)),
      ),
      padding: EdgeInsets.only(bottom: bottom),
      height: 64 + bottom,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          tab(0),
          tab(1),
          _RecordButton(onTap: onRecord),
          tab(2),
          tab(3),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final String number;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavTab({
    required this.number,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? FN.paper : FN.ink;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.fromLTRB(3, 6, 3, 6),
          color: selected ? FN.ink : Colors.transparent,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(number,
                  style: FN.label(
                      size: 9, color: selected ? FN.signal : FN.inkMuted)),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label,
                    style: FN.label(size: 10.5, color: fg)
                        .copyWith(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RecordButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Rekam aktivitas',
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 84,
          child: OverflowBox(
            maxHeight: 92,
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.fromLTRB(4, 0, 4, 8),
              decoration: const BoxDecoration(
                color: FN.signal,
                border: Border.fromBorderSide(
                    BorderSide(color: FN.ink, width: 2)),
                boxShadow: [BoxShadow(color: FN.ink, offset: Offset(3, 3))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: FN.ink,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                          color: FN.signal, shape: BoxShape.circle),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('REKAM',
                      style: TextStyle(
                          fontFamily: FN.display,
                          fontSize: 22,
                          height: 1,
                          color: FN.ink,
                          letterSpacing: 1)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
