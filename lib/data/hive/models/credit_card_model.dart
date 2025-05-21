import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../enums/card_type.dart';

part 'credit_card_model.g.dart';

@HiveType(typeId: 1)
class CreditCardModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String bankId;

  @HiveField(3)
  final String last4Digits;

  @HiveField(4)
  final DateTime billingDate;

  @HiveField(5)
  final DateTime dueDate;

  @HiveField(6)
  final CardType cardType;

  @HiveField(7)
  final double creditLimit;

  @HiveField(8)
  final double currentUtilization;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime updatedAt;

  CreditCardModel({
    String? id,
    required this.name,
    required this.bankId,
    required this.last4Digits,
    required this.billingDate,
    required this.dueDate,
    required this.cardType,
    required this.creditLimit,
    this.currentUtilization = 0.0,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = (createdAt ?? DateTime.now()).toUtc(),
       updatedAt = (updatedAt ?? DateTime.now()).toUtc();

  CreditCardModel copyWith({
    String? name,
    String? bankId,
    String? last4Digits,
    DateTime? billingDate,
    DateTime? dueDate,
    CardType? cardType,
    double? creditLimit,
    double? currentUtilization,
  }) {
    return CreditCardModel(
      id: id,
      name: name ?? this.name,
      bankId: bankId ?? this.bankId,
      last4Digits: last4Digits ?? this.last4Digits,
      billingDate: billingDate ?? this.billingDate,
      dueDate: dueDate ?? this.dueDate,
      cardType: cardType ?? this.cardType,
      creditLimit: creditLimit ?? this.creditLimit,
      currentUtilization: currentUtilization ?? this.currentUtilization,
      createdAt: createdAt,
    );
  }

  // Helper method to update utilization and automatically refresh updatedAt
  CreditCardModel updateUtilization(double newUtilization) {
    return copyWith(currentUtilization: newUtilization);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreditCardModel &&
        other.id == id &&
        other.name == name &&
        other.bankId == bankId &&
        other.last4Digits == last4Digits &&
        other.billingDate == billingDate &&
        other.dueDate == dueDate &&
        other.cardType == cardType &&
        other.creditLimit == creditLimit &&
        other.currentUtilization == currentUtilization;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        bankId.hashCode ^
        last4Digits.hashCode ^
        billingDate.hashCode ^
        dueDate.hashCode ^
        cardType.hashCode ^
        creditLimit.hashCode ^
        currentUtilization.hashCode;
  }

  // Additional helpful methods
  bool get isNearDueDate => dueDate.difference(DateTime.now()).inDays <= 7;
  bool get isOverUtilized => currentUtilization > creditLimit * 0.9;
  double get utilizationPercentage => (currentUtilization / creditLimit) * 100;
  bool get isFavorite => false;
}
