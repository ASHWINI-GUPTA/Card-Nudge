import 'package:card_nudge/data/hive/storage/payment_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'credit_card_app.dart';
import 'data/hive/storage/bank_storage.dart';
import 'data/hive/storage/credit_card_storage.dart';
import 'data/hive/storage/setting_storage.dart';
import 'data/hive/storage/user_storage.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
  if (supabaseUrl == null ||
      supabaseUrl.isEmpty ||
      supabaseAnonKey == null ||
      supabaseAnonKey.isEmpty) {
    throw Exception('Supabase URL and Anon Key must not be null or empty.');
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  // Notification
  await NotificationService.init();

  // Hive
  await Hive.initFlutter();

  await BankStorage.initHive();
  await CreditCardStorage.initHive();
  await PaymentStorage.initHive();
  await UserStorage.initHive();
  await SettingStorage.initHive();

  runApp(const ProviderScope(child: CreditCardApp()));
}
