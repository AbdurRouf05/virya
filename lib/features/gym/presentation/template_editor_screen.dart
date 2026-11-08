import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/gym/data/gym_providers.dart';
import 'package:virya/features/gym/data/gym_repository.dart';
import 'package:virya/features/gym/domain/gym_models.dart';
import 'package:virya/features/gym/presentation/exercise_picker_screen.dart';
import 'package:virya/features/gym/presentation/widgets/gym_dialogs.dart';
import 'package:virya/features/gym/presentation/widgets/gym_template_item_row.dart';

/// Buka editor template ([template] null = template baru).
Future<void> openTemplateEditor(
  BuildContext context, {
  GymTemplate? template,
}) => Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => TemplateEditorScreen(template: template)),
);

/// Buat / ubah template: nama, catatan, gerakan dengan target set × reps.
class TemplateEditorScreen extends ConsumerStatefulWidget {
  final GymTemplate? template;
  const TemplateEditorScreen({super.key, this.template});

  @override
  ConsumerState<TemplateEditorScreen> createState() => _State();
}

class _State extends ConsumerState<TemplateEditorScreen> {
  late final _name = TextEditingController(text: widget.template?.name ?? '');
  late final _note = TextEditingController(text: widget.template?.note ?? '');
  late final List<TemplateItem> _items = [...?widget.template?.items];
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  void _set(int i, {int? sets, int? reps}) => setState(() {
    final it = _items[i];
    _items[i] = TemplateItem(
      exerciseId: it.exerciseId,
      targetSets: sets ?? it.targetSets,
      targetReps: reps ?? it.targetReps,
    );
  });

  Future<void> _add() async {
    final e = await pickExercise(context);
    if (e != null) setState(() => _items.add(TemplateItem(exerciseId: e.id)));
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      gymToast(context, 'Beri nama template dulu.');
      return;
    }
    if (_items.isEmpty) {
      gymToast(context, 'Tambah minimal satu gerakan.');
      return;
    }
    setState(() => _busy = true);
    await ref
        .read(gymRepositoryProvider)
        .saveTemplate(
          id: widget.template?.id,
          name: _name.text,
          note: _note.text,
          items: _items,
        );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final t = widget.template;
    if (t == null) return;
    final ok = await gymConfirm(
      context,
      title: 'Hapus template?',
      body: '"${t.name}" akan dihapus. Sesi yang sudah tercatat tidak berubah.',
      action: 'HAPUS',
      danger: true,
    );
    if (!ok) return;
    await ref.read(gymRepositoryProvider).deleteTemplate(t.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final lib = ref.watch(exerciseMapProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.template == null ? 'TEMPLATE BARU' : 'UBAH TEMPLATE',
        ),
        actions: [
          if (widget.template != null)
            IconButton(
              tooltip: 'Hapus template',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: PaperBackground(
        child: Column(
          children: [
            Expanded(
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                header: _form(),
                footer: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: InkButton(
                    label: 'Gerakan',
                    icon: Icons.add,
                    style: InkButtonStyle.outline,
                    expand: true,
                    onPressed: _add,
                  ),
                ),
                itemCount: _items.length,
                onReorder: (from, to) => setState(() {
                  final it = _items.removeAt(from);
                  _items.insert(to > from ? to - 1 : to, it);
                }),
                itemBuilder: (_, i) {
                  final it = _items[i];
                  return GymTemplateItemRow(
                    key: ObjectKey(it),
                    index: i,
                    name: lib[it.exerciseId]?.name ?? 'Gerakan terhapus',
                    sets: it.targetSets,
                    reps: it.targetReps,
                    onSets: (v) => _set(i, sets: v),
                    onReps: (v) => _set(i, reps: v),
                    onRemove: () => setState(() => _items.removeAt(i)),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SafeArea(
                top: false,
                child: InkButton(
                  label: 'Simpan template',
                  icon: Icons.check,
                  style: InkButtonStyle.primary,
                  expand: true,
                  busy: _busy,
                  onPressed: _save,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _form() => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'NAMA (mis. Push day)'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _note,
          maxLines: 2,
          minLines: 1,
          decoration: const InputDecoration(labelText: 'CATATAN (opsional)'),
        ),
        const SizedBox(height: 18),
        Text('GERAKAN · ${_items.length}', style: FN.label(size: 10)),
      ],
    ),
  );
}
