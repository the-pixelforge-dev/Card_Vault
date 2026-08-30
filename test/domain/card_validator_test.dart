import 'package:card_vault/domain/card/card_entity.dart';
import 'package:card_vault/domain/card/card_network.dart';
import 'package:card_vault/domain/card/card_validator.dart';
import 'package:flutter_test/flutter_test.dart';

CardEntity _card({
  String cardholderName = 'Jane Doe',
  String cardNumber = '4111111111111111',
  String expiryMonthYear = '09/28',
  String cvv = '123',
  String issuerName = 'Test Bank',
  String nickname = 'Test Card',
  CardNetwork network = CardNetwork.visa,
}) {
  final now = DateTime.now();
  return CardEntity(
    id: 'id',
    cardholderName: cardholderName,
    cardNumber: cardNumber,
    expiryMonthYear: expiryMonthYear,
    cvv: cvv,
    issuerName: issuerName,
    network: network,
    nickname: nickname,
    colorArgb: 0xFF000000,
    sortOrder: 0,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('CardValidator', () {
    test('accepts a fully-filled-out card', () {
      expect(() => CardValidator.ensureValid(_card()), returnsNormally);
    });

    test('rejects a completely empty card', () {
      final card = _card(
        cardholderName: '',
        cardNumber: '',
        expiryMonthYear: '',
        cvv: '',
        issuerName: '',
        nickname: '',
      );
      expect(
        () => CardValidator.ensureValid(card),
        throwsA(isA<CardValidationException>()),
      );
    });

    test('rejects a card missing only the number', () {
      final card = _card(cardNumber: '');
      expect(
        () => CardValidator.ensureValid(card),
        throwsA(isA<CardValidationException>()),
      );
    });

    test('rejects a card missing only the CVV', () {
      final card = _card(cvv: '');
      expect(
        () => CardValidator.ensureValid(card),
        throwsA(isA<CardValidationException>()),
      );
    });

    test('rejects a card missing only the expiry', () {
      final card = _card(expiryMonthYear: '');
      expect(
        () => CardValidator.ensureValid(card),
        throwsA(isA<CardValidationException>()),
      );
    });

    test('rejects a card whose number length does not match its network', () {
      // 16 digits passed as an Amex card, which must be 15.
      final card = _card(
        cardNumber: '4111111111111111',
        network: CardNetwork.amex,
        cvv: '1234',
      );
      expect(
        () => CardValidator.ensureValid(card),
        throwsA(isA<CardValidationException>()),
      );
    });
  });
}
