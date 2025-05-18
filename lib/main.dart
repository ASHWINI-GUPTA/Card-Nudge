import 'package:card_nudge/data/hive/models/bank_model.dart';
import 'package:card_nudge/data/hive/storage/bank_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'credit_card_app.dart';
import 'data/hive/adapters/card_type_adapter.dart';
import 'data/hive/models/credit_card_model.dart';
import 'data/hive/models/payment_model.dart';
import 'notification_service.dart';
import 'presentation/providers/card_card_mock_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await Hive.initFlutter();
  Hive.registerAdapter(BankModelAdapter());
  Hive.registerAdapter(CreditCardModelAdapter());
  Hive.registerAdapter(PaymentModelAdapter());
  Hive.registerAdapter(CardTypeAdapter());

  await Hive.openBox<BankModel>('bank_box');
  await Hive.openBox<PaymentModel>('payment_box');
  await Hive.openBox<CreditCardModel>('card_box');

  await BankStorage.initBankInfo();

  // Add mock data only in debug mode. Remove in production automatically.
  assert(() {
    final creditCardBox = Hive.box<CreditCardModel>('card_box');
    if (creditCardBox.isEmpty) {
      creditCardBox.addAll(CardMockDataProvider.getMockCreditCards());
    }
    return true;
  }());

  runApp(const ProviderScope(child: CreditCardApp()));
}
