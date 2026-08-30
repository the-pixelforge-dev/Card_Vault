import 'dart:io';

import 'package:flutter/services.dart';

import '../../data/settings/imported_font_hive_model.dart';

/// Registers previously-imported custom fonts with the engine.
///
/// [FontLoader] registration is in-memory only for the current engine
/// session — there is no built-in persistence — so [registerAll] must be
/// awaited before `runApp()` on every cold start, re-reading each font's
/// bytes from disk and re-running the same registration performed at
/// import time.
class DynamicFontLoader {
  const DynamicFontLoader._();

  static Future<void> registerAll(
    List<ImportedFontHiveModel> importedFonts,
  ) async {
    for (final font in importedFonts) {
      await _registerOne(font);
    }
  }

  static Future<void> registerFont({
    required String fontFamily,
    required String filePath,
  }) async {
    await _registerOne(
      ImportedFontHiveModel(
        fontFamily: fontFamily,
        filePath: filePath,
        displayName: fontFamily,
      ),
    );
  }

  static Future<void> _registerOne(ImportedFontHiveModel font) async {
    final file = File(font.filePath);
    if (!await file.exists()) return;

    final bytes = await file.readAsBytes();
    final fontLoader = FontLoader(font.fontFamily);
    fontLoader.addFont(
      Future.value(ByteData.sublistView(Uint8List.fromList(bytes))),
    );
    await fontLoader.load();
  }
}
