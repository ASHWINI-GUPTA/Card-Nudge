import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 5)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id; // Supabase user ID

  @HiveField(1)
  String firstName;

  @HiveField(2)
  String lastName;

  @HiveField(3)
  String email;

  @HiveField(4)
  String? avatarLink;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatarLink,
  });
}
