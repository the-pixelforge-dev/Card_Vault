import 'package:hive_ce/hive.dart';

import 'imported_font_hive_model.dart';

part 'settings_hive_model.g.dart';

@HiveType(typeId: 3)
class AppSettingsHiveModel extends HiveObject {
  AppSettingsHiveModel({
    this.themeMode = 'system',
    this.uiScaleFactor = 1.0,
    this.activeFontFamily,
    List<ImportedFontHiveModel>? importedFonts,
    this.biometricLockEnabled = false,
    this.autoLockAfterSeconds = 30,
    this.biometricUnlockEnabled = false,
    this.themeSeedColorArgb,
    this.defaultCardholderName,
  }) : importedFonts = importedFonts ?? [];

  /// One of 'system', 'light', 'dark'.
  @HiveField(0)
  String themeMode;

  @HiveField(1)
  double uiScaleFactor;

  @HiveField(2)
  String? activeFontFamily;

  @HiveField(3)
  List<ImportedFontHiveModel> importedFonts;

  @HiveField(4)
  bool biometricLockEnabled;

  /// 0 means "lock immediately" on backgrounding.
  @HiveField(5)
  int autoLockAfterSeconds;

  /// Whether biometrics can be used as a quick-unlock shortcut. The app PIN
  /// (see PinStore) is always the guaranteed fallback regardless of this.
  @HiveField(6)
  bool biometricUnlockEnabled;

  /// Seed color for the app-wide Material 3 color scheme. Null uses the
  /// built-in default seed.
  @HiveField(7)
  int? themeSeedColorArgb;

  /// Pre-fills the cardholder name field when adding a new card. Null means
  /// no default is set.
  @HiveField(8)
  String? defaultCardholderName;
}
