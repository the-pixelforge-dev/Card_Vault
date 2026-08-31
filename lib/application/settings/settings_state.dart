import 'package:flutter/material.dart';

import '../../core/cards/card_stack_style.dart';
import '../../core/haptics/haptics_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/settings/imported_font_hive_model.dart';
import '../../data/settings/settings_hive_model.dart';

/// UI-facing settings state, decoupled from the Hive storage shape.
class SettingsState {
  const SettingsState({
    required this.themeMode,
    required this.uiScaleFactor,
    required this.activeFontFamily,
    required this.importedFonts,
    required this.biometricLockEnabled,
    required this.autoLockAfterSeconds,
    required this.biometricUnlockEnabled,
    required this.themeSeedColorArgb,
    required this.defaultCardholderName,
    required this.hapticsEnabled,
    required this.hapticsStrength,
    required this.cardStackDepthStyle,
    required this.cardStackGlowIntensity,
    required this.defaultStackFilter,
  });

  factory SettingsState.fromHiveModel(AppSettingsHiveModel m) {
    return SettingsState(
      themeMode: ThemeMode.values.byName(m.themeMode),
      uiScaleFactor: m.uiScaleFactor,
      activeFontFamily: m.activeFontFamily,
      importedFonts: List<ImportedFontHiveModel>.from(m.importedFonts),
      biometricLockEnabled: m.biometricLockEnabled,
      autoLockAfterSeconds: m.autoLockAfterSeconds,
      biometricUnlockEnabled: m.biometricUnlockEnabled,
      themeSeedColorArgb: m.themeSeedColorArgb,
      defaultCardholderName: m.defaultCardholderName,
      hapticsEnabled: m.hapticsEnabled,
      hapticsStrength: HapticsStrength.values.byName(m.hapticsStrength),
      cardStackDepthStyle: CardStackDepthStyle.values.byName(
        m.cardStackDepthStyle,
      ),
      cardStackGlowIntensity: m.cardStackGlowIntensity,
      defaultStackFilter: DefaultCardStackFilter.values.byName(
        m.defaultStackFilter,
      ),
    );
  }

  final ThemeMode themeMode;
  final double uiScaleFactor;
  final String? activeFontFamily;
  final List<ImportedFontHiveModel> importedFonts;
  final bool biometricLockEnabled;
  final int autoLockAfterSeconds;
  final bool biometricUnlockEnabled;
  final int? themeSeedColorArgb;
  final String? defaultCardholderName;
  final bool hapticsEnabled;
  final HapticsStrength hapticsStrength;
  final CardStackDepthStyle cardStackDepthStyle;
  final double cardStackGlowIntensity;
  final DefaultCardStackFilter defaultStackFilter;

  /// The display name shown in Settings for the active font — the bundled
  /// family name itself, or the human-readable name of an imported font
  /// (never its internal `UserFont_<uuid>` family id).
  String activeFontDisplayName(String defaultBundledFamily) {
    final family = activeFontFamily;
    if (family == null) return BundledFonts.displayName(defaultBundledFamily);
    final imported = importedFonts
        .where((f) => f.fontFamily == family)
        .firstOrNull;
    return imported?.displayName ?? BundledFonts.displayName(family);
  }

  AppSettingsHiveModel toHiveModel() => AppSettingsHiveModel(
    themeMode: themeMode.name,
    uiScaleFactor: uiScaleFactor,
    activeFontFamily: activeFontFamily,
    importedFonts: importedFonts,
    biometricLockEnabled: biometricLockEnabled,
    autoLockAfterSeconds: autoLockAfterSeconds,
    biometricUnlockEnabled: biometricUnlockEnabled,
    themeSeedColorArgb: themeSeedColorArgb,
    defaultCardholderName: defaultCardholderName,
    hapticsEnabled: hapticsEnabled,
    hapticsStrength: hapticsStrength.name,
    cardStackDepthStyle: cardStackDepthStyle.name,
    cardStackGlowIntensity: cardStackGlowIntensity,
    defaultStackFilter: defaultStackFilter.name,
  );

  SettingsState copyWith({
    ThemeMode? themeMode,
    double? uiScaleFactor,
    String? Function()? activeFontFamily,
    List<ImportedFontHiveModel>? importedFonts,
    bool? biometricLockEnabled,
    int? autoLockAfterSeconds,
    bool? biometricUnlockEnabled,
    int? Function()? themeSeedColorArgb,
    String? Function()? defaultCardholderName,
    bool? hapticsEnabled,
    HapticsStrength? hapticsStrength,
    CardStackDepthStyle? cardStackDepthStyle,
    double? cardStackGlowIntensity,
    DefaultCardStackFilter? defaultStackFilter,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      uiScaleFactor: uiScaleFactor ?? this.uiScaleFactor,
      activeFontFamily: activeFontFamily != null
          ? activeFontFamily()
          : this.activeFontFamily,
      importedFonts: importedFonts ?? this.importedFonts,
      biometricLockEnabled: biometricLockEnabled ?? this.biometricLockEnabled,
      autoLockAfterSeconds:
          autoLockAfterSeconds ?? this.autoLockAfterSeconds,
      biometricUnlockEnabled:
          biometricUnlockEnabled ?? this.biometricUnlockEnabled,
      themeSeedColorArgb: themeSeedColorArgb != null
          ? themeSeedColorArgb()
          : this.themeSeedColorArgb,
      defaultCardholderName: defaultCardholderName != null
          ? defaultCardholderName()
          : this.defaultCardholderName,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      hapticsStrength: hapticsStrength ?? this.hapticsStrength,
      cardStackDepthStyle: cardStackDepthStyle ?? this.cardStackDepthStyle,
      cardStackGlowIntensity:
          cardStackGlowIntensity ?? this.cardStackGlowIntensity,
      defaultStackFilter: defaultStackFilter ?? this.defaultStackFilter,
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
