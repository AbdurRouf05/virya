import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/app/theme/export_tokens.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/app/theme/palette.dart';
import 'package:virya/app/theme/styles/field_notes_style.dart';
import 'package:virya/app/theme/styles/night_style.dart';
import 'package:virya/app/theme/styles/styles.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/constants/sport_category.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (la > lb ? la + 0.05 : lb + 0.05) / (la > lb ? lb + 0.05 : la + 0.05);
}

void main() {
  tearDown(() => FN.use(fieldNotesStyle));

  test('id unik dan ada style gelap', () {
    expect(allStyles.map((s) => s.id).toSet(), hasLength(allStyles.length));
    expect(allStyles.any((s) => s.brightness == Brightness.dark), isTrue);
  });

  test('id tidak dikenal kembali ke Field Notes', () {
    expect(styleById(null), same(fieldNotesStyle));
    expect(styleById('tidak_ada'), same(fieldNotesStyle));
    expect(styleById('night'), same(nightStyle));
  });

  test('token baru Field Notes sama dengan warna lamanya', () {
    expect(fieldNotesStyle.onNight, fieldNotesStyle.paper);
    expect(fieldNotesStyle.onNightMuted, fieldNotesStyle.paperLine);
    expect(fieldNotesStyle.onAccent, fieldNotesStyle.ink);
  });

  test('font tiap style terdaftar di pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final s in allStyles) {
      for (final f in [s.display, s.mono, s.sans]) {
        expect(pubspec, contains('family: $f'), reason: '${s.id}: $f');
      }
    }
  });

  group('kontras', () {
    for (final Palette s in allStyles) {
      group(s.id, () {
        test('teks di halaman', () {
          expect(contrast(s.ink, s.paper), greaterThanOrEqualTo(7));
          expect(contrast(s.inkSoft, s.paper), greaterThanOrEqualTo(4.5));
          expect(contrast(s.inkMuted, s.paper), greaterThanOrEqualTo(3.5));
          expect(contrast(s.ink, s.paperDeep), greaterThanOrEqualTo(4.5));
        });

        test('teks di permukaan gelap', () {
          for (final bg in [s.night, s.nightSurface]) {
            expect(contrast(s.onNight, bg), greaterThanOrEqualTo(7));
            expect(contrast(s.onNightMuted, bg), greaterThanOrEqualTo(4.5));
          }
          expect(contrast(s.acid, s.night), greaterThanOrEqualTo(7));
        });

        test('teks di atas aksen', () {
          expect(contrast(s.onAccent, s.signal), greaterThanOrEqualTo(4.5));
          expect(contrast(s.onAccent, s.acid), greaterThanOrEqualTo(4.5));
        });

        test('aksen dan data terlihat di halaman', () {
          expect(contrast(s.signal, s.paper), greaterThanOrEqualTo(2.5));
          expect(contrast(s.warn, s.paper), greaterThanOrEqualTo(3));
          for (final c in SportCategory.values) {
            expect(
              contrast(s.category[c]!, s.paper),
              greaterThanOrEqualTo(2.5),
              reason: c.name,
            );
          }
          for (final g in s.gradeRamp) {
            expect(contrast(g, s.paper), greaterThanOrEqualTo(1.5));
          }
        });

        test('zona detak jantung terlihat dan berbeda', () {
          FN.use(s);
          expect(FN.hrZones, hasLength(5));
          expect(FN.hrZones.toSet(), hasLength(5));
          for (final z in FN.hrZones) {
            expect(contrast(z, s.paper), greaterThanOrEqualTo(1.5));
          }
        });

        test('angka di atas warna kategori terbaca', () {
          for (final c in SportCategory.values) {
            expect(
              contrast(s.paper, s.category[c]!),
              greaterThanOrEqualTo(2.5),
              reason: c.name,
            );
          }
        });

        test('aksen di atas blok tinta terbaca', () {
          FN.use(s);
          expect(contrast(FN.onInk(s.acid), s.ink), greaterThanOrEqualTo(4.5));
          expect(contrast(FN.onInk(s.signal), s.ink), greaterThanOrEqualTo(2.5));
        });

        test('peta token lengkap dan kategori berbeda', () {
          expect(s.surface.keys, containsAll(SurfaceType.values));
          expect(s.gradeRamp, hasLength(6));
          final colors = [
            for (final c in SportCategory.values) s.category[c]!,
          ];
          expect(colors.toSet(), hasLength(colors.length));
        });
      });
    }
  });

  test('warna ekspor tidak ikut style aktif', () {
    final before = (FNExport.paper, FNExport.ink, FNExport.grade(4));
    FN.use(nightStyle);
    expect(FN.paper, isNot(fieldNotesStyle.paper));
    expect((FNExport.paper, FNExport.ink, FNExport.grade(4)), before);
    expect(FNExport.bigNumber(12).color, fieldNotesStyle.ink);
  });
}
