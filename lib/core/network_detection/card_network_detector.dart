import '../../domain/card/card_network.dart';

/// Detects a [CardNetwork] from a card number's BIN/IIN prefix.
///
/// Ranges are best-effort and may need periodic verification against each
/// network's published IIN documentation (issuers occasionally receive new
/// range allocations).
class CardNetworkDetector {
  const CardNetworkDetector._();

  static CardNetwork detect(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return CardNetwork.unknown;

    if (_matchesAmex(digits)) return CardNetwork.amex;
    if (_matchesDinersClub(digits)) return CardNetwork.dinersClub;
    if (_matchesRuPay(digits)) return CardNetwork.rupay;
    if (_matchesDiscover(digits)) return CardNetwork.discover;
    if (_matchesJcb(digits)) return CardNetwork.jcb;
    if (_matchesUnionPay(digits)) return CardNetwork.unionPay;
    if (_matchesMastercard(digits)) return CardNetwork.mastercard;
    if (_matchesVisa(digits)) return CardNetwork.visa;

    return CardNetwork.unknown;
  }

  static bool _matchesVisa(String d) => d.startsWith('4');

  static bool _matchesMastercard(String d) {
    if (d.length < 2) return false;
    final twoDigit = int.parse(d.substring(0, 2));
    if (twoDigit >= 51 && twoDigit <= 55) return true;
    if (d.length < 4) return false;
    final fourDigit = int.parse(d.substring(0, 4));
    return fourDigit >= 2221 && fourDigit <= 2720;
  }

  static bool _matchesAmex(String d) =>
      d.startsWith('34') || d.startsWith('37');

  static bool _matchesDiscover(String d) {
    if (d.startsWith('6011') || d.startsWith('65')) return true;
    if (d.length >= 6) {
      final sixDigit = int.parse(d.substring(0, 6));
      if (sixDigit >= 622126 && sixDigit <= 622925) return true;
    }
    if (d.length >= 3) {
      final threeDigit = int.parse(d.substring(0, 3));
      if (threeDigit >= 644 && threeDigit <= 649) return true;
    }
    return false;
  }

  static bool _matchesRuPay(String d) {
    if (d.startsWith('508') || d.startsWith('81') || d.startsWith('82')) {
      return true;
    }
    if (d.length >= 6) {
      final sixDigit = int.parse(d.substring(0, 6));
      if (sixDigit >= 606985 && sixDigit <= 606999) return true;
      if (sixDigit >= 607000 && sixDigit <= 607099) return true;
      if (sixDigit >= 608001 && sixDigit <= 608999) return true;
      if (sixDigit >= 652150 && sixDigit <= 653149) return true;
    }
    return false;
  }

  static bool _matchesDinersClub(String d) {
    if (d.startsWith('36') || d.startsWith('38')) return true;
    if (d.length >= 3) {
      final threeDigit = int.parse(d.substring(0, 3));
      if (threeDigit >= 300 && threeDigit <= 305) return true;
    }
    return false;
  }

  static bool _matchesJcb(String d) {
    if (d.length < 4) return false;
    final fourDigit = int.parse(d.substring(0, 4));
    return fourDigit >= 3528 && fourDigit <= 3589;
  }

  static bool _matchesUnionPay(String d) => d.startsWith('62');
}
