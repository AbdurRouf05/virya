import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/features/recording/presentation/widgets/recording_sport_icon.dart';

/// Asks to confirm discarding the current session. Returns true to discard.
Future<bool?> showDiscardRecordingDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: FN.nightSurface,
      shape: const RoundedRectangleBorder(),
      title: Text('BUANG AKTIVITAS?', style: FN.label(size: 14, color: FN.paper)),
      content: Text(
        'Seluruh rute, data, dan foto sesi ini akan dihapus permanen.',
        style: TextStyle(fontFamily: FN.sans, color: FN.paper),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text('BATAL', style: FN.label(color: FN.paperLine)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text('BUANG', style: FN.label(color: FN.warn)),
        ),
      ],
    ),
  );
}

/// Bottom sheet listing every sport. Returns the picked sport or null.
Future<SportType?> showRecordingSportPicker(
    BuildContext context, SportType current) {
  return showModalBottomSheet<SportType>(
    context: context,
    backgroundColor: FN.nightSurface,
    shape: const RoundedRectangleBorder(),
    builder: (ctx) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Text('PILIH OLAHRAGA',
                style: FN.label(size: 12, color: FN.signal)),
          ),
          for (final s in SportType.gps)
            ListTile(
              minTileHeight: 56,
              leading: Icon(sportIcon(s),
                  color: s == current ? FN.acid : FN.paperLine),
              title: Text(
                s.displayName.toUpperCase(),
                style: TextStyle(
                  fontFamily: FN.display,
                  fontSize: 20,
                  color: s == current ? FN.acid : FN.paper,
                ),
              ),
              onTap: () => Navigator.pop(ctx, s),
            ),
        ],
      ),
    ),
  );
}
