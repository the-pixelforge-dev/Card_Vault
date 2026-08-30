import 'package:card_vault/domain/card/card_network.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CardNetwork.validNumberLengths', () {
    test('Amex is 15 digits, not 16', () {
      expect(CardNetwork.amex.validNumberLengths, {15});
    });

    test('Diners Club accepts the classic 14-digit format', () {
      expect(CardNetwork.dinersClub.validNumberLengths.contains(14), isTrue);
    });

    test('Visa accepts 13, 16, and 19 digit variants', () {
      expect(CardNetwork.visa.validNumberLengths, {13, 16, 19});
    });

    test('unknown network has no length restriction of its own', () {
      expect(CardNetwork.unknown.validNumberLengths, isEmpty);
    });
  });
}
