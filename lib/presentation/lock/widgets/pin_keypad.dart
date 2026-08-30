import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/settings/haptics_provider.dart';

/// A simple 0-9 + backspace numeric keypad used for both setting and
/// entering the app PIN.
class PinKeypad extends ConsumerWidget {
  const PinKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
  });

  final void Function(String digit) onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const layout = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: layout
          .map(
            (row) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((key) {
                if (key.isEmpty) {
                  return const SizedBox(width: 72, height: 64);
                }
                final isBackspace = key == '⌫';
                return SizedBox(
                  width: 72,
                  height: 64,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(36),
                      onTap: () {
                        ref.read(hapticsServiceProvider).selectionClick();
                        if (isBackspace) {
                          onBackspace();
                        } else {
                          onDigit(key);
                        }
                      },
                      child: Center(
                        child: isBackspace
                            ? const Icon(Icons.backspace_outlined)
                            : Text(key, style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          )
          .toList(),
    );
  }
}
