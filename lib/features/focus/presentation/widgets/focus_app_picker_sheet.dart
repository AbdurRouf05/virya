import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/focus/data/focus_providers.dart';
import 'package:virya/features/focus/domain/focus_models.dart';

/// Pilih satu aplikasi yang belum dibatasi. Null bila dibatalkan.
Future<FocusInstalledApp?> showFocusAppPicker(BuildContext context) =>
    showModalBottomSheet<FocusInstalledApp>(
      context: context,
      backgroundColor: FN.paper,
      shape: const RoundedRectangleBorder(),
      isScrollControlled: true,
      builder: (_) => const FocusAppPickerSheet(),
    );

class FocusAppPickerSheet extends ConsumerStatefulWidget {
  const FocusAppPickerSheet({super.key});

  @override
  ConsumerState<FocusAppPickerSheet> createState() => _State();
}

class _State extends ConsumerState<FocusAppPickerSheet> {
  String _query = '';

  Widget _message(String text) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontFamily: FN.sans, fontSize: 14, color: FN.inkMuted),
      ),
    ),
  );

  Widget _list(List<FocusInstalledApp> apps) {
    final limited = {
      for (final l in ref.watch(focusLimitsProvider).valueOrNull ?? const [])
        l.packageName,
    };
    final available = apps.where((a) => !limited.contains(a.packageName));
    if (available.isEmpty) return _message('Tidak ada aplikasi yang bisa dipilih.');
    final q = _query.trim().toLowerCase();
    final shown = available
        .where((a) => a.label.toLowerCase().contains(q))
        .toList()
      ..sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
    if (shown.isEmpty) return _message('Tidak ada aplikasi bernama itu.');
    return ListView.separated(
      itemCount: shown.length,
      separatorBuilder: (_, _) => Container(height: 1, color: FN.paperLine),
      itemBuilder: (context, i) => InkWell(
        onTap: () => Navigator.pop(context, shown[i]),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Text(
            shown[i].label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontFamily: FN.sans, fontSize: 15, color: FN.ink),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apps = ref.watch(focusInstalledAppsProvider);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.8,
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'PILIH APLIKASI',
                  style: TextStyle(
                    fontFamily: FN.display,
                    fontSize: 32,
                    height: 1.05,
                    color: FN.ink,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  textInputAction: TextInputAction.search,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(hintText: 'Cari aplikasi'),
                ),
              ),
              Container(height: 2, color: FN.ink),
              Expanded(
                child: apps.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => _message('Daftar aplikasi gagal dimuat.'),
                  data: _list,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
