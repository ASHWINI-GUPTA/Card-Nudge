import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'bank_model.g.dart';

@HiveType(typeId: 1)
class BankModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String name;

  @HiveField(3)
  String? code;

  @HiveField(4)
  String? logoPath;

  @HiveField(5)
  String? supportNumber;

  @HiveField(6)
  String? website;

  @HiveField(7)
  bool isFavorite;

  @HiveField(8)
  String? colorHex;

  @HiveField(9)
  int? priority;

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  DateTime updatedAt;

  @HiveField(12)
  bool syncPending;

  @HiveField(13)
  bool isDefault;

  BankModel({
    String? id,
    required this.userId,
    required this.name,
    this.code,
    this.logoPath,
    this.supportNumber,
    this.website,
    this.isFavorite = false,
    this.colorHex,
    this.priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncPending = true,
    this.isDefault = false,
  }) : id = id ?? const Uuid().v4(),
       createdAt = (createdAt ?? DateTime.now()).toUtc(),
       updatedAt = (updatedAt ?? DateTime.now()).toUtc();

  BankModel copyWith({
    String? id,
    String? name,
    String? code,
    String? logoPath,
    String? supportNumber,
    String? website,
    bool? isFavorite,
    String? colorHex,
    int? priority,
    bool? syncPending,
  }) {
    return BankModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      logoPath: logoPath ?? this.logoPath,
      supportNumber: supportNumber ?? this.supportNumber,
      website: website ?? this.website,
      isFavorite: isFavorite ?? this.isFavorite,
      colorHex: colorHex ?? this.colorHex,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      updatedAt: DateTime.now().toUtc(),
      userId: this.userId,
      syncPending: syncPending ?? this.syncPending,
    );
  }
}
