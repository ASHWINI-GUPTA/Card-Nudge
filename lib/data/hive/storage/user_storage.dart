import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';

class UserStorage {
  static Box<UserModel>? _box;

  static Box<UserModel> getBox() {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Hive box not initialized. Call initHive() first.');
    }
    return _box!;
  }

  static Future<void> initHive() async {
    Hive.registerAdapter(UserModelAdapter());
    _box = await Hive.openBox<UserModel>('users');
  }
}
