import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'bank_model.g.dart';

/// Represents a bank entity where the user holds a credit card.
/// Stored locally via Hive and synchronized with the remote Supabase database.
@HiveType(typeId: 1)
class BankModel {
  @HiveField(0, defaultValue: '')
  String id;

  @HiveField(1, defaultValue: '')
  String userId;

  @HiveField(2, defaultValue: '')
  String name;

  @HiveField(3, defaultValue: null)
  String? code;

  @HiveField(4, defaultValue: null)
  String? logoPath;

  @HiveField(5, defaultValue: null)
  String? supportNumber;

  @HiveField(6, defaultValue: null)
  String? website;

  @HiveField(7, defaultValue: false)
  bool isFavorite;

  @HiveField(8, defaultValue: null)
  String? colorHex;

  @HiveField(9, defaultValue: null)
  int? priority;

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  DateTime updatedAt;

  @HiveField(12, defaultValue: true)
  bool syncPending;

  @HiveField(13, defaultValue: false)
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
    DateTime? createdAt,
    DateTime? updatedAt,
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
      createdAt: createdAt?.toUtc() ?? this.createdAt,
      updatedAt: updatedAt?.toUtc() ?? DateTime.now().toUtc(),
      userId: this.userId,
      syncPending: syncPending ?? this.syncPending,
    );
  }
}
