import 'package:flutter/services.dart';

import '../../core/network_detection/card_network_detector.dart';
import '../../domain/card/card_network.dart';

/// Groups card number digits as the user types, using the spacing
/// convention for the detected network — 4-6-5 for American Express,
/// 4-6-4 for Diners Club, and 4-4-4-4(-...) for everyone else (Visa,
/// Mastercard, and other 16+ digit PANs).
class CardNumberInputFormatter extends TextInputFormatter {
  static const _amexGroups = [4, 6, 5];
  static const _dinersClubGroups = [4, 6, 4];
  static const _defaultGroups = [4, 4, 4, 4, 4];

  /// Groups a raw (or already-formatted) card number string, e.g. for
  /// pre-filling a field with a value that didn't pass through
  /// [formatEditUpdate], such as an existing card's saved number.
  static String format(String rawValue) {
    final digits = rawValue.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';

    final groupSizes = switch (CardNetworkDetector.detect(digits)) {
      CardNetwork.amex => _amexGroups,
      CardNetwork.dinersClub => _dinersClubGroups,
      _ => _defaultGroups,
    };

    final buffer = StringBuffer();
    var index = 0;
    for (final size in groupSizes) {
      if (index >= digits.length) break;
      final end = (index + size).clamp(0, digits.length);
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(digits.substring(index, end));
      index = end;
    }
    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = format(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
