import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'credit_card_app.dart';
import 'data/hive/models/credit_card_model.dart';
import 'data/hive/models/reminder_model.dart';
import 'notification_service.dart';
import 'presentation/providers/card_mock_data_provider.dart';
import 'presentation/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await Hive.initFlutter();
  Hive.registerAdapter(CreditCardModelAdapter());
  Hive.registerAdapter(ReminderModelAdapter());

  await Hive.openBox<ReminderModel>('reminders_box');
  await Hive.openBox<CreditCardModel>('credit_cards');

  final creditCardBox = Hive.box<CreditCardModel>('credit_cards');

  if (creditCardBox.isEmpty) {
    creditCardBox.addAll(CardMockDataProvider.getMockCreditCards());
  }

  runApp(const ProviderScope(child: CreditCardApp()));
}
