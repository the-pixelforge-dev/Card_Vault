import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/settings/imported_font_hive_model.dart';
import '../core_providers.dart';
import 'settings_state.dart';

part 'settings_provider.g.dart';

@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  @override
  SettingsState build() {
    final repo = ref.watch(settingsRepositoryProvider);
    return SettingsState.fromHiveModel(repo.get());
  }

  Future<void> _persist(SettingsState next) async {
    state = next;
    await ref.read(settingsRepositoryProvider).save(next.toHiveModel());
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _persist(state.copyWith(themeMode: mode));

  Future<void> setUiScaleFactor(double scale) =>
      _persist(state.copyWith(uiScaleFactor: scale));

  Future<void> setBiometricLockEnabled(bool enabled) =>
      _persist(state.copyWith(biometricLockEnabled: enabled));

  Future<void> setAutoLockAfterSeconds(int seconds) =>
      _persist(state.copyWith(autoLockAfterSeconds: seconds));

  Future<void> setActiveFontFamily(String? fontFamily) =>
      _persist(state.copyWith(activeFontFamily: () => fontFamily));

  Future<void> addImportedFont(ImportedFontHiveModel font) => _persist(
    state.copyWith(importedFonts: [...state.importedFonts, font]),
  );

  Future<void> removeImportedFont(String fontFamily) async {
    final remaining = state.importedFonts
        .where((f) => f.fontFamily != fontFamily)
        .toList();
    final revertActive = state.activeFontFamily == fontFamily;
    await _persist(
      state.copyWith(
        importedFonts: remaining,
        activeFontFamily: revertActive ? () => null : null,
      ),
    );
  }
}
