import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/integrations.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/features/activity_history/presentation/journal_screen.dart';
import 'package:virya/features/dashboard/presentation/stats_screen.dart';
import 'package:virya/features/training/presentation/widgets/training_switch.dart';

/// "LATIHAN": saklar JURNAL · STATISTIK · GYM di atas, isi layar di bawahnya.
/// GYM datang dari modul gym lewat [Integrations.gymHome].
///
/// Saklar menggantikan judul besar; halaman di bawahnya tampil `embedded`
/// (masthead tanpa judul). SafeArea luar sudah memakan padding atas, jadi SafeArea di dalam
/// halaman tidak menambah jarak ganda.
class TrainingScreen extends ConsumerStatefulWidget {
  const TrainingScreen({super.key});

  @override
  ConsumerState<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends ConsumerState<TrainingScreen> {
  static const _labels = ['JURNAL', 'STATISTIK', 'GYM'];
  int _index = 0;
  final _built = <int>{0};

  Widget _page(int i) {
    if (!_built.contains(i)) return const SizedBox.shrink();
    return switch (i) {
      0 => const JournalScreen(embedded: true),
      1 => const StatsScreen(embedded: true),
      _ => ref.watch(integrationsProvider).gymHome(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: FN.paper,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: TrainingSwitch(
                labels: _labels,
                index: _index,
                onChanged: (i) => setState(() {
                  _index = i;
                  _built.add(i);
                }),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _index,
                children: [for (var i = 0; i < _labels.length; i++) _page(i)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
