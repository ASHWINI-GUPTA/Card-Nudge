import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'payment_model.g.dart';

@HiveType(typeId: 3)
class PaymentModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String cardId;

  @HiveField(3)
  double dueAmount;

  @HiveField(4)
  DateTime? paymentDate;

  @HiveField(5)
  bool isPaid;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  @HiveField(8)
  double? minimumDueAmount;

  @HiveField(9)
  double paidAmount;

  @HiveField(10)
  DateTime dueDate;

  @HiveField(11)
  double statementAmount;

  @HiveField(12)
  bool syncPending;

  PaymentModel({
    String? id,
    required this.userId,
    required this.cardId,
    required this.dueAmount,
    DateTime? paymentDate,
    this.isPaid = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.minimumDueAmount,
    this.paidAmount = 0.0,
    required this.dueDate,
    double? statementAmount,
    this.syncPending = false,
  }) : id = id ?? const Uuid().v4(),
       createdAt = (createdAt ?? DateTime.now()).toUtc(),
       updatedAt = (updatedAt ?? DateTime.now()).toUtc(),
       statementAmount = statementAmount ?? dueAmount;

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
      statementAmount: this.statementAmount,
      userId: this.userId,
    );
  }

  bool get isOverdue => !isPaid && dueDate.isBefore(DateTime.now());
  bool get isPartiallyPaid => remainingAmount > 0;
  double get remainingAmount => statementAmount - paidAmount;
}
