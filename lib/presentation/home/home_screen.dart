import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/ai_advisor/gemini_advisor_provider.dart';
import '../../application/cards/card_filter_provider.dart';
import '../../domain/card/card_entity.dart';
import '../ai_advisor/advisor_screen.dart';
import '../card_detail/card_detail_screen.dart';
import '../card_form/card_form_screen.dart';
import '../settings/settings_screen.dart';
import 'widgets/card_search_bar.dart';
import 'widgets/card_stack_view.dart';
import 'widgets/group_filter_dropdown.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openCard(BuildContext context, CardEntity card) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CardDetailScreen(cardId: card.id)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(filteredCardListProvider);
    final hasGeminiKey = ref.watch(geminiApiKeyProvider).value != null;
    final activeFilter = ref.watch(activeCardFilterProvider);
    final isFiltered =
        activeFilter.mode != GroupingMode.all ||
        (activeFilter.searchQuery ?? '').trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Vault'),
        actions: [
          if (hasGeminiKey)
            IconButton(
              icon: const Icon(Icons.auto_awesome_outlined),
              tooltip: 'Which card should I use?',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdvisorScreen()),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const GroupFilterDropdown(),
                const CardSearchBar(),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 28),
              child: CardStackView(
                cards: cards,
                isFiltered: isFiltered,
                onOpenCard: (card) => _openCard(context, card),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CardFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Card'),
      ),
    );
  }
}
