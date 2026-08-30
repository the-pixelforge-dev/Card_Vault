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
        passphrase: 'correct horse battery staple',
      );

      final decrypted = await cipher.decrypt(
        blob: blob,
        passphrase: 'correct horse battery staple',
      );

      expect(utf8.decode(decrypted), '{"cards":[{"nickname":"Test"}]}');
    });

    test('throws ExportDecryptionException on wrong passphrase', () async {
      final plainText = utf8.encode('secret data');
      final blob = await cipher.encrypt(
        plainText: plainText,
        passphrase: 'right passphrase',
      );

      expect(
        () => cipher.decrypt(blob: blob, passphrase: 'wrong passphrase'),
        throwsA(isA<ExportDecryptionException>()),
      );
    });

    test('KDF cost params travel with the blob', () async {
      final blob = await cipher.encrypt(
        plainText: utf8.encode('x'),
        passphrase: 'p',
      );
      expect(blob.memory, 256);
      expect(blob.iterations, 1);
      expect(blob.parallelism, 1);
      expect(blob.kdf, 'argon2id');
      expect(blob.cipher, 'aes-256-gcm');
    });
  });
}
