import 'package:virya/app/theme/palette.dart';
import 'package:virya/app/theme/styles/field_notes_style.dart';

/// Registry of selectable UI styles. To add a style: create one file in
/// this folder exporting a `const Palette`, then add it to [allStyles].
const allStyles = <Palette>[fieldNotesStyle];

Palette styleById(String? id) =>
    allStyles.firstWhere((s) => s.id == id, orElse: () => fieldNotesStyle);
