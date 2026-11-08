import 'package:flutter/material.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Ledger-style table header cell text.
TextStyle detailTh() => FN.label(size: 9.5);

/// Ledger-style table body cell text (defaults to ink).
TextStyle detailTd({bool bold = false, Color? color}) => FN
    .label(size: 12, color: color ?? FN.ink)
    .copyWith(
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
      fontFeatures: FN.tabular,
    );
