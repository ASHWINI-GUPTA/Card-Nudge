// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 4;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      userId: fields[1] as String,
      language: fields[2] as Language,
      currency: fields[3] as Currency,
      themeMode: fields[4] as ThemeMode,
      notificationsEnabled: fields[5] as bool,
      reminderTime: fields[6] as TimeOfDay?,
      syncSettings: fields[7] as bool,
      createdAt: fields[8] as DateTime?,
      updatedAt: fields[9] as DateTime?,
      syncPending: fields[10] as bool,
      utilizationAlertThreshold: fields[11] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.language)
      ..writeByte(3)
      ..write(obj.currency)
      ..writeByte(4)
      ..write(obj.themeMode)
      ..writeByte(5)
      ..write(obj.notificationsEnabled)
      ..writeByte(6)
      ..write(obj.reminderTime)
      ..writeByte(7)
      ..write(obj.syncSettings)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.syncPending)
      ..writeByte(11)
      ..write(obj.utilizationAlertThreshold);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
