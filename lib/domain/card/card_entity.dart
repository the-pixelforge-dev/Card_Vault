import 'card_network.dart';
import 'card_type.dart';

/// Pure-Dart representation of a saved card, independent of Hive.
class CardEntity {
  const CardEntity({
    required this.id,
    required this.cardholderName,
    required this.cardNumber,
    required this.expiryMonthYear,
    required this.cvv,
    required this.issuerName,
    required this.network,
    this.cardType = CardType.credit,
    required this.nickname,
    required this.colorArgb,
    this.artworkImagePath,
    this.rewardsText = '',
    this.bestForText = '',
    this.rewardsUrl,
    this.paymentUrl,
    this.managementUrl,
    this.customerServiceUrl,
    this.customFields = const {},
    this.notes = '',
    this.groupIds = const [],
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String cardholderName;
  final String cardNumber;
  final String expiryMonthYear;
  final String cvv;
  final String issuerName;
  final CardNetwork network;
  final CardType cardType;
  final String nickname;
  final int colorArgb;
  final String? artworkImagePath;
  final String rewardsText;
  final String bestForText;
  final String? rewardsUrl;
  final String? paymentUrl;
  final String? managementUrl;
  final String? customerServiceUrl;
  final Map<String, String> customFields;
  final String notes;
  final List<String> groupIds;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Last 4 digits, for masked display.
  String get lastFourDigits {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return digits;
    return digits.substring(digits.length - 4);
  }

  String get maskedCardNumber => '•••• •••• •••• $lastFourDigits';

  CardEntity copyWith({
    String? cardholderName,
    String? cardNumber,
    String? expiryMonthYear,
    String? cvv,
    String? issuerName,
    CardNetwork? network,
    CardType? cardType,
    String? nickname,
    int? colorArgb,
    String? artworkImagePath,
    String? rewardsText,
    String? bestForText,
    String? rewardsUrl,
    String? paymentUrl,
    String? managementUrl,
    String? customerServiceUrl,
    Map<String, String>? customFields,
    String? notes,
    List<String>? groupIds,
    int? sortOrder,
    DateTime? updatedAt,
  }) {
    return CardEntity(
      id: id,
      cardholderName: cardholderName ?? this.cardholderName,
      cardNumber: cardNumber ?? this.cardNumber,
      expiryMonthYear: expiryMonthYear ?? this.expiryMonthYear,
      cvv: cvv ?? this.cvv,
      issuerName: issuerName ?? this.issuerName,
      network: network ?? this.network,
      cardType: cardType ?? this.cardType,
      nickname: nickname ?? this.nickname,
      colorArgb: colorArgb ?? this.colorArgb,
      artworkImagePath: artworkImagePath ?? this.artworkImagePath,
      rewardsText: rewardsText ?? this.rewardsText,
      bestForText: bestForText ?? this.bestForText,
      rewardsUrl: rewardsUrl ?? this.rewardsUrl,
      paymentUrl: paymentUrl ?? this.paymentUrl,
      managementUrl: managementUrl ?? this.managementUrl,
      customerServiceUrl: customerServiceUrl ?? this.customerServiceUrl,
      customFields: customFields ?? this.customFields,
      notes: notes ?? this.notes,
      groupIds: groupIds ?? this.groupIds,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
