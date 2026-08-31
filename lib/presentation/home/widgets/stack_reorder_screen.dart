import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/cards/card_list_provider.dart';
import '../../../application/settings/haptics_provider.dart';
import '../../../domain/card/card_entity.dart';
import '../../widgets_shared/card_visual_style.dart';

/// A plain drag-handle list for rearranging the whole card stack's saved
/// order in bulk — easier than long-press-dragging one overlapping card at
/// a time directly on the stack. Always shows every card, regardless of
/// whatever filter/search is active on the home screen, since the stack's
/// order is a single vault-wide property.
class StackReorderScreen extends ConsumerStatefulWidget {
  const StackReorderScreen({super.key});

  @override
  ConsumerState<StackReorderScreen> createState() =>
      _StackReorderScreenState();
}

class _StackReorderScreenState extends ConsumerState<StackReorderScreen> {
  // Reordered locally and applied to the list immediately, rather than
  // driven straight off `ref.watch(cardListProvider)` — persisting a
  // reorder is async, so rendering off the provider would show the list
  // snap back to its old order for a frame after each drag (while waiting
  // on that save) before jumping to the new one once it resolved.
  late List<CardEntity> _cards;

  @override
  void initState() {
    super.initState();
    _cards = [...ref.read(cardListProvider)];
  }

  String _nameOf(CardEntity card) =>
      card.nickname.isNotEmpty ? card.nickname : card.cardholderName;

  void _onReorder(int oldIndex, int newIndex) {
    ref.read(hapticsServiceProvider).mediumImpact();
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final moved = _cards.removeAt(oldIndex);
      _cards.insert(newIndex, moved);
    });
    ref
        .read(cardListProvider.notifier)
        .reorder(_cards.map((c) => c.id).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rearrange Cards')),
      body: _cards.isEmpty
          ? Center(
              child: Text(
                'No cards yet.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _cards.length,
              onReorder: _onReorder,
              itemBuilder: (context, index) {
                final card = _cards[index];
                final style = CardVisualStyle(card.colorArgb);
                return ListTile(
                  key: ValueKey(card.id),
                  leading: CircleAvatar(backgroundColor: style.baseColor),
                  title: Text(_nameOf(card)),
                  subtitle: Text(card.issuerName),
                  trailing: const Icon(Icons.drag_handle_rounded),
                );
              },
            ),
    );
  }
}
