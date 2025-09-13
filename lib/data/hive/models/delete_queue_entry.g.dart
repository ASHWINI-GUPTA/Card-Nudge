// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_queue_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeleteQueueEntryAdapter extends TypeAdapter<DeleteQueueEntry> {
  @override
  final int typeId = 21;

  @override
  DeleteQueueEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeleteQueueEntry(
      id: fields[0] as String,
      entityType: fields[1] as Entities,
    );
  }

  @override
  void write(BinaryWriter writer, DeleteQueueEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.entityType)
      ..writeByte(2)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeleteQueueEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
