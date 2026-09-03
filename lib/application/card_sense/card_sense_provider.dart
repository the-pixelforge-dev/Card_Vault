import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/ai/groq_client.dart';
import '../../core/security/groq_key_store.dart';
import '../../domain/card_sense/card_recommendation_request.dart';
import '../cards/card_list_provider.dart';

part 'card_sense_provider.g.dart';

@Riverpod(keepAlive: true)
GroqKeyStore groqKeyStore(Ref ref) => GroqKeyStore();

@Riverpod(keepAlive: true)
GroqClient groqClient(Ref ref) => const GroqClient();

/// Whether Card Sense should be shown at all — purely a function of
/// whether the user has supplied their own key, refreshed after
/// [GroqApiKey.set]/[GroqApiKey.clear].
@Riverpod(keepAlive: true)
class GroqApiKey extends _$GroqApiKey {
  @override
  Future<String?> build() => ref.watch(groqKeyStoreProvider).read();

  Future<void> set(String apiKey) async {
    await ref.read(groqKeyStoreProvider).write(apiKey);
    ref.invalidateSelf();
    await future;
  }

  Future<void> clear() async {
    await ref.read(groqKeyStoreProvider).clear();
    ref.invalidateSelf();
    await future;
  }
}

@riverpod
Future<CardSenseAnswer> purchaseAdvice(
  Ref ref, {
  required String purchaseDescription,
  required bool isOnlinePurchase,
  String? onlinePlatform,
  int? purchaseAmount,
}) async {
  final apiKey = await ref.watch(groqApiKeyProvider.future);
  if (apiKey == null || apiKey.isEmpty) {
    throw const GroqRequestException(
      'No Groq API key is set. Add one in Settings to use Card Sense.',
    );
  }

  final cards = ref.watch(cardListProvider);

  final request = CardRecommendationRequest(
    purchaseDescription: purchaseDescription,
    isOnlinePurchase: isOnlinePurchase,
    onlinePlatform: onlinePlatform,
    purchaseAmount: purchaseAmount,
    cards: cards.map(SanitizedCardSummary.fromEntity).toList(),
  );

  if (request.cards.isEmpty) {
    throw const GroqRequestException(
      'Add at least one card before asking Card Sense.',
    );
  }

  final prompt = buildCardSensePrompt(request);
  final responseJson = await ref.watch(groqClientProvider).generateText(
    apiKey: apiKey,
    prompt: prompt,
    responseSchema: cardSenseResponseSchema,
  );

  final Object? decoded;
  try {
    decoded = jsonDecode(responseJson);
  } on FormatException {
    throw const GroqRequestException(
      'Groq returned a response that could not be read.',
    );
  }
  if (decoded is! Map<String, Object?> ||
      decoded['recommendedCard'] is! String ||
      decoded['reasoning'] is! String) {
    throw const GroqRequestException(
      'Groq returned a response that could not be read.',
    );
  }
  // Only ever asked for when an amount was given, and the model is told to
  // omit it otherwise — so treat anything missing, non-string or blank as
  // simply "no estimate", never as a malformed response.
  final reward = decoded['estimatedReward'];
  final estimatedReward = reward is String && reward.trim().isNotEmpty
      ? reward.trim()
      : null;

  return CardSenseAnswer(
    recommendedCard: decoded['recommendedCard'] as String,
    reasoning: decoded['reasoning'] as String,
    estimatedReward: purchaseAmount != null ? estimatedReward : null,
  );
}

/// The fixed persona/behavior instructions given to Groq — never
/// configurable, and the one part of the prompt that's the same for every
/// question. Exposed so the "Prompt" preview screen can show it verbatim.
const cardSenseInstructions =
    'You are Card Sense, a credit card rewards advisor. Given a purchase '
    '(including whether it\'s made online or in person, and which '
    'platform if online — some cards have different reward rates for '
    'each) and a list of the user\'s cards (with only non-sensitive '
    'metadata — no card numbers, CVVs, expiry dates, or cardholder names '
    'are ever provided to you), respond with the single best card to use '
    'and a brief explanation why, referencing the rewards/best-for text '
    'provided.\n'
    '\n'
    'When — and only when — an Amount is given below, also estimate what '
    'the recommended card earns back on this purchase (cashback, reward '
    'points, miles or discount) as an "estimatedReward" field. Give the '
    'figure in the same currency as the Amount and say briefly how you '
    'arrived at it. An approximate or range-based figure is fine when '
    'the card\'s reward text is not precise enough for an exact number — '
    'just say plainly that it is approximate. If the reward text does '
    'not contain enough information to estimate anything at all, set '
    '"estimatedReward" to a short sentence saying so rather than '
    'guessing a number. If no Amount is given below, omit the '
    '"estimatedReward" field entirely.\n'
    '\n'
    'Two rules govern that estimate. First: a multiplier such as "3X" or '
    '"10X" means that many times the card\'s BASE earn rate, and a base '
    'rate is itself normally written as some number of points per N '
    'units of currency spent (for example, 1 point per 150 spent) — not '
    'one point per single unit. So if the reward text gives a multiplier '
    'but never states the base earn rate, or never states what one point '
    'is worth, you do NOT have enough information to compute a figure: '
    'say exactly that in "estimatedReward", naming which piece is '
    'missing, rather than assuming a multiplier means points per single '
    'unit of currency. Second: sanity-check the figure before returning '
    'it. Real card rewards are a small fraction of the amount spent — '
    'almost always under 10% of it, and effectively never above 20%. A '
    'figure above that means you have made a unit error, most often the '
    'one just described; re-derive it, and if you still cannot reach a '
    'plausible figure, say the card\'s reward text does not record '
    'enough detail to estimate.\n'
    '\n'
    'Respond ONLY with a JSON object of the exact shape '
    '{"recommendedCard": string, "reasoning": string, "estimatedReward": '
    'string — omitted entirely when no Amount is given} and no other '
    'text.';

/// Describes the JSON fields Groq is instructed to reply with, instead of
/// one free-form paragraph, so the app can render "which card", "why" and
/// "how much back" as distinct sections rather than parsing prose.
/// Exposed for the "Prompt" preview screen, and passed to
/// [GroqClient.generateText] as `responseSchema` (used only to decide
/// whether to request JSON output — the shape itself is described in
/// [cardSenseInstructions] since Groq's `json_object` response format
/// takes no schema of its own).
const cardSenseResponseSchema = {
  'type': 'OBJECT',
  'properties': {
    'recommendedCard': {
      'type': 'STRING',
      'description':
          'The nickname of the single best card from the provided list to '
          'use for this purchase.',
    },
    'reasoning': {
      'type': 'STRING',
      'description':
          'A brief explanation of why this card is the best choice, '
          'referencing the rewards/best-for text provided. Under 120 '
          'words.',
    },
    'estimatedReward': {
      'type': 'STRING',
      'description':
          'What the recommended card earns back on this purchase, in the '
          'same currency as the amount — exact where the reward text '
          'allows it, approximate where it does not, or a short sentence '
          'saying an estimate is not possible. Omitted entirely when no '
          'amount was given.',
    },
  },
  'required': ['recommendedCard', 'reasoning'],
};

/// Builds the exact prompt text sent to Groq for [request] — also used
/// by the "Prompt" preview screen so what's shown there can never drift
/// from what's actually sent.
String buildCardSensePrompt(CardRecommendationRequest request) {
  final buffer = StringBuffer()
    ..writeln(cardSenseInstructions)
    ..writeln()
    ..writeln('Purchase: ${request.purchaseDescription}');
  if (request.isOnlinePurchase) {
    buffer.writeln(
      request.onlinePlatform != null && request.onlinePlatform!.isNotEmpty
          ? 'Mode: Online (via ${request.onlinePlatform})'
          : 'Mode: Online',
    );
  } else {
    buffer.writeln('Mode: Offline (in person)');
  }
  if (request.purchaseAmount != null) {
    buffer.writeln('Amount: ${request.purchaseAmount}');
  }
  buffer.writeln();
  buffer.writeln('Cards:');
  for (final card in request.cards) {
    buffer
      ..writeln(formatCardSenseCardHeader(card))
      ..writeln(formatCardSenseCardDetails(card))
      ..writeln();
  }
  return buffer.toString();
}

/// The "- Nickname (Issuer, Network):" portion of a card's line in the
/// prompt — always visible in the Prompt preview screen, even collapsed.
String formatCardSenseCardHeader(SanitizedCardSummary card) =>
    '- ${card.nickname} (${card.issuerName}, ${card.networkName}):';

/// The `rewards="…"` / `bestFor="…"` / `notes="…"` portion of a card's
/// entry in the prompt — the part worth collapsing in the preview screen,
/// since it's the user's own free-text fields and can run long. Each field
/// gets its own line rather than being run together, so a long rewards
/// paragraph can't visually swallow the shorter fields after it; `notes`
/// is only included when the user has actually written one.
String formatCardSenseCardDetails(SanitizedCardSummary card) {
  final lines = [
    'rewards="${card.rewardsText}"',
    'bestFor="${card.bestForText}"',
    if (card.notes.trim().isNotEmpty) 'notes="${card.notes}"',
  ];
  return lines.join('\n');
}
