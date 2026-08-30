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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Default cardholder name',
          hintText: 'Pre-fills new cards — you can still change it',
        ),
        onChanged: (value) => ref
            .read(settingsProvider.notifier)
            .setDefaultCardholderName(value.trim().isEmpty ? null : value),
      ),
    );
  }
}
