import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce/hive.dart';

/// Owns the lifecycle of the AES-256 key that encrypts every Hive box.
///
/// The key itself is generated once and stored only in the platform
/// keystore/keychain via [FlutterSecureStorage] — it never touches a Hive
/// box, SharedPreferences, or any file on disk.
class KeyManager {
  KeyManager({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _hiveMasterKeyStorageKey = 'hive_master_key';

  final FlutterSecureStorage _secureStorage;

  /// Returns the existing Hive AES key, generating and persisting a new one
  /// on first run.
  Future<List<int>> getOrCreateHiveKey() async {
    final existing = await _secureStorage.read(key: _hiveMasterKeyStorageKey);
    if (existing != null) {
      return base64Decode(existing);
    }

    final generated = Hive.generateSecureKey();
    await _secureStorage.write(
      key: _hiveMasterKeyStorageKey,
      value: base64Encode(generated),
    );
    return generated;
  }

  Future<HiveCipher> getOrCreateHiveCipher() async {
    final key = await getOrCreateHiveKey();
    return HiveAesCipher(key);
  }
}
