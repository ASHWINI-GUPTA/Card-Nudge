import 'package:card_nudge/helper/date_extension.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../enums/card_type.dart';

part 'credit_card_model.g.dart';

@HiveType(typeId: 2)
class CreditCardModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String name;

  @HiveField(3)
  String? bankId;

  @HiveField(4)
  String last4Digits;

  @HiveField(5)
  DateTime billingDate;

  @HiveField(6)
  DateTime dueDate;

  @HiveField(7)
  CardType cardType;

  @HiveField(8)
  double creditLimit;

  @HiveField(9)
  double currentUtilization;

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  DateTime updatedAt;

  @HiveField(12, defaultValue: false)
  bool isArchived;

  @HiveField(13, defaultValue: false)
  bool isFavorite;

  @HiveField(14)
  bool syncPending;

  CreditCardModel({
    String? id,
    required this.userId,
    required this.name,
    required String? bankId,
    required this.last4Digits,
    required this.billingDate,
    required this.dueDate,
    required this.cardType,
    required this.creditLimit,
    this.currentUtilization = 0.0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isArchived = false,
    this.isFavorite = false,
    this.syncPending = true,
  }) : id = id ?? const Uuid().v4(),
       bankId = bankId,
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
    bool? isArchived,
    bool? isFavorite,
    bool? syncPending,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CreditCardModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      bankId: bankId ?? this.bankId,
      last4Digits: last4Digits ?? this.last4Digits,
      billingDate: billingDate ?? this.billingDate,
      dueDate: dueDate ?? this.dueDate,
      cardType: cardType ?? this.cardType,
      creditLimit: creditLimit ?? this.creditLimit,
      currentUtilization: currentUtilization ?? this.currentUtilization,
      isArchived: isArchived ?? this.isArchived,
      isFavorite: isFavorite ?? this.isFavorite,
      syncPending: syncPending ?? this.syncPending,
      createdAt: createdAt?.toUtc() ?? this.createdAt,
      updatedAt: updatedAt?.toUtc() ?? DateTime.now().toUtc(),
    );
  }

  CreditCardModel updateUtilization(double newUtilization) {
    return copyWith(currentUtilization: newUtilization);
  }

  bool get isNearDueDate => dueDate.differenceInDaysCeil(DateTime.now()) <= 7;
  bool get isOverUtilized => currentUtilization > creditLimit * 0.3;
  double get utilizationPercentage => (currentUtilization / creditLimit) * 100;
}
