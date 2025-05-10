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

  runApp(const ProviderScope(child: CreditCardApp()));
}
