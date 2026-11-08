import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/settings/data/data_actions.dart';

/// Dialog to edit name, weight, max HR and FTP.
class AthleteEditDialog extends ConsumerStatefulWidget {
  final UserProfile? profile;
  const AthleteEditDialog({super.key, this.profile});

  @override
  ConsumerState<AthleteEditDialog> createState() => _AthleteEditDialogState();
}

class _AthleteEditDialogState extends ConsumerState<AthleteEditDialog> {
  late final _name = TextEditingController(
    text: widget.profile?.displayName ?? '',
  );
  late final _weight = TextEditingController(
    text: (widget.profile?.weightKg ?? 70).toStringAsFixed(0),
  );
  late final _hr = TextEditingController(
    text: '${widget.profile?.maxHeartRate ?? 190}',
  );
  late final _ftp = TextEditingController(
    text: widget.profile?.ftpWatts?.toString() ?? '',
  );

  @override
  void dispose() {
    for (final c in [_name, _weight, _hr, _ftp]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final db = ref.read(databaseProvider);
    final weight = double.tryParse(_weight.text.replaceAll(',', '.')) ?? 70;
    final hr = int.tryParse(_hr.text) ?? 190;
    final ftp = int.tryParse(_ftp.text);
    final name = _name.text.trim().isEmpty ? 'Atlet' : _name.text.trim();
    try {
      final p = widget.profile;
      if (p == null) {
        await db
            .into(db.userProfiles)
            .insert(
              UserProfilesCompanion.insert(
                id: 'me',
                displayName: name,
                weightKg: Value(weight),
                maxHeartRate: Value(hr),
                ftpWatts: Value(ftp),
                createdAt: DateTime.now(),
              ),
            );
      } else {
        await (db.update(
          db.userProfiles,
        )..where((t) => t.id.equals(p.id))).write(
          UserProfilesCompanion(
            displayName: Value(name),
            weightKg: Value(weight),
            maxHeartRate: Value(hr),
            ftpWatts: Value(ftp),
          ),
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) DataActions.toast(context, 'Gagal menyimpan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final digits = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))];
    return AlertDialog(
      title: const Text('DATA ATLET'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'NAMA'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _weight,
              keyboardType: TextInputType.number,
              inputFormatters: digits,
              decoration: const InputDecoration(
                labelText: 'BERAT (KG)',
                suffixText: 'kg',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _hr,
              keyboardType: TextInputType.number,
              inputFormatters: digits,
              decoration: const InputDecoration(
                labelText: 'DETAK JANTUNG MAKS',
                suffixText: 'bpm',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ftp,
              keyboardType: TextInputType.number,
              inputFormatters: digits,
              decoration: const InputDecoration(
                labelText: 'FTP (OPSIONAL)',
                suffixText: 'W',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dipakai untuk estimasi daya, kalori & zona. Analisis ulang '
              'aktivitas lama lewat "Ubah catatan".',
              style: FN.label(size: 9.5),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('BATAL'),
        ),
        TextButton(
          onPressed: _save,
          style: TextButton.styleFrom(foregroundColor: FN.signal),
          child: const Text('SIMPAN'),
        ),
      ],
    );
  }
}
