import 'package:flutter/services.dart';

enum HapticsStrength {
  low('Low'),
  medium('Medium'),
  high('High');

  const HapticsStrength(this.displayName);
  final String displayName;
}

enum _Level { selection, light, medium, heavy }

/// The single place every haptic call in the app goes through, so the
/// "Haptics" on/off + strength settings actually apply everywhere rather
/// than needing every call site to remember to check them.
///
/// [strength] shifts every call up or down one notch on the
/// selection→light→medium→heavy ladder rather than needing a separate
/// mapping per call site — "low" makes everything a little subtler, "high"
/// a little more pronounced, "medium" leaves call sites as authored.
class HapticsService {
  const HapticsService({required this.enabled, required this.strength});

  final bool enabled;
  final HapticsStrength strength;

  static const _ladder = [
    _Level.selection,
    _Level.light,
    _Level.medium,
    _Level.heavy,
  ];

  void selectionClick() => _fire(_Level.selection);
  void lightImpact() => _fire(_Level.light);
  void mediumImpact() => _fire(_Level.medium);
  void heavyImpact() => _fire(_Level.heavy);

  void _fire(_Level level) {
    if (!enabled) return;
    switch (_adjust(level)) {
      case _Level.selection:
        HapticFeedback.selectionClick();
      case _Level.light:
        HapticFeedback.lightImpact();
      case _Level.medium:
        HapticFeedback.mediumImpact();
      case _Level.heavy:
        HapticFeedback.heavyImpact();
    }
  }

  _Level _adjust(_Level level) {
    final shift = switch (strength) {
      HapticsStrength.low => -1,
      HapticsStrength.medium => 0,
      HapticsStrength.high => 1,
    };
    final index = (_ladder.indexOf(level) + shift).clamp(
      0,
      _ladder.length - 1,
    );
    return _ladder[index];
  }
}
