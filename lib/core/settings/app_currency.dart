/// The top 20 most commonly used currencies, for displaying money amounts
/// (e.g. a card's credit limit) with a familiar symbol.
enum AppCurrency {
  usd('USD', r'$', 'US Dollar'),
  eur('EUR', '€', 'Euro'),
  gbp('GBP', '£', 'British Pound'),
  jpy('JPY', '¥', 'Japanese Yen'),
  inr('INR', '₹', 'Indian Rupee'),
  aud('AUD', r'A$', 'Australian Dollar'),
  cad('CAD', r'C$', 'Canadian Dollar'),
  chf('CHF', 'Fr', 'Swiss Franc'),
  cny('CNY', '¥', 'Chinese Yuan'),
  sek('SEK', 'kr', 'Swedish Krona'),
  nzd('NZD', r'NZ$', 'New Zealand Dollar'),
  mxn('MXN', r'Mex$', 'Mexican Peso'),
  sgd('SGD', r'S$', 'Singapore Dollar'),
  hkd('HKD', r'HK$', 'Hong Kong Dollar'),
  nok('NOK', 'kr', 'Norwegian Krone'),
  krw('KRW', '₩', 'South Korean Won'),
  tryLira('TRY', '₺', 'Turkish Lira'),
  rub('RUB', '₽', 'Russian Ruble'),
  brl('BRL', r'R$', 'Brazilian Real'),
  zar('ZAR', 'R', 'South African Rand');

  const AppCurrency(this.code, this.symbol, this.currencyName);

  final String code;
  final String symbol;
  final String currencyName;

  String get displayName => '$currencyName ($symbol)';
}
