import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/security/lock_state_provider.dart';
import '../../application/settings/haptics_provider.dart';
import '../../application/settings/settings_provider.dart';
import '../../core/haptics/haptics_service.dart';
import '../../core/theme/app_theme.dart';
import '../ai_advisor/advisor_settings_screen.dart';
import '../groups/groups_screen.dart';
import '../lock/set_pin_screen.dart';
import '../lock/verify_pin_screen.dart';
import 'export_import_screen.dart';
import 'font_import_screen.dart';
import 'widgets/default_cardholder_name_field.dart';

/// Segmented button labels are given an explicit, slightly smaller text
/// style — the default text theme wraps a word like "Medium" onto two
/// lines once three roughly-equal segments share the row.
const _segmentedLabelStyle = TextStyle(fontSize: 13);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _tap(WidgetRef ref) => ref.read(hapticsServiceProvider).selectionClick();

  /// Gates a sensitive Settings action behind re-entering the current PIN.
  /// Returns true only if the user proved they know it.
  Future<bool> _verifyCurrentPin(BuildContext context, {String? reason}) async {
    final confirmed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => VerifyPinScreen(reason: reason)),
    );
    return confirmed == true;
  }

  Future<void> _toggleAppLock(
    BuildContext context,
    WidgetRef ref,
    bool enable,
  ) async {
    _tap(ref);
    final notifier = ref.read(settingsProvider.notifier);
    final lockNotifier = ref.read(appLockProvider.notifier);

    if (enable) {
      final success = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const SetPinScreen()),
      );
      if (success == true) {
        await notifier.setBiometricLockEnabled(true);
      }
      return;
    }

    if (!context.mounted) return;
    final verified = await _verifyCurrentPin(
      context,
      reason: 'to turn off App Lock',
    );
    if (!verified) return;

    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Turn off App Lock?'),
        content: const Text(
          'Card Vault will open without a PIN or biometric check.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Turn off'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await lockNotifier.clearPin();
    await notifier.setBiometricLockEnabled(false);
    await notifier.setBiometricUnlockEnabled(false);
  }

  Future<void> _changePin(BuildContext context, WidgetRef ref) async {
    _tap(ref);
    final verified = await _verifyCurrentPin(
      context,
      reason: 'to change it',
    );
    if (!verified || !context.mounted) return;

    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const SetPinScreen()),
    );
  }

  Future<void> _toggleBiometricUnlock(
    BuildContext context,
    WidgetRef ref,
    bool enable,
  ) async {
    _tap(ref);
    final verified = await _verifyCurrentPin(
      context,
      reason: enable
          ? 'to enable biometric unlock'
          : 'to disable biometric unlock',
    );
    if (!verified) return;

    await ref.read(settingsProvider.notifier).setBiometricUnlockEnabled(enable);
  }

  Future<void> _pickCustomAccentColor(BuildContext context, WidgetRef ref) async {
    _tap(ref);
    final settings = ref.read(settingsProvider);
    var pickedColor = Color(
      settings.themeSeedColorArgb ?? AppAccentColors.defaultColor.toARGB32(),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Pick an accent color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickedColor,
            onColorChanged: (color) => pickedColor = color,
            enableAlpha: false,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Select'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(settingsProvider.notifier)
          .setThemeSeedColor(pickedColor.toARGB32());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final biometricAvailable =
        ref.watch(isBiometricAvailableProvider).value ?? false;
    final isCustomAccentColor =
        settings.themeSeedColorArgb != null &&
        !AppAccentColors.all.any(
          (c) => c.toARGB32() == settings.themeSeedColorArgb,
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SettingsSection(
            title: 'Appearance',
            icon: Icons.palette_outlined,
            children: [
              _SubLabel('Theme'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<ThemeMode>(
                  style: SegmentedButton.styleFrom(
                    textStyle: _segmentedLabelStyle,
                  ),
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('System'),
                      icon: Icon(Icons.brightness_auto_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('Light'),
                      icon: Icon(Icons.light_mode_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('Dark'),
                      icon: Icon(Icons.dark_mode_outlined),
                    ),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (selection) {
                    _tap(ref);
                    notifier.setThemeMode(selection.first);
                  },
                ),
              ),
              const SizedBox(height: 16),
              _SubLabel('Accent Color'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ...AppAccentColors.all.map((color) {
                      final isSelected =
                          !isCustomAccentColor &&
                          (settings.themeSeedColorArgb ??
                                  AppAccentColors.defaultColor.toARGB32()) ==
                              color.toARGB32();
                      return GestureDetector(
                        onTap: () {
                          _tap(ref);
                          notifier.setThemeSeedColor(color.toARGB32());
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    width: 3,
                                  )
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : null,
                        ),
                      );
                    }),
                    GestureDetector(
                      onTap: () => _pickCustomAccentColor(context, ref),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isCustomAccentColor
                              ? Color(settings.themeSeedColorArgb!)
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCustomAccentColor
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).colorScheme.outlineVariant,
                            width: isCustomAccentColor ? 3 : 1.5,
                          ),
                        ),
                        child: isCustomAccentColor
                            ? null
                            : Icon(
                                Icons.colorize_rounded,
                                size: 16,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.format_size),
                title: const Text('UI Scale'),
                subtitle: Slider(
                  value: settings.uiScaleFactor,
                  min: 0.85,
                  max: 1.3,
                  divisions: 9,
                  label: '${(settings.uiScaleFactor * 100).round()}%',
                  onChanged: notifier.setUiScaleFactor,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.font_download_outlined),
                title: const Text('Font'),
                subtitle: Text(
                  settings.activeFontDisplayName(BundledFonts.inter),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _tap(ref);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FontImportScreen()),
                  );
                },
              ),
            ],
          ),
          _SettingsSection(
            title: 'Security',
            icon: Icons.shield_outlined,
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.lock_outline),
                title: const Text('App Lock'),
                subtitle: const Text('Require a PIN to open Card Vault'),
                value: settings.biometricLockEnabled,
                onChanged: (v) => _toggleAppLock(context, ref, v),
              ),
              if (settings.biometricLockEnabled) ...[
                ListTile(
                  leading: const Icon(Icons.password),
                  title: const Text('Change PIN'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _changePin(context, ref),
                ),
                if (biometricAvailable)
                  SwitchListTile(
                    secondary: const Icon(Icons.fingerprint),
                    title: const Text('Unlock with biometrics'),
                    subtitle: const Text('Your PIN always still works'),
                    value: settings.biometricUnlockEnabled,
                    onChanged: (v) => _toggleBiometricUnlock(context, ref, v),
                  ),
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Auto-lock after'),
                      const SizedBox(width: 4),
                      Tooltip(
                        message:
                            'How long Card Vault can sit in the background '
                            'before you have to unlock it again. '
                            '"Immediately" locks the instant you leave — '
                            'even a quick glance at another app. A longer '
                            'setting gives you a grace period to switch '
                            'apps and come right back without unlocking '
                            'again.',
                        triggerMode: TooltipTriggerMode.tap,
                        child: Icon(
                          Icons.help_outline_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  trailing: DropdownButton<int>(
                    value: settings.autoLockAfterSeconds,
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Immediately')),
                      DropdownMenuItem(value: 30, child: Text('30 seconds')),
                      DropdownMenuItem(value: 60, child: Text('1 minute')),
                      DropdownMenuItem(value: 300, child: Text('5 minutes')),
                      DropdownMenuItem(value: 900, child: Text('15 minutes')),
                    ],
                    onChanged: (v) {
                      _tap(ref);
                      notifier.setAutoLockAfterSeconds(v!);
                    },
                  ),
                ),
              ],
            ],
          ),
          _SettingsSection(
            title: 'Haptics',
            icon: Icons.vibration,
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.vibration),
                title: const Text('Haptics'),
                subtitle: const Text('Feel a tick for taps, drags, and reveals'),
                value: settings.hapticsEnabled,
                onChanged: (v) {
                  _tap(ref);
                  notifier.setHapticsEnabled(v);
                },
              ),
              if (settings.hapticsEnabled)
                ListTile(
                  leading: const Icon(Icons.tune),
                  title: const Text('Strength'),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SegmentedButton<HapticsStrength>(
                      style: SegmentedButton.styleFrom(
                        textStyle: _segmentedLabelStyle,
                      ),
                      segments: HapticsStrength.values
                          .map(
                            (s) => ButtonSegment(
                              value: s,
                              label: Text(s.displayName),
                            ),
                          )
                          .toList(),
                      selected: {settings.hapticsStrength},
                      onSelectionChanged: (selection) {
                        _tap(ref);
                        notifier.setHapticsStrength(selection.first);
                      },
                    ),
                  ),
                ),
            ],
          ),
          _SettingsSection(
            title: 'Card Defaults',
            icon: Icons.badge_outlined,
            children: const [DefaultCardholderNameField()],
          ),
          _SettingsSection(
            title: 'Organization',
            icon: Icons.folder_outlined,
            children: [
              ListTile(
                leading: const Icon(Icons.label_outline),
                title: const Text('Manage Groups'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _tap(ref);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GroupsScreen()),
                  );
                },
              ),
            ],
          ),
          _SettingsSection(
            title: 'Data',
            icon: Icons.storage_outlined,
            children: [
              ListTile(
                leading: const Icon(Icons.import_export),
                title: const Text('Encrypted Export / Import'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _tap(ref);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ExportImportScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          _SettingsSection(
            title: 'AI Purchase Advisor',
            icon: Icons.auto_awesome_outlined,
            children: [
              ListTile(
                leading: const Icon(Icons.vpn_key_outlined),
                title: const Text('Gemini API Key'),
                subtitle: const Text(
                  'Optional — off by default, no cloud sync',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _tap(ref);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdvisorSettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(children: children),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubLabel extends StatelessWidget {
  const _SubLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
