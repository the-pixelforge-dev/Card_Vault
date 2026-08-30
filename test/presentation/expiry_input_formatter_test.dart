import 'package:card_vault/presentation/card_form/expiry_input_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

TextEditingValue _value(String text) =>
    TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));

void main() {
  group('ExpiryInputFormatter', () {
    late ExpiryInputFormatter formatter;

    setUp(() => formatter = ExpiryInputFormatter());

    test('inserts a slash once a valid two-digit month is typed', () {
      var result = formatter.formatEditUpdate(_value(''), _value('0'));
      expect(result.text, '0');

      result = formatter.formatEditUpdate(_value('0'), _value('09'));
      expect(result.text, '09/');
    });

    test('auto-pads a single digit month greater than 1', () {
      final result = formatter.formatEditUpdate(_value(''), _value('9'));
      expect(result.text, '09/');
    });

    test('rejects an invalid month and keeps only the first digit', () {
      var result = formatter.formatEditUpdate(_value(''), _value('1'));
      expect(result.text, '1');

      result = formatter.formatEditUpdate(_value('1'), _value('15'));
      expect(result.text, '1');
    });

    test('continues appending year digits after the slash', () {
      final result = formatter.formatEditUpdate(_value('09/'), _value('09/2'));
      expect(result.text, '09/2');
    });

    test('backspacing through the slash does not resurrect it', () {
      // Simulates the TextField already having removed the "/" character.
      final result = formatter.formatEditUpdate(_value('09/'), _value('09'));
      expect(result.text, '09');
    });

    test('clears entirely when all digits are deleted', () {
      final result = formatter.formatEditUpdate(_value('0'), _value(''));
      expect(result.text, '');
    });
  });
}
