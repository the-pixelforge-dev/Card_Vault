import 'package:flutter/material.dart';

import 'blurred_dialog.dart';

/// A "?" icon that shows [message] in a small dismissible dialog on tap,
/// instead of the built-in [Tooltip] bubble — which looks like a stray
/// system popup here rather than part of the app, and auto-hides after
/// about 1.5 seconds, often before there's time to finish reading it. This
/// stays open until the user dismisses it, by tapping "Got it" or outside.
class InfoTooltipIcon extends StatelessWidget {
  const InfoTooltipIcon({super.key, required this.message, this.size = 16});

  final String message;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showBlurredDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Got it'),
            ),
          ],
        ),
      ),
      child: Icon(
        Icons.help_outline_rounded,
        size: size,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
