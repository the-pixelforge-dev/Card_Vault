import 'package:hive_ce/hive.dart';

part 'imported_font_hive_model.g.dart';

/// Metadata for a user-imported custom font. The actual font bytes live on
/// disk at [filePath]; [FontLoader] registration itself cannot be persisted
/// and must be re-run from this record on every app start.
@HiveType(typeId: 2)
class ImportedFontHiveModel {
  ImportedFontHiveModel({
    required this.fontFamily,
    required this.filePath,
    required this.displayName,
  });

  @HiveField(0)
  String fontFamily;

  @HiveField(1)
  String filePath;

  @HiveField(2)
  String displayName;
}
