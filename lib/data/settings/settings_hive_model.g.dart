// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsHiveModelAdapter extends TypeAdapter<AppSettingsHiveModel> {
  @override
  final typeId = 3;

  @override
  AppSettingsHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettingsHiveModel(
      themeMode: fields[0] == null ? 'system' : fields[0] as String,
      uiScaleFactor: fields[1] == null ? 1.0 : (fields[1] as num).toDouble(),
      activeFontFamily: fields[2] as String?,
      importedFonts: (fields[3] as List?)?.cast<ImportedFontHiveModel>(),
      biometricLockEnabled: fields[4] == null ? false : fields[4] as bool,
      autoLockAfterSeconds: fields[5] == null ? 30 : (fields[5] as num).toInt(),
      biometricUnlockEnabled: fields[6] == null ? false : fields[6] as bool,
      themeSeedColorArgb: (fields[7] as num?)?.toInt(),
      defaultCardholderName: fields[8] as String?,
      hapticsEnabled: fields[9] == null ? true : fields[9] as bool,
      hapticsStrength: fields[10] == null ? 'medium' : fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettingsHiveModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.themeMode)
      ..writeByte(1)
      ..write(obj.uiScaleFactor)
      ..writeByte(2)
      ..write(obj.activeFontFamily)
      ..writeByte(3)
      ..write(obj.importedFonts)
      ..writeByte(4)
      ..write(obj.biometricLockEnabled)
      ..writeByte(5)
      ..write(obj.autoLockAfterSeconds)
      ..writeByte(6)
      ..write(obj.biometricUnlockEnabled)
      ..writeByte(7)
      ..write(obj.themeSeedColorArgb)
      ..writeByte(8)
      ..write(obj.defaultCardholderName)
      ..writeByte(9)
      ..write(obj.hapticsEnabled)
      ..writeByte(10)
      ..write(obj.hapticsStrength);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
