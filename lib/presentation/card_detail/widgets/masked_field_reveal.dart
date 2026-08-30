import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/security/clipboard_guard_provider.dart';

/// A labeled sensitive value (card number, CVV, expiry) with a reveal
/// toggle and a copy button. Copies go through the shared [ClipboardGuard]
/// so the clipboard auto-clears 15 seconds later.
class MaskedFieldReveal extends ConsumerStatefulWidget {
  const MaskedFieldReveal({
    super.key,
    required this.label,
    required this.maskedValue,
    required this.realValue,
    required this.onColor,
  });

  final String label;
  final String maskedValue;
  final String realValue;
  final Color onColor;

  @override
  ConsumerState<MaskedFieldReveal> createState() => _MaskedFieldRevealState();
}

class _MaskedFieldRevealState extends ConsumerState<MaskedFieldReveal> {
  bool _revealed = false;
  bool _justCopied = false;

  Future<void> _copy() async {
    HapticFeedback.mediumImpact();
    await ref
        .read(clipboardGuardProvider)
        .copyWithAutoClear(widget.realValue);
    if (!mounted) return;
    setState(() => _justCopied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _justCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final onColor = widget.onColor;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  color: onColor.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _revealed ? widget.realValue : widget.maskedValue,
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: onColor,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            _revealed ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: onColor,
            size: 20,
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            setState(() => _revealed = !_revealed);
          },
        ),
        IconButton(
          icon: Icon(
            _justCopied ? Icons.check_rounded : Icons.copy_rounded,
            color: onColor,
            size: 20,
          ),
          onPressed: _copy,
        ),
      ],
    );
  }
}
