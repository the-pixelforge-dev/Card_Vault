// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CardHiveModelAdapter extends TypeAdapter<CardHiveModel> {
  @override
  final typeId = 0;

  @override
  CardHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CardHiveModel(
      id: fields[0] as String,
      cardholderName: fields[1] as String,
      cardNumber: fields[2] as String,
      expiryMonthYear: fields[3] as String,
      cvv: fields[4] as String,
      issuerName: fields[5] as String,
      network: fields[6] as String,
      cardType: fields[22] == null ? 'credit' : fields[22] as String,
      nickname: fields[7] as String,
      colorArgb: (fields[8] as num).toInt(),
      artworkImagePath: fields[9] as String?,
      rewardsText: fields[10] == null ? '' : fields[10] as String,
      bestForText: fields[11] == null ? '' : fields[11] as String,
      rewardsUrl: fields[12] as String?,
      paymentUrl: fields[13] as String?,
      managementUrl: fields[14] as String?,
      customerServiceUrl: fields[15] as String?,
      customFields: (fields[16] as Map?)?.cast<String, String>(),
      notes: fields[17] == null ? '' : fields[17] as String,
      groupIds: (fields[18] as List?)?.cast<String>(),
      sortOrder: (fields[19] as num).toInt(),
      createdAt: fields[20] as DateTime,
      updatedAt: fields[21] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CardHiveModel obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cardholderName)
      ..writeByte(2)
      ..write(obj.cardNumber)
      ..writeByte(3)
      ..write(obj.expiryMonthYear)
      ..writeByte(4)
      ..write(obj.cvv)
      ..writeByte(5)
      ..write(obj.issuerName)
      ..writeByte(6)
      ..write(obj.network)
      ..writeByte(7)
      ..write(obj.nickname)
      ..writeByte(8)
      ..write(obj.colorArgb)
      ..writeByte(9)
      ..write(obj.artworkImagePath)
      ..writeByte(10)
      ..write(obj.rewardsText)
      ..writeByte(11)
      ..write(obj.bestForText)
      ..writeByte(12)
      ..write(obj.rewardsUrl)
      ..writeByte(13)
      ..write(obj.paymentUrl)
      ..writeByte(14)
      ..write(obj.managementUrl)
      ..writeByte(15)
      ..write(obj.customerServiceUrl)
      ..writeByte(16)
      ..write(obj.customFields)
      ..writeByte(17)
      ..write(obj.notes)
      ..writeByte(18)
      ..write(obj.groupIds)
      ..writeByte(19)
      ..write(obj.sortOrder)
      ..writeByte(20)
      ..write(obj.createdAt)
      ..writeByte(21)
      ..write(obj.updatedAt)
      ..writeByte(22)
      ..write(obj.cardType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
