import 'package:card_nudge/data/hive/models/payment_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ReminderStorage {
  static const String boxName = 'payment_box';
  static Box<PaymentModel> getBox() => Hive.box<PaymentModel>(boxName);
}
