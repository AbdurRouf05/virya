import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/database/daos/social_dao.dart';
import 'package:virya/features/social/domain/circle_invite.dart';

const _socialKeyName = 'virya.social.ed25519';

/// Penyimpanan privat untuk pasangan kunci identitas perangkat.
abstract class SocialKeyStore {
  Future<SimpleKeyPairData?> read();
  Future<void> write(SimpleKeyPairData pair);
}

class SecureSocialKeyStore implements SocialKeyStore {
  final FlutterSecureStorage _storage;
  const SecureSocialKeyStore([this._storage = const FlutterSecureStorage()]);

  @override
  Future<SimpleKeyPairData?> read() async {
    final raw = await _storage.read(key: _socialKeyName);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return SimpleKeyPairData(
        base64Url.decode(json['private'] as String),
        type: KeyPairType.ed25519,
        publicKey: SimplePublicKey(
          base64Url.decode(json['public'] as String),
          type: KeyPairType.ed25519,
        ),
      );
    } on FormatException {
      throw StateError('Kunci identitas perangkat tidak valid');
    }
  }

  @override
  Future<void> write(SimpleKeyPairData pair) => _storage.write(
    key: _socialKeyName,
    value: jsonEncode({
      'private': base64Url.encode(pair.bytes),
      'public': base64Url.encode(pair.publicKey.bytes),
    }),
  );
}

/// Penyimpanan kunci dalam memori untuk unit test.
class MemorySocialKeyStore implements SocialKeyStore {
  SimpleKeyPairData? _pair;

  @override
  Future<SimpleKeyPairData?> read() async => _pair;

  @override
  Future<void> write(SimpleKeyPairData pair) async {
    _pair = pair;
  }
}

/// Data identitas yang aman ditampilkan atau dipakai oleh modul sosial.
class LocalSocialIdentity {
  final String id;
  final String displayName;
  final String publicKey;

  const LocalSocialIdentity({
    required this.id,
    required this.displayName,
    required this.publicKey,
  });
}

/// Semua perubahan identitas dan circle lokal harus masuk lewat repository ini.
class SocialRepository {
  static const _uuid = Uuid();

  final SocialDao _dao;
  final SocialKeyStore _keyStore;
  final Ed25519 _algorithm;

  SocialRepository(this._dao, {SocialKeyStore? keyStore, Ed25519? algorithm})
    : _keyStore = keyStore ?? SecureSocialKeyStore(),
      _algorithm = algorithm ?? Ed25519();

  Future<LocalSocialIdentity?> localIdentity() async {
    final row = await _dao.localIdentity();
    if (row == null) return null;
    return LocalSocialIdentity(
      id: row.id,
      displayName: row.displayName,
      publicKey: row.publicKey,
    );
  }

  /// Membuat satu identitas lokal. Null bila nama kosong.
  Future<LocalSocialIdentity?> ensureIdentity(String rawName) async {
    final name = _name(rawName);
    if (name == null) return null;
    final existing = await localIdentity();
    if (existing != null) {
      if (await _keyStore.read() == null) {
        throw StateError('Kunci identitas perangkat tidak ditemukan');
      }
      return existing;
    }
    final pair = await _algorithm.newKeyPair();
    final data = await pair.extract();
    final publicKey = base64Url.encode(data.publicKey.bytes);
    final identity = LocalSocialIdentity(
      id: _uuid.v4(),
      displayName: name,
      publicKey: publicKey,
    );
    await _keyStore.write(data);
    try {
      await _dao.insertIdentity(
        SocialIdentitiesCompanion.insert(
          id: identity.id,
          displayName: identity.displayName,
          publicKey: identity.publicKey,
          isLocal: const Value(true),
          createdAt: DateTime.now().toUtc(),
        ),
      );
    } catch (_) {
      final winner = await localIdentity();
      if (winner == null) rethrow;
      return winner;
    }
    return identity;
  }

  /// Membuat circle dengan pemilik identitas lokal. Null bila nama tidak valid.
  Future<String?> createCircle(String rawName) async {
    final name = _name(rawName);
    final owner = await localIdentity();
    if (name == null || owner == null) return null;
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    await _dao.createOwnedCircle(
      circle: SocialCirclesCompanion.insert(
        id: id,
        name: name,
        ownerIdentityId: owner.id,
        createdAt: now,
        updatedAt: now,
      ),
      owner: CircleMembersCompanion.insert(
        circleId: id,
        identityId: owner.id,
        role: const Value('owner'),
        joinedAt: now,
      ),
    );
    return id;
  }

  Future<String> createPairingRequest() async {
    final identity = await localIdentity();
    if (identity == null) throw StateError('Buat identitas terlebih dahulu');
    return CircleInviteCodec.encodeRequest(
      PairingRequest(identityId: identity.id, publicKey: identity.publicKey),
    );
  }

  Future<String> issueInvite(
    String circleId,
    String pairingPayload, {
    Duration validFor = const Duration(minutes: 10),
  }) async {
    final owner = await localIdentity();
    final pair = await _keyStore.read();
    final request = CircleInviteCodec.decodeRequest(pairingPayload);
    final circle = await _dao.circleById(circleId);
    if (owner == null ||
        pair == null ||
        circle == null ||
        circle.ownerIdentityId != owner.id) {
      throw StateError('Hanya pemilik circle yang dapat membuat undangan');
    }
    if (request.identityId == owner.id) {
      throw const InviteFormatException(
        'Tidak bisa mengundang identitas sendiri',
      );
    }
    final now = DateTime.now().toUtc();
    final unsigned = CircleInvite(
      circleId: circle.id,
      circleName: circle.name,
      issuerId: owner.id,
      issuerName: owner.displayName,
      issuerPublicKey: owner.publicKey,
      recipientId: request.identityId,
      recipientPublicKey: request.publicKey,
      issuedAt: now,
      expiresAt: now.add(validFor),
      signature: '',
    );
    final signature = await _algorithm.sign(
      CircleInviteCodec.signingBytes(unsigned),
      keyPair: pair,
    );
    return CircleInviteCodec.encodeInvite(
      unsigned.withSignature(base64Url.encode(signature.bytes)),
    );
  }

  /// Menyimpan otorisasi undangan pada perangkat penerima. Circle pemilik
  /// belum diberi tahu hingga transport peer-to-peer tersedia.
  Future<String> acceptInvite(String payload, {DateTime? now}) async {
    final invite = CircleInviteCodec.decodeInvite(payload);
    final recipient = await localIdentity();
    if (recipient == null) throw StateError('Buat identitas terlebih dahulu');
    final at = (now ?? DateTime.now()).toUtc();
    if (!invite.expiresAt.isAfter(at)) {
      throw const InviteFormatException('Undangan sudah kedaluwarsa');
    }
    if (invite.issuerId == recipient.id ||
        invite.recipientId != recipient.id ||
        invite.recipientPublicKey != recipient.publicKey) {
      throw const InviteFormatException(
        'Undangan ini bukan untuk identitas perangkat ini',
      );
    }
    final verified = await _algorithm.verify(
      CircleInviteCodec.signingBytes(invite),
      signature: Signature(
        base64Url.decode(invite.signature),
        publicKey: SimplePublicKey(
          base64Url.decode(invite.issuerPublicKey),
          type: KeyPairType.ed25519,
        ),
      ),
    );
    if (!verified) {
      throw const InviteFormatException('Tanda tangan undangan tidak valid');
    }
    final existing = await _dao.circleById(invite.circleId);
    if (existing != null &&
        (existing.ownerIdentityId != invite.issuerId ||
            existing.name != invite.circleName)) {
      throw const InviteFormatException(
        'Circle lokal tidak cocok dengan undangan',
      );
    }
    await _dao.saveAcceptedInvite(
      issuer: SocialIdentitiesCompanion.insert(
        id: invite.issuerId,
        displayName: invite.issuerName,
        publicKey: invite.issuerPublicKey,
        createdAt: invite.issuedAt,
      ),
      circle: SocialCirclesCompanion.insert(
        id: invite.circleId,
        name: invite.circleName,
        ownerIdentityId: invite.issuerId,
        createdAt: invite.issuedAt,
        updatedAt: invite.issuedAt,
      ),
      owner: CircleMembersCompanion.insert(
        circleId: invite.circleId,
        identityId: invite.issuerId,
        role: const Value('owner'),
        joinedAt: invite.issuedAt,
      ),
      recipient: CircleMembersCompanion.insert(
        circleId: invite.circleId,
        identityId: recipient.id,
        joinedAt: at,
      ),
    );
    return invite.circleId;
  }

  String? _name(String raw) {
    final value = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    return value.isEmpty ? null : value;
  }
}
