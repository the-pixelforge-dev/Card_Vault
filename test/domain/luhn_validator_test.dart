import 'package:card_vault/domain/card/luhn_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LuhnValidator', () {
    test('accepts known-valid test card numbers', () {
      expect(LuhnValidator.isValid('4111111111111111'), isTrue); // Visa
      expect(LuhnValidator.isValid('5500000000000004'), isTrue); // Mastercard
      expect(LuhnValidator.isValid('340000000000009'), isTrue); // Amex
      expect(LuhnValidator.isValid('6011000000000004'), isTrue); // Discover
    });

    test('accepts numbers with spaces/dashes', () {
      expect(LuhnValidator.isValid('4111 1111 1111 1111'), isTrue);
      expect(LuhnValidator.isValid('4111-1111-1111-1111'), isTrue);
    });

    test('rejects a number with a corrupted digit', () {
      expect(LuhnValidator.isValid('4111111111111112'), isFalse);
    });

    test('rejects numbers outside the valid length range', () {
      expect(LuhnValidator.isValid('4111'), isFalse);
      expect(LuhnValidator.isValid(''), isFalse);
    });
  });
}
