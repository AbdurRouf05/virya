import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virya/app/theme/native_style.dart';
import 'package:virya/app/theme/styles/field_notes_style.dart';
import 'package:virya/app/theme/styles/night_style.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('virya/style');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    resetNativeStyleForTest();
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('style yang sama hanya dikirim sekali', () async {
    await pushNativeStyle(fieldNotesStyle);
    await pushNativeStyle(fieldNotesStyle);
    await pushNativeStyle(nightStyle);
    expect(calls, hasLength(2));
  });

  test('mengirim warna ARGB dan mode gelap', () async {
    await pushNativeStyle(nightStyle);
    final args = calls.single.arguments as Map;
    expect(calls.single.method, 'apply');
    expect(args['paper'], nightStyle.paper.toARGB32());
    expect(args['ink'], nightStyle.ink.toARGB32());
    expect(args['warn'], nightStyle.warn.toARGB32());
    expect(args['muted'], nightStyle.inkMuted.toARGB32());
    expect(args['dark'], isTrue);
  });

  test('gagal di sisi native bisa dicoba lagi', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      throw PlatformException(code: 'bad');
    });
    await pushNativeStyle(nightStyle);
    await pushNativeStyle(nightStyle);
    expect(calls, hasLength(2));
  });

  test('tanpa kode native tidak melempar galat', () async {
    messenger.setMockMethodCallHandler(channel, null);
    await expectLater(pushNativeStyle(fieldNotesStyle), completes);
  });
}
