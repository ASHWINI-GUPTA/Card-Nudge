// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreditCardModelAdapter extends TypeAdapter<CreditCardModel> {
  @override
  final int typeId = 1;

  @override
  CreditCardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreditCardModel(
      id: fields[0] as String?,
      name: fields[1] as String,
      bankId: fields[2] as String,
      last4Digits: fields[3] as String,
      billingDate: fields[4] as DateTime,
      dueDate: fields[5] as DateTime,
      cardType: fields[6] as CardType,
      creditLimit: fields[7] as double,
      currentUtilization: fields[8] as double,
      createdAt: fields[9] as DateTime?,
      updatedAt: fields[10] as DateTime?,
      isArchived: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CreditCardModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.bankId)
      ..writeByte(3)
      ..write(obj.last4Digits)
      ..writeByte(4)
      ..write(obj.billingDate)
      ..writeByte(5)
      ..write(obj.dueDate)
      ..writeByte(6)
      ..write(obj.cardType)
      ..writeByte(7)
      ..write(obj.creditLimit)
      ..writeByte(8)
      ..write(obj.currentUtilization)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.isArchived);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreditCardModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
