import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/settings/haptics_provider.dart';

/// A full-screen plain-text editor for a single long-form field (Rewards,
/// Best For, Notes) — pushed from the card form when its inline field feels
/// too cramped for pasting or reviewing a long entry. Pops the edited text
/// back to the caller, or null if cancelled.
class FullTextEditorScreen extends ConsumerStatefulWidget {
  const FullTextEditorScreen({
    super.key,
    required this.title,
    required this.initialText,
  });

  final String title;
  final String initialText;

  @override
  ConsumerState<FullTextEditorScreen> createState() =>
      _FullTextEditorScreenState();
}

class _FullTextEditorScreenState extends ConsumerState<FullTextEditorScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _done() {
    ref.read(hapticsServiceProvider).selectionClick();
    Navigator.of(context).pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton(onPressed: _done, child: const Text('Done')),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: TextField(
            controller: _controller,
            autofocus: true,
            maxLines: null,
            expands: true,
            keyboardType: TextInputType.multiline,
            textAlignVertical: TextAlignVertical.top,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: const InputDecoration(
              border: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }
}
