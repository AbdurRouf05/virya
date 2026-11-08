import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/app/settings.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/app/theme/styles/field_notes_style.dart';
import 'package:virya/app/theme/styles/night_style.dart';
import 'package:virya/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async {
    FN.use(fieldNotesStyle);
    await db.close();
  });

  ProviderContainer container({String? initial}) {
    final c = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        initialStyleIdProvider.overrideWithValue(initial),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('nilai awal dipakai sebelum pengaturan termuat', () {
    final c = container(initial: 'night');
    expect(c.read(styleIdProvider), 'night');
  });

  test('tanpa nilai tersimpan, id null', () {
    expect(container().read(styleIdProvider), isNull);
  });

  test('memilih style tersimpan dan menang atas nilai awal', () async {
    final c = container(initial: 'night');
    await c.read(settingsProvider.notifier).set(SettingKeys.styleId, 'forest');
    expect(c.read(styleIdProvider), 'forest');
    expect(await db.getSetting(SettingKeys.styleId), 'forest');
  });

  test('tema halaman mengikuti kecerahan style', () {
    FN.use(nightStyle);
    expect(FN.palette.brightness, Brightness.dark);
    expect(FN.onNight, isNot(FN.paper));
    expect(FN.onAccent, isNot(FN.ink));
  });
}
