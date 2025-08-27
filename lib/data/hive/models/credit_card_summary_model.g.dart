// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card_summary_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreditCardSummaryModelAdapter
    extends TypeAdapter<CreditCardSummaryModel> {
  @override
  final int typeId = 7;

  @override
  CreditCardSummaryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreditCardSummaryModel(
      id: fields[0] as String,
      cardId: fields[1] as String,
      markdownSummary: fields[2] as String,
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
      status: fields[5] as int,
      userLiked: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CreditCardSummaryModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cardId)
      ..writeByte(2)
      ..write(obj.markdownSummary)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.userLiked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreditCardSummaryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
