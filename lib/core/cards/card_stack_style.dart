/// Controls how the cards behind the front one in the home screen's card
/// stack are sized relative to it.
enum CardStackDepthStyle {
  shrink('Shrink'),
  uniform('Uniform');

  const CardStackDepthStyle(this.displayName);
  final String displayName;
}

/// Which card type filter the home screen's stack and group dropdown start
/// on. Mirrors the "All Cards"/"Credit Cards"/"Debit Cards" entries at the
/// top of that dropdown's picker sheet.
enum DefaultCardStackFilter {
  all('All Cards'),
  credit('Credit Cards'),
  debit('Debit Cards');

  const DefaultCardStackFilter(this.displayName);
  final String displayName;
}
