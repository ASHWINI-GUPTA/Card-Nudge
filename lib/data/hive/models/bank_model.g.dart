// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BankModelAdapter extends TypeAdapter<BankModel> {
  @override
  final int typeId = 1;

  @override
  BankModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BankModel(
      id: fields[0] as String?,
      userId: fields[1] as String,
      name: fields[2] as String,
      code: fields[3] as String?,
      logoPath: fields[4] as String?,
      supportNumber: fields[5] as String?,
      website: fields[6] as String?,
      isFavorite: fields[7] as bool,
      colorHex: fields[8] as String?,
      priority: fields[9] as int?,
      createdAt: fields[10] as DateTime?,
      updatedAt: fields[11] as DateTime?,
      syncPending: fields[12] as bool,
      isDefault: fields[13] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, BankModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.code)
      ..writeByte(4)
      ..write(obj.logoPath)
      ..writeByte(5)
      ..write(obj.supportNumber)
      ..writeByte(6)
      ..write(obj.website)
      ..writeByte(7)
      ..write(obj.isFavorite)
      ..writeByte(8)
      ..write(obj.colorHex)
      ..writeByte(9)
      ..write(obj.priority)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.syncPending)
      ..writeByte(13)
      ..write(obj.isDefault);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BankModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
