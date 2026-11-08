import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/widgets/paper_background.dart';
import 'package:virya/features/activity_history/presentation/journal_screen.dart';
import 'package:virya/features/dashboard/presentation/stats_screen.dart';

/// "LATIHAN" hub — unifies activity history (Journal) and analytics (Stats),
/// with slot ready for Gym workout templates in Phase 4.
class TrainingScreen extends StatefulWidget {
  final int initialSubTab;
  const TrainingScreen({super.key, this.initialSubTab = 0});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  late int _subTab;

  @override
  void initState() {
    super.initState();
    _subTab = widget.initialSubTab;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaperBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Sub-navigation bar
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                decoration: BoxDecoration(
                  color: FN.paper,
                  border: Border.all(color: FN.ink, width: 1.5),
                ),
                child: Row(
                  children: [
                    _subTabButton(0, 'JURNAL RIWAYAT'),
                    Container(width: 1.5, height: 36, color: FN.ink),
                    _subTabButton(1, 'STATISTIK & BEBAN'),
                  ],
                ),
              ),
              Expanded(
                child: IndexedStack(
                  index: _subTab,
                  children: const [
                    JournalScreen(),
                    StatsScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _subTabButton(int index, String label) {
    final active = _subTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _subTab = index),
        child: Container(
          height: 36,
          color: active ? FN.ink : Colors.transparent,
          alignment: Alignment.center,
          child: Text(
            label,
            style: FN.label(size: 11, color: active ? FN.paper : FN.ink).copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}

