import 'package:flutter/material.dart';

import '../../domain/card/card_network.dart';

/// A small, deliberately generic badge naming the card network as text.
///
/// This app never reproduces real network logos (trademark risk) — the
/// network name is simply set in a compact pill, styled to blend with the
/// card's own color scheme.
class NetworkMark extends StatelessWidget {
  const NetworkMark({super.key, required this.network, required this.onColor});

  final CardNetwork network;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    if (network == CardNetwork.unknown) return const SizedBox.shrink();

    return Text(
      network.displayName.toUpperCase(),
      style: TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: onColor.withValues(alpha: 0.92),
      ),
    );
  }
}
