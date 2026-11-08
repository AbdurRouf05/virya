import 'package:flutter/material.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Dialog ya/tidak bergaya tinta. `true` bila dikonfirmasi.
Future<bool> gymConfirm(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
  bool danger = false,
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      shape: const RoundedRectangleBorder(),
      title: Text(title.toUpperCase()),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: const Text('BATAL'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(c, true),
          child: Text(
            action,
            style: TextStyle(color: danger ? FN.warn : FN.ink),
          ),
        ),
      ],
    ),
  );
  return r ?? false;
}

/// Dialog satu kolom teks. Mengembalikan teks (sudah di-trim) atau null.
Future<String?> gymPrompt(
  BuildContext context, {
  required String title,
  String initial = '',
  String label = 'NAMA',
  String action = 'SIMPAN',
}) async {
  final c = TextEditingController(text: initial);
  final r = await showDialog<String>(
    context: context,
    builder: (d) => AlertDialog(
      shape: const RoundedRectangleBorder(),
      title: Text(title.toUpperCase()),
      content: TextField(
        controller: c,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: label),
        onSubmitted: (v) => Navigator.pop(d, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(d),
          child: const Text('BATAL'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(d, c.text),
          child: Text(action),
        ),
      ],
    ),
  );
  c.dispose();
  final t = r?.trim();
  return t == null || t.isEmpty ? null : t;
}

void gymToast(BuildContext context, String msg) {
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg)));
}
