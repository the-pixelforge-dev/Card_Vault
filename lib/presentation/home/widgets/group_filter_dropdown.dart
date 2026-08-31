import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/cards/card_filter_provider.dart';
import '../../../application/cards/card_list_provider.dart';
import '../../../application/groups/group_provider.dart';
import '../../../application/settings/haptics_provider.dart';
import '../../../domain/card/card_entity.dart';
import '../../../domain/card/card_network.dart';
import '../../../domain/card/card_type.dart';

/// How many cards match [filter], ignoring any concurrent free-text search
/// — this describes the grouping criterion itself (e.g. "Credit Cards"),
/// not how many of those happen to also match whatever's in the search box
/// right now.
int _countFor(List<CardEntity> cards, CardFilter filter) {
  if (filter.mode == GroupingMode.all) return cards.length;
  final groupOnly = CardFilter(mode: filter.mode, value: filter.value);
  return cards.where(groupOnly.matches).length;
}

class GroupFilterDropdown extends ConsumerWidget {
  const GroupFilterDropdown({super.key});

  String _labelFor(WidgetRef ref, CardFilter filter) {
    switch (filter.mode) {
      case GroupingMode.all:
        return 'All Cards';
      case GroupingMode.cardType:
        return switch (filter.value) {
          'credit' => 'Credit Cards',
          'debit' => 'Debit Cards',
          _ => 'Card Type',
        };
      case GroupingMode.issuer:
        return filter.value ?? 'Issuer';
      case GroupingMode.network:
        return filter.value != null
            ? CardNetwork.values.byName(filter.value!).displayName
            : 'Network';
      case GroupingMode.custom:
        final groups = ref.read(groupListProvider);
        return groups
            .firstWhere(
              (g) => g.id == filter.value,
              orElse: () => groups.first,
            )
            .name;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(activeCardFilterProvider);
    final cards = ref.watch(cardListProvider);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        ref.read(hapticsServiceProvider).selectionClick();
        _openPicker(context, ref);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                '${_labelFor(ref, filter)} (${_countFor(cards, filter)})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more_rounded),
          ],
        ),
      ),
    );
  }

  void _openPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => _GroupPickerSheet(
        onSelect: (newFilter) {
          ref.read(hapticsServiceProvider).selectionClick();
          ref.read(activeCardFilterProvider.notifier).set(newFilter);
          Navigator.of(sheetContext).pop();
        },
      ),
    );
  }
}

class _GroupPickerSheet extends ConsumerWidget {
  const _GroupPickerSheet({required this.onSelect});

  final void Function(CardFilter filter) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(cardListProvider);
    final groups = ref.watch(groupListProvider);
    final theme = Theme.of(context);

    final creditCount = cards
        .where((c) => c.cardType == CardType.credit)
        .length;
    final debitCount = cards.where((c) => c.cardType == CardType.debit).length;

    final issuers =
        cards
            .map((c) => c.issuerName.trim())
            .where((issuer) => issuer.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final networks = cards.map((c) => c.network).toSet().toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));

    Widget sectionTitle(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text('All Cards (${cards.length})'),
              leading: const Icon(Icons.grid_view_rounded),
              onTap: () => onSelect(const CardFilter()),
            ),
            ListTile(
              title: Text('Credit Cards ($creditCount)'),
              leading: const Icon(Icons.credit_card_rounded),
              onTap: () => onSelect(
                const CardFilter(mode: GroupingMode.cardType, value: 'credit'),
              ),
            ),
            ListTile(
              title: Text('Debit Cards ($debitCount)'),
              leading: const Icon(Icons.payments_outlined),
              onTap: () => onSelect(
                const CardFilter(mode: GroupingMode.cardType, value: 'debit'),
              ),
            ),
            if (groups.isNotEmpty) ...[
              sectionTitle('Custom Groups'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: groups
                      .map(
                        (g) => ChoiceChip(
                          label: Text(g.name),
                          selected: false,
                          onSelected: (_) => onSelect(
                            CardFilter(mode: GroupingMode.custom, value: g.id),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
            if (issuers.isNotEmpty) ...[
              sectionTitle('By Issuer'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: issuers
                      .map(
                        (issuer) => ChoiceChip(
                          label: Text(issuer),
                          selected: false,
                          onSelected: (_) => onSelect(
                            CardFilter(
                              mode: GroupingMode.issuer,
                              value: issuer,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
            if (networks.isNotEmpty) ...[
              sectionTitle('By Network'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: networks
                      .map(
                        (network) => ChoiceChip(
                          label: Text(network.displayName),
                          selected: false,
                          onSelected: (_) => onSelect(
                            CardFilter(
                              mode: GroupingMode.network,
                              value: network.name,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
