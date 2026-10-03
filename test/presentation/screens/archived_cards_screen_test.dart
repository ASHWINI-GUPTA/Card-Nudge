import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:card_nudge/presentation/screens/archived_cards_screen.dart';
import 'package:card_nudge/presentation/providers/credit_card_provider.dart';
import 'package:card_nudge/presentation/providers/bank_provider.dart';
import 'package:card_nudge/presentation/providers/payment_provider.dart';
import 'package:card_nudge/data/hive/models/credit_card_model.dart';
import 'package:card_nudge/data/enums/card_type.dart';
import 'package:card_nudge/presentation/widgets/credit_card_color_dot_indicator.dart';
import 'package:card_nudge/presentation/widgets/credit_card_details_list_tile.dart';
import '../../helpers/test_utilities.dart';
import '../../helpers/mock_providers.dart';

void main() {
  group('ArchivedCardsScreen Tests', () {
    testWidgets('renders loading state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          const ArchivedCardsScreen(),
          overrides: [
            creditCardProvider.overrideWith(
              () => MockCreditCardNotifier(isLoading: true),
            ),
          ],
        ),
      );

      await tester.pump();
      expect(find.byType(CreditCardColorDotIndicator), findsOneWidget);
    });

    testWidgets('renders empty state when no archived cards', (
      WidgetTester tester,
    ) async {
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
          isArchived: false,
        ),
      ];

      await tester.pumpWidget(
        createTestApp(
          const ArchivedCardsScreen(),
          overrides: [
            creditCardProvider.overrideWith(
              () => MockCreditCardNotifier(initialCards: cards),
            ),
          ],
        ),
      );

      await tester.pump(); // Start async build
      await tester.pump(); // Settle
      expect(find.byIcon(Icons.archive_outlined), findsOneWidget);
    });

    testWidgets('renders list of archived cards', (WidgetTester tester) async {
      final List<CreditCardModel> cards = [
        CreditCardModel(
          id: 'card_2',
          userId: 'user_1',
          name: 'Archived Card',
          bankId: 'bank_1',
          last4Digits: '5678',
          billingDate: DateTime.now(),
          dueDate: DateTime.now(),
          cardType: CardType.MasterCard,
          creditLimit: 20000.0,
          isArchived: true,
        ),
      ];

      await tester.pumpWidget(
        createTestApp(
          const ArchivedCardsScreen(),
          overrides: [
            creditCardProvider.overrideWith(
              () => MockCreditCardNotifier(initialCards: cards),
            ),
            bankProvider.overrideWith(() => MockBankNotifier()),
            paymentProvider.overrideWith(() => MockPaymentNotifier()),
          ],
        ),
      );

      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CreditCardDetailsListTile), findsOneWidget);
    });
  });
}
