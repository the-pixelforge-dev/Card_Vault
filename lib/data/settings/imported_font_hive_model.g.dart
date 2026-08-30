// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'imported_font_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ImportedFontHiveModelAdapter extends TypeAdapter<ImportedFontHiveModel> {
  @override
  final typeId = 2;

  @override
  ImportedFontHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ImportedFontHiveModel(
      fontFamily: fields[0] as String,
      filePath: fields[1] as String,
      displayName: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ImportedFontHiveModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.fontFamily)
      ..writeByte(1)
      ..write(obj.filePath)
      ..writeByte(2)
      ..write(obj.displayName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImportedFontHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
