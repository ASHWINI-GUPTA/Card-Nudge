import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:card_nudge/presentation/screens/card_details_screen.dart';
import 'package:card_nudge/presentation/providers/credit_card_provider.dart';
import 'package:card_nudge/presentation/providers/payment_provider.dart';
import 'package:card_nudge/presentation/providers/user_provider.dart';
import 'package:card_nudge/presentation/providers/bank_provider.dart';
import 'package:card_nudge/presentation/providers/setting_provider.dart';
import 'package:card_nudge/data/hive/models/user_model.dart';
import 'package:card_nudge/data/hive/models/credit_card_model.dart';
import 'package:card_nudge/data/hive/models/payment_model.dart';
import 'package:card_nudge/data/hive/models/settings_model.dart';
import 'package:card_nudge/data/enums/card_type.dart';
import 'package:card_nudge/presentation/widgets/payment_summary_display_card.dart';
import 'package:card_nudge/presentation/widgets/credit_card_color_dot_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../helpers/test_utilities.dart';
import '../../helpers/mock_providers.dart';

void main() {
  group('CardDetailsScreen Tests', () {
    late UserModel user;
    late CreditCardModel card;
    late MockUserNotifier mockUserNotifier;
    late MockCreditCardNotifier mockCreditCardNotifier;

    setUp(() {
      user = UserModel(id: 'user_1', email: 'test@example.com', firstName: 'John', lastName: 'Doe');
      card = CreditCardModel(
        id: 'card_1',
        userId: 'user_1',
        name: 'Test Card',
        bankId: 'bank_1',
        last4Digits: '1234',
        billingDate: DateTime.now().add(const Duration(days: 10)),
        dueDate: DateTime.now().add(const Duration(days: 30)),
        cardType: CardType.Visa,
        creditLimit: 50000.0,
      );
      
      mockUserNotifier = MockUserNotifier(user);
      
      mockCreditCardNotifier = MockCreditCardNotifier();
    });

    testWidgets('renders loading state', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        CardDetailsScreen(card: card),
        overrides: [
          paymentProvider.overrideWith(() => MockPaymentNotifier(isLoading: true)),
          creditCardProvider.overrideWith(() => mockCreditCardNotifier),
          userProvider.overrideWith((ref) => mockUserNotifier),
          bankProvider.overrideWith(() => MockBankNotifier()),
          settingsProvider.overrideWith((ref) => MockSettingsNotifier(SettingsModel(userId: 'user_1'))),
        ],
      ));

      await tester.pump();
      expect(find.byType(CreditCardColorDotIndicator), findsOneWidget);
    });

    testWidgets('renders empty upcoming and history', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        CardDetailsScreen(card: card),
        overrides: [
          paymentProvider.overrideWith(() => MockPaymentNotifier(initialPayments: [])),
          creditCardProvider.overrideWith(() => mockCreditCardNotifier),
          userProvider.overrideWith((ref) => mockUserNotifier),
          bankProvider.overrideWith(() => MockBankNotifier()),
          settingsProvider.overrideWith((ref) => MockSettingsNotifier(SettingsModel(userId: 'user_1'))),
        ],
      ));

      await tester.pump();
      await tester.pump(); // Settle
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No past payments available.'), findsOneWidget);
    });

    testWidgets('renders upcoming and history payments', (WidgetTester tester) async {
      final payments = [
        PaymentModel(
          id: 'pay_1',
          userId: 'user_1',
          cardId: 'card_1',
          statementAmount: 10000,
          dueAmount: 10000,
          minimumDueAmount: 1000,
          dueDate: DateTime.now(),
          isPaid: false,
        ),
        PaymentModel(
          id: 'pay_2',
          userId: 'user_1',
          cardId: 'card_1',
          statementAmount: 5000,
          dueAmount: 0,
          minimumDueAmount: 500,
          dueDate: DateTime.now().subtract(const Duration(days: 30)),
          isPaid: true,
          paidAmount: 5000,
          paymentDate: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ];

      await tester.pumpWidget(createTestApp(
        CardDetailsScreen(card: card),
        overrides: [
          paymentProvider.overrideWith(() => MockPaymentNotifier(initialPayments: payments)),
          creditCardProvider.overrideWith(() => mockCreditCardNotifier),
          userProvider.overrideWith((ref) => mockUserNotifier),
          bankProvider.overrideWith(() => MockBankNotifier()),
          settingsProvider.overrideWith((ref) => MockSettingsNotifier(SettingsModel(userId: 'user_1'))),
        ],
      ));

      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(PaymentSummaryDisplayCard), findsNWidgets(2));
    });

    testWidgets('archive card via menu', (WidgetTester tester) async {
      when(() => mockCreditCardNotifier.markArchive(any())).thenAnswer((_) async => {});
      
      await tester.pumpWidget(createTestApp(
        CardDetailsScreen(card: card),
        overrides: [
          paymentProvider.overrideWith(() => MockPaymentNotifier(initialPayments: [])),
          creditCardProvider.overrideWith(() => mockCreditCardNotifier),
          userProvider.overrideWith((ref) => mockUserNotifier),
          bankProvider.overrideWith(() => MockBankNotifier()),
          settingsProvider.overrideWith((ref) => MockSettingsNotifier(SettingsModel(userId: 'user_1'))),
        ],
      ));

      await tester.pump();
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Archive'));
      await tester.pumpAndSettle();

      verify(() => mockCreditCardNotifier.markArchive('card_1')).called(1);
    });
  });
}
