import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/profile/data/gear_providers.dart';
import 'package:virya/features/settings/data/data_actions.dart';

/// Dialog to add a bike or pair of shoes.
class AddGearDialog extends ConsumerStatefulWidget {
  const AddGearDialog({super.key});

  @override
  ConsumerState<AddGearDialog> createState() => _AddGearDialogState();
}

class _AddGearDialogState extends ConsumerState<AddGearDialog> {
  final _name = TextEditingController();
  final _brand = TextEditingController();
  String _type = 'gravelBike';

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      DataActions.toast(context, 'Beri nama dulu.');
      return;
    }
    final db = ref.read(databaseProvider);
    final hasAny = (await db.gearsDao.getActiveGears()).isNotEmpty;
    await db.gearsDao.insertGear(
      GearsCompanion.insert(
        id: const Uuid().v4(),
        name: _name.text.trim(),
        gearType: _type,
        brandModel: Value(
          _brand.text.trim().isEmpty ? null : _brand.text.trim(),
        ),
        isDefault: Value(!hasAny),
        createdAt: DateTime.now(),
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('GEAR BARU'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'NAMA'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _brand,
              decoration: const InputDecoration(labelText: 'MEREK / MODEL'),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final e in gearTypes.entries)
                  StampChip(
                    text: e.value,
                    fontSize: 10,
                    selected: _type == e.key,
                    onTap: () => setState(() => _type = e.key),
                  ),
              ],
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
          child: const Text('TAMBAH'),
        ),
      ],
    );
  }
}
