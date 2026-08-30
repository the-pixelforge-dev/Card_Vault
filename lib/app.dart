import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application/settings/settings_provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/lock/app_lock_gate.dart';

class CardVaultApp extends ConsumerWidget {
  const CardVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Card Vault',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: AppTheme.light(
        fontFamily: settings.activeFontFamily,
        seedColorArgb: settings.themeSeedColorArgb,
      ),
      darkTheme: AppTheme.dark(
        fontFamily: settings.activeFontFamily,
        seedColorArgb: settings.themeSeedColorArgb,
      ),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(settings.uiScaleFactor),
          ),
          child: AppLockGate(child: child ?? const SizedBox.shrink()),
        );
      },
      home: const HomeScreen(),
    );
  }
}
