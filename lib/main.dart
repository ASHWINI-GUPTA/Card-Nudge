import 'package:card_nudge/data/hive/storage/payment_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'credit_card_app.dart';
import 'data/hive/models/credit_card_model.dart';
import 'data/hive/storage/bank_storage.dart';
import 'data/hive/storage/credit_card_storage.dart';
import 'services/notification_service.dart';
import 'presentation/providers/card_card_mock_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  // Hive
  await Hive.initFlutter();
  await BankStorage.initHive();
  await CreditCardStorage.initHive();
  await PaymentStorage.initHive();

  // Add mock data only in debug mode. Remove in production automatically.
  assert(() {
    final creditCardBox = Hive.box<CreditCardModel>('credit_cards');
    if (creditCardBox.isEmpty) {
      creditCardBox.addAll(CardMockDataProvider.getMockCreditCards());
    }
    return true;
  }());

  runApp(const ProviderScope(child: CreditCardApp()));
}
