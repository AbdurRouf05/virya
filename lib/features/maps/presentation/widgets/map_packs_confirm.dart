import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// "Hapus?" dialog used by the offline map screen. True = confirmed.
Future<bool> confirmMapDelete(BuildContext context,
    {required String title, required String body, String ok = 'HAPUS'}) async {
  final res = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      backgroundColor: FN.paper,
      shape: RoundedRectangleBorder(side: BorderSide(color: FN.ink, width: 2)),
      title: Text(title, style: FN.bigNumber(24)),
      content: Text(body, style: TextStyle(fontFamily: FN.sans, color: FN.inkSoft)),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text('BATAL', style: FN.label(color: FN.ink))),
        TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(ok, style: FN.label(color: FN.warn))),
      ],
    ),
  );
  return res == true;
}

/// Short dark snackbar.
void mapToast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: FN.ink,
    content: Text(msg, style: FN.label(size: 12, color: FN.paper)),
  ));
}
