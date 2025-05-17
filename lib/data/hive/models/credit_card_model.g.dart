// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreditCardModelAdapter extends TypeAdapter<CreditCardModel> {
  @override
  final int typeId = 0;

  @override
  CreditCardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreditCardModel(
      id: fields[0] as String?,
      cardName: fields[1] as String,
      bankName: fields[2] as String,
      last4Digits: fields[3] as String,
      billingDate: fields[4] as DateTime,
      dueDate: fields[5] as DateTime,
      limit: fields[6] as double,
      currentDueAmount: fields[7] as double,
      lastPaidDate: fields[8] as DateTime?,
      cardType: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CreditCardModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cardName)
      ..writeByte(2)
      ..write(obj.bankName)
      ..writeByte(3)
      ..write(obj.last4Digits)
      ..writeByte(4)
      ..write(obj.billingDate)
      ..writeByte(5)
      ..write(obj.dueDate)
      ..writeByte(6)
      ..write(obj.limit)
      ..writeByte(7)
      ..write(obj.currentDueAmount)
      ..writeByte(8)
      ..write(obj.lastPaidDate)
      ..writeByte(9)
      ..write(obj.cardType);
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
