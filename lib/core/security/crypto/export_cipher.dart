import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Thrown when decrypting an export fails — either the passcode was wrong
/// or the file was corrupted/tampered with (the AES-GCM auth tag no longer
/// matches).
class ExportDecryptionException implements Exception {
  const ExportDecryptionException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// A self-describing encrypted export container. The KDF cost parameters
/// travel with the file (rather than being hardcoded in the app) so tuning
/// them later never breaks restoring an older export.
class EncryptedExportBlob {
  const EncryptedExportBlob({
    required this.formatVersion,
    required this.kdf,
    required this.memory,
    required this.iterations,
    required this.parallelism,
    required this.cipher,
    required this.saltBase64,
    required this.payloadBase64,
  });

  factory EncryptedExportBlob.fromJson(Map<String, Object?> json) {
    return EncryptedExportBlob(
      formatVersion: json['formatVersion'] as int,
      kdf: json['kdf'] as String,
      memory: json['memory'] as int,
      iterations: json['iterations'] as int,
      parallelism: json['parallelism'] as int,
      cipher: json['cipher'] as String,
      saltBase64: json['salt'] as String,
      payloadBase64: json['payload'] as String,
    );
  }

  final int formatVersion;
  final String kdf;
  final int memory;
  final int iterations;
  final int parallelism;
  final String cipher;
  final String saltBase64;
  final String payloadBase64;

  Map<String, Object?> toJson() => {
    'formatVersion': formatVersion,
    'kdf': kdf,
    'memory': memory,
    'iterations': iterations,
    'parallelism': parallelism,
    'cipher': cipher,
    'salt': saltBase64,
    'payload': payloadBase64,
  };

  String encodePretty() => const JsonEncoder.withIndent('  ').convert(toJson());
}

/// Encrypts/decrypts the export file using a passcode-derived key
/// (Argon2id) that is entirely separate from the device's own Hive Keystore
/// key — this is what makes an export portable to a new device.
///
/// The passcode is a short numeric code (4-10 digits, enforced by the UI)
/// rather than a free-form passphrase, so it has far less entropy than a
/// typical password — a 4-digit code is only 10,000 possibilities. The KDF
/// cost below is set high specifically to compensate: it can't turn a weak
/// passcode into a strong one, but it does make offline brute-forcing the
/// exported file meaningfully slower than it would be against a fast hash.
class ExportCipher {
  const ExportCipher({
    this.memory = 65536, // 64 MiB
    this.iterations = 3,
    this.parallelism = 1,
  });

  final int memory;
  final int iterations;
  final int parallelism;

  static const _formatVersion = 1;
  static const _kdfName = 'argon2id';
  static const _cipherName = 'aes-256-gcm';
  static const _keyLength = 32;
  static const _saltLength = 16;

  Future<EncryptedExportBlob> encrypt({
    required List<int> plainText,
    required String passcode,
  }) async {
    final salt = _randomBytes(_saltLength);
    final secretKey = await _deriveKey(
      passcode: passcode,
      salt: salt,
      memory: memory,
      iterations: iterations,
      parallelism: parallelism,
    );

    final aesGcm = AesGcm.with256bits();
    final secretBox = await aesGcm.encrypt(plainText, secretKey: secretKey);

    return EncryptedExportBlob(
      formatVersion: _formatVersion,
      kdf: _kdfName,
      memory: memory,
      iterations: iterations,
      parallelism: parallelism,
      cipher: _cipherName,
      saltBase64: base64Encode(salt),
      payloadBase64: base64Encode(secretBox.concatenation()),
    );
  }

  Future<List<int>> decrypt({
    required EncryptedExportBlob blob,
    required String passcode,
  }) async {
    if (blob.kdf != _kdfName || blob.cipher != _cipherName) {
      throw const ExportDecryptionException(
        'Unsupported export format or cipher.',
      );
    }

    final salt = base64Decode(blob.saltBase64);
    final secretKey = await _deriveKey(
      passcode: passcode,
      salt: salt,
      memory: blob.memory,
      iterations: blob.iterations,
      parallelism: blob.parallelism,
    );

    final aesGcm = AesGcm.with256bits();
    final payload = base64Decode(blob.payloadBase64);
    final secretBox = SecretBox.fromConcatenation(
      payload,
      nonceLength: aesGcm.nonceLength,
      macLength: aesGcm.macAlgorithm.macLength,
    );

    try {
      return await aesGcm.decrypt(secretBox, secretKey: secretKey);
    } on SecretBoxAuthenticationError {
      throw const ExportDecryptionException(
        'Incorrect passcode or corrupted file.',
      );
    }
  }

  Future<SecretKey> _deriveKey({
    required String passcode,
    required List<int> salt,
    required int memory,
    required int iterations,
    required int parallelism,
  }) {
    final argon2id = Argon2id(
      parallelism: parallelism,
      memory: memory,
      iterations: iterations,
      hashLength: _keyLength,
    );
    return argon2id.deriveKey(
      secretKey: SecretKey(utf8.encode(passcode)),
      nonce: salt,
    );
  }

  Uint8List _randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }
}
