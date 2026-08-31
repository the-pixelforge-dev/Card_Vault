import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/cards/card_list_provider.dart';
import '../../../application/settings/haptics_provider.dart';
import '../../../domain/card/card_entity.dart';
import 'stack_reorder_screen.dart';

enum _SortAction { nameAscending, nameDescending, rearrange }

String _nameOf(CardEntity card) =>
    card.nickname.isNotEmpty ? card.nickname : card.cardholderName;

/// A one-time "sort by name" action (not a persistent mode — cards can
/// still be freely dragged into any order afterward, and new cards are
/// just appended as usual) plus an entry point into [StackReorderScreen]
/// for bulk manual reordering.
class CardStackSortButton extends ConsumerWidget {
  const CardStackSortButton({super.key});

  Future<void> _sortByName(WidgetRef ref, {required bool ascending}) async {
    final cards = [...ref.read(cardListProvider)];
    cards.sort((a, b) {
      final comparison = _nameOf(
        a,
      ).toLowerCase().compareTo(_nameOf(b).toLowerCase());
      return ascending ? comparison : -comparison;
    });
    await ref
        .read(cardListProvider.notifier)
        .reorder(cards.map((c) => c.id).toList());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<_SortAction>(
      icon: const Icon(Icons.sort_rounded),
      tooltip: 'Sort or rearrange',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (action) async {
        ref.read(hapticsServiceProvider).selectionClick();
        switch (action) {
          case _SortAction.nameAscending:
            await _sortByName(ref, ascending: true);
          case _SortAction.nameDescending:
            await _sortByName(ref, ascending: false);
          case _SortAction.rearrange:
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StackReorderScreen()),
            );
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _SortAction.nameAscending,
          child: ListTile(
            leading: Icon(Icons.arrow_upward_rounded),
            title: Text('Sort by name (A–Z)'),
          ),
        ),
        PopupMenuItem(
          value: _SortAction.nameDescending,
          child: ListTile(
            leading: Icon(Icons.arrow_downward_rounded),
            title: Text('Sort by name (Z–A)'),
          ),
        ),
        PopupMenuItem(
          value: _SortAction.rearrange,
          child: ListTile(
            leading: Icon(Icons.drag_indicator_rounded),
            title: Text('Rearrange manually'),
          ),
        ),
      ],
    );
  }
}
