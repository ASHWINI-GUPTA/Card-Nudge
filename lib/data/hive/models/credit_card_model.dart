import 'package:hive/hive.dart';

part 'credit_card_model.g.dart';

@HiveType(typeId: 0)
class CreditCardModel extends HiveObject {
  @HiveField(0)
  final String cardName;

  @HiveField(1)
  final String bankName;

  @HiveField(2)
  final String last4Digits;

  @HiveField(3)
  final DateTime billingDate;

  @HiveField(4)
  final DateTime dueDate;

  @HiveField(5)
  final double limit;

  @HiveField(6)
  double currentDueAmount;

  @HiveField(7)
  DateTime? lastPaidDate;

  CreditCardModel({
    required this.cardName,
    required this.bankName,
    required this.last4Digits,
    required this.billingDate,
    required this.dueDate,
    required this.limit,
    required this.currentDueAmount,
    this.lastPaidDate,
  });

  CreditCardModel copyWith({
    required double currentDueAmount,
    required DateTime lastPaidDate,
  }) {
    return CreditCardModel(
      cardName: cardName,
      bankName: bankName,
      last4Digits: last4Digits,
      billingDate: billingDate,
      dueDate: dueDate,
      limit: limit,
      currentDueAmount: currentDueAmount,
      lastPaidDate: lastPaidDate,
    );
  }
}
