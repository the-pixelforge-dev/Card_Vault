import 'card_entity.dart';
import 'cvv_validator.dart';
import 'expiry_validator.dart';
import 'luhn_validator.dart';

/// Thrown by [CardValidator.ensureValid] when a card is missing a required
/// field or has an invalid value.
class CardValidationException implements Exception {
  const CardValidationException(this.errors);
  final List<String> errors;

  @override
  String toString() => errors.join(' ');
}

/// The single source of truth for "is this card complete enough to save."
///
/// This runs at the data boundary (see [CardList.upsert]) rather than only
/// in the add/edit form's UI validators, so it is impossible for a card
/// missing a required field to reach persistent storage through any code
/// path — the form, a future UI change, or the encrypted-import flow.
class CardValidator {
  const CardValidator._();

  static void ensureValid(CardEntity card) {
    final errors = <String>[];

    if (card.cardholderName.trim().isEmpty) {
      errors.add('Cardholder name is required.');
    }

    final digits = card.cardNumber.replaceAll(RegExp(r'\D'), '');
    if (!LuhnValidator.isValid(digits)) {
      errors.add('A valid card number is required.');
    } else if (card.network.validNumberLengths.isNotEmpty &&
        !card.network.validNumberLengths.contains(digits.length)) {
      errors.add(
        '${card.network.displayName} numbers must be '
        '${(card.network.validNumberLengths.toList()..sort()).join(" or ")} digits.',
      );
    }

    if (!ExpiryValidator.hasValidFormat(card.expiryMonthYear)) {
      errors.add('A valid expiry (MM/YY) is required.');
    }

    if (!CvvValidator.isValid(card.cvv, card.network)) {
      errors.add('A valid ${card.network.cvvLength}-digit CVV is required.');
    }

    if (card.issuerName.trim().isEmpty) {
      errors.add('Issuer is required.');
    }

    if (card.nickname.trim().isEmpty) {
      errors.add('Card name is required.');
    }

    if (errors.isNotEmpty) {
      throw CardValidationException(errors);
    }
  }
}
