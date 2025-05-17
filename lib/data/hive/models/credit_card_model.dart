import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'credit_card_model.g.dart';

@HiveType(typeId: 0)
class CreditCardModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String cardName;

  @HiveField(2)
  final String bankName;

  @HiveField(3)
  final String last4Digits;

  @HiveField(4)
  final DateTime billingDate;

  @HiveField(5)
  DateTime dueDate;

  @HiveField(6)
  final double limit;

  @HiveField(7)
  double currentDueAmount;

  @HiveField(8)
  DateTime? lastPaidDate;

  @HiveField(9)
  String? cardType;

  CreditCardModel({
    String? id,
    required this.cardName,
    required this.bankName,
    required this.last4Digits,
    required this.billingDate,
    required this.dueDate,
    required this.limit,
    required this.currentDueAmount,
    this.lastPaidDate,
    this.cardType,
  }) : id = id ?? const Uuid().v4();

  CreditCardModel copyWith({
    String? id,
    String? cardName,
    String? last4Digits,
    String? bankName,
    DateTime? billingDate,
    DateTime? dueDate,
    double? limit,
    double? currentDueAmount,
    String? cardType,
    double? interestRate,
  }) {
    return CreditCardModel(
      id: id ?? this.id,
      cardName: cardName ?? this.cardName,
      last4Digits: last4Digits ?? this.last4Digits,
      bankName: bankName ?? this.bankName,
      billingDate: billingDate ?? this.billingDate,
      dueDate: dueDate ?? this.dueDate,
      limit: limit ?? this.limit,
      currentDueAmount: currentDueAmount ?? this.currentDueAmount,
      lastPaidDate: lastPaidDate ?? this.lastPaidDate,
      cardType: cardType ?? this.cardType,
    );
  }
}
