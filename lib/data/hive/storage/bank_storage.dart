import 'package:card_nudge/data/hive/models/bank_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BankStorage {
  static Box<BankModel>? _box;

  static Box<BankModel> getBox() {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Hive box not initialized. Call initHive() first.');
    }
    return _box!;
  }

  static Future<void> initHive() async {
    Hive.registerAdapter(BankModelAdapter());

    _box = await Hive.openBox<BankModel>('banks');
  }
}
