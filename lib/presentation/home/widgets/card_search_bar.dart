import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/cards/card_filter_provider.dart';

/// A search icon that expands into a text field, right-aligned next to the
/// group filter dropdown. Typing filters the card stack live by nickname.
class CardSearchBar extends ConsumerStatefulWidget {
  const CardSearchBar({super.key});

  @override
  ConsumerState<CardSearchBar> createState() => _CardSearchBarState();
}

class _CardSearchBarState extends ConsumerState<CardSearchBar> {
  final _controller = TextEditingController();
  bool _expanded = false;

  void _open() => setState(() => _expanded = true);

  void _close() {
    _controller.clear();
    ref.read(activeCardFilterProvider.notifier).setSearchQuery(null);
    setState(() => _expanded = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_expanded) {
      return IconButton(
        icon: const Icon(Icons.search_rounded),
        onPressed: _open,
      );
    }

    return SizedBox(
      width: 200,
      child: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search by card name',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            onPressed: _close,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
        onChanged: (value) => ref
            .read(activeCardFilterProvider.notifier)
            .setSearchQuery(value),
      ),
    );
  }
}
