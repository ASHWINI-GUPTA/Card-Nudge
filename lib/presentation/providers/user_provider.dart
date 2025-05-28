import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/hive/models/user_model.dart';
import '../../data/hive/storage/user_storage.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null);

  // Save user details to Hive
  Future<void> saveUserDetails({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    String? avatarLink,
  }) async {
    final userModel = UserModel(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      avatarLink: avatarLink,
    );
    await UserStorage.getBox().put(id, userModel);
    state = userModel;
  }

  // Update user details in Hive
  Future<void> updateUserDetails({
    required String userId,
    String? firstName,
    String? lastName,
    String? email,
    String? avatarLink,
  }) async {
    final user = UserStorage.getBox().get(userId);
    if (user != null) {
      if (firstName != null) user.firstName = firstName;
      if (lastName != null) user.lastName = lastName;
      if (email != null) user.email = email;
      if (avatarLink != null) user.avatarLink = avatarLink;
      await user.save();
      state = user;
    } else {
      throw Exception('User not found.');
    }
  }

  // Clear user data
  Future<void> clearUserData() async {
    await UserStorage.getBox().clear();
    state = null;
  }
}
