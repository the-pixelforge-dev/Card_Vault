import 'dart:ui';

import 'package:flutter/material.dart';

/// Like [showDialog], but blurs the screen behind the dialog instead of
/// just dimming it, so focus stays on the dialog content instead of the
/// still-legible page behind it.
Future<T?> showBlurredDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.2),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final t = Curves.easeOut.transform(animation.value);
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6 * t, sigmaY: 6 * t),
        child: Opacity(opacity: t, child: child),
      );
    },
  );
}
