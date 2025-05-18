import 'package:hive/hive.dart';

import '../../enums/card_type.dart';

class CardTypeAdapter extends TypeAdapter<CardType> {
  @override
  final int typeId = 3;

  @override
  CardType read(BinaryReader reader) {
    return CardType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, CardType obj) {
    writer.writeByte(obj.index);
  }
}
