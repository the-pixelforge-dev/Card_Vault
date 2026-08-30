import 'package:card_vault/domain/card/expiry_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpiryValidator', () {
    test('accepts well-formed MM/YY and MM/YYYY', () {
      expect(ExpiryValidator.hasValidFormat('09/28'), isTrue);
      expect(ExpiryValidator.hasValidFormat('09/2028'), isTrue);
    });

    test('rejects malformed input', () {
      expect(ExpiryValidator.hasValidFormat('13/28'), isFalse);
      expect(ExpiryValidator.hasValidFormat('00/28'), isFalse);
      expect(ExpiryValidator.hasValidFormat('9/28'), isFalse);
      expect(ExpiryValidator.hasValidFormat('09-28'), isFalse);
    });

    test('treats an expiry in a past month as expired', () {
      final now = DateTime(2026, 8, 30);
      expect(
        ExpiryValidator.isValidAndNotExpired('07/26', now: now),
        isFalse,
      );
    });

    test('treats the current month and future months as not expired', () {
      final now = DateTime(2026, 8, 30);
      expect(ExpiryValidator.isValidAndNotExpired('08/26', now: now), isTrue);
      expect(ExpiryValidator.isValidAndNotExpired('09/26', now: now), isTrue);
    });
  });
}
