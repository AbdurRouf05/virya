import 'dart:convert';
import 'dart:typed_data';

const _prefix = 'virya-circle:';
const _version = 1;

class PairingRequest {
  final String identityId;
  final String publicKey;

  const PairingRequest({required this.identityId, required this.publicKey});
}

class CircleInvite {
  final String circleId;
  final String circleName;
  final String issuerId;
  final String issuerName;
  final String issuerPublicKey;
  final String recipientId;
  final String recipientPublicKey;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String signature;

  const CircleInvite({
    required this.circleId,
    required this.circleName,
    required this.issuerId,
    required this.issuerName,
    required this.issuerPublicKey,
    required this.recipientId,
    required this.recipientPublicKey,
    required this.issuedAt,
    required this.expiresAt,
    required this.signature,
  });

  CircleInvite withSignature(String value) => CircleInvite(
    circleId: circleId,
    circleName: circleName,
    issuerId: issuerId,
    issuerName: issuerName,
    issuerPublicKey: issuerPublicKey,
    recipientId: recipientId,
    recipientPublicKey: recipientPublicKey,
    issuedAt: issuedAt,
    expiresAt: expiresAt,
    signature: value,
  );
}

class InviteFormatException implements Exception {
  final String message;
  const InviteFormatException(this.message);

  @override
  String toString() => message;
}

/// Format teks ringkas untuk QR atau clipboard. Tidak membawa rute, aktivitas,
/// foto, kontak, maupun kunci privat.
class CircleInviteCodec {
  static String encodeRequest(PairingRequest request) => _encode({
    'v': _version,
    't': 'request',
    'id': request.identityId,
    'key': request.publicKey,
  });

  static PairingRequest decodeRequest(String payload) {
    final map = _decode(payload, {'v', 't', 'id', 'key'});
    if (map['t'] != 'request') {
      throw const InviteFormatException('Bukan permintaan pasangan');
    }
    return PairingRequest(
      identityId: _text(map, 'id'),
      publicKey: _key(map, 'key'),
    );
  }

  static Uint8List signingBytes(CircleInvite invite) =>
      Uint8List.fromList(utf8.encode(jsonEncode(_unsigned(invite))));

  static String encodeInvite(CircleInvite invite) =>
      _encode({..._unsigned(invite), 'sig': invite.signature});

  static CircleInvite decodeInvite(String payload) {
    final map = _decode(payload, {
      'v',
      't',
      'circle',
      'name',
      'issuer',
      'issuerName',
      'issuerKey',
      'recipient',
      'recipientKey',
      'issued',
      'expires',
      'sig',
    });
    if (map['t'] != 'invite') {
      throw const InviteFormatException('Bukan undangan circle');
    }
    final issued = _time(map, 'issued');
    final expires = _time(map, 'expires');
    if (!expires.isAfter(issued)) {
      throw const InviteFormatException('Masa berlaku undangan tidak valid');
    }
    return CircleInvite(
      circleId: _text(map, 'circle'),
      circleName: _text(map, 'name'),
      issuerId: _text(map, 'issuer'),
      issuerName: _text(map, 'issuerName'),
      issuerPublicKey: _key(map, 'issuerKey'),
      recipientId: _text(map, 'recipient'),
      recipientPublicKey: _key(map, 'recipientKey'),
      issuedAt: issued,
      expiresAt: expires,
      signature: _key(map, 'sig'),
    );
  }

  static Map<String, Object> _unsigned(CircleInvite invite) => {
    'v': _version,
    't': 'invite',
    'circle': invite.circleId,
    'name': invite.circleName,
    'issuer': invite.issuerId,
    'issuerName': invite.issuerName,
    'issuerKey': invite.issuerPublicKey,
    'recipient': invite.recipientId,
    'recipientKey': invite.recipientPublicKey,
    'issued': invite.issuedAt.toUtc().millisecondsSinceEpoch,
    'expires': invite.expiresAt.toUtc().millisecondsSinceEpoch,
  };

  static String _encode(Map<String, Object> map) =>
      _prefix + base64Url.encode(utf8.encode(jsonEncode(map)));

  static Map<String, dynamic> _decode(String raw, Set<String> expected) {
    if (!raw.startsWith(_prefix)) {
      throw const InviteFormatException('Kode undangan tidak dikenali');
    }
    try {
      final value = jsonDecode(
        utf8.decode(base64Url.decode(raw.substring(_prefix.length))),
      );
      if (value is! Map<String, dynamic> ||
          value['v'] != _version ||
          value.keys.length != expected.length ||
          !value.keys.toSet().containsAll(expected)) {
        throw const InviteFormatException('Format undangan tidak didukung');
      }
      return value;
    } on FormatException {
      throw const InviteFormatException('Kode undangan rusak');
    }
  }

  static String _text(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! String || value.trim().isEmpty || value.length > 160) {
      throw InviteFormatException('Data $key tidak valid');
    }
    return value;
  }

  static String _key(Map<String, dynamic> map, String key) {
    final value = _text(map, key);
    try {
      base64Url.decode(value);
      return value;
    } on FormatException {
      throw InviteFormatException('Kunci $key tidak valid');
    }
  }

  static DateTime _time(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! int) {
      throw InviteFormatException('Waktu $key tidak valid');
    }
    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }
}
