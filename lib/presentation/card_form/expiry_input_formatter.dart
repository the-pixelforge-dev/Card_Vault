import 'package:flutter/services.dart';

/// Formats expiry entry as MM/YY, inserting the slash automatically once
/// two valid month digits (01-12) have been typed while the user is typing
/// forward. Deleting (including deleting through the slash) is left alone
/// so backspace always behaves predictably.
class ExpiryInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final isDeleting = newValue.text.length < oldValue.text.length;
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    if (isDeleting) {
      // Never re-insert a slash the user just deleted through; just show
      // the plain digits (re-adding "/" happens again on the next forward
      // keystroke via the insertion path below).
      final month = digitsOnly.length >= 2
          ? digitsOnly.substring(0, 2)
          : digitsOnly;
      final year = digitsOnly.length > 2 ? digitsOnly.substring(2) : '';
      final text = year.isEmpty ? month : '$month/$year';
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }

    if (digitsOnly.length == 1) {
      final firstDigit = int.parse(digitsOnly);
      // Skip straight past an impossible first digit (3-9) to "0" + digit.
      if (firstDigit > 1) {
        final formatted = '0$digitsOnly/';
        return TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
      return TextEditingValue(
        text: digitsOnly,
        selection: TextSelection.collapsed(offset: digitsOnly.length),
      );
    }

    final month = digitsOnly.substring(0, 2);
    final monthValue = int.parse(month);
    if (monthValue < 1 || monthValue > 12) {
      // Invalid month — keep only the first digit and let the user retype.
      final firstDigit = digitsOnly.substring(0, 1);
      return TextEditingValue(
        text: firstDigit,
        selection: TextSelection.collapsed(offset: firstDigit.length),
      );
    }

    final year = digitsOnly.length > 2
        ? digitsOnly.substring(2, digitsOnly.length.clamp(0, 4))
        : '';
    final formatted = '$month/$year';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
