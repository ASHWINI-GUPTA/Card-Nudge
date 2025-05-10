import 'package:hive_flutter/hive_flutter.dart';
import '../models/credit_card_model.dart';

class CreditCardStorage {
  static const String boxName = 'credit_cards';

  static Box<CreditCardModel> getBox() => Hive.box<CreditCardModel>(boxName);
}
