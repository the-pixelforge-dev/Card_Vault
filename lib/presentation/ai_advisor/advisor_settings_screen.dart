import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/ai_advisor/gemini_advisor_provider.dart';
import '../../application/settings/haptics_provider.dart';

class AdvisorSettingsScreen extends ConsumerStatefulWidget {
  const AdvisorSettingsScreen({super.key});

  @override
  ConsumerState<AdvisorSettingsScreen> createState() =>
      _AdvisorSettingsScreenState();
}

class _AdvisorSettingsScreenState extends ConsumerState<AdvisorSettingsScreen> {
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
    await ref.read(geminiApiKeyProvider.notifier).set(value);
    _controller.clear();
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _clear() async {
    ref.read(hapticsServiceProvider).selectionClick();
    setState(() => _saving = true);
    await ref.read(geminiApiKeyProvider.notifier).clear();
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final apiKeyAsync = ref.watch(geminiApiKeyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Purchase Advisor')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Bring your own Google Gemini API key to get card '
            'recommendations for a purchase. Only card nickname, issuer, '
            'network, rewards, "best for" text, and groups are ever sent — '
            'never your card number, CVV, expiry, or cardholder name. '
            'Without a key, this feature stays off and the app makes no '
            'network calls.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
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
                  TextField(
                    controller: _controller,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Gemini API key',
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
