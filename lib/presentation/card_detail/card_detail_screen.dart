import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../application/cards/card_list_provider.dart';
import '../../application/groups/group_provider.dart';
import '../../application/settings/haptics_provider.dart';
import '../../application/settings/settings_provider.dart';
import '../../domain/card/card_entity.dart';
import '../card_form/card_form_screen.dart';
import '../widgets_shared/digital_card_widget.dart';
import 'widgets/flip_card_widget.dart';

/// Formats a money amount with thousands separators, dropping the decimal
/// part entirely for whole numbers (e.g. 12500.0 -> "12,500", 12500.5 ->
/// "12,500.50").
String _formatMoney(double value) {
  final isWhole = value == value.roundToDouble();
  final fixed = isWhole ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final intDigits = parts[0];
  final buffer = StringBuffer();
  for (var i = 0; i < intDigits.length; i++) {
    if (i > 0 && (intDigits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(intDigits[i]);
  }
  return parts.length > 1 ? '$buffer.${parts[1]}' : buffer.toString();
}

class CardDetailScreen extends ConsumerWidget {
  const CardDetailScreen({super.key, required this.cardId});

  final String cardId;

  Future<void> _openUrl(WidgetRef ref, String url) async {
    ref.read(hapticsServiceProvider).selectionClick();
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CardEntity card,
  ) async {
    ref.read(hapticsServiceProvider).selectionClick();
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
    final currency = ref.watch(settingsProvider).currency;

    final links = <(String, String)>[
      if (card.rewardsUrl != null) ('Rewards', card.rewardsUrl!),
      if (card.paymentUrl != null) ('Make a Payment', card.paymentUrl!),
      if (card.managementUrl != null) ('Manage Card', card.managementUrl!),
      if (card.customerServiceUrl != null)
        ('Customer Service', card.customerServiceUrl!),
    ];

    return Scaffold(
      // The card's own glow is meant to bleed up past its top edge, but a
      // normal opaque app bar would hard-clip it right at the seam. Making
      // the app bar transparent and extending the body behind it lets that
      // glow carry on underneath instead, so it reads as one continuous
      // surface rather than the card looking cut off.
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text(card.nickname),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              ref.read(hapticsServiceProvider).selectionClick();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CardFormScreen(existingCard: card),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Theme.of(context).colorScheme.error,
            onPressed: () => _confirmDelete(context, ref, card),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + kToolbarHeight + 20,
              20,
              0,
            ),
            child: Column(
              children: [
                FlipCardWidget(
                  front: DigitalCardFront(card: card),
                  back: DigitalCardBack(card: card),
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
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              children: [
                if (card.cardVariant.isNotEmpty)
                  _DetailSection(
                    title: 'Card Variant',
                    icon: Icons.workspace_premium_outlined,
                    body: card.cardVariant,
                  ),
                if (card.creditLimit != null)
                  _DetailSection(
                    title: 'Credit Limit',
                    icon: Icons.account_balance_wallet_outlined,
                    body:
                        '${currency.symbol}${_formatMoney(card.creditLimit!)}',
                  ),
                if (card.rewardsText.isNotEmpty ||
                    card.bestForText.isNotEmpty ||
                    card.notes.isNotEmpty)
                  _InfoSection(
                    rewardsText: card.rewardsText,
                    bestForText: card.bestForText,
                    notes: card.notes,
                  ),
                if (card.customFields.isNotEmpty)
                  _DetailSection(
                    title: 'Details',
                    icon: Icons.list_alt_outlined,
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
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
                    icon: Icons.link_rounded,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: links
                          .map(
                            (link) => OutlinedButton.icon(
                              onPressed: () => _openUrl(ref, link.$2),
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
                    icon: Icons.label_outline,
                    child: Wrap(
                      spacing: 8,
                      children: cardGroups
                          .map((g) => Chip(label: Text(g.name)))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.icon,
    this.body,
    this.child,
  }) : assert(body != null || child != null);

  final String title;
  final IconData icon;
  final String? body;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child ?? _ExpandableText(body!),
          ],
        ),
      ),
    );
  }
}

/// Merges Rewards, Best For, and Notes into a single collapsible "Info"
/// block instead of three separate boxes — showing all three by default
/// made the card screen feel cluttered, so this starts collapsed or
/// expanded per [SettingsState.cardInfoExpandedByDefault] and can be
/// toggled per visit from its header.
class _InfoSection extends ConsumerStatefulWidget {
  const _InfoSection({
    required this.rewardsText,
    required this.bestForText,
    required this.notes,
  });

  final String rewardsText;
  final String bestForText;
  final String notes;

  @override
  ConsumerState<_InfoSection> createState() => _InfoSectionState();
}

class _InfoSectionState extends ConsumerState<_InfoSection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = ref.read(settingsProvider).cardInfoExpandedByDefault;
  }

  Widget _subsection(
    BuildContext context,
    IconData icon,
    String label,
    String text,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _ExpandableText(text),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                ref.read(hapticsServiceProvider).selectionClick();
                setState(() => _expanded = !_expanded);
              },
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Info',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              if (widget.rewardsText.isNotEmpty)
                _subsection(
                  context,
                  Icons.card_giftcard_outlined,
                  'Rewards',
                  widget.rewardsText,
                ),
              if (widget.bestForText.isNotEmpty)
                _subsection(
                  context,
                  Icons.thumb_up_outlined,
                  'Best For',
                  widget.bestForText,
                ),
              if (widget.notes.isNotEmpty)
                _subsection(
                  context,
                  Icons.notes_outlined,
                  'Notes',
                  widget.notes,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Body text that collapses to [collapsedMaxLines] with a "Show more" /
/// "Show less" toggle once it actually overflows — long free-text fields
/// like Rewards or Notes can run to several bullet points, and we don't
/// want that to dominate the whole detail screen by default.
class _ExpandableText extends ConsumerStatefulWidget {
  const _ExpandableText(this.text);

  final String text;
  static const _collapsedMaxLines = 4;

  @override
  ConsumerState<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends ConsumerState<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style;

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: _ExpandableText._collapsedMaxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              maxLines: _expanded ? null : _ExpandableText._collapsedMaxLines,
              overflow: _expanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),
            if (overflows)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: GestureDetector(
                    onTap: () {
                      ref.read(hapticsServiceProvider).selectionClick();
                      setState(() => _expanded = !_expanded);
                    },
                    child: Text(
                      _expanded ? 'Show less' : 'Show more',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
