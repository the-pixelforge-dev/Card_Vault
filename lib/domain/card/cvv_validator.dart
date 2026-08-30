import 'card_network.dart';

/// Validates a CVV/CVC against the digit-length expected for a network.
class CvvValidator {
  const CvvValidator._();

  static bool isValid(String cvv, CardNetwork network) {
    if (!RegExp(r'^\d+$').hasMatch(cvv)) return false;
    return cvv.length == network.cvvLength;
  }
}
