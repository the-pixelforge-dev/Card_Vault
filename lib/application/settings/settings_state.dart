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
  });

  factory SettingsState.fromHiveModel(AppSettingsHiveModel m) {
    return SettingsState(
      themeMode: ThemeMode.values.byName(m.themeMode),
      uiScaleFactor: m.uiScaleFactor,
      activeFontFamily: m.activeFontFamily,
      importedFonts: List<ImportedFontHiveModel>.from(m.importedFonts),
      biometricLockEnabled: m.biometricLockEnabled,
      autoLockAfterSeconds: m.autoLockAfterSeconds,
    );
  }

  final ThemeMode themeMode;
  final double uiScaleFactor;
  final String? activeFontFamily;
  final List<ImportedFontHiveModel> importedFonts;
  final bool biometricLockEnabled;
  final int autoLockAfterSeconds;

  AppSettingsHiveModel toHiveModel() => AppSettingsHiveModel(
    themeMode: themeMode.name,
    uiScaleFactor: uiScaleFactor,
    activeFontFamily: activeFontFamily,
    importedFonts: importedFonts,
    biometricLockEnabled: biometricLockEnabled,
    autoLockAfterSeconds: autoLockAfterSeconds,
  );

  SettingsState copyWith({
    ThemeMode? themeMode,
    double? uiScaleFactor,
    String? Function()? activeFontFamily,
    List<ImportedFontHiveModel>? importedFonts,
    bool? biometricLockEnabled,
    int? autoLockAfterSeconds,
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
    );
  }
}
