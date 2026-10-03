import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:card_nudge/presentation/screens/home_screen.dart';
import 'package:card_nudge/presentation/providers/user_provider.dart';
import 'package:card_nudge/presentation/providers/credit_card_provider.dart';
import 'package:card_nudge/presentation/providers/payment_provider.dart';
import 'package:card_nudge/presentation/providers/setting_provider.dart';
import 'package:card_nudge/data/hive/models/user_model.dart';
import 'package:card_nudge/data/hive/models/settings_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import '../../helpers/test_utilities.dart';
import '../../helpers/mock_providers.dart';

void main() {
  group('HomeScreen Tests', () {
    late MockUserNotifier mockUserNotifier;
    late MockSettingsNotifier mockSettingsNotifier;

    setUp(() {
      mockUserNotifier = MockUserNotifier(
        UserModel(id: 'user_1', email: 'test@example.com', firstName: 'Test', lastName: 'User')
      );
      mockSettingsNotifier = MockSettingsNotifier(SettingsModel(userId: 'user_1'));
    });

    testWidgets('renders bottom navigation bar with 4 items for normal user', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        const HomeScreen(),
        overrides: [
          userProvider.overrideWith((ref) => mockUserNotifier),
          creditCardProvider.overrideWith(MockCreditCardNotifier.new),
          paymentProvider.overrideWith(MockPaymentNotifier.new),
          settingsProvider.overrideWith((ref) => mockSettingsNotifier),
        ],
      ));

      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Cards'), findsOneWidget);
      expect(find.text('Dues'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Demo Mode'), findsNothing); // Not demo user
    });

    testWidgets('renders Demo Mode tab for demo user', (WidgetTester tester) async {
      final demoUserNotifier = MockUserNotifier(
        UserModel(id: 'demo-user', email: 'demo@example.com', firstName: 'Demo', lastName: 'User')
      );

      await tester.pumpWidget(createTestApp(
        const HomeScreen(),
        overrides: [
          userProvider.overrideWith((ref) => demoUserNotifier),
          creditCardProvider.overrideWith(MockCreditCardNotifier.new),
          paymentProvider.overrideWith(MockPaymentNotifier.new),
          settingsProvider.overrideWith((ref) => mockSettingsNotifier),
        ],
      ));

      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Demo Mode'), findsOneWidget);
    });

    testWidgets('shows Demo Mode dialog when Demo Mode tab is tapped', (WidgetTester tester) async {
      final demoUserNotifier = MockUserNotifier(
        UserModel(id: 'demo-user', email: 'demo@example.com', firstName: 'Demo', lastName: 'User')
      );

      await tester.pumpWidget(createTestApp(
        const HomeScreen(),
        overrides: [
          userProvider.overrideWith((ref) => demoUserNotifier),
          creditCardProvider.overrideWith(MockCreditCardNotifier.new),
          paymentProvider.overrideWith(MockPaymentNotifier.new),
          settingsProvider.overrideWith((ref) => mockSettingsNotifier),
        ],
      ));

      await tester.pump(const Duration(seconds: 1));
      
      final demoTab = find.text('Demo Mode');
      await tester.tap(demoTab);
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Demo Mode Active'), findsOneWidget);
      expect(find.text('Continue Demo'), findsOneWidget);
      expect(find.text('Exit & Sign In'), findsOneWidget);
    });
  });
}
