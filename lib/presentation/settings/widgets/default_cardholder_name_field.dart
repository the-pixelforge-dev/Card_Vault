import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/settings/settings_provider.dart';

/// A preference text field with a persistent controller — plain
/// `TextField`s inline in a stateless settings screen would reset on every
/// unrelated settings change, losing cursor position/focus mid-edit.
class DefaultCardholderNameField extends ConsumerStatefulWidget {
  const DefaultCardholderNameField({super.key});

  @override
  ConsumerState<DefaultCardholderNameField> createState() =>
      _DefaultCardholderNameFieldState();
}

class _DefaultCardholderNameFieldState
    extends ConsumerState<DefaultCardholderNameField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(settingsProvider).defaultCardholderName,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Default cardholder name',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message:
                    'Pre-fills new cards — you can still change it '
                    'any time.',
                triggerMode: TooltipTriggerMode.tap,
                child: Icon(
                  Icons.help_outline_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            onChanged: (value) => ref
                .read(settingsProvider.notifier)
                .setDefaultCardholderName(
                  value.trim().isEmpty ? null : value,
                ),
          ),
        ],
      ),
    );
  }
}
