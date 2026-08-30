import 'dart:convert';

import 'package:card_vault/core/security/crypto/export_cipher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExportCipher', () {
    // Low cost params so the test suite stays fast; production defaults are
    // set in ExportCipher's own constructor.
    const cipher = ExportCipher(memory: 256, iterations: 1, parallelism: 1);

    test('round-trips plaintext through encrypt/decrypt', () async {
      final plainText = utf8.encode('{"cards":[{"nickname":"Test"}]}');

      final blob = await cipher.encrypt(
        plainText: plainText,
        passcode: '482917',
      );

      final decrypted = await cipher.decrypt(blob: blob, passcode: '482917');

      expect(utf8.decode(decrypted), '{"cards":[{"nickname":"Test"}]}');
    });

    test('round-trips with the shortest allowed 4-digit passcode', () async {
      final plainText = utf8.encode('short passcode');
      final blob = await cipher.encrypt(plainText: plainText, passcode: '4821');
      final decrypted = await cipher.decrypt(blob: blob, passcode: '4821');
      expect(utf8.decode(decrypted), 'short passcode');
    });

    test('throws ExportDecryptionException on wrong passcode', () async {
      final plainText = utf8.encode('secret data');
      final blob = await cipher.encrypt(
        plainText: plainText,
        passcode: '135790',
      );

      expect(
        () => cipher.decrypt(blob: blob, passcode: '246801'),
        throwsA(isA<ExportDecryptionException>()),
      );
    });

    test('KDF cost params travel with the blob', () async {
      final blob = await cipher.encrypt(
        plainText: utf8.encode('x'),
        passcode: '1234',
      );
      expect(blob.memory, 256);
      expect(blob.iterations, 1);
      expect(blob.parallelism, 1);
      expect(blob.kdf, 'argon2id');
      expect(blob.cipher, 'aes-256-gcm');
    });
  });
}
