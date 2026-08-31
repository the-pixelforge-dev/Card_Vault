import 'package:flutter/material.dart';

/// A fade-and-zoom page transition, used in place of a `Hero` flight where
/// the same content would otherwise need to be laid out at two very
/// different sizes (the card stack's small card vs. the detail screen's
/// full-width one) — that reflow is what made text visibly jitter and
/// re-kern mid-flight. This transition never renders the destination
/// content at an intermediate size: the incoming page is laid out once, at
/// its own real size, and simply fades and scales up as a whole.
///
/// Since the stack card and the detail card each have their own glow
/// (independently sized/positioned, not a shared element), briefly cross-
/// fading between the two still shows the glow changing shape for a beat —
/// there's no clean way to morph one glow into the other. Keeping the
/// transition very short is what actually hides it: too little of that
/// cross-fade is visible for the eye to register it.
Route<T> zoomFadeRoute<T>(WidgetBuilder builder) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) =>
        builder(context),
    transitionDuration: const Duration(milliseconds: 120),
    reverseTransitionDuration: const Duration(milliseconds: 100),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}
