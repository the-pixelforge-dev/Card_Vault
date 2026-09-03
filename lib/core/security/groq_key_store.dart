import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores the user's own Groq API key, if they choose to provide one.
///
/// Lives only in the platform Keystore/Keychain via [FlutterSecureStorage] —
/// never in a Hive box, and never included in an encrypted export (a live
/// credential isn't app data, and re-entering it on a new device is safer
/// than baking it into a backup file that might travel further than
/// intended).
class GroqKeyStore {
  GroqKeyStore({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _storageKey = 'groq_api_key';

  final FlutterSecureStorage _secureStorage;

  Future<String?> read() => _secureStorage.read(key: _storageKey);

  Future<void> write(String apiKey) =>
      _secureStorage.write(key: _storageKey, value: apiKey);

  Future<void> clear() => _secureStorage.delete(key: _storageKey);
}
