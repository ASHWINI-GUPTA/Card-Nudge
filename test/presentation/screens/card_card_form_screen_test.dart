import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:card_nudge/presentation/screens/card_card_form_screen.dart';
import 'package:card_nudge/presentation/providers/credit_card_provider.dart';
import 'package:card_nudge/presentation/providers/bank_provider.dart';
import 'package:card_nudge/presentation/providers/setting_provider.dart';
import 'package:card_nudge/data/hive/models/user_model.dart';
import 'package:card_nudge/data/hive/models/bank_model.dart';
import 'package:card_nudge/data/hive/models/credit_card_model.dart';
import 'package:card_nudge/data/hive/models/settings_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../helpers/test_utilities.dart';
import '../../helpers/mock_providers.dart';

class FallbackCreditCardModel extends Fake implements CreditCardModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FallbackCreditCardModel());
  });

  group('CreditCardFormScreen Tests', () {
    late UserModel user;
    late MockCreditCardNotifier mockCreditCardNotifier;
    late MockBankNotifier mockBankNotifier;

    setUp(() {
      user = UserModel(id: 'user_1', email: 'test@example.com', firstName: 'John', lastName: 'Doe');
      
      mockCreditCardNotifier = MockCreditCardNotifier();
      when(() => mockCreditCardNotifier.save(any())).thenAnswer((_) async => {});

      mockBankNotifier = MockBankNotifier(initialBanks: [
        BankModel(id: 'bank_1', userId: 'user_1', name: 'Test Bank'),
      ]);
    });

    testWidgets('renders all form fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        CreditCardFormScreen(user: user),
        overrides: [
          creditCardProvider.overrideWith(() => mockCreditCardNotifier),
          bankProvider.overrideWith(() => mockBankNotifier),
          settingsProvider.overrideWith((ref) => MockSettingsNotifier(SettingsModel(userId: 'user_1'))),
        ],
      ));

      await tester.pump();
      await tester.pump();

      expect(find.text('Add Card'), findsOneWidget); // Appbar title
      expect(find.byType(TextFormField), findsNWidgets(6)); // Name, Bank, Network, Last4, Limit, Grace period
      expect(find.text('Save', skipOffstage: false), findsOneWidget);
    });

    testWidgets('shows validation errors when saving empty form', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        CreditCardFormScreen(user: user),
        overrides: [
          creditCardProvider.overrideWith(() => mockCreditCardNotifier),
          bankProvider.overrideWith(() => mockBankNotifier),
          settingsProvider.overrideWith((ref) => MockSettingsNotifier(SettingsModel(userId: 'user_1'))),
        ],
      ));

      await tester.pump();
      await tester.pump();

      final saveButton = find.text('Save', skipOffstage: false);
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('This field is required.', skipOffstage: false), findsWidgets);
    });

    testWidgets('saves card successfully', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        CreditCardFormScreen(user: user),
        overrides: [
          creditCardProvider.overrideWith(() => mockCreditCardNotifier),
          bankProvider.overrideWith(() => mockBankNotifier),
          settingsProvider.overrideWith((ref) => MockSettingsNotifier(SettingsModel(userId: 'user_1'))),
        ],
      ));

      await tester.pump();
      await tester.pump();

      // Enter Card Name
      await tester.enterText(find.widgetWithText(TextFormField, 'Card Name *'), 'My New Card');

      // Enter Last 4 Digits
      await tester.ensureVisible(find.widgetWithText(TextFormField, 'Last 4 Digits'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'Last 4 Digits'), '4321');

      // Enter Credit Limit
      await tester.ensureVisible(find.widgetWithText(TextFormField, 'Credit Limit'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'Credit Limit'), '50000');
      
      // Select Date
      await tester.ensureVisible(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.widgetWithText(TextFormField, 'Bank *'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextFormField, 'Bank *'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test Bank'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.widgetWithText(TextFormField, 'Card Network'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextFormField, 'Card Network'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Visa'));
      await tester.pumpAndSettle();

      final saveButton = find.text('Save', skipOffstage: false);
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      verify(() => mockCreditCardNotifier.save(any())).called(1);
    });
  });
}
