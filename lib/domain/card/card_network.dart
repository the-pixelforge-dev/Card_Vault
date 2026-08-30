/// Card payment networks the app can auto-detect from a card number's BIN.
enum CardNetwork {
  visa('Visa', cvvLength: 3, validNumberLengths: {13, 16, 19}),
  mastercard('Mastercard', cvvLength: 3, validNumberLengths: {16}),
  amex('American Express', cvvLength: 4, validNumberLengths: {15}),
  discover('Discover', cvvLength: 3, validNumberLengths: {16, 19}),
  rupay('RuPay', cvvLength: 3, validNumberLengths: {16}),
  dinersClub('Diners Club', cvvLength: 3, validNumberLengths: {14, 16}),
  jcb('JCB', cvvLength: 3, validNumberLengths: {16, 17, 18, 19}),
  unionPay('UnionPay', cvvLength: 3, validNumberLengths: {16, 17, 18, 19}),
  unknown('Unknown', cvvLength: 3, validNumberLengths: {});

  const CardNetwork(
    this.displayName, {
    required this.cvvLength,
    required this.validNumberLengths,
  });

  final String displayName;

  /// Expected CVV/CVC digit length for this network (Amex uses 4-digit CID).
  final int cvvLength;

  /// Card number lengths this network actually issues. Empty for
  /// [unknown], where only the general 12-19 PAN range (enforced by
  /// [LuhnValidator]) applies.
  final Set<int> validNumberLengths;
}
