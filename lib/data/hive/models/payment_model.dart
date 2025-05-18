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
  final DateTime paymentDate;

  @HiveField(4)
  final bool isPaid;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  PaymentModel({
    String? id,
    required this.cardId,
    required this.dueAmount,
    required this.paymentDate,
    this.isPaid = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = (createdAt ?? DateTime.now()).toUtc(),
       updatedAt = (updatedAt ?? DateTime.now()).toUtc();

  PaymentModel copyWith({
    String? cardId,
    double? dueAmount,
    DateTime? paymentDate,
    bool? isPaid,
  }) {
    return PaymentModel(
      id: id,
      cardId: cardId ?? this.cardId,
      dueAmount: dueAmount ?? this.dueAmount,
      paymentDate: paymentDate ?? this.paymentDate,
      isPaid: isPaid ?? this.isPaid,
      createdAt: createdAt,
    );
  }

  // Helper method to mark payment as paid
  PaymentModel markAsPaid() {
    return copyWith(isPaid: true);
  }

  // Helper method to update payment amount
  PaymentModel updateAmount(double newAmount) {
    return copyWith(dueAmount: newAmount);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentModel &&
        other.id == id &&
        other.cardId == cardId &&
        other.dueAmount == dueAmount &&
        other.paymentDate == paymentDate &&
        other.isPaid == isPaid;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        cardId.hashCode ^
        dueAmount.hashCode ^
        paymentDate.hashCode ^
        isPaid.hashCode;
  }

  // Additional helpful methods
  bool get isOverdue => !isPaid && paymentDate.isBefore(DateTime.now());
  bool get isDueSoon =>
      !isPaid && paymentDate.difference(DateTime.now()).inDays <= 3;
}
