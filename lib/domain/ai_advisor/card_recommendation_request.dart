import '../card/card_entity.dart';

/// Sanitized, non-sensitive view of a card sent to Gemini for the purchase
/// advisor. Deliberately built via an explicit allow-list of fields rather
/// than by excluding fields from [CardEntity], so a new sensitive field
/// added to the card model can never leak into an AI request by omission.
class SanitizedCardSummary {
  const SanitizedCardSummary({
    required this.id,
    required this.nickname,
    required this.issuerName,
    required this.networkName,
    required this.rewardsText,
    required this.bestForText,
    required this.groupNames,
  });

  factory SanitizedCardSummary.fromEntity(
    CardEntity card, {
    required List<String> groupNames,
  }) {
    return SanitizedCardSummary(
      id: card.id,
      nickname: card.nickname,
      issuerName: card.issuerName,
      networkName: card.network.displayName,
      rewardsText: card.rewardsText,
      bestForText: card.bestForText,
      groupNames: groupNames,
    );
  }

  final String id;
  final String nickname;
  final String issuerName;
  final String networkName;
  final String rewardsText;
  final String bestForText;
  final List<String> groupNames;

  Map<String, Object?> toJson() => {
    'id': id,
    'nickname': nickname,
    'issuer': issuerName,
    'network': networkName,
    'rewards': rewardsText,
    'bestFor': bestForText,
    'groups': groupNames,
  };
}

/// The full request sent to the advisor: what the user wants to buy, plus
/// the sanitized card summaries to choose among.
class CardRecommendationRequest {
  const CardRecommendationRequest({
    required this.purchaseDescription,
    required this.purchaseAmount,
    required this.cards,
  });

  final String purchaseDescription;
  final double? purchaseAmount;
  final List<SanitizedCardSummary> cards;
}
