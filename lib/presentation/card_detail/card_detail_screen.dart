import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../application/cards/card_list_provider.dart';
import '../../application/groups/group_provider.dart';
import '../../domain/card/card_entity.dart';
import '../card_form/card_form_screen.dart';
import '../widgets_shared/digital_card_widget.dart';
import 'widgets/flip_card_widget.dart';

class CardDetailScreen extends ConsumerWidget {
  const CardDetailScreen({super.key, required this.cardId});

  final String cardId;

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CardEntity card,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete card?'),
        content: Text(
          'This permanently removes "${card.nickname}" from Card Vault.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(cardListProvider.notifier).remove(card.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(cardListProvider);
    final card = cards.where((c) => c.id == cardId).firstOrNull;

    if (card == null) {
      return const Scaffold(body: Center(child: Text('Card not found')));
    }

    final groups = ref.watch(groupListProvider);
    final cardGroups = groups.where((g) => card.groupIds.contains(g.id));

    final links = <(String, String)>[
      if (card.rewardsUrl != null) ('Rewards', card.rewardsUrl!),
      if (card.paymentUrl != null) ('Make a Payment', card.paymentUrl!),
      if (card.managementUrl != null) ('Manage Card', card.managementUrl!),
      if (card.customerServiceUrl != null)
        ('Customer Service', card.customerServiceUrl!),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(card.nickname),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CardFormScreen(existingCard: card),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref, card),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Hero(
            tag: 'card-${card.id}',
            child: FlipCardWidget(
              front: DigitalCardFront(card: card),
              back: DigitalCardBack(card: card),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Tap the card to flip',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (card.rewardsText.isNotEmpty)
            _DetailSection(title: 'Rewards', body: card.rewardsText),
          if (card.bestForText.isNotEmpty)
            _DetailSection(title: 'Best For', body: card.bestForText),
          if (card.customFields.isNotEmpty)
            _DetailSection(
              title: 'Details',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: card.customFields.entries
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text(
                              '${e.key}: ',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Expanded(child: Text(e.value)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          if (links.isNotEmpty)
            _DetailSection(
              title: 'Links',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: links
                    .map(
                      (link) => OutlinedButton.icon(
                        onPressed: () => _openUrl(link.$2),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: Text(link.$1),
                      ),
                    )
                    .toList(),
              ),
            ),
          if (cardGroups.isNotEmpty)
            _DetailSection(
              title: 'Groups',
              child: Wrap(
                spacing: 8,
                children: cardGroups
                    .map((g) => Chip(label: Text(g.name)))
                    .toList(),
              ),
            ),
          if (card.notes.isNotEmpty)
            _DetailSection(title: 'Notes', body: card.notes),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, this.body, this.child})
    : assert(body != null || child != null);

  final String title;
  final String? body;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          child ?? Text(body!),
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
