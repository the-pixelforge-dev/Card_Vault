import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/ai/gemini_client.dart';
import '../../core/security/gemini_key_store.dart';
import '../../domain/ai_advisor/card_recommendation_request.dart';
import '../cards/card_list_provider.dart';
import '../groups/group_provider.dart';

part 'gemini_advisor_provider.g.dart';

@Riverpod(keepAlive: true)
GeminiKeyStore geminiKeyStore(Ref ref) => GeminiKeyStore();

@Riverpod(keepAlive: true)
GeminiClient geminiClient(Ref ref) => const GeminiClient();

/// Whether the advisor feature should be shown at all — purely a function
/// of whether the user has supplied their own key, refreshed after
/// [GeminiApiKey.set]/[GeminiApiKey.clear].
@Riverpod(keepAlive: true)
class GeminiApiKey extends _$GeminiApiKey {
  @override
  Future<String?> build() => ref.watch(geminiKeyStoreProvider).read();

  Future<void> set(String apiKey) async {
    await ref.read(geminiKeyStoreProvider).write(apiKey);
    ref.invalidateSelf();
    await future;
  }

  Future<void> clear() async {
    await ref.read(geminiKeyStoreProvider).clear();
    ref.invalidateSelf();
    await future;
  }
}

@riverpod
Future<String> purchaseAdvice(
  Ref ref, {
  required String purchaseDescription,
  double? purchaseAmount,
}) async {
  final apiKey = await ref.watch(geminiApiKeyProvider.future);
  if (apiKey == null || apiKey.isEmpty) {
    throw const GeminiRequestException(
      'No Gemini API key is set. Add one in Settings to use the advisor.',
    );
  }

  final cards = ref.watch(cardListProvider);
  final groups = {for (final g in ref.watch(groupListProvider)) g.id: g.name};

  final request = CardRecommendationRequest(
    purchaseDescription: purchaseDescription,
    purchaseAmount: purchaseAmount,
    cards: cards
        .map(
          (c) => SanitizedCardSummary.fromEntity(
            c,
            groupNames: c.groupIds
                .map((id) => groups[id])
                .whereType<String>()
                .toList(),
          ),
        )
        .toList(),
  );

  if (request.cards.isEmpty) {
    throw const GeminiRequestException(
      'Add at least one card before asking the advisor.',
    );
  }

  final prompt = _buildPrompt(request);
  return ref.watch(geminiClientProvider).generateText(
    apiKey: apiKey,
    prompt: prompt,
  );
}

String _buildPrompt(CardRecommendationRequest request) {
  final buffer = StringBuffer()
    ..writeln(
      'You are a credit card rewards advisor. Given a purchase and a list '
      'of the user\'s cards (with only non-sensitive metadata — no card '
      'numbers, CVVs, expiry dates, or cardholder names are ever provided '
      'to you), recommend the single best card to use and briefly explain '
      'why, referencing the rewards/best-for text provided. Keep the '
      'answer under 120 words.',
    )
    ..writeln()
    ..writeln('Purchase: ${request.purchaseDescription}');
  if (request.purchaseAmount != null) {
    buffer.writeln('Amount: ${request.purchaseAmount}');
  }
  buffer.writeln();
  buffer.writeln('Cards:');
  for (final card in request.cards) {
    buffer.writeln(
      '- ${card.nickname} (${card.issuerName}, ${card.networkName}): '
      'rewards="${card.rewardsText}", bestFor="${card.bestForText}", '
      'groups=${card.groupNames.join(", ")}',
    );
  }
  return buffer.toString();
}
