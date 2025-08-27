import 'package:hive/hive.dart';

part 'credit_card_summary_model.g.dart';

@HiveType(typeId: 7)
class CreditCardSummaryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String cardId;

  @HiveField(2)
  String markdownSummary;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  @HiveField(5)
  int status;

  @HiveField(6)
  bool userLiked;

  CreditCardSummaryModel({
    required this.id,
    required this.cardId,
    required this.markdownSummary,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    this.userLiked = false,
  });
}
