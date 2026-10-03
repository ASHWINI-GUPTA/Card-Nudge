import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:card_nudge/presentation/screens/benefits_summary_screen.dart';
import 'package:card_nudge/data/hive/models/credit_card_model.dart';
import 'package:card_nudge/data/hive/models/credit_card_summary_model.dart';
import 'package:card_nudge/data/enums/card_type.dart';
import 'package:card_nudge/providers/credit_card_summary_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../../helpers/test_utilities.dart';
import '../../helpers/mock_providers.dart';

void main() {
  setUpAll(() {
    registerFallbacks();
  });

  group('BenefitsSummaryScreen Tests', () {
    late CreditCardModel mockCard;
    late MockCreditCardSummaryNotifier mockNotifier;

    setUp(() {
      mockCard = CreditCardModel(
        id: 'card_123',
        userId: 'user_1',
        name: 'Sapphire Reserve',
        bankId: 'bank_123',
        last4Digits: '1234',
        billingDate: DateTime.now(),
        dueDate: DateTime.now(),
        cardType: CardType.Visa,
        creditLimit: 10000,
      );
      mockNotifier = MockCreditCardSummaryNotifier([]);
    });

    testWidgets('renders no benefits available text if summary is null', (WidgetTester tester) async {
      when(() => mockNotifier.getSummaryByCardId('card_123')).thenReturn(null);

      await tester.pumpWidget(createTestApp(
        BenefitsSummaryScreen(card: mockCard),
        overrides: [
          creditCardSummariesProvider.overrideWith((ref) => mockNotifier),
        ],
      ));

      expect(find.text('No benefits information available.'), findsOneWidget);
    });

    testWidgets('renders markdown summary when available', (WidgetTester tester) async {
      final summary = CreditCardSummaryModel(
        id: 'sum_123',
        cardId: 'card_123',
        markdownSummary: '# Great Benefits\n- Free Lounge Access',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: 1,
      );

      when(() => mockNotifier.getSummaryByCardId('card_123')).thenReturn(summary);

      await tester.pumpWidget(createTestApp(
        BenefitsSummaryScreen(card: mockCard),
        overrides: [
          creditCardSummariesProvider.overrideWith((ref) => mockNotifier),
        ],
      ));

      expect(find.byType(Markdown), findsOneWidget);
      expect(find.text('Sapphire Reserve Card Benefits'), findsOneWidget); // AppBar title
    });
  });
}
