import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'bank_model.g.dart';

@HiveType(typeId: 0)
class BankModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? code;

  @HiveField(3)
  final String? logoPath;

  @HiveField(4)
  final String? supportNumber;

  @HiveField(5)
  final String? website;

  @HiveField(6)
  final bool isFavorite;

  @HiveField(7)
  final String? colorHex;

  @HiveField(8)
  final int? priority;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime updatedAt;

  BankModel({
    String? id,
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
      createdAt: createdAt, // Keep original creation time
      updatedAt: DateTime.now().toUtc(), // Always update this timestamp
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BankModel &&
        other.id == id &&
        other.name == name &&
        other.code == code &&
        other.logoPath == logoPath &&
        other.supportNumber == supportNumber &&
        other.website == website &&
        other.isFavorite == isFavorite &&
        other.colorHex == colorHex &&
        other.priority == priority;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        code.hashCode ^
        logoPath.hashCode ^
        supportNumber.hashCode ^
        website.hashCode ^
        isFavorite.hashCode ^
        colorHex.hashCode ^
        priority.hashCode;
  }
}
