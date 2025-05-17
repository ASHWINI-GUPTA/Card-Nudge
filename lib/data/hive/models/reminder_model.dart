// lib/models/reminder_model.dart
import 'package:hive/hive.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: 2)
class ReminderModel extends HiveObject {
  @HiveField(0)
  final int cardId;

  @HiveField(1)
  final DateTime scheduledDate;

  @HiveField(2)
  final String type; // e.g. 'dueReminder', 'enterDue'

  ReminderModel({
    required this.cardId,
    required this.scheduledDate,
    required this.type,
  });
}
