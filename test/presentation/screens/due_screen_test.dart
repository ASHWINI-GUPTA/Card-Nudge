import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:card_nudge/presentation/screens/due_screen.dart';
import 'package:card_nudge/presentation/providers/credit_card_provider.dart';
import 'package:card_nudge/presentation/providers/payment_provider.dart';
import 'package:card_nudge/presentation/providers/bank_provider.dart';
import 'package:card_nudge/presentation/providers/user_provider.dart';
import 'package:card_nudge/presentation/providers/setting_provider.dart';
import 'package:card_nudge/data/hive/models/credit_card_model.dart';
import 'package:card_nudge/data/hive/models/payment_model.dart';
import 'package:card_nudge/data/hive/models/bank_model.dart';
import 'package:card_nudge/data/hive/models/user_model.dart';
import 'package:card_nudge/data/hive/models/settings_model.dart';
import 'package:card_nudge/data/enums/card_type.dart';
import 'package:card_nudge/presentation/widgets/empty_credit_card_list_widget.dart';
import 'package:card_nudge/presentation/widgets/credit_card_color_dot_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../helpers/test_utilities.dart';
import '../../helpers/mock_providers.dart';

void main() {
  group('DueScreen Tests', () {
    late MockUserNotifier mockUserNotifier;
    late MockSettingsNotifier mockSettingsNotifier;

    setUp(() {
      mockUserNotifier = MockUserNotifier(
        UserModel(id: 'user_1', email: 'test@example.com', firstName: 'John', lastName: 'Doe')
      );
      mockSettingsNotifier = MockSettingsNotifier(SettingsModel(userId: 'user_1'));
    });

    testWidgets('renders loading state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        const DueScreen(),
        overrides: [
          userProvider.overrideWith((ref) => mockUserNotifier),
          settingsProvider.overrideWith((ref) => mockSettingsNotifier),
          creditCardProvider.overrideWith(() => MockCreditCardNotifier(isLoading: true)),
        ],
      ));

      await tester.pump();
      expect(find.byType(CreditCardColorDotIndicator), findsOneWidget);
    });

    testWidgets('renders empty state correctly if no active cards', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        const DueScreen(),
        overrides: [
          userProvider.overrideWith((ref) => mockUserNotifier),
          settingsProvider.overrideWith((ref) => mockSettingsNotifier),
          creditCardProvider.overrideWith(() => MockCreditCardNotifier(initialCards: [])),
        ],
      ));

      await tester.pump();
      expect(find.byType(EmptyCreditCardListWidget), findsOneWidget);
    });

    testWidgets('renders payments categorized by due date', (WidgetTester tester) async {
      final List<CreditCardModel> cards = [
        CreditCardModel(
          id: 'card_1',
          userId: 'user_1',
          name: 'Active Card',
          bankId: 'bank_1',
          last4Digits: '1234',
          billingDate: DateTime.now(),
          dueDate: DateTime.now(),
          cardType: CardType.Visa,
          creditLimit: 50000.0,
        ),
      ];

      final List<BankModel> banks = [
        BankModel(id: 'bank_1', userId: 'user_1', name: 'Test Bank'),
      ];

      final List<PaymentModel> payments = [
        PaymentModel(
          id: 'pay_1',
          userId: 'user_1',
          cardId: 'card_1',
          statementAmount: 25000.0,
          dueAmount: 25000.0,
          minimumDueAmount: 5000.0,
          dueDate: DateTime.now(), // Due today
        )
      ];

      await tester.pumpWidget(createTestApp(
        const DueScreen(),
        overrides: [
          userProvider.overrideWith((ref) => mockUserNotifier),
          settingsProvider.overrideWith((ref) => mockSettingsNotifier),
          creditCardProvider.overrideWith(() => MockCreditCardNotifier(initialCards: cards)),
          bankProvider.overrideWith(() => MockBankNotifier(initialBanks: banks)),
          paymentProvider.overrideWith(() => MockPaymentNotifier(initialPayments: payments)),
        ],
      ));

      await tester.pump(); // Start async build
      await tester.pump(); // Let providers return data
      await tester.pump(const Duration(milliseconds: 100));

      try {
        expect(find.text('Today'), findsOneWidget);
        expect(find.byType(DueCard), findsOneWidget);
        expect(find.text('Active Card'), findsOneWidget);
      } catch (e) {
        debugDumpApp();
        rethrow;
      }
    });
  });
}
