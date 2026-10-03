import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:card_nudge/presentation/screens/dashboard_screen.dart';
import 'package:card_nudge/presentation/providers/user_provider.dart';
import 'package:card_nudge/presentation/providers/credit_card_provider.dart';
import 'package:card_nudge/presentation/providers/payment_provider.dart';
import 'package:card_nudge/presentation/providers/setting_provider.dart';
import 'package:card_nudge/data/hive/models/user_model.dart';
import 'package:card_nudge/data/hive/models/credit_card_model.dart';
import 'package:card_nudge/data/hive/models/payment_model.dart';
import 'package:card_nudge/data/hive/models/settings_model.dart';
import 'package:card_nudge/data/enums/card_type.dart';
import 'package:card_nudge/presentation/widgets/credit_card_color_dot_indicator.dart';
import 'package:card_nudge/presentation/widgets/dashboard_metrics_display_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../helpers/test_utilities.dart';
import '../../helpers/mock_providers.dart';

void main() {
  group('DashboardScreen Tests', () {
    late MockUserNotifier mockUserNotifier;
    late MockSettingsNotifier mockSettingsNotifier;
    late UserModel mockUser;

    setUp(() {
      mockUser = UserModel(id: 'user_1', email: 'test@example.com', firstName: 'John', lastName: 'Doe');
      mockUserNotifier = MockUserNotifier(mockUser);
      mockSettingsNotifier = MockSettingsNotifier(SettingsModel(userId: 'user_1'));
    });

    testWidgets('renders loading state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        const DashboardScreen(),
        overrides: [
          userProvider.overrideWith((ref) => mockUserNotifier),
          settingsProvider.overrideWith((ref) => mockSettingsNotifier),
          creditCardProvider.overrideWith(() => MockCreditCardNotifier(isLoading: true)),
          paymentProvider.overrideWith(() => MockPaymentNotifier()),
        ],
      ));

      await tester.pump();

      expect(find.byType(CreditCardColorDotIndicator), findsOneWidget);
    });

    testWidgets('renders empty state without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        const DashboardScreen(),
        overrides: [
          userProvider.overrideWith((ref) => mockUserNotifier),
          settingsProvider.overrideWith((ref) => mockSettingsNotifier),
          creditCardProvider.overrideWith(() => MockCreditCardNotifier(initialCards: [])),
          paymentProvider.overrideWith(() => MockPaymentNotifier(initialPayments: [])),
        ],
      ));

      await tester.pump();
      
      // Should find the username in the greeting
      expect(find.textContaining('John', findRichText: true), findsOneWidget);
      expect(find.text('Quick Insights'), findsOneWidget);
      expect(find.text('Total Credit Limit'), findsOneWidget);
      
      // Total Credit Limit should be zero
      expect(find.text('₹0.00'), findsOneWidget);
    });

    testWidgets('renders metrics accurately based on cards and payments', (WidgetTester tester) async {
      final List<CreditCardModel> cards = [
        CreditCardModel(
          id: 'card_1',
          userId: 'user_1',
          name: 'Test Card',
          bankId: 'bank_1',
          last4Digits: '1234',
          billingDate: DateTime.now(),
          dueDate: DateTime.now(),
          cardType: CardType.Visa,
          creditLimit: 100000.0,
        ),
      ];

      final List<PaymentModel> payments = [
        PaymentModel(
          id: 'pay_1',
          userId: 'user_1',
          cardId: 'card_1',
          statementAmount: 25000.0,
          dueAmount: 25000.0,
          minimumDueAmount: 5000.0,
          dueDate: DateTime.now(),
        )
      ];

      await tester.pumpWidget(createTestApp(
        const DashboardScreen(),
        overrides: [
          userProvider.overrideWith((ref) => mockUserNotifier),
          settingsProvider.overrideWith((ref) => mockSettingsNotifier),
          creditCardProvider.overrideWith(() => MockCreditCardNotifier(initialCards: cards)),
          paymentProvider.overrideWith(() => MockPaymentNotifier(initialPayments: payments)),
        ],
      ));

      await tester.pump();

      // Should show metrics
      expect(find.text('Total Credit Limit'), findsOneWidget);
      expect(find.text('₹1,00,000.00'), findsOneWidget); // Formatted correctly in INR

      expect(find.text('Total Due'), findsOneWidget);
      expect(find.text('₹25,000.00'), findsOneWidget);

      expect(find.text('Utilization'), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);
    });
  });
}
