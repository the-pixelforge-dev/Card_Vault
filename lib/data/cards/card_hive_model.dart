import 'package:hive_ce/hive.dart';

part 'card_hive_model.g.dart';

@HiveType(typeId: 0)
class CardHiveModel extends HiveObject {
  CardHiveModel({
    required this.id,
    required this.cardholderName,
    required this.cardNumber,
    required this.expiryMonthYear,
    required this.cvv,
    required this.issuerName,
    required this.network,
    this.cardType = 'credit',
    required this.nickname,
    required this.colorArgb,
    this.artworkImagePath,
    this.rewardsText = '',
    this.bestForText = '',
    this.rewardsUrl,
    this.paymentUrl,
    this.managementUrl,
    this.customerServiceUrl,
    Map<String, String>? customFields,
    this.notes = '',
    List<String>? groupIds,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  }) : customFields = customFields ?? {},
       groupIds = groupIds ?? [];

  @HiveField(0)
  String id;

  @HiveField(1)
  String cardholderName;

  @HiveField(2)
  String cardNumber;

  @HiveField(3)
  String expiryMonthYear;

  @HiveField(4)
  String cvv;

  @HiveField(5)
  String issuerName;

  /// Stored as [CardNetwork.name] (see domain/card/card_network.dart).
  @HiveField(6)
  String network;

  @HiveField(7)
  String nickname;

  @HiveField(8)
  int colorArgb;

  @HiveField(9)
  String? artworkImagePath;

  @HiveField(10)
  String rewardsText;

  @HiveField(11)
  String bestForText;

  @HiveField(12)
  String? rewardsUrl;

  @HiveField(13)
  String? paymentUrl;

  @HiveField(14)
  String? managementUrl;

  @HiveField(15)
  String? customerServiceUrl;

  @HiveField(16)
  Map<String, String> customFields;

  @HiveField(17)
  String notes;

  @HiveField(18)
  List<String> groupIds;

  @HiveField(19)
  int sortOrder;

  @HiveField(20)
  DateTime createdAt;

  @HiveField(21)
  DateTime updatedAt;

  /// Stored as [CardType.name] (see domain/card/card_type.dart).
  @HiveField(22)
  String cardType;
}
