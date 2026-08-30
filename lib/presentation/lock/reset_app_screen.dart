import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/security/app_reset_service.dart';

/// The explicit, hard-to-trigger-by-accident escape hatch for a forgotten
/// PIN: requires typing RESET to confirm, then wipes every card, group,
/// setting, and stored key — there is no cloud backup to recover from, so
/// this is equivalent to reinstalling.
class ResetAppScreen extends StatefulWidget {
  const ResetAppScreen({super.key});

  @override
  State<ResetAppScreen> createState() => _ResetAppScreenState();
}

class _ResetAppScreenState extends State<ResetAppScreen> {
  final _controller = TextEditingController();
  bool _resetting = false;
  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    setState(() => _resetting = true);
    await AppResetService().resetEverything();
    if (!mounted) return;
    setState(() {
      _resetting = false;
      _done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confirmed = _controller.text.trim().toUpperCase() == 'RESET';

    if (_done) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Card Vault has been reset.',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Close the app completely and reopen it to start fresh.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => SystemNavigator.pop(),
                    child: const Text('Close Card Vault'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Card Vault')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'This permanently deletes every card, group, and setting '
                'stored on this device. There is no cloud backup to '
                'restore from — this cannot be undone unless you have an '
                'encrypted export saved elsewhere.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Text(
                'Type RESET to confirm',
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(hintText: 'RESET'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: confirmed && !_resetting ? _reset : null,
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
                child: _resetting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Erase everything'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
