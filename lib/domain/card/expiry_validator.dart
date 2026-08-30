/// Validates and parses a card expiry entered as "MM/YY" or "MM/YYYY".
class ExpiryValidator {
  const ExpiryValidator._();

  static final _pattern = RegExp(r'^(0[1-9]|1[0-2])\/(\d{2}|\d{4})$');

  static bool hasValidFormat(String expiry) => _pattern.hasMatch(expiry);

  /// Returns true if the format is valid AND the expiry month/year has not
  /// already passed (compared to [now], defaulting to the current time).
  static bool isValidAndNotExpired(String expiry, {DateTime? now}) {
    if (!hasValidFormat(expiry)) return false;

    final parts = expiry.split('/');
    final month = int.parse(parts[0]);
    var year = int.parse(parts[1]);
    if (year < 100) year += 2000;

    final reference = now ?? DateTime.now();
    // Card is valid through the last day of the expiry month.
    final firstOfNextMonth = DateTime(year, month + 1);
    return reference.isBefore(firstOfNextMonth);
  }
}
