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
    this.hapticsEnabled = true,
    this.hapticsStrength = 'medium',
    this.cardStackDepthStyle = 'shrink',
    this.cardStackGlowIntensity = 1.0,
    this.defaultStackFilter = 'all',
    this.cardStackVisibleCount = 5,
    this.currency = 'usd',
    this.cardInfoExpandedByDefault = false,
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

  @HiveField(9)
  bool hapticsEnabled;

  /// One of 'low', 'medium', 'high'.
  @HiveField(10)
  String hapticsStrength;

  /// One of 'shrink', 'uniform'.
  @HiveField(11)
  String cardStackDepthStyle;

  /// 0.0 (no glow) to 1.0 (full glow), in steps of 0.1.
  @HiveField(12)
  double cardStackGlowIntensity;

  /// One of 'all', 'credit', 'debit' — the card type filter the home
  /// screen's stack and group dropdown start on.
  @HiveField(13)
  String defaultStackFilter;

  /// How many cards deep the home screen stack renders at once, 2-5.
  @HiveField(14)
  int cardStackVisibleCount;

  /// Stored as [AppCurrency.name] (see core/settings/app_currency.dart).
  @HiveField(15)
  String currency;

  /// Whether the card detail screen's merged "Info" section (Rewards, Best
  /// For, Notes) starts expanded or collapsed.
  @HiveField(16)
  bool cardInfoExpandedByDefault;
}
