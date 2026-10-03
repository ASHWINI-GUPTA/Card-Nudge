import 'dart:async';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_nudge/providers/credit_card_summary_provider.dart';
import 'package:card_nudge/data/hive/models/credit_card_summary_model.dart';
import 'package:card_nudge/data/hive/models/credit_card_model.dart';
import 'package:card_nudge/services/supabase_service.dart';
import 'package:card_nudge/presentation/providers/user_provider.dart';
import 'package:card_nudge/presentation/providers/credit_card_provider.dart';
import 'package:card_nudge/presentation/providers/payment_provider.dart';
import 'package:card_nudge/presentation/providers/setting_provider.dart';
import 'package:card_nudge/data/hive/models/user_model.dart';
import 'package:card_nudge/data/hive/models/payment_model.dart';
import 'package:card_nudge/data/hive/models/settings_model.dart';
import 'package:card_nudge/data/hive/models/bank_model.dart';
import 'package:card_nudge/presentation/providers/bank_provider.dart';

class MockCreditCardSummaryNotifier extends StateNotifier<List<CreditCardSummaryModel>>
    with Mock
    implements CreditCardSummaryNotifier {
  MockCreditCardSummaryNotifier(super.state);
}

class MockSupabaseService extends Mock implements SupabaseService {}

class MockUserNotifier extends StateNotifier<UserModel?> with Mock implements UserNotifier {
  MockUserNotifier(super.state);
}

class MockCreditCardNotifier extends AsyncNotifier<List<CreditCardModel>> with Mock implements CreditCardNotifier {
  final List<CreditCardModel> initialCards;
  final bool isLoading;
  
  MockCreditCardNotifier({this.initialCards = const [], this.isLoading = false});

  @override
  Future<List<CreditCardModel>> build() async {
    if (isLoading) {
      return Completer<List<CreditCardModel>>().future; // Simulate loading infinitely
    }
    return initialCards;
  }
}

class MockPaymentNotifier extends AsyncNotifier<List<PaymentModel>> with Mock implements PaymentNotifier {
  final List<PaymentModel> initialPayments;
  final bool isLoading;

  MockPaymentNotifier({this.initialPayments = const [], this.isLoading = false});

  @override
  Future<List<PaymentModel>> build() async {
    if (isLoading) {
      return Completer<List<PaymentModel>>().future; // Simulate loading infinitely
    }
    return initialPayments;
  }
}

class MockBankNotifier extends AsyncNotifier<List<BankModel>> with Mock implements BankNotifier {
  final List<BankModel> initialBanks;
  final bool isLoading;

  MockBankNotifier({this.initialBanks = const [], this.isLoading = false});

  @override
  Future<List<BankModel>> build() async {
    if (isLoading) {
      return Completer<List<BankModel>>().future; // Simulate loading infinitely
    }
    return initialBanks;
  }
}

class MockSettingsNotifier extends StateNotifier<SettingsModel> with Mock implements SettingsNotifier {
  MockSettingsNotifier(super.state);
}

// Dummy objects for fallback values in mocktail
class FakeCreditCardModel extends Fake implements CreditCardModel {}
class FakeCreditCardSummaryModel extends Fake implements CreditCardSummaryModel {}

void registerFallbacks() {
  registerFallbackValue(FakeCreditCardModel());
  registerFallbackValue(FakeCreditCardSummaryModel());
}
