import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/card_sense/card_sense_provider.dart';
import '../../application/cards/card_list_provider.dart';
import '../../application/settings/haptics_provider.dart';
import '../../domain/card/card_entity.dart';
import '../../domain/card_sense/card_recommendation_request.dart';

/// A read-only view of the prompt Card Sense sends to Groq. The fixed
/// instructions and each card's header are shown verbatim via the same
/// functions the real request uses, so they can never drift from what's
/// actually sent. Each card's rewards/best-for/notes text — the user's own
/// free-text fields, which can run long — collapses behind a tap, tinted
/// with that card's own color so it's easy to tell them apart at a glance.
/// Those three fields are laid out as labelled sections rather than in the
/// `rewards="…"` form they're sent as: same content, but readable instead
/// of one run-on string.
class PromptPreviewScreen extends ConsumerWidget {
  const PromptPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(cardListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Prompt')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'This is the prompt Card Sense sends to Groq for every '
            'question. The instructions and card list are fixed and not '
            'configurable — only the purchase, its mode (online/offline '
            'and platform), and the amount are filled in from what you '
            'enter in the chat. Tap a card below to see its exact rewards, '
            'best-for and notes text as it would be sent. Groq is also '
            'instructed to reply '
            'with the recommended card, its reasoning, and — only when '
            'you give an amount — an estimate of what that card earns '
            'back, which the app renders as separate sections.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  cardSenseInstructions,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 16),
                _PlaceholderLine(
                  label: 'Purchase',
                  placeholder: 'whatever you type in the chat',
                ),
                const SizedBox(height: 4),
                _PlaceholderLine(
                  label: 'Mode',
                  placeholder: 'Online (via the platform, if given) or Offline',
                ),
                const SizedBox(height: 4),
                _PlaceholderLine(
                  label: 'Amount',
                  placeholder: 'only included if you give one',
                ),
                const SizedBox(height: 16),
                Text(
                  'Cards:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                if (cards.isEmpty)
                  Text(
                    'No cards yet.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  ...cards.map((card) => _CardPromptBlock(card: card)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderLine extends StatelessWidget {
  const _PlaceholderLine({required this.label, required this.placeholder});

  final String label;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: '<$placeholder>',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// One labelled field inside an expanded card block. Rendered as its own
/// titled section rather than echoing the `rewards="…"` wire syntax, so a
/// long rewards paragraph can't visually swallow the shorter fields that
/// follow it — the content is identical to what's sent, only the
/// presentation differs.
class _PromptField extends StatelessWidget {
  const _PromptField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmpty = value.trim().isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.9,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 3),
        SelectableText(
          isEmpty ? 'Not set' : value,
          style: theme.textTheme.bodySmall?.copyWith(
            height: 1.4,
            fontStyle: isEmpty ? FontStyle.italic : null,
            color: isEmpty ? theme.colorScheme.onSurfaceVariant : null,
          ),
        ),
      ],
    );
  }
}

class _CardPromptBlock extends ConsumerStatefulWidget {
  const _CardPromptBlock({required this.card});

  final CardEntity card;

  @override
  ConsumerState<_CardPromptBlock> createState() => _CardPromptBlockState();
}

class _CardPromptBlockState extends ConsumerState<_CardPromptBlock> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = Color(widget.card.colorArgb);
    final summary = SanitizedCardSummary.fromEntity(widget.card);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: cardColor, width: 4)),
      ),
      child: GestureDetector(
        onTap: () {
          ref.read(hapticsServiceProvider).selectionClick();
          setState(() => _expanded = !_expanded);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formatCardSenseCardHeader(summary),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 10),
                _PromptField(label: 'Rewards', value: summary.rewardsText),
                const SizedBox(height: 12),
                _PromptField(label: 'Best for', value: summary.bestForText),
                // Omitted rather than shown as "Not set", matching the
                // prompt itself — an empty Notes field isn't sent at all.
                if (summary.notes.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _PromptField(label: 'Notes', value: summary.notes),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
