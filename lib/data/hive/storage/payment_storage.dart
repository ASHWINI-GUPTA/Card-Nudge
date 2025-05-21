import 'package:card_nudge/data/hive/models/payment_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PaymentStorage {
  static Box<PaymentModel>? _box;

  static Box<PaymentModel> getBox() {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Hive box not initialized. Call initHive() first.');
    }
    return _box!;
  }

  static Future<void> initHive() async {
    Hive.registerAdapter(PaymentModelAdapter());
    _box = await Hive.openBox<PaymentModel>('payments');
  }
}
