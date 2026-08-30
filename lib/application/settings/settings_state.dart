import 'package:flutter/material.dart';

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

  /// The display name shown in Settings for the active font — the bundled
  /// family name itself, or the human-readable name of an imported font
  /// (never its internal `UserFont_<uuid>` family id).
  String activeFontDisplayName(String defaultBundledFamily) {
    final family = activeFontFamily;
    if (family == null) return defaultBundledFamily;
    final imported = importedFonts
        .where((f) => f.fontFamily == family)
        .firstOrNull;
    return imported?.displayName ?? family;
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
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
