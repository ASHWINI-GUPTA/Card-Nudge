import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 1)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String cardId;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.cardId,
    required this.description,
    required this.amount,
    required this.date,
  });
}
