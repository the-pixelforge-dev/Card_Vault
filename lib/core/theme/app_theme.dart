import 'package:flutter/material.dart';

/// Bundled premium font families, shipped as static assets so the app never
/// fetches fonts over the network.
class BundledFonts {
  const BundledFonts._();

  static const inter = 'Inter';
  static const manrope = 'Manrope';
  static const spaceGrotesk = 'SpaceGrotesk';
  static const poppinsBold = 'PoppinsBold';

  static const all = [inter, manrope, spaceGrotesk, poppinsBold];

  /// Human-readable label for [poppinsBold] in Settings — the family id
  /// itself isn't a display name.
  static String displayName(String family) =>
      family == poppinsBold ? 'Poppins Bold' : family;
}

/// A curated palette of accent seed colors offered in Settings. Each drives
/// the whole app's Material 3 [ColorScheme] — surfaces, containers, and
/// backgrounds all derive their tone from this single seed.
class AppAccentColors {
  const AppAccentColors._();

  static const violet = Color(0xFF6C5CE7);
  static const ocean = Color(0xFF0984E3);
  static const emerald = Color(0xFF00B894);
  static const teal = Color(0xFF00CEC9);
  static const rose = Color(0xFFE84393);
  static const crimson = Color(0xFFD63031);
  static const sunset = Color(0xFFE17055);
  static const amber = Color(0xFFF0932B);
  static const plum = Color(0xFF8E44AD);
  static const slate = Color(0xFF2D3436);
  static const indigo = Color(0xFF4834D4);
  static const forest = Color(0xFF10AC84);
  static const coral = Color(0xFFFF6B6B);

  static const all = [
    violet,
    ocean,
    emerald,
    teal,
    rose,
    crimson,
    sunset,
    amber,
    plum,
    slate,
    indigo,
    forest,
    coral,
  ];

  static const defaultColor = violet;
}

class AppTheme {
  const AppTheme._();

  static ThemeData light({String? fontFamily, int? seedColorArgb}) => _build(
    Brightness.light,
    fontFamily,
    seedColorArgb,
  );

  static ThemeData dark({String? fontFamily, int? seedColorArgb}) => _build(
    Brightness.dark,
    fontFamily,
    seedColorArgb,
  );

  static ThemeData _build(
    Brightness brightness,
    String? fontFamily,
    int? seedColorArgb,
  ) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColorArgb != null
          ? Color(seedColorArgb)
          : AppAccentColors.defaultColor,
      brightness: brightness,
    );

    final theme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: fontFamily ?? BundledFonts.inter,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily ?? BundledFonts.spaceGrotesk,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );

    return theme.copyWith(
      // Smaller than the Material default (bodyMedium) so the one-line
      // explainer under a setting reads clearly as secondary to its title,
      // rather than competing with it.
      listTileTheme: ListTileThemeData(
        subtitleTextStyle: theme.textTheme.bodySmall?.copyWith(
          fontSize: 10,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
