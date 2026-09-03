import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/settings/settings_provider.dart';
import '../../domain/card/card_entity.dart';
import '../card_detail/widgets/masked_field_reveal.dart';
import 'card_visual_style.dart';
import 'network_mark.dart';

/// Standard card aspect ratio (ISO/IEC 7810 ID-1, matching a physical card).
const cardAspectRatio = 1.586;

/// The gradient/artwork shell shared by every rendering of a card — the
/// stack, the list, and both faces of the flip detail view all wrap this so
/// a card looks identical everywhere it appears.
class DigitalCardShell extends ConsumerWidget {
  const DigitalCardShell({
    super.key,
    required this.card,
    required this.child,
    this.glowStrength = 1.0,
  });

  final CardEntity card;
  final Widget child;

  /// Scales the glow's reach and opacity relative to the user's base
  /// intensity setting. Used in the home stack so the topmost card's glow
  /// visibly dominates right at its own edge while cards further back taper
  /// off, rather than every layer competing at equal strength.
  final double glowStrength;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = CardVisualStyle(card.colorArgb);
    final glow =
        ref.watch(settingsProvider.select((s) => s.cardStackGlowIntensity)) *
        glowStrength;

    return AspectRatio(
      aspectRatio: cardAspectRatio,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: style.gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            // Tight, vivid ring hugging the card's own edge so the border
            // reads as this card's color first, before anything further
            // out blends with the layers behind it.
            BoxShadow(
              color: style.baseColor.withValues(alpha: 0.55 * glow),
              blurRadius: 18 * glow,
              spreadRadius: 1 * glow,
            ),
            BoxShadow(
              color: style.baseColor.withValues(alpha: 0.65 * glow),
              blurRadius: 48 * glow,
              spreadRadius: 2 * glow,
              offset: Offset(0, 14 * glow),
            ),
            BoxShadow(
              color: style.baseColor.withValues(alpha: 0.4 * glow),
              blurRadius: 72 * glow,
              spreadRadius: -6 * glow,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: DefaultTextStyle.merge(
            // Explicit `none` guards against an underline ever leaking in
            // from an inherited style.
            style: TextStyle(
              color: style.onColor,
              decoration: TextDecoration.none,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Front face: card design, network, issuer, and nickname — no sensitive
/// data ever appears here.
class DigitalCardFront extends StatelessWidget {
  const DigitalCardFront({super.key, required this.card, this.glowStrength = 1.0});

  final CardEntity card;
  final double glowStrength;

  @override
  Widget build(BuildContext context) {
    final style = CardVisualStyle(card.colorArgb);

    return DigitalCardShell(
      card: card,
      glowStrength: glowStrength,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  card.issuerName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              NetworkMark(network: card.network, onColor: style.onColor),
            ],
          ),
          const Spacer(),
          Text(
            card.maskedCardNumber,
            style: const TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            card.nickname.isNotEmpty ? card.nickname : card.cardholderName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Back face: masked card number, CVV, and expiry, each independently
/// revealable and copyable.
class DigitalCardBack extends StatelessWidget {
  const DigitalCardBack({super.key, required this.card});

  final CardEntity card;

  @override
  Widget build(BuildContext context) {
    final style = CardVisualStyle(card.colorArgb);
    final digits = card.cardNumber;
    final grouped = [
      for (var i = 0; i < digits.length; i += 4)
        digits.substring(i, i + 4 > digits.length ? digits.length : i + 4),
    ].join(' ');

    return DigitalCardShell(
      card: card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          MaskedFieldReveal(
            label: 'Card Number',
            maskedValue: card.maskedCardNumber,
            realValue: grouped,
            onColor: style.onColor,
          ),
          MaskedFieldReveal(
            label: 'CVV',
            maskedValue: '•' * card.cvv.length,
            realValue: card.cvv,
            onColor: style.onColor,
          ),
          MaskedFieldReveal(
            label: 'Expiry',
            maskedValue: '••/••',
            realValue: card.expiryMonthYear,
            onColor: style.onColor,
          ),
          if (card.pin.isNotEmpty)
            MaskedFieldReveal(
              label: 'PIN',
              maskedValue: '•' * card.pin.length,
              realValue: card.pin,
              onColor: style.onColor,
            ),
        ],
      ),
    );
  }
}
