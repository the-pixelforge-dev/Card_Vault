import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../application/settings/haptics_provider.dart';
import '../../application/settings/settings_provider.dart';
import '../../core/fonts/dynamic_font_loader.dart';
import '../../core/theme/app_theme.dart';
import '../../data/settings/imported_font_hive_model.dart';

class FontImportScreen extends ConsumerStatefulWidget {
  const FontImportScreen({super.key});

  @override
  ConsumerState<FontImportScreen> createState() => _FontImportScreenState();
}

class _FontImportScreenState extends ConsumerState<FontImportScreen> {
  bool _importing = false;

  Future<void> _importFont() async {
    ref.read(hapticsServiceProvider).selectionClick();
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['ttf', 'otf'],
      dialogTitle: 'Choose a font file',
    );
    if (picked == null || picked.path == null) return;

    setState(() => _importing = true);
    try {
      final sourcePath = picked.path!;
      final fontsDir = Directory(
        p.join((await getApplicationDocumentsDirectory()).path, 'fonts'),
      );
      if (!await fontsDir.exists()) {
        await fontsDir.create(recursive: true);
      }

      final id = const Uuid().v4();
      final displayName = p.basenameWithoutExtension(sourcePath);
      final fontFamily = 'UserFont_$id';
      final destPath = p.join(fontsDir.path, '$id${p.extension(sourcePath)}');
      await File(sourcePath).copy(destPath);

      await DynamicFontLoader.registerFont(
        fontFamily: fontFamily,
        filePath: destPath,
      );

      final record = ImportedFontHiveModel(
        fontFamily: fontFamily,
        filePath: destPath,
        displayName: displayName,
      );
      await ref.read(settingsProvider.notifier).addImportedFont(record);
      await ref.read(settingsProvider.notifier).setActiveFontFamily(
        fontFamily,
      );
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Font')),
      body: RadioGroup<String>(
        groupValue: settings.activeFontFamily ?? BundledFonts.inter,
        onChanged: (family) {
          ref.read(hapticsServiceProvider).selectionClick();
          notifier.setActiveFontFamily(family);
        },
        child: ListView(
          children: [
            const _Header('Bundled'),
            ...BundledFonts.all.map(
              (family) => RadioListTile<String>(
                title: Text(
                  BundledFonts.displayName(family),
                  style: TextStyle(fontFamily: family),
                ),
                value: family,
              ),
            ),
            if (settings.importedFonts.isNotEmpty) ...[
              const _Header('Imported'),
              ...settings.importedFonts.map(
                (font) => ListTile(
                  title: Text(
                    font.displayName,
                    style: TextStyle(fontFamily: font.fontFamily),
                  ),
                  leading: Radio<String>(value: font.fontFamily),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      ref.read(hapticsServiceProvider).selectionClick();
                      notifier.removeImportedFont(font.fontFamily);
                    },
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: _importing ? null : _importFont,
                icon: _importing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_file),
                label: const Text('Import a .ttf/.otf font'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
