import 'package:card_vault/core/network_detection/card_network_detector.dart';
import 'package:card_vault/domain/card/card_network.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CardNetworkDetector', () {
    test('detects Visa', () {
      expect(
        CardNetworkDetector.detect('4111111111111111'),
        CardNetwork.visa,
      );
    });

    test('detects Mastercard (51-55 and 2221-2720 ranges)', () {
      expect(
        CardNetworkDetector.detect('5500000000000004'),
        CardNetwork.mastercard,
      );
      expect(
        CardNetworkDetector.detect('2223000048400011'),
        CardNetwork.mastercard,
      );
    });

    test('detects American Express', () {
      expect(CardNetworkDetector.detect('340000000000009'), CardNetwork.amex);
      expect(CardNetworkDetector.detect('370000000000002'), CardNetwork.amex);
    });

    test('detects Discover', () {
      expect(
        CardNetworkDetector.detect('6011000000000004'),
        CardNetwork.discover,
      );
    });

    test('detects Diners Club', () {
      expect(
        CardNetworkDetector.detect('36000000000008'),
        CardNetwork.dinersClub,
      );
    });

    test('detects JCB', () {
      expect(
        CardNetworkDetector.detect('3530111333300000'),
        CardNetwork.jcb,
      );
    });

    test('detects RuPay', () {
      expect(
        CardNetworkDetector.detect('6080011234567890'),
        CardNetwork.rupay,
      );
      expect(
        CardNetworkDetector.detect('8100001234567890'),
        CardNetwork.rupay,
      );
    });

    test('returns unknown for unrecognized or empty input', () {
      expect(CardNetworkDetector.detect(''), CardNetwork.unknown);
      expect(CardNetworkDetector.detect('9999999999999999'), CardNetwork.unknown);
    });
  });
}
