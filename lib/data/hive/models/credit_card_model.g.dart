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
      cardName: fields[0] as String,
      bankName: fields[1] as String,
      last4Digits: fields[2] as String,
      billingDate: fields[3] as DateTime,
      dueDate: fields[4] as DateTime,
      limit: fields[5] as double,
      currentDueAmount: fields[6] as double,
      lastPaidDate: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CreditCardModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.cardName)
      ..writeByte(1)
      ..write(obj.bankName)
      ..writeByte(2)
      ..write(obj.last4Digits)
      ..writeByte(3)
      ..write(obj.billingDate)
      ..writeByte(4)
      ..write(obj.dueDate)
      ..writeByte(5)
      ..write(obj.limit)
      ..writeByte(6)
      ..write(obj.currentDueAmount)
      ..writeByte(7)
      ..write(obj.lastPaidDate);
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
