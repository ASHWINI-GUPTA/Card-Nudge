import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:card_nudge/presentation/screens/loading_screen.dart';
import '../../helpers/test_utilities.dart';

void main() {
  group('LoadingIndicatorScreen Tests', () {
    testWidgets('renders loading text and elements', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const LoadingIndicatorScreen()));
      
      // Wait for the first frame
      await tester.pump();

      // Find the loading text
      // 'Loading...' is the default translation for l10n.loading in english
      // We check for the Text widget that we expect
      expect(find.text('Loading, please wait...'), findsOneWidget);

      // We expect to find the CreditCardColorDotIndicator widget
      expect(find.byType(TweenAnimationBuilder<double>), findsOneWidget);
    });
  });
}
