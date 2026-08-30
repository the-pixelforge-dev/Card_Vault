// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GroupHiveModelAdapter extends TypeAdapter<GroupHiveModel> {
  @override
  final typeId = 1;

  @override
  GroupHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GroupHiveModel(
      id: fields[0] as String,
      name: fields[1] as String,
      colorArgb: (fields[2] as num?)?.toInt(),
      sortOrder: (fields[3] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, GroupHiveModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.colorArgb)
      ..writeByte(3)
      ..write(obj.sortOrder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
