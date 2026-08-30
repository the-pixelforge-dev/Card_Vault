import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores the app-specific unlock PIN as a salted PBKDF2 hash — never in
/// plaintext — in the platform Keystore/Keychain.
///
/// This PIN is the app's own, independent of any device-level screen lock,
/// so it works identically on a device or emulator with no OS lock screen
/// configured, and it is always available as a fallback if biometrics are
/// unavailable or fail — the app can never lock a user out with no way back
/// in short of the explicit "reset" escape hatch.
class PinStore {
  PinStore({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _hashKey = 'app_pin_hash';
  static const _saltKey = 'app_pin_salt';

  final FlutterSecureStorage _secureStorage;

  // Deliberately lighter than the export-file KDF cost: this runs on every
  // unlock attempt and must stay snappy. The primary defense for the PIN
  // hash is the platform Keystore/Keychain it's stored in, not KDF cost.
  static const _iterations = 20000;
  static const _bits = 256;

  Future<bool> hasPin() async {
    final hash = await _secureStorage.read(key: _hashKey);
    return hash != null;
  }

  Future<void> setPin(String pin) async {
    final salt = _randomBytes(16);
    final hash = await _hash(pin, salt);
    await _secureStorage.write(key: _saltKey, value: base64Encode(salt));
    await _secureStorage.write(key: _hashKey, value: base64Encode(hash));
  }

  Future<bool> verifyPin(String pin) async {
    final saltEncoded = await _secureStorage.read(key: _saltKey);
    final hashEncoded = await _secureStorage.read(key: _hashKey);
    if (saltEncoded == null || hashEncoded == null) return false;

    final salt = base64Decode(saltEncoded);
    final expectedHash = base64Decode(hashEncoded);
    final actualHash = await _hash(pin, salt);

    return _constantTimeEquals(actualHash, expectedHash);
  }

  Future<void> clear() async {
    await _secureStorage.delete(key: _hashKey);
    await _secureStorage.delete(key: _saltKey);
  }

  Future<List<int>> _hash(String pin, List<int> salt) async {
    final pbkdf2 = Pbkdf2.hmacSha256(iterations: _iterations, bits: _bits);
    final secretKey = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );
    return secretKey.extractBytes();
  }

  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }

  Uint8List _randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }
}
