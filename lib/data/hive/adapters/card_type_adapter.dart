import 'package:card_nudge/data/enums/entities.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../enums/card_type.dart';
import '../../enums/currency.dart';
import '../../enums/language.dart';

class CardTypeAdapter extends TypeAdapter<CardType> {
  @override
  final int typeId = 10;

  @override
  CardType read(BinaryReader reader) {
    return CardType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, CardType obj) {
    writer.writeByte(obj.index);
  }
}

class LanguageAdapter extends TypeAdapter<Language> {
  @override
  final int typeId = 11;

  @override
  Language read(BinaryReader reader) {
    return Language.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, Language obj) {
    writer.writeByte(obj.index);
  }
}

class CurrencyAdapter extends TypeAdapter<Currency> {
  @override
  final int typeId = 12;

  @override
  Currency read(BinaryReader reader) {
    return Currency.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, Currency obj) {
    writer.writeByte(obj.index);
  }
}

class ThemeModeAdapter extends TypeAdapter<ThemeMode> {
  @override
  final int typeId = 13;

  @override
  ThemeMode read(BinaryReader reader) {
    return ThemeMode.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, ThemeMode obj) {
    writer.writeByte(obj.index);
  }
}

class TimeOfDayAdapter extends TypeAdapter<TimeOfDay> {
  @override
  final typeId = 101;

  @override
  void write(BinaryWriter writer, TimeOfDay obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.hour)
      ..writeByte(1)
      ..write(obj.minute);
  }

  TimeOfDay read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimeOfDay(hour: fields[0] as int, minute: fields[1] as int);
  }
}

class EntitiesAdapter extends TypeAdapter<Entities> {
  @override
  final int typeId = 102;

  @override
  Entities read(BinaryReader reader) {
    return Entities.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, Entities obj) {
    writer.writeByte(obj.index);
  }
}
