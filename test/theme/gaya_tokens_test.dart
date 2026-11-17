import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/app/theme/caps.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/app/theme/gaya.dart';
import 'package:virya/app/theme/palette.dart';
import 'package:virya/app/theme/styles/bersih_dark_style.dart';
import 'package:virya/app/theme/styles/bersih_style.dart';
import 'package:virya/app/theme/styles/field_notes_style.dart';
import 'package:virya/app/theme/styles/night_style.dart';
import 'package:virya/app/theme/styles/styles.dart';

void main() {
  tearDown(() => FN.use(fieldNotesStyle));

  group('Tegas sama dengan tampilan lama', () {
    setUp(() => FN.use(fieldNotesStyle));

    test('garis, sudut, bayangan', () {
      expect(FN.isClean, isFalse);
      expect(FN.stroke, 2);
      expect(FN.line(3), 3);
      expect(FN.radius, 0);
      expect(FN.radiusSmall, 0);
      expect(FN.boxRadius, isNull);
      expect(FN.cardLine, FN.ink);
      expect(FN.divider, FN.ink);
      expect(FN.cardFill, FN.paper);
      expect(FN.frame(), Border.all(color: FN.ink, width: 2));
      expect(
        FN.frame(color: FN.signal, width: 3),
        Border.all(color: FN.signal, width: 3),
      );
      expect(FN.side(), BorderSide(color: FN.ink, width: 1));
      expect(FN.stripe(FN.signal), BorderSide(color: FN.signal, width: 4));
      final s = FN.hardShadow()!;
      expect(s.single.offset, const Offset(3, 3));
      expect(s.single.color, FN.ink);
      expect(FN.card().borderRadius, isNull);
      expect(FN.card().color, FN.paper);
    });

    test('huruf', () {
      expect(FN.caps('Minggu ini'), 'MINGGU INI');
      expect(FN.track(1.4), 1.4);
      expect(FN.bigNumber(40).fontFamily, FN.display);
      expect(FN.bigNumber(40).fontSize, 40);
      expect(FN.title(30).fontFamily, FN.display);
      expect(FN.title(30).fontSize, 30);
      expect(FN.title(30).height, isNull);
      final l = FN.label();
      expect(l.fontFamily, FN.mono);
      expect(l.fontSize, 11);
      expect(l.letterSpacing, 1.2);
      expect(l.fontWeight, FontWeight.w500);
      expect(FN.labelStrong().fontWeight, FontWeight.w700);
      expect(FN.heading().fontWeight, FontWeight.w700);
      expect(FN.monoStyle().fontFamily, FN.mono);
    });

    test('palet lama tetap Tegas', () {
      for (final p in allStyles) {
        expect(p.gaya, UiGaya.tegas, reason: p.id);
        expect(p.card, isNull, reason: p.id);
      }
    });
  });

  group('Bersih', () {
    setUp(() => FN.use(bersihStyle));

    test('warna', () {
      expect(FN.paper, const Color(0xFFF7F6F3));
      expect(FN.cardFill, const Color(0xFFFFFFFF));
      expect(FN.paperLine, const Color(0xFFECEAE5));
      expect(FN.ink, const Color(0xFF1B1B1A));
      expect(FN.inkMuted, const Color(0xFF8A8780));
      expect(FN.signal, const Color(0xFFFF4F00));
    });

    test('garis rambut, sudut 14/10, tanpa bayangan', () {
      expect(FN.isClean, isTrue);
      expect(FN.stroke, 1);
      expect(FN.line(3), 1);
      expect(FN.radius, 14);
      expect(FN.radiusSmall, 10);
      expect(FN.boxRadius, BorderRadius.circular(14));
      expect(FN.frame(), Border.all(color: FN.paperLine, width: 1));
      expect(FN.frame(color: FN.ink, width: 2).top.width, 1);
      expect(FN.frame(color: FN.signal, width: 3).top.color, FN.signal);
      expect(FN.side(width: 2).width, 1);
      expect(FN.stripe(FN.signal), BorderSide.none);
      expect(FN.hardShadow(), isNull);
      expect(FN.card(shadow: true).boxShadow, isNull);
      expect(FN.card().borderRadius, BorderRadius.circular(14));
    });

    test('huruf kalimat dan Plex Sans', () {
      expect(FN.caps('MINGGU INI'), 'Minggu ini');
      expect(FN.caps('Rekam GPS'), 'Rekam GPS');
      expect(FN.track(1.4), isNull);
      expect(FN.bigNumber(40).fontFamily, FN.sans);
      expect(FN.bigNumber(40).fontWeight, FontWeight.w600);
      expect(FN.bigNumber(40).fontFeatures, FN.tabular);
      expect(FN.title(30).fontFamily, FN.sans);
      expect(FN.label().fontFamily, FN.sans);
      expect(FN.label().letterSpacing, 0);
    });

    test('varian gelap', () {
      FN.use(bersihDarkStyle);
      expect(FN.isClean, isTrue);
      expect(FN.isDark, isTrue);
      expect(FN.cardFill, isNot(FN.paper));
    });
  });

  group('sentenceCase', () {
    test('kapital semua menjadi kapital kalimat', () {
      expect(sentenceCase('MINGGU INI'), 'Minggu ini');
      expect(sentenceCase('ZONA HR Z2'), 'Zona HR Z2');
      expect(sentenceCase('EKSPOR GPX'), 'Ekspor GPX');
    });

    test('teks yang sudah berhuruf kecil tidak diubah', () {
      expect(sentenceCase('Jarak total'), 'Jarak total');
      expect(sentenceCase('km'), 'km');
    });
  });

  group('resolveStyle', () {
    test('Tegas memakai palet tersimpan', () {
      expect(resolveStyle(styleId: 'night', gaya: UiGaya.tegas), nightStyle);
      expect(resolveStyle(styleId: null, gaya: UiGaya.tegas), fieldNotesStyle);
    });

    test('Bersih memilih terang/gelap', () {
      Palette r(BersihMode m, [Brightness b = Brightness.light]) =>
          resolveStyle(styleId: 'night', gaya: UiGaya.bersih, mode: m, platform: b);
      expect(r(BersihMode.terang), bersihStyle);
      expect(r(BersihMode.gelap), bersihDarkStyle);
      expect(r(BersihMode.sistem), bersihStyle);
      expect(r(BersihMode.sistem, Brightness.dark), bersihDarkStyle);
    });
  });
}
