import 'package:card_nudge/data/hive/models/reminder_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ReminderStorage {
  static const String boxName = 'reminders_box';

  static Box<ReminderModel> getBox() => Hive.box<ReminderModel>(boxName);
}
