import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/gym/domain/session_draft.dart';

/// Lebar kolom tabel set (dipakai juga oleh header tabel).
class GymSetColumns {
  GymSetColumns._();
  static const set = 34.0;
  static const field = 62.0;
  static const rpe = 44.0;
  static const check = 40.0;
}

/// Satu baris: SET · SEBELUMNYA · KG · REPS · (RPE) · centang.
/// Ketuk nomor set untuk menu pemanasan / hapus.
class GymSetRow extends StatefulWidget {
  final DraftSet set;
  final int index;
  final (double, int)? previous;
  final bool showRpe;
  final ValueChanged<double?> onWeight;
  final ValueChanged<int?> onReps;
  final ValueChanged<double?> onRpe;
  final VoidCallback onToggleDone;
  final VoidCallback onToggleWarmup;
  final VoidCallback onRemove;

  const GymSetRow({
    super.key,
    required this.set,
    required this.index,
    required this.previous,
    required this.showRpe,
    required this.onWeight,
    required this.onReps,
    required this.onRpe,
    required this.onToggleDone,
    required this.onToggleWarmup,
    required this.onRemove,
  });

  @override
  State<GymSetRow> createState() => _GymSetRowState();
}

class _GymSetRowState extends State<GymSetRow> {
  late final _kg = TextEditingController(text: _kgText(widget.set.weightKg));
  late final _reps = TextEditingController(text: _int(widget.set.reps));
  late final _rpe = TextEditingController(text: _kgText(widget.set.rpe));

  static String _kgText(double? v) => v == null ? '' : fmtKg(v);
  static String _int(int? v) => v == null ? '' : '$v';

  @override
  void didUpdateWidget(GymSetRow old) {
    super.didUpdateWidget(old);
    // Sinkronkan saat nilai diubah dari luar (mis. dicentang → isi patokan).
    _sync(_kg, _kgText(widget.set.weightKg), (t) => parseKg(t));
    _sync(_reps, _int(widget.set.reps), (t) => int.tryParse(t));
  }

  void _sync(TextEditingController c, String text, Object? Function(String) p) {
    if (p(c.text) != p(text)) c.text = text;
  }

  @override
  void dispose() {
    _kg.dispose();
    _reps.dispose();
    _rpe.dispose();
    super.dispose();
  }

  Future<void> _menu() async {
    final box = context.findRenderObject() as RenderBox?;
    final at = box?.localToGlobal(Offset.zero) ?? Offset.zero;
    final v = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(at.dx, at.dy + 40, at.dx + 200, 0),
      shape: const RoundedRectangleBorder(),
      items: [
        PopupMenuItem(
          value: 'warm',
          child: Text(widget.set.isWarmup ? 'Jadikan set kerja' : 'Pemanasan'),
        ),
        const PopupMenuItem(value: 'del', child: Text('Hapus set')),
      ],
    );
    if (v == 'warm') widget.onToggleWarmup();
    if (v == 'del') widget.onRemove();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.set;
    final p = widget.previous;
    final done = s.done;
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: done ? FN.paperDeep : null,
        border: Border(top: BorderSide(color: FN.paperLine, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          SizedBox(
            width: GymSetColumns.set,
            child: InkWell(
              onTap: _menu,
              child: Text(
                s.isWarmup ? 'W' : '${widget.index + 1}',
                style: FN.bigNumber(
                  20,
                  color: s.isWarmup ? FN.caution : (done ? FN.ink : FN.inkSoft),
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              p == null ? '—' : 'sblm ${fmtKg(p.$1)}×${p.$2}',
              overflow: TextOverflow.ellipsis,
              style: FN.label(size: 11),
            ),
          ),
          _field(
            _kg,
            s.hintWeightKg == null ? 'kg' : fmtKg(s.hintWeightKg!),
            GymSetColumns.field,
            true,
            (t) => widget.onWeight(parseKg(t)),
          ),
          const SizedBox(width: 6),
          _field(
            _reps,
            s.hintReps?.toString() ?? 'reps',
            GymSetColumns.field,
            false,
            (t) => widget.onReps(int.tryParse(t.trim())),
          ),
          if (widget.showRpe) ...[
            const SizedBox(width: 6),
            _field(
              _rpe,
              'RPE',
              GymSetColumns.rpe,
              true,
              (t) => widget.onRpe(parseKg(t)?.clamp(1, 10).toDouble()),
            ),
          ],
          const SizedBox(width: 8),
          _Check(done: done, onTap: widget.onToggleDone),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String hint,
    double width,
    bool decimal,
    ValueChanged<String> onChanged,
  ) {
    final done = widget.set.done;
    return SizedBox(
      width: width,
      height: 38,
      child: TextField(
        controller: c,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.numberWithOptions(decimal: decimal),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp(decimal ? r'[0-9.,]' : r'[0-9]'),
          ),
        ],
        style: FN
            .label(size: 15, color: FN.ink)
            .copyWith(fontWeight: FontWeight.w700, letterSpacing: 0),
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: FN.label(size: 14, color: FN.inkMuted),
          contentPadding: const EdgeInsets.symmetric(vertical: 9),
          filled: false,
          enabledBorder: done
              ? InputBorder.none
              : OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: FN.ink, width: 1.5),
                ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: FN.signal, width: 2),
          ),
        ),
      ),
    );
  }
}

class _Check extends StatelessWidget {
  final bool done;
  final VoidCallback onTap;
  const _Check({required this.done, required this.onTap});

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    checked: done,
    label: 'Set selesai',
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: GymSetColumns.check,
        height: 38,
        decoration: BoxDecoration(
          color: done ? FN.ok : null,
          border: Border.all(color: FN.ink, width: 2),
        ),
        child: done ? Icon(Icons.check, color: FN.paper, size: 22) : null,
      ),
    ),
  );
}
