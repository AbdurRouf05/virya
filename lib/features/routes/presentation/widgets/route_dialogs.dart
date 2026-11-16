import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Dialog satu kolom teks. Mengembalikan teks (sudah di-trim) atau null.
Future<String?> routePrompt(
  BuildContext context, {
  required String title,
  String initial = '',
  String label = 'Nama',
  String action = 'Simpan',
  bool number = false,
}) async {
  final c = TextEditingController(text: initial);
  final r = await showDialog<String>(
    context: context,
    builder: (d) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: FN.smallRadius),
      title: Text(FN.caps(title)),
      content: TextField(
        controller: c,
        autofocus: true,
        keyboardType: number
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        inputFormatters: number
            ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
            : null,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: FN.caps(label)),
        onSubmitted: (v) => Navigator.pop(d, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(d),
          child: Text(FN.caps('Batal')),
        ),
        TextButton(
          onPressed: () => Navigator.pop(d, c.text),
          child: Text(FN.caps(action)),
        ),
      ],
    ),
  );
  c.dispose();
  final t = r?.trim();
  return t == null || t.isEmpty ? null : t;
}

/// Konfirmasi ya/tidak.
Future<bool> routeConfirm(BuildContext context,
    {required String title, required String message, String action = 'Hapus'}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (d) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: FN.smallRadius),
      title: Text(FN.caps(title)),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(d, false),
          child: Text(FN.caps('Batal')),
        ),
        TextButton(
          onPressed: () => Navigator.pop(d, true),
          child: Text(FN.caps(action)),
        ),
      ],
    ),
  );
  return r ?? false;
}

void routeToast(BuildContext context, String msg) {
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg)));
}
