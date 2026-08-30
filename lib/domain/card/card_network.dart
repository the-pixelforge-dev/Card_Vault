/// Card payment networks the app can auto-detect from a card number's BIN.
enum CardNetwork {
  visa('Visa', cvvLength: 3),
  mastercard('Mastercard', cvvLength: 3),
  amex('American Express', cvvLength: 4),
  discover('Discover', cvvLength: 3),
  rupay('RuPay', cvvLength: 3),
  dinersClub('Diners Club', cvvLength: 3),
  jcb('JCB', cvvLength: 3),
  unionPay('UnionPay', cvvLength: 3),
  unknown('Unknown', cvvLength: 3);

  const CardNetwork(this.displayName, {required this.cvvLength});

  final String displayName;

  /// Expected CVV/CVC digit length for this network (Amex uses 4-digit CID).
  final int cvvLength;
}
