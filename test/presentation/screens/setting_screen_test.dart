import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:card_nudge/presentation/screens/setting_screen.dart';
import 'package:card_nudge/presentation/providers/user_provider.dart';
import 'package:card_nudge/presentation/providers/setting_provider.dart';
import 'package:card_nudge/presentation/providers/supabase_provider.dart';
import 'package:card_nudge/presentation/providers/sync_provider.dart';
import 'package:card_nudge/presentation/providers/credit_card_provider.dart';
import 'package:card_nudge/presentation/providers/payment_provider.dart';
import 'package:card_nudge/providers/credit_card_summary_provider.dart';
import 'package:card_nudge/services/sync_service.dart';
import 'package:card_nudge/data/hive/models/user_model.dart';
import 'package:card_nudge/data/hive/models/settings_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../helpers/test_utilities.dart';
import '../../helpers/mock_providers.dart';

class MockSyncService extends Mock implements SyncService {}

void main() {
  group('SettingsScreen Tests', () {
    late UserModel user;
    late SettingsModel settings;
    late MockUserNotifier mockUserNotifier;
    late MockSettingsNotifier mockSettingsNotifier;
    late MockSupabaseService mockSupabaseService;
    late MockSyncService mockSyncService;
    late MockCreditCardNotifier mockCreditCardNotifier;
    late MockPaymentNotifier mockPaymentNotifier;
    late MockCreditCardSummaryNotifier mockCreditCardSummaryNotifier;

    setUp(() {
      user = UserModel(id: 'user_1', email: 'test@example.com', firstName: 'John', lastName: 'Doe');
      settings = SettingsModel(userId: 'user_1');
      
      mockUserNotifier = MockUserNotifier(user);
      mockSettingsNotifier = MockSettingsNotifier(settings);
      
      mockSupabaseService = MockSupabaseService();
      when(() => mockSupabaseService.signOut()).thenAnswer((_) async => {});

      mockSyncService = MockSyncService();
      when(() => mockSyncService.isOnline()).thenAnswer((_) async => true);
      when(() => mockSyncService.syncData()).thenAnswer((_) async => {});

      mockCreditCardNotifier = MockCreditCardNotifier();
      when(() => mockCreditCardNotifier.reset()).thenAnswer((_) async => {});
      
      mockPaymentNotifier = MockPaymentNotifier();
      when(() => mockPaymentNotifier.reset()).thenAnswer((_) async => {});

      mockCreditCardSummaryNotifier = MockCreditCardSummaryNotifier([]);
      when(() => mockCreditCardSummaryNotifier.reset()).thenAnswer((_) async => {});
    });

    testWidgets('renders user info', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        const SettingsScreen(),
        overrides: [
          userProvider.overrideWith((ref) => mockUserNotifier),
          settingsProvider.overrideWith((ref) => mockSettingsNotifier),
          supabaseServiceProvider.overrideWithValue(mockSupabaseService),
        ],
      ));

      await tester.pump();
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('calls signOut when logout is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        const SettingsScreen(),
        overrides: [
          userProvider.overrideWith((ref) => mockUserNotifier),
          settingsProvider.overrideWith((ref) => mockSettingsNotifier),
          supabaseServiceProvider.overrideWithValue(mockSupabaseService),
        ],
      ));

      await tester.pump();
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      verify(() => mockSupabaseService.signOut()).called(1);
    });

    testWidgets('calls clear data successfully', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        const SettingsScreen(),
        overrides: [
          userProvider.overrideWith((ref) => mockUserNotifier),
          settingsProvider.overrideWith((ref) => mockSettingsNotifier),
          supabaseServiceProvider.overrideWithValue(mockSupabaseService),
          syncServiceProvider.overrideWithValue(mockSyncService),
          creditCardProvider.overrideWith(() => mockCreditCardNotifier),
          paymentProvider.overrideWith(() => mockPaymentNotifier),
          creditCardSummariesProvider.overrideWith((ref) => mockCreditCardSummaryNotifier),
        ],
      ));

      await tester.pump();
      
      final clearDataButton = find.text('Clear Local Data', skipOffstage: false);
      await tester.scrollUntilVisible(clearDataButton, 100);
      await tester.pump();
      await tester.tap(clearDataButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Are you sure you want to clear all data? This action cannot be undone.'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      verify(() => mockCreditCardNotifier.reset()).called(1);
      verify(() => mockPaymentNotifier.reset()).called(1);
      verify(() => mockCreditCardSummaryNotifier.reset()).called(1);
    });
  });
}
