import 'package:credit_card_manager/credit_card_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/hive/models/credit_card_model.dart';
import 'data/hive/models/transaction_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(CreditCardModelAdapter());
  Hive.registerAdapter(TransactionModelAdapter());

  await Hive.openBox<CreditCardModel>('credit_cards');
  await Hive.openBox<TransactionModel>('transactions');

  final creditCardBox = Hive.box<CreditCardModel>('credit_cards');
  if (creditCardBox.isEmpty) {
    creditCardBox.addAll([
      CreditCardModel(
        cardName: 'Coral',
        bankName: 'ICICI Bank',
        last4Digits: '1234',
        billingDate: DateTime(2025, 5, 15),
        dueDate: DateTime(2025, 6, 5),
        limit: 5000.0,
        currentDueAmount: 1500.0,
        lastPaidDate: DateTime(2025, 4, 20),
      ),
      CreditCardModel(
        cardName: 'Moneyback',
        bankName: 'HDFC Bank',
        last4Digits: '5678',
        billingDate: DateTime(2025, 5, 10),
        dueDate: DateTime(2025, 6, 1),
        limit: 3000.0,
        currentDueAmount: 800.0,
        lastPaidDate: DateTime(2025, 4, 15),
      ),
      CreditCardModel(
        cardName: 'Amazon Pay',
        bankName: 'ICICI Bank',
        last4Digits: '9012',
        billingDate: DateTime(2025, 5, 20),
        dueDate: DateTime(2025, 6, 10),
        limit: 7000.0,
        currentDueAmount: 0,
      ),
      CreditCardModel(
        cardName: 'Atlas',
        bankName: 'Axis Bank',
        last4Digits: '3456',
        billingDate: DateTime(2025, 5, 25),
        dueDate: DateTime(2025, 6, 15),
        limit: 6000.0,
        currentDueAmount: 0,
      ),
    ]);
  }

  runApp(const ProviderScope(child: CreditCardApp()));
}
