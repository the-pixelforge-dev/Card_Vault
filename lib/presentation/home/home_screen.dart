import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/cards/card_filter_provider.dart';
import '../../application/settings/haptics_provider.dart';
import '../../domain/card/card_entity.dart';
import '../card_sense/card_sense_screen.dart';
import '../card_detail/card_detail_screen.dart';
import '../card_form/card_form_screen.dart';
import '../settings/settings_screen.dart';
import '../widgets_shared/zoom_fade_route.dart';
import 'widgets/card_search_bar.dart';
import 'widgets/card_stack_sort_button.dart';
import 'widgets/card_stack_view.dart';
import 'widgets/group_filter_dropdown.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openCard(BuildContext context, CardEntity card) {
    Navigator.of(
      context,
    ).push(zoomFadeRoute((_) => CardDetailScreen(cardId: card.id)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(filteredCardListProvider);
    final activeFilter = ref.watch(activeCardFilterProvider);
    final isFiltered =
        activeFilter.mode != GroupingMode.all ||
        (activeFilter.searchQuery ?? '').trim().isNotEmpty;

    return Scaffold(
      // Matches the card detail screen: a transparent app bar with the
      // body extended behind it, so the front card's glow can bleed all
      // the way up into the banner instead of being clipped right below
      // it.
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text('Card Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              ref.read(hapticsServiceProvider).selectionClick();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              12,
              MediaQuery.of(context).padding.top + kToolbarHeight + 8,
              12,
              0,
            ),
            child: Row(
              children: [
                const Expanded(child: GroupFilterDropdown()),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [CardStackSortButton(), CardSearchBar()],
                ),
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
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'addCardFab',
            tooltip: 'Add Card',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onPressed: () {
              ref.read(hapticsServiceProvider).selectionClick();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CardFormScreen()),
              );
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: 'cardSenseFab',
            tooltip: 'Card Sense',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onPressed: () {
              ref.read(hapticsServiceProvider).selectionClick();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CardSenseScreen()),
              );
            },
            child: const Icon(Icons.auto_awesome_outlined),
          ),
        ],
      ),
    );
  }
}
