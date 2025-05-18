// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BankModelAdapter extends TypeAdapter<BankModel> {
  @override
  final int typeId = 0;

  @override
  BankModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BankModel(
      id: fields[0] as String?,
      name: fields[1] as String,
      code: fields[2] as String?,
      logoPath: fields[3] as String?,
      supportNumber: fields[4] as String?,
      website: fields[5] as String?,
      isFavorite: fields[6] as bool,
      colorHex: fields[7] as String?,
      priority: fields[8] as int?,
      createdAt: fields[9] as DateTime?,
      updatedAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BankModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.code)
      ..writeByte(3)
      ..write(obj.logoPath)
      ..writeByte(4)
      ..write(obj.supportNumber)
      ..writeByte(5)
      ..write(obj.website)
      ..writeByte(6)
      ..write(obj.isFavorite)
      ..writeByte(7)
      ..write(obj.colorHex)
      ..writeByte(8)
      ..write(obj.priority)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
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
