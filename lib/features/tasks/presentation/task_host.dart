import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/features/tasks/application/task_inbox_sync.dart';
import 'package:virya/features/tasks/data/task_bridge.dart';
import 'package:virya/features/tasks/data/task_providers.dart';
import 'package:virya/features/tasks/domain/task_logic.dart';
import 'package:virya/features/tasks/domain/task_models.dart';
import 'package:virya/features/tasks/presentation/widgets/task_quick_add_sheet.dart';

/// Menghubungkan modul tugas dengan sisi Android selama shell hidup:
/// menguras antrean native, mengirim data ke widget, dan membuka catat cepat
/// saat aplikasi diluncurkan dari ubin, pintasan, atau tombol widget.
class TaskHost extends ConsumerStatefulWidget {
  final Widget child;
  const TaskHost({super.key, required this.child});

  @override
  ConsumerState<TaskHost> createState() => _TaskHostState();
}

class _TaskHostState extends ConsumerState<TaskHost>
    with WidgetsBindingObserver {
  late final TaskBridge _bridge = ref.read(taskBridgeProvider);
  bool _sheetOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bridge.listen(_sync);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _sync();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bridge.listen(null);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _sync();
  }

  Future<void> _sync() async {
    try {
      await ref.read(taskInboxSyncProvider).drain();
      final action = await _bridge.takeLaunchAction();
      if (action == 'quick_task' && mounted) await _openQuickAdd();
    } catch (e) {
      debugPrint('Sinkron tugas gagal: $e');
    }
  }

  Future<void> _openQuickAdd() async {
    if (_sheetOpen) return;
    _sheetOpen = true;
    try {
      await showQuickAddTask(context);
    } finally {
      _sheetOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<TaskItem>>>(openTasksProvider, (_, next) {
      final open = next.valueOrNull;
      if (open != null) _bridge.pushSnapshot(taskWidgetSnapshot(open));
    });
    return widget.child;
  }
}
