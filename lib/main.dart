import 'package:card_nudge/data/hive/storage/credit_card_summary_storage.dart';
import 'package:card_nudge/data/hive/storage/delete_queue_entry_storage.dart';
import 'package:card_nudge/data/hive/storage/payment_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'credit_card_app.dart';
import 'data/hive/storage/bank_storage.dart';
import 'data/hive/storage/credit_card_storage.dart';
import 'data/hive/storage/setting_storage.dart';
import 'data/hive/storage/user_storage.dart';
import 'firebase_options.dart';
import 'helper/notification_handler.dart';

import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  try {
    await dotenv.load(fileName: '.env');
    print('1️⃣ ENV LOADED SUCCESSFULLY');
  } catch (e, stack) {
    print('❌ ENV LOAD FAILED: $e');
    print(stack);
    rethrow;
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('2️⃣ FIREBASE INITIALIZED');
  } catch (e, stack) {
    print('❌ FIREBASE FAILED: $e');
    print(stack);
    rethrow;
  }

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null ||
      supabaseUrl.isEmpty ||
      supabaseAnonKey == null ||
      supabaseAnonKey.isEmpty) {
    throw Exception('Supabase URL and Anon Key must not be null or empty.');
  }

  try {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    print('3️⃣ SUPABASE INITIALIZED');
  } catch (e, stack) {
    print('❌ SUPABASE FAILED: $e');
    print(stack);
    rethrow;
  }

  try {
    await NotificationTapHandler.init();
    print('4️⃣ NOTIFICATION HANDLER INITIALIZED');
  } catch (e, stack) {
    print('❌ NOTIFICATION HANDLER FAILED: $e');
    print(stack);
    rethrow;
  }

  try {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final payload =
          message.data['payload'] ??
          message.data['route'] ??
          message.data['path'] ??
          '';

      if (payload is String && payload.isNotEmpty) {
        NotificationTapHandler.handleNotificationTap(payload);
      }
    });

    print('5️⃣ FCM LISTENER INITIALIZED');
  } catch (e, stack) {
    print('❌ FCM LISTENER FAILED: $e');
    print(stack);
    rethrow;
  }

  try {
    await Hive.initFlutter();

    await BankStorage.initHive();
    await CreditCardStorage.initHive();
    await CreditCardSummaryStorage.initHive();
    await PaymentStorage.initHive();
    await UserStorage.initHive();
    await SettingStorage.initHive();
    await DeleteQueueEntryStorage.initHive();

    print('6️⃣ HIVE INITIALIZED');
  } catch (e, stack) {
    print('❌ HIVE FAILED: $e');
    print(stack);
    rethrow;
  }

  print('7️⃣ STARTING APP');

  runApp(const ProviderScope(child: CreditCardApp()));
}
