import 'package:card_vault/domain/card/card_network.dart';
import 'package:card_vault/domain/card/cvv_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CvvValidator', () {
    test('accepts 3-digit CVV for non-Amex networks', () {
      expect(CvvValidator.isValid('123', CardNetwork.visa), isTrue);
      expect(CvvValidator.isValid('123', CardNetwork.mastercard), isTrue);
    });

    test('requires 4-digit CID for Amex', () {
      expect(CvvValidator.isValid('123', CardNetwork.amex), isFalse);
      expect(CvvValidator.isValid('1234', CardNetwork.amex), isTrue);
    });

    test('rejects non-numeric input', () {
      expect(CvvValidator.isValid('12a', CardNetwork.visa), isFalse);
    });
  });
}
