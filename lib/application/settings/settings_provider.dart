import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/cards/card_stack_style.dart';
import '../../core/haptics/haptics_service.dart';
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

  Future<void> setBiometricUnlockEnabled(bool enabled) =>
      _persist(state.copyWith(biometricUnlockEnabled: enabled));

  Future<void> setAutoLockAfterSeconds(int seconds) =>
      _persist(state.copyWith(autoLockAfterSeconds: seconds));

  Future<void> setThemeSeedColor(int? colorArgb) =>
      _persist(state.copyWith(themeSeedColorArgb: () => colorArgb));

  Future<void> setDefaultCardholderName(String? name) => _persist(
    state.copyWith(defaultCardholderName: () => name),
  );

  Future<void> setHapticsEnabled(bool enabled) =>
      _persist(state.copyWith(hapticsEnabled: enabled));

  Future<void> setHapticsStrength(HapticsStrength strength) =>
      _persist(state.copyWith(hapticsStrength: strength));

  Future<void> setCardStackDepthStyle(CardStackDepthStyle style) =>
      _persist(state.copyWith(cardStackDepthStyle: style));

  Future<void> setCardStackGlowIntensity(double intensity) =>
      _persist(state.copyWith(cardStackGlowIntensity: intensity));

  Future<void> setDefaultStackFilter(DefaultCardStackFilter filter) =>
      _persist(state.copyWith(defaultStackFilter: filter));

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

  /// Applies settings restored from an encrypted backup, in one write.
  ///
  /// Deliberately has no App Lock parameters (on/off, biometric unlock,
  /// auto-lock timeout) — those describe device-local security state tied
  /// to a PIN that lives in secure storage and is never itself part of a
  /// backup, so importing them could enable App Lock on a device with no
  /// PIN configured and strand the user. `copyWith` leaves whatever App
  /// Lock configuration already exists on this device untouched.
  Future<void> restoreBackedUpSettings({
    required ThemeMode themeMode,
    required double uiScaleFactor,
    required String? activeFontFamily,
    required List<ImportedFontHiveModel> importedFonts,
    required int? themeSeedColorArgb,
    required String? defaultCardholderName,
    required bool hapticsEnabled,
    required HapticsStrength hapticsStrength,
    required CardStackDepthStyle cardStackDepthStyle,
    required double cardStackGlowIntensity,
    required DefaultCardStackFilter defaultStackFilter,
  }) => _persist(
    state.copyWith(
      themeMode: themeMode,
      uiScaleFactor: uiScaleFactor,
      activeFontFamily: () => activeFontFamily,
      importedFonts: importedFonts,
      themeSeedColorArgb: () => themeSeedColorArgb,
      defaultCardholderName: () => defaultCardholderName,
      hapticsEnabled: hapticsEnabled,
      hapticsStrength: hapticsStrength,
      cardStackDepthStyle: cardStackDepthStyle,
      cardStackGlowIntensity: cardStackGlowIntensity,
      defaultStackFilter: defaultStackFilter,
    ),
  );
}
