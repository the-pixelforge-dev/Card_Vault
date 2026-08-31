import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/ai_advisor/gemini_advisor_provider.dart';
import '../../application/settings/haptics_provider.dart';

class AdvisorScreen extends ConsumerStatefulWidget {
  const AdvisorScreen({super.key});

  @override
  ConsumerState<AdvisorScreen> createState() => _AdvisorScreenState();
}

class _AdvisorScreenState extends ConsumerState<AdvisorScreen> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  String? _result;
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    ref.read(hapticsServiceProvider).selectionClick();
    final description = _descriptionController.text.trim();
    if (description.isEmpty) return;

    setState(() {
      _loading = true;
      _result = null;
      _error = null;
    });

    try {
      final amount = double.tryParse(_amountController.text.trim());
      final advice = await ref.read(
        purchaseAdviceProvider(
          purchaseDescription: description,
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
    return Scaffold(
      appBar: AppBar(title: const Text('Card Sense')),
      body: ListView(
        padding: const EdgeInsets.all(20),
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
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Amount (optional)',
            ),
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _loading ? null : _ask,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: const Text('Ask'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 20),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          if (_result != null) ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_result!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
