import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'payment_model.g.dart';

@HiveType(typeId: 2)
class PaymentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String cardId;

  @HiveField(2)
  final double dueAmount;

  @HiveField(3)
  DateTime? paymentDate;

  @HiveField(4)
  final bool isPaid;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  @HiveField(7)
  final double? minimumDueAmount;

  @HiveField(8)
  double paidAmount;

  @HiveField(9)
  final DateTime dueDate;

  PaymentModel({
    String? id,
    required this.cardId,
    required this.dueAmount,
    DateTime? paymentDate,
    this.isPaid = false, // Default to false
    DateTime? createdAt,
    DateTime? updatedAt,
    this.minimumDueAmount, // Optional field
    this.paidAmount = 0.0, // Default to 0.0
    required this.dueDate,
  }) : id = id ?? const Uuid().v4(),
       createdAt = (createdAt ?? DateTime.now()).toUtc(),
       updatedAt = (updatedAt ?? DateTime.now()).toUtc();

  PaymentModel copyWith({
    String? cardId,
    double? dueAmount,
    DateTime? paymentDate,
    bool? isPaid,
    double? minimumDueAmount,
    double? paidAmount,
    DateTime? dueDate,
  }) {
    return PaymentModel(
      id: id,
      cardId: cardId ?? this.cardId,
      dueAmount: dueAmount ?? this.dueAmount,
      paymentDate: paymentDate ?? this.paymentDate,
      isPaid: isPaid ?? this.isPaid,
      createdAt: createdAt,
      updatedAt: DateTime.now().toUtc(),
      minimumDueAmount: minimumDueAmount ?? this.minimumDueAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentModel &&
        other.id == id &&
        other.cardId == cardId &&
        other.dueAmount == dueAmount &&
        other.paymentDate == paymentDate &&
        other.isPaid == isPaid &&
        other.paidAmount == paidAmount &&
        other.dueDate == dueDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        cardId.hashCode ^
        dueAmount.hashCode ^
        paymentDate.hashCode ^
        isPaid.hashCode ^
        paidAmount.hashCode ^
        dueDate.hashCode;
  }

  // Status helpers
  bool get isOverdue => !isPaid && dueDate.isBefore(DateTime.now());

  bool get isDueSoon =>
      !isPaid && dueDate.difference(DateTime.now()).inDays <= 3;

  bool get isPartiallyPaid => paidAmount > 0 && paidAmount < dueAmount;

  double get remainingAmount => dueAmount - paidAmount;
}
