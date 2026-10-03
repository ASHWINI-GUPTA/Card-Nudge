import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:card_nudge/presentation/screens/error_screen.dart';
import 'package:go_router/go_router.dart';
import '../../helpers/test_utilities.dart';

void main() {
  group('ErrorScreen Tests', () {
    testWidgets('renders default error message when no message provided', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const ErrorScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Something went wrong!'), findsOneWidget);
      expect(find.text('An unexpected error occurred. Please try again or return to the home screen. If the problem persists, contact support.'), findsOneWidget);
    });

    testWidgets('renders custom error message', (WidgetTester tester) async {
      const customMessage = 'Network connection failed.';
      await tester.pumpWidget(createTestApp(const ErrorScreen(message: customMessage)));
      await tester.pumpAndSettle();

      expect(find.text(customMessage), findsOneWidget);
    });

    testWidgets('renders retry button if onRetry is provided', (WidgetTester tester) async {
      bool retryPressed = false;
      await tester.pumpWidget(createTestApp(
        ErrorScreen(onRetry: () => retryPressed = true),
      ));
      await tester.pumpAndSettle();

      final retryButton = find.text('Retry');
      expect(retryButton, findsOneWidget);

      await tester.tap(retryButton);
      expect(retryPressed, isTrue);
    });
  });
}
