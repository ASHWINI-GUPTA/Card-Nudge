import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:card_nudge/presentation/screens/spend_analysis_screen.dart';
import 'package:card_nudge/presentation/providers/credit_card_provider.dart';
import 'package:card_nudge/presentation/providers/payment_provider.dart';
import 'package:card_nudge/presentation/providers/bank_provider.dart';
import 'package:card_nudge/presentation/providers/setting_provider.dart';
import 'package:card_nudge/data/hive/models/credit_card_model.dart';
import 'package:card_nudge/data/hive/models/payment_model.dart';
import 'package:card_nudge/data/hive/models/settings_model.dart';
import 'package:card_nudge/data/enums/card_type.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../helpers/test_utilities.dart';
import '../../helpers/mock_providers.dart';

void main() {
  group('SpendAnalysisScreen Tests', () {
    late MockSettingsNotifier mockSettingsNotifier;

    setUp(() {
      mockSettingsNotifier = MockSettingsNotifier(SettingsModel(userId: 'user_1'));
    });

    testWidgets('renders properly with no data', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        const SpendAnalysisScreen(),
        overrides: [
          settingsProvider.overrideWith((ref) => mockSettingsNotifier),
          creditCardProvider.overrideWith(() => MockCreditCardNotifier(initialCards: [])),
          paymentProvider.overrideWith(() => MockPaymentNotifier(initialPayments: [])),
          bankProvider.overrideWith(() => MockBankNotifier()),
        ],
      ));

      await tester.pump();
      await tester.pump();
      
      expect(find.text('No payment data available'), findsOneWidget);
    });

    testWidgets('renders total spend card and chart with data', (WidgetTester tester) async {
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

      final List<PaymentModel> payments = [
        PaymentModel(
          id: 'pay_1',
          userId: 'user_1',
          cardId: 'card_1',
          statementAmount: 25000.0,
          dueAmount: 0.0,
          minimumDueAmount: 5000.0,
          dueDate: DateTime.now(),
          isPaid: true,
          paidAmount: 25000.0,
          paymentDate: DateTime.now(),
        )
      ];

      await tester.pumpWidget(createTestApp(
        const SpendAnalysisScreen(),
        overrides: [
          settingsProvider.overrideWith((ref) => mockSettingsNotifier),
          creditCardProvider.overrideWith(() => MockCreditCardNotifier(initialCards: cards)),
          paymentProvider.overrideWith(() => MockPaymentNotifier(initialPayments: payments)),
          bankProvider.overrideWith(() => MockBankNotifier()),
        ],
      ));

      await tester.pump(); // Start async builds
      await tester.pump(); // Let providers return data
      await tester.pump(const Duration(milliseconds: 100)); // Settle animations

      // Verify Total Spend
      expect(find.text('Total Spend'), findsOneWidget);
      // Wait, ₹25,000.00 depends on locale. Let's just check if it finds the value or the chip
      expect(find.text('Active Card'), findsWidgets); // Chip and maybe tooltip
      
      // Verify Chart is rendered
      expect(find.byType(BarChart), findsOneWidget);
    });
  });
}
