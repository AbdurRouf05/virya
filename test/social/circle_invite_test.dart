import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/social/data/social_repository.dart';
import 'package:virya/features/social/domain/circle_invite.dart';

void main() {
  late AppDatabase ownerDb;
  late AppDatabase memberDb;
  late SocialRepository owner;
  late SocialRepository member;

  setUp(() {
    ownerDb = AppDatabase.memory();
    memberDb = AppDatabase.memory();
    owner = SocialRepository(
      ownerDb.socialDao,
      keyStore: MemorySocialKeyStore(),
    );
    member = SocialRepository(
      memberDb.socialDao,
      keyStore: MemorySocialKeyStore(),
    );
  });

  tearDown(() async {
    await ownerDb.close();
    await memberDb.close();
  });

  Future<String> invite({
    Duration validFor = const Duration(minutes: 10),
  }) async {
    await owner.ensureIdentity('Laras');
    final circleId = (await owner.createCircle('Night Runners'))!;
    await member.ensureIdentity('Raka');
    return owner.issueInvite(
      circleId,
      await member.createPairingRequest(),
      validFor: validFor,
    );
  }

  test(
    'invite bertanda tangan hanya berlaku untuk penerima yang diminta',
    () async {
      final payload = await invite();
      final circleId = await member.acceptInvite(payload);

      expect(circleId, isNotEmpty);
      expect(await member.acceptInvite(payload), circleId);
      final circles = await memberDb.select(memberDb.socialCircles).get();
      final memberships = await memberDb.select(memberDb.circleMembers).get();
      expect(circles.single.name, 'Night Runners');
      expect(memberships, hasLength(2));
    },
  );

  test(
    'invite rusak, kedaluwarsa, atau untuk identitas lain ditolak',
    () async {
      final payload = await invite();
      final wrongDevice = AppDatabase.memory();
      final wrongRepo = SocialRepository(
        wrongDevice.socialDao,
        keyStore: MemorySocialKeyStore(),
      );
      await wrongRepo.ensureIdentity('Nia');

      expect(
        () => wrongRepo.acceptInvite(payload),
        throwsA(isA<InviteFormatException>()),
      );
      expect(
        () =>
            member.acceptInvite('${payload.substring(0, payload.length - 1)}x'),
        throwsA(isA<InviteFormatException>()),
      );
      final expired = await invite(validFor: const Duration(minutes: -1));
      expect(
        () => member.acceptInvite(expired),
        throwsA(isA<InviteFormatException>()),
      );
      await wrongDevice.close();
    },
  );

  test(
    'pairing and invite payloads do not contain private activity data',
    () async {
      final payload = await invite();
      final raw = utf8.decode(
        base64Url.decode(payload.substring('virya-circle:'.length)),
      );

      expect(raw, contains('"circle"'));
      expect(raw, isNot(contains('route')));
      expect(raw, isNot(contains('location')));
      expect(raw, isNot(contains('activity')));
      expect(raw, isNot(contains('private')));
    },
  );
}
