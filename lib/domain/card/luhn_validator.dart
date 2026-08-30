/// Validates a card number against the Luhn (mod 10) checksum algorithm.
class LuhnValidator {
  const LuhnValidator._();

  static bool isValid(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 12 || digits.length > 19) return false;

    var sum = 0;
    var alternate = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var digit = int.parse(digits[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }
}
