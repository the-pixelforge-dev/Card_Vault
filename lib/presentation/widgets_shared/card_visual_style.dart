import 'package:flutter/material.dart';

/// Derives a polished gradient + readable foreground color from the single
/// ARGB int a user picks for a card, so every card looks intentional without
/// asking them to configure a full gradient by hand.
class CardVisualStyle {
  CardVisualStyle(int colorArgb) : baseColor = Color(colorArgb) {
    final hsl = HSLColor.fromColor(baseColor);
    gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        hsl.withLightness((hsl.lightness + 0.08).clamp(0.0, 1.0)).toColor(),
        baseColor,
        hsl.withLightness((hsl.lightness - 0.14).clamp(0.0, 1.0)).toColor(),
      ],
      stops: const [0.0, 0.55, 1.0],
    );
    onColor = ThemeData.estimateBrightnessForColor(baseColor) ==
            Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  final Color baseColor;
  late final Gradient gradient;
  late final Color onColor;
}
