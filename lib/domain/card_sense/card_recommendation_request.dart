import '../card/card_entity.dart';

/// Sanitized, non-sensitive view of a card sent to Groq for Card Sense's
/// purchase recommendation. Deliberately built via an explicit allow-list of fields rather
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
    required this.notes,
  });

  factory SanitizedCardSummary.fromEntity(CardEntity card) {
    return SanitizedCardSummary(
      id: card.id,
      nickname: card.nickname,
      issuerName: card.issuerName,
      networkName: card.network.displayName,
      rewardsText: card.rewardsText,
      bestForText: card.bestForText,
      notes: card.notes,
    );
  }

  final String id;
  final String nickname;
  final String issuerName;
  final String networkName;
  final String rewardsText;
  final String bestForText;

  /// The card's free-text Notes field, included because it's often where
  /// reward caveats/exclusions end up (e.g. "no points on rent/fuel").
  /// Like [rewardsText] and [bestForText], it's the user's own writing —
  /// nothing the app itself populates — but unlike those two it isn't
  /// scoped to rewards, so whatever the user has written there is sent
  /// verbatim.
  final String notes;

  Map<String, Object?> toJson() => {
    'id': id,
    'nickname': nickname,
    'issuer': issuerName,
    'network': networkName,
    'rewards': rewardsText,
    'bestFor': bestForText,
    'notes': notes,
  };
}

/// The full request sent to Card Sense: what the user wants to buy, plus
/// the sanitized card summaries to choose among.
class CardRecommendationRequest {
  const CardRecommendationRequest({
    required this.purchaseDescription,
    required this.isOnlinePurchase,
    this.onlinePlatform,
    required this.purchaseAmount,
    required this.cards,
  });

  final String purchaseDescription;

  /// Whether the purchase is being made online vs. in person — some cards
  /// have different reward rates for each, so this can change which card
  /// is the best choice.
  final bool isOnlinePurchase;

  /// The online platform/merchant (e.g. "Amazon"), if given and relevant —
  /// only meaningful when [isOnlinePurchase] is true.
  final String? onlinePlatform;

  final int? purchaseAmount;
  final List<SanitizedCardSummary> cards;
}

/// Card Sense's structured answer to a purchase question — which card to
/// use, and why — returned as two separate fields (via Groq's structured
/// JSON output) rather than one free-form paragraph, so the app can render
/// them as distinct sections instead of parsing prose.
class CardSenseAnswer {
  const CardSenseAnswer({
    required this.recommendedCard,
    required this.reasoning,
    this.estimatedReward,
  });

  final String recommendedCard;
  final String reasoning;

  /// What the recommended card earns back on this purchase — only ever
  /// present when the user gave an amount to estimate against, and even
  /// then it may say an estimate isn't possible from the reward text on
  /// file rather than give a figure.
  final String? estimatedReward;
}
