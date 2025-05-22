import 'package:hive_flutter/hive_flutter.dart';
import '../adapters/card_type_adapter.dart';
import '../models/credit_card_model.dart';

class CreditCardStorage {
  static Box<CreditCardModel>? _box;

  static Box<CreditCardModel> getBox() {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Hive box not initialized. Call initHive() first.');
    }
    return _box!;
  }

  static Future<void> initHive() async {
    Hive.registerAdapter(CreditCardModelAdapter());
    Hive.registerAdapter(CardTypeAdapter());
    _box = await Hive.openBox<CreditCardModel>('credit_cards');
  }
}
