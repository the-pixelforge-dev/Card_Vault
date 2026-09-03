import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../application/card_sense/card_sense_provider.dart';
import '../../application/settings/haptics_provider.dart';
import '../widgets_shared/blurred_dialog.dart';

class CardSenseSettingsScreen extends ConsumerStatefulWidget {
  const CardSenseSettingsScreen({super.key});

  @override
  ConsumerState<CardSenseSettingsScreen> createState() =>
      _CardSenseSettingsScreenState();
}

class _CardSenseSettingsScreenState
    extends ConsumerState<CardSenseSettingsScreen> {
  final _controller = TextEditingController();
  bool _obscure = true;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    ref.read(hapticsServiceProvider).selectionClick();
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    setState(() => _saving = true);
    await ref.read(groqApiKeyProvider.notifier).set(value);
    _controller.clear();
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _clear() async {
    ref.read(hapticsServiceProvider).selectionClick();
    setState(() => _saving = true);
    await ref.read(groqApiKeyProvider.notifier).clear();
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _openUrl(String url) async {
    ref.read(hapticsServiceProvider).selectionClick();
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showApiKeyInstructions() {
    ref.read(hapticsServiceProvider).selectionClick();
    showBlurredDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Getting a Groq API key'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const _FreeBadge(),
              const SizedBox(height: 8),
              Text(
                "It's completely free to get, and Groq's free usage tier "
                "covers typical personal use — so using Card Sense costs "
                "you nothing, ongoing.",
                style: Theme.of(dialogContext).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              _InstructionStep(
                number: 1,
                text: 'Go to the Groq console and sign in (or create a '
                    'free account).',
                linkText: 'Groq console',
                onLinkTap: () => _openUrl('https://console.groq.com/keys'),
              ),
              const _InstructionStep(
                number: 2,
                text: 'Accept the Terms of Service if prompted — new '
                    'accounts get free API access automatically.',
              ),
              const _InstructionStep(
                number: 3,
                text: 'Click "Create API Key" and give it a name.',
              ),
              const _InstructionStep(
                number: 4,
                text: 'Copy the key that appears, then come back here and '
                    'paste it in.',
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => _openUrl('https://console.groq.com/keys'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'console.groq.com/keys',
                      style: TextStyle(
                        color: Theme.of(dialogContext).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.open_in_new_rounded,
                      size: 16,
                      color: Theme.of(dialogContext).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiKeyAsync = ref.watch(groqApiKeyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Card Sense')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Bring your own Groq API key to get card '
            'recommendations for a purchase. Only card nickname, issuer, '
            'network, rewards, "best for" text, and groups are ever sent — '
            'never your card number, CVV, expiry, or cardholder name. '
            'Without a key, this feature stays off and the app makes no '
            'network calls.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          const _FreeBadge(),
          const SizedBox(height: 24),
          apiKeyAsync.when(
            data: (key) {
              final hasKey = key != null && key.isNotEmpty;
              if (hasKey) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        const Expanded(child: Text('API key is set.')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _saving ? null : _clear,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Remove API key'),
                    ),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: _showApiKeyInstructions,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text("Here's how to get one →"),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Groq API key',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save API key'),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }
}

class _FreeBadge extends StatelessWidget {
  const _FreeBadge();

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.money_off_rounded, size: 16, color: accent),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Free — no credit card required',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionStep extends StatefulWidget {
  const _InstructionStep({
    required this.number,
    required this.text,
    this.linkText,
    this.onLinkTap,
  });

  final int number;
  final String text;
  final String? linkText;
  final VoidCallback? onLinkTap;

  @override
  State<_InstructionStep> createState() => _InstructionStepState();
}

class _InstructionStepState extends State<_InstructionStep> {
  TapGestureRecognizer? _recognizer;

  @override
  void dispose() {
    _recognizer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final linkText = widget.linkText;
    final onLinkTap = widget.onLinkTap;
    final linkIndex = linkText == null ? -1 : widget.text.indexOf(linkText);

    Widget textWidget;
    if (linkText == null || onLinkTap == null || linkIndex == -1) {
      textWidget = Text(widget.text);
    } else {
      _recognizer?.dispose();
      _recognizer = TapGestureRecognizer()..onTap = onLinkTap;
      textWidget = Text.rich(
        TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(text: widget.text.substring(0, linkIndex)),
            TextSpan(
              text: linkText,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
              ),
              recognizer: _recognizer,
            ),
            TextSpan(text: widget.text.substring(linkIndex + linkText.length)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              '${widget.number}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: textWidget),
        ],
      ),
    );
  }
}
