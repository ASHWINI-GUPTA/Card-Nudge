// lib/data/models/credit_card.dart
import 'package:uuid/uuid.dart';

class CreditCard {
  final String id;
  final String cardName;
  final String last4Digits;
  final String bankName;
  final DateTime billingDate;
  final DateTime dueDate;
  final double limit;
  double currentDue;
  bool isPaid;

  CreditCard({
    String? id,
    required this.cardName,
    required this.last4Digits,
    required this.bankName,
    required this.billingDate,
    required this.dueDate,
    required this.limit,
    required this.currentDue,
    this.isPaid = false,
  }) : id = id ?? const Uuid().v4();

  CreditCard copyWith({
    String? id,
    String? cardName,
    String? last4Digits,
    String? bankName,
    DateTime? billingDate,
    DateTime? dueDate,
    double? limit,
    double? currentDue,
    bool? isPaid,
  }) {
    return CreditCard(
      id: id ?? this.id,
      cardName: cardName ?? this.cardName,
      last4Digits: last4Digits ?? this.last4Digits,
      bankName: bankName ?? this.bankName,
      billingDate: billingDate ?? this.billingDate,
      dueDate: dueDate ?? this.dueDate,
      limit: limit ?? this.limit,
      currentDue: currentDue ?? this.currentDue,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}
