import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:card_nudge/presentation/screens/auth_screen.dart';
import 'package:card_nudge/presentation/providers/supabase_provider.dart';
import 'package:card_nudge/presentation/providers/user_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../helpers/test_utilities.dart';
import '../../helpers/mock_providers.dart';

class MockSession extends Mock implements Session {}
class MockUser extends Mock implements User {}

void main() {
  group('AuthScreen Tests', () {
    late MockSupabaseService mockSupabaseService;
    late MockUserNotifier mockUserNotifier;

    setUp(() {
      mockSupabaseService = MockSupabaseService();
      mockUserNotifier = MockUserNotifier(null);
      
      // Stub the async operations
      when(() => mockUserNotifier.enableDemoMode()).thenAnswer((_) async {});
      when(() => mockSupabaseService.signInWithGoogle()).thenAnswer((_) async {});
      when(() => mockSupabaseService.signInWithGitHub()).thenAnswer((_) async {});
    });

    testWidgets('renders login buttons and demo mode', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        const AuthScreen(),
        overrides: [
          supabaseServiceProvider.overrideWithValue(mockSupabaseService),
          authStateChangesProvider.overrideWith((ref) => const Stream.empty()),
          userProvider.overrideWith((ref) => mockUserNotifier),
        ],
      ));

      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Welcome to Card Nudge 🔔'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with GitHub'), findsOneWidget);
      expect(find.text('Demo Mode'), findsOneWidget);
    });

    testWidgets('tapping Google sign in calls SupabaseService', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        const AuthScreen(),
        overrides: [
          supabaseServiceProvider.overrideWithValue(mockSupabaseService),
          authStateChangesProvider.overrideWith((ref) => const Stream.empty()),
          userProvider.overrideWith((ref) => mockUserNotifier),
        ],
      ));

      await tester.pump(const Duration(seconds: 1));

      final googleBtn = find.text('Continue with Google');
      await tester.tap(googleBtn);
      await tester.pump(); // Allow tap to trigger future

      verify(() => mockSupabaseService.signInWithGoogle()).called(1);
    });

    testWidgets('tapping Demo Mode calls enableDemoMode on userProvider', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        const AuthScreen(),
        overrides: [
          supabaseServiceProvider.overrideWithValue(mockSupabaseService),
          authStateChangesProvider.overrideWith((ref) => const Stream.empty()),
          userProvider.overrideWith((ref) => mockUserNotifier),
        ],
      ));

      await tester.pump(const Duration(seconds: 1));

      final demoBtn = find.text('Demo Mode');
      await tester.tap(demoBtn);
      await tester.pump();

      verify(() => mockUserNotifier.enableDemoMode()).called(1);
    });
  });
}
