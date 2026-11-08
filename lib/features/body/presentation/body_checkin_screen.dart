import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/format.dart';
import 'package:virya/app/theme/app_theme.dart';
import 'package:virya/core/time/day_key.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/body/data/body_providers.dart';
import 'package:virya/features/body/domain/body_logic.dart';
import 'package:virya/features/body/domain/body_models.dart';
import 'package:virya/features/body/presentation/body_camera_screen.dart';
import 'package:virya/features/body/presentation/widgets/body_pose_slot.dart';

/// Buka layar check-in untuk [day].
Future<void> openBodyCheckin(BuildContext context, DateTime day) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => BodyCheckinScreen(day: day)),
    );

/// Foto dan ukuran pada satu hari.
class BodyCheckinScreen extends ConsumerStatefulWidget {
  final DateTime day;
  const BodyCheckinScreen({super.key, required this.day});

  @override
  ConsumerState<BodyCheckinScreen> createState() => _BodyCheckinScreenState();
}

class _BodyCheckinScreenState extends ConsumerState<BodyCheckinScreen> {
  final _inputs = {
    for (final f in BodyField.values) f: TextEditingController(),
  };
  final _note = TextEditingController();
  final _errors = <BodyField, String>{};

  /// Formulir hanya diisi sekali supaya perubahan data (mis. foto baru) tidak
  /// menimpa angka yang sedang diketik.
  bool _prefilled = false;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in _inputs.values) {
      c.dispose();
    }
    _note.dispose();
    super.dispose();
  }

  void _prefill(BodyEntry? entry) {
    _prefilled = true;
    if (entry == null) return;
    for (final e in entry.values.entries) {
      _inputs[e.key]!.text = _number(e.value);
    }
    _note.text = entry.note ?? '';
  }

  String _number(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : '$v';

  void _shoot(BodyPose pose) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => Theme(
        data: FieldNotesTheme.night,
        child: BodyCameraScreen(pose: pose, day: widget.day),
      ),
    ),
  );

  /// Null bila ada isian yang tidak valid; kesalahannya tampil di kolomnya.
  Map<BodyField, double>? _readValues() {
    final values = <BodyField, double>{};
    final errors = <BodyField, String>{};
    for (final f in BodyField.values) {
      final raw = _inputs[f]!.text.trim();
      if (raw.isEmpty) continue;
      final v = parseBodyValue(f, raw);
      if (v == null) {
        errors[f] = 'Isi ${_number(f.min)}–${_number(f.max)} ${f.unit}';
      } else {
        values[f] = v;
      }
    }
    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
    });
    return errors.isEmpty ? values : null;
  }

  Future<void> _save(BodyEntry? entry) async {
    final values = _readValues();
    if (values == null || _saving) return;
    final nav = Navigator.of(context);
    // Formulir kosong tidak boleh membuat check-in, karena akan mengatur ulang
    // jadwal pengingat.
    if (entry == null && values.isEmpty && _note.text.trim().isEmpty) {
      nav.pop();
      return;
    }
    setState(() => _saving = true);
    final repo = ref.read(bodyRepositoryProvider);
    try {
      final id = await repo.ensureCheckin(widget.day);
      await repo.saveDetails(id, values, _note.text);
      if (mounted) nav.pop();
    } on Exception catch (e) {
      debugPrint('Check-in gagal disimpan: $e');
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-in gagal disimpan. Coba lagi.')),
      );
    }
  }

  Future<void> _delete(BodyEntry entry) async {
    final nav = Navigator.of(context);
    final repo = ref.read(bodyRepositoryProvider);
    final sure = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Hapus check-in ini?'),
        content: const Text('Foto dan ukuran pada tanggal ini akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (sure != true) return;
    await repo.deleteCheckin(entry.id);
    if (mounted) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(bodyEntriesProvider);
    final entry = ref.watch(bodyEntryOnProvider(dayKeyOf(widget.day)));
    return Scaffold(
      body: PaperBackground(
        child: SafeArea(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                'Gagal memuat check-in: $e',
                style: FN.label(size: 12, color: FN.ink),
              ),
            ),
            data: (_) {
              // TextField belum terpasang saat ini, jadi aman mengisi di build.
              if (!_prefilled) _prefill(entry);
              return _form(context, entry);
            },
          ),
        ),
      ),
    );
  }

  Widget _form(BuildContext context, BodyEntry? entry) => ListView(
    padding: const EdgeInsets.only(bottom: 48),
    children: [
      Row(
        children: [
          IconButton(
            tooltip: 'Kembali',
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back),
          ),
        ],
      ),
      Masthead(
        kicker: 'Check-in',
        title: 'Foto tubuh',
        subtitle: Fmt.dateStamp(widget.day, withTime: false),
      ),
      const SectionHeader(title: 'Foto'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final pose in BodyPose.values) ...[
              if (pose != BodyPose.values.first) const SizedBox(width: 8),
              Expanded(
                child: BodyPoseSlot(
                  pose: pose,
                  shot: entry?.shots[pose],
                  onTap: () => _shoot(pose),
                ),
              ),
            ],
          ],
        ),
      ),
      const SectionHeader(title: 'Ukuran'),
      for (final f in BodyField.values) _fieldInput(f),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: TextField(
          controller: _note,
          maxLines: 3,
          minLines: 1,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Catatan'),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: InkButton(
          label: 'Simpan',
          icon: Icons.check,
          style: InkButtonStyle.primary,
          expand: true,
          busy: _saving,
          onPressed: () => _save(entry),
        ),
      ),
      if (entry != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: InkButton(
            label: 'Hapus check-in',
            icon: Icons.delete_outline,
            style: InkButtonStyle.danger,
            expand: true,
            onPressed: _saving ? null : () => _delete(entry),
          ),
        ),
    ],
  );

  Widget _fieldInput(BodyField f) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    child: TextField(
      controller: _inputs[f],
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      onChanged: (_) {
        if (_errors.containsKey(f)) setState(() => _errors.remove(f));
      },
      decoration: InputDecoration(
        labelText: f.label,
        suffixText: f.unit,
        errorText: _errors[f],
      ),
    ),
  );
}
