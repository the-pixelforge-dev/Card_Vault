/// Whether a saved card is a credit or debit card.
enum CardType {
  credit('Credit Card'),
  debit('Debit Card');

  const CardType(this.displayName);

  final String displayName;
}
