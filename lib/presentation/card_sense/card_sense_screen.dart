import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/card_sense/card_sense_provider.dart';
import '../../application/cards/card_list_provider.dart';
import '../../application/settings/haptics_provider.dart';
import '../../application/settings/settings_provider.dart';
import '../../core/settings/app_currency.dart';
import '../../domain/card_sense/card_recommendation_request.dart';
import '../widgets_shared/vendor/expressive_loading_indicator.dart';
import 'card_sense_settings_screen.dart';
import 'prompt_preview_screen.dart';

class CardSenseScreen extends ConsumerStatefulWidget {
  const CardSenseScreen({super.key});

  @override
  ConsumerState<CardSenseScreen> createState() => _CardSenseScreenState();
}

class _CardSenseScreenState extends ConsumerState<CardSenseScreen> {
  final _descriptionController = TextEditingController();
  final _platformController = TextEditingController();
  final _amountController = TextEditingController();

  bool _isOnline = false;
  _AskedQuery? _askedQuery;
  CardSenseAnswer? _result;
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _platformController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String? _emptyToNull(String value) =>
      value.trim().isEmpty ? null : value.trim();

  /// Whether the input area should be visible — hidden while loading and
  /// once an answer has arrived, since the query recap above the answer
  /// already shows what was asked. Reappears on error (to retry) or once
  /// "Ask Another Question" clears the result.
  bool get _showInputBar => !_loading && _result == null;

  void _askAnother() {
    ref.read(hapticsServiceProvider).selectionClick();
    setState(() {
      _result = null;
      _askedQuery = null;
      _error = null;
    });
  }

  Future<void> _ask() async {
    ref.read(hapticsServiceProvider).selectionClick();
    final description = _descriptionController.text.trim();
    if (description.isEmpty) return;

    final amount = int.tryParse(
      _amountController.text.replaceAll(',', '').trim(),
    );
    final platform = _isOnline ? _emptyToNull(_platformController.text) : null;

    setState(() {
      _loading = true;
      _result = null;
      _error = null;
      _askedQuery = _AskedQuery(
        description: description,
        isOnline: _isOnline,
        platform: platform,
        amount: amount,
      );
    });

    try {
      final advice = await ref.read(
        purchaseAdviceProvider(
          purchaseDescription: description,
          isOnlinePurchase: _isOnline,
          onlinePlatform: platform,
          purchaseAmount: amount,
        ).future,
      );
      setState(() => _result = advice);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasGroqKey = ref.watch(groqApiKeyProvider).value != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Sense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.description_outlined),
            tooltip: 'Prompt',
            onPressed: () {
              ref.read(hapticsServiceProvider).selectionClick();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PromptPreviewScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: hasGroqKey ? _buildChat(context) : _buildNoKeyState(context),
      ),
    );
  }

  Widget _buildNoKeyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 48,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Card Sense looks at your saved cards and tells you which '
              'one to use for a purchase — best rewards, no guesswork.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'It runs on Groq, so it needs your own free API key to '
              'work. Nothing is sent anywhere until you add one.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                ref.read(hapticsServiceProvider).selectionClick();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CardSenseSettingsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.vpn_key_outlined),
              label: const Text('Set Up Card Sense'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChat(BuildContext context) {
    final cards = ref.watch(cardListProvider);
    final withRewards = cards
        .where((card) => card.rewardsText.trim().isNotEmpty)
        .length;
    final missingRewards = cards.length - withRewards;
    // Card Sense compares cards purely on their rewards text, so with none
    // of it filled in there is nothing to compare — better to block the
    // question than answer it with a guess.
    final canAsk = withRewards > 0;

    return Column(
      children: [
        Expanded(
          child: _loading
              ? const Align(
                  alignment: Alignment(0, -0.25),
                  child: _ProcessingIndicator(),
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (_error != null)
                      _ErrorCard(message: _error!)
                    else if (_result != null) ...[
                      if (_askedQuery != null) ...[
                        _QueryRecap(
                          query: _askedQuery!,
                          currency: ref.watch(settingsProvider).currency,
                        ),
                        const SizedBox(height: 16),
                      ],
                      _AnswerSection(
                        icon: Icons.credit_card_rounded,
                        label: 'Recommended Card',
                        child: Text(
                          _result!.recommendedCard,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (_result!.estimatedReward != null) ...[
                        const SizedBox(height: 16),
                        _AnswerSection(
                          icon: Icons.savings_outlined,
                          label: 'Estimated Rewards',
                          child: _EmphasisText(_result!.estimatedReward!),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _AnswerSection(
                        icon: Icons.lightbulb_outline,
                        label: 'Reasoning',
                        child: _EmphasisText(_result!.reasoning),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _askAnother,
                          icon: const Icon(Icons.replay_rounded),
                          label: const Text('Ask Another Question'),
                        ),
                      ),
                    ] else
                      Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Column(
                          children: [
                            Icon(
                              Icons.auto_awesome_outlined,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tell Card Sense what you\'re buying, and it '
                              'will pick the best card from your vault.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 20),
                            if (cards.isEmpty)
                              const _VaultNotice(
                                blocking: true,
                                message:
                                    'Add at least one card to your vault '
                                    'before using Card Sense.',
                              )
                            else if (withRewards == 0)
                              const _VaultNotice(
                                blocking: true,
                                message:
                                    'None of your cards have rewards info '
                                    'yet. Card Sense compares cards using '
                                    'that text, so add it to at least one '
                                    'card before asking.',
                              )
                            else if (missingRewards > 0)
                              _VaultNotice(
                                blocking: false,
                                message:
                                    '$missingRewards of your ${cards.length} '
                                    'cards '
                                    '${missingRewards == 1 ? "has" : "have"} '
                                    'no rewards info, so they can\'t be '
                                    'compared fairly. Add their details for '
                                    'better recommendations.',
                              )
                            else
                              const _VaultNotice(
                                blocking: false,
                                message:
                                    'Card Sense is only as accurate as the '
                                    'rewards info on your cards. Missing or '
                                    'outdated details can lead to misleading '
                                    'recommendations.',
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            // Deliberately not clipped: the panel casts a soft shadow that
            // needs to bleed a few pixels above its own box at rest, and
            // clipping it here would cut that off permanently, not just
            // mid-transition. The simultaneous fade hides the brief
            // overflow while the panel is actually shrinking.
            child: FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
          ),
          child: _showInputBar
              ? _buildInputBar(
                  context,
                  key: const ValueKey('inputVisible'),
                  canAsk: canAsk,
                )
              : const SizedBox.shrink(key: ValueKey('inputHidden')),
        ),
      ],
    );
  }

  Widget _buildInputBar(
    BuildContext context, {
    required Key key,
    required bool canAsk,
  }) {
    final currency = ref.watch(settingsProvider).currency;
    return Container(
      key: key,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'What are you buying?',
              hintText: 'e.g. Dinner at an Italian restaurant',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<bool>(
              style: SegmentedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Offline'),
                  icon: Icon(Icons.storefront_outlined),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Online'),
                  icon: Icon(Icons.shopping_cart_outlined),
                ),
              ],
              selected: {_isOnline},
              onSelectionChanged: (selection) {
                ref.read(hapticsServiceProvider).selectionClick();
                setState(() => _isOnline = selection.first);
              },
            ),
          ),
          if (_isOnline) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _platformController,
              decoration: const InputDecoration(
                labelText: 'Where online? (optional)',
                hintText: 'e.g. Amazon, Flipkart',
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: 'Amount (optional)',
              prefixText: '${currency.symbol} ',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _ThousandsSeparatorFormatter(),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            // Rebuilt per keystroke via the controller rather than
            // setState, so typing only repaints the button.
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _descriptionController,
              builder: (context, value, _) => FilledButton.icon(
                onPressed: canAsk && value.text.trim().isNotEmpty
                    ? _ask
                    : null,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Ask'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inserts thousands separators (`1234567` -> `1,234,567`) into a
/// digits-only [TextField] as the user types, keeping the cursor
/// positioned relative to the digits rather than jumping to the end.
class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(',', '');
    if (digitsOnly.isEmpty) return newValue.copyWith(text: '');

    final formatted = formatThousands(digitsOnly);
    final digitsBeforeCursor = newValue.text
        .substring(0, newValue.selection.end)
        .replaceAll(',', '')
        .length;

    var cursor = 0;
    var digitsSeen = 0;
    while (cursor < formatted.length && digitsSeen < digitsBeforeCursor) {
      if (formatted[cursor] != ',') digitsSeen++;
      cursor++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }
}

/// Adds `,` thousands separators to a plain digit string, e.g. `1234567` ->
/// `1,234,567`.
String formatThousands(String digits) {
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// A snapshot of what was asked, taken at the moment "Ask" is tapped —
/// rendered above the answer as a recap, independent of whatever the
/// input fields hold afterward.
class _AskedQuery {
  const _AskedQuery({
    required this.description,
    required this.isOnline,
    required this.platform,
    required this.amount,
  });

  final String description;
  final bool isOnline;
  final String? platform;
  final int? amount;
}

/// Recaps the question just asked, above the answer. Deliberately has no
/// container of its own — a small accent label trailed by a hairline rule,
/// then the question itself — so it reads as the question being answered
/// rather than as another result card competing with the answer below.
class _QueryRecap extends StatelessWidget {
  const _QueryRecap({required this.query, required this.currency});

  final _AskedQuery query;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modeText = query.isOnline
        ? (query.platform != null ? 'Online (via ${query.platform})' : 'Online')
        : 'Offline';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'YOU ASKED',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 1,
                color: theme.colorScheme.outlineVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          query.description,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          query.amount != null
              ? '$modeText · ${currency.symbol}${formatThousands('${query.amount}')}'
              : modeText,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Shown while waiting on Groq: Material 3 Expressive's morphing shape
/// loading indicator, plus a cycling typewriter-style status label.
class _ProcessingIndicator extends StatelessWidget {
  const _ProcessingIndicator();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExpressiveLoadingIndicator(
          color: colorScheme.primary,
          constraints: const BoxConstraints.tightFor(width: 220, height: 220),
        ),
        const SizedBox(height: 16),
        const _ProcessingLabel(),
      ],
    );
  }
}

/// Cycles through a few one-word status verbs with a typewriter effect —
/// typing each one out, holding briefly, then deleting it before moving to
/// the next — instead of a single static "Processing…" label.
class _ProcessingLabel extends StatefulWidget {
  const _ProcessingLabel();

  @override
  State<_ProcessingLabel> createState() => _ProcessingLabelState();
}

class _ProcessingLabelState extends State<_ProcessingLabel> {
  static const _words = [
    'Thinking',
    'Comparing',
    'Weighing',
    'Analyzing',
    'Calculating',
    'Considering',
    'Crunching',
    'Deciding',
  ];

  static const _typeSpeed = Duration(milliseconds: 55);
  static const _deleteSpeed = Duration(milliseconds: 30);
  static const _holdDuration = Duration(milliseconds: 900);
  static const _wordGap = Duration(milliseconds: 200);

  Timer? _timer;
  int _wordIndex = 0;
  int _charCount = 0;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_typeSpeed, _tick);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    if (!mounted) return;
    final word = _words[_wordIndex];

    if (!_deleting) {
      if (_charCount < word.length) {
        setState(() => _charCount++);
        _timer = Timer(_typeSpeed, _tick);
      } else {
        _deleting = true;
        _timer = Timer(_holdDuration, _tick);
      }
    } else {
      if (_charCount > 0) {
        setState(() => _charCount--);
        _timer = Timer(_deleteSpeed, _tick);
      } else {
        _deleting = false;
        _wordIndex = (_wordIndex + 1) % _words.length;
        _timer = Timer(_wordGap, _tick);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _words[_wordIndex].substring(0, _charCount);
    return Text(
      '$visible…',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// A labeled section in Card Sense's answer — "Recommended Card" or
/// "Reasoning" — styled like the app's other icon+label content blocks.
/// A styled error message — an icon+text card in the theme's error tint,
/// matching the app's other content blocks, instead of a bare line of red
/// text.
/// Tells the user how usable their vault currently is for Card Sense —
/// since recommendations are only ever as good as the rewards text on each
/// card. [blocking] marks the cases where asking is disabled outright
/// (no cards, or no rewards text anywhere) rather than merely degraded.
class _VaultNotice extends StatelessWidget {
  const _VaultNotice({required this.blocking, required this.message});

  final bool blocking;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = blocking
        ? colorScheme.errorContainer.withValues(alpha: 0.5)
        : colorScheme.tertiaryContainer.withValues(alpha: 0.5);
    final foreground = blocking
        ? colorScheme.onErrorContainer
        : colorScheme.onTertiaryContainer;
    final outline = blocking ? colorScheme.error : colorScheme.tertiary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            blocking
                ? Icons.warning_amber_rounded
                : Icons.info_outline_rounded,
            size: 18,
            color: foreground,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.left,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, size: 20, color: colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerSection extends StatelessWidget {
  const _AnswerSection({
    required this.icon,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
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
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

/// Renders `**bold**`-style markdown emphasis as underlined text instead of
/// actual bold — a user picking a single-weight display font (e.g.
/// PoppinsBold, which renders every requested weight identically) would
/// see no visual difference from real bold, but underline always shows.
class _EmphasisText extends StatelessWidget {
  const _EmphasisText(this.text);

  final String text;

  static final _boldPattern = RegExp(r'\*\*(.+?)\*\*', dotAll: true);

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(height: 1.6);
    final accentColor = Theme.of(context).colorScheme.primary;

    final spans = <InlineSpan>[];
    var lastEnd = 0;
    for (final match in _boldPattern.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(
            decoration: TextDecoration.underline,
            decorationColor: accentColor,
            decorationThickness: 2,
          ),
        ),
      );
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return Text.rich(TextSpan(style: baseStyle, children: spans));
  }
}
