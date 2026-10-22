import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:card_nudge/presentation/widgets/payment_history_bottom_sheet.dart';
import 'package:card_nudge/data/hive/models/payment_model.dart';
import 'package:card_nudge/data/hive/models/credit_card_model.dart';
import 'package:card_nudge/data/hive/models/settings_model.dart';
import 'package:card_nudge/data/enums/card_type.dart';
import 'package:card_nudge/presentation/providers/setting_provider.dart';
import 'package:card_nudge/presentation/providers/payment_provider.dart';
import 'package:card_nudge/presentation/providers/credit_card_provider.dart';
import '../../helpers/test_utilities.dart';
import '../../helpers/mock_providers.dart';

void main() {
  group('PaymentHistoryBottomSheet Widget Tests', () {
    late MockSettingsNotifier mockSettingsNotifier;
    late MockPaymentNotifier mockPaymentNotifier;
    late MockCreditCardNotifier mockCreditCardNotifier;

    setUp(() {
      mockSettingsNotifier = MockSettingsNotifier(
        SettingsModel(userId: 'user_1'),
      );
      mockPaymentNotifier = MockPaymentNotifier();
      mockCreditCardNotifier = MockCreditCardNotifier();
    });

    testWidgets(
      'does not show date picker when payment is due today or in the future',
      (WidgetTester tester) async {
        final payment = PaymentModel(
          id: 'p1',
          userId: 'u1',
          cardId: 'c1',
          dueAmount: 5000.0,
          statementAmount: 5000.0,
          minimumDueAmount: 500.0,
          dueDate: DateTime.now().add(const Duration(days: 3)),
        );

        await tester.pumpWidget(
          createTestApp(
            Scaffold(body: PaymentHistoryBottomSheet(payment: payment)),
            overrides: [
              settingsProvider.overrideWith((ref) => mockSettingsNotifier),
              paymentProvider.overrideWith(() => mockPaymentNotifier),
              creditCardProvider.overrideWith(() => mockCreditCardNotifier),
            ],
          ),
        );
        await tester.pumpAndSettle();

        // Should show Log Payment and due amounts
        expect(find.text('Log Payment'), findsWidgets);
        // Date options should NOT be displayed
        expect(find.text('Payment is past due date'), findsNothing);
        expect(find.text('When was this payment made?'), findsNothing);
        expect(find.text('Custom Date'), findsNothing);
      },
    );

    testWidgets(
      'shows date options when payment is past due date and defaults to Due Date for auto-debit',
      (WidgetTester tester) async {
        final pastDueDate = DateTime.now().subtract(const Duration(days: 2));
        final payment = PaymentModel(
          id: 'p1',
          userId: 'u1',
          cardId: 'c1',
          dueAmount: 5000.0,
          statementAmount: 5000.0,
          minimumDueAmount: 500.0,
          dueDate: pastDueDate,
        );

        final card = CreditCardModel(
          id: 'c1',
          userId: 'u1',
          name: 'Test Card',
          bankId: 'b1',
          last4Digits: '1234',
          billingDate: pastDueDate.subtract(const Duration(days: 20)),
          dueDate: pastDueDate,
          cardType: CardType.Visa,
          creditLimit: 50000.0,
          isAutoDebitEnabled: true,
        );

        await tester.pumpWidget(
          createTestApp(
            Scaffold(
              body: PaymentHistoryBottomSheet(
                payment: payment,
                card: card,
                isAutoDebit: true,
              ),
            ),
            overrides: [
              settingsProvider.overrideWith((ref) => mockSettingsNotifier),
              paymentProvider.overrideWith(() => mockPaymentNotifier),
              creditCardProvider.overrideWith(() => mockCreditCardNotifier),
            ],
          ),
        );
        await tester.pumpAndSettle();

        // Should show the past due date warning and prompt
        expect(find.text('Payment is past due date'), findsOneWidget);
        expect(find.text('When was this payment made?'), findsOneWidget);
        expect(find.text('Custom Date'), findsOneWidget);

        // Verify custom date input decorator is hidden initially since Due Date is selected
        expect(
          find.byKey(const ValueKey('customDatePickerContainer')),
          findsNothing,
        );

        // Tap "Custom Date" radio
        await tester.tap(find.text('Custom Date'));
        await tester.pumpAndSettle();

        // Custom date input decorator should now be visible
        expect(
          find.byKey(const ValueKey('customDatePickerContainer')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'defaults to Today when payment is past due date and card is not auto-debit',
      (WidgetTester tester) async {
        final pastDueDate = DateTime.now().subtract(const Duration(days: 2));
        final payment = PaymentModel(
          id: 'p1',
          userId: 'u1',
          cardId: 'c1',
          dueAmount: 5000.0,
          statementAmount: 5000.0,
          dueDate: pastDueDate,
        );

        await tester.pumpWidget(
          createTestApp(
            Scaffold(
              body: PaymentHistoryBottomSheet(
                payment: payment,
                isAutoDebit: false,
              ),
            ),
            overrides: [
              settingsProvider.overrideWith((ref) => mockSettingsNotifier),
              paymentProvider.overrideWith(() => mockPaymentNotifier),
              creditCardProvider.overrideWith(() => mockCreditCardNotifier),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Payment is past due date'), findsOneWidget);
        expect(find.text('When was this payment made?'), findsOneWidget);
        expect(find.text('Custom Date'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('customDatePickerContainer')),
          findsNothing,
        );
      },
    );
  });
}
