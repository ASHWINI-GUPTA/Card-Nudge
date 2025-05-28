// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreditCardModelAdapter extends TypeAdapter<CreditCardModel> {
  @override
  final int typeId = 2;

  @override
  CreditCardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreditCardModel(
      id: fields[0] as String?,
      userId: fields[1] as String,
      name: fields[2] as String,
      bankId: fields[3] as String?,
      last4Digits: fields[4] as String,
      billingDate: fields[5] as DateTime,
      dueDate: fields[6] as DateTime,
      cardType: fields[7] as CardType,
      creditLimit: fields[8] as double,
      currentUtilization: fields[9] as double,
      createdAt: fields[10] as DateTime?,
      updatedAt: fields[11] as DateTime?,
      isArchived: fields[12] == null ? false : fields[12] as bool,
      isFavorite: fields[13] == null ? false : fields[13] as bool,
      syncPending: fields[14] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CreditCardModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.bankId)
      ..writeByte(4)
      ..write(obj.last4Digits)
      ..writeByte(5)
      ..write(obj.billingDate)
      ..writeByte(6)
      ..write(obj.dueDate)
      ..writeByte(7)
      ..write(obj.cardType)
      ..writeByte(8)
      ..write(obj.creditLimit)
      ..writeByte(9)
      ..write(obj.currentUtilization)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.isArchived)
      ..writeByte(13)
      ..write(obj.isFavorite)
      ..writeByte(14)
      ..write(obj.syncPending);
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
