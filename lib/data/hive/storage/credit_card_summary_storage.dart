import 'package:hive_flutter/hive_flutter.dart';
import '../models/credit_card_summary_model.dart';

class CreditCardSummaryStorage {
  static Box<CreditCardSummaryModel>? _box;

  static Box<CreditCardSummaryModel> getBox() {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Hive box not initialized. Call initHive() first.');
    }
    return _box!;
  }

  static Future<void> initHive() async {
    Hive.registerAdapter(CreditCardSummaryModelAdapter());
    _box = await Hive.openBox<CreditCardSummaryModel>('credit_card_summaries');
  }
}
