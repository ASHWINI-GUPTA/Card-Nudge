import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../presentation/providers/user_provider.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;
  final Ref _ref;
  final GoogleSignIn _googleSignIn;

  SupabaseService(this._ref)
    : _googleSignIn = GoogleSignIn(
        clientId: dotenv.env['GOOGLE_IOS_CLIENT_ID'],
        serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
        scopes: const ['email', 'profile'],
      );

  // Initialize Supabase and load env variables
  static Future<void> initialize() async {
    await dotenv.load();
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
  }

  // Sign in with GitHub
  Future<void> signInWithGitHub() async {
    try {
      final success = await _client.auth.signInWithOAuth(
        OAuthProvider.github,
        redirectTo: 'https://card.fnlsg.in/login-callback',
      );
      if (!success) {
        throw const AuthException('GitHub Sign-In failed');
      }
      await syncUserDetails();
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Google Sign-In cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw const AuthException('Missing Google authentication tokens');
      }

      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        throw const AuthException('Failed to sign in with Google');
      }

      await syncUserDetails();
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _client.auth.signOut();
      _ref.read(userProvider.notifier).clearUserDetails();
    } catch (e) {
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  // Auth state changes stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Check if user is authenticated
  bool get isAuthenticated => _client.auth.currentSession != null;

  // Sync user details with Riverpod
  Future<void> syncUserDetails() async {
    try {
      final user = _client.auth.currentSession?.user;
      if (user == null) {
        throw const AuthException('No authenticated user found');
      }

      final metadata = user.userMetadata ?? {};
      final nameParts = (metadata['name']?.toString() ?? '').split(' ');

      await _ref
          .read(userProvider.notifier)
          .saveUserDetails(
            id: user.id,
            firstName:
                metadata['first_name']?.toString() ??
                (nameParts.isNotEmpty ? nameParts.first : ''),
            lastName:
                metadata['last_name']?.toString() ??
                (nameParts.length > 1 ? nameParts.last : ''),
            email: user.email ?? metadata['email']?.toString() ?? '',
            avatarLink:
                metadata['avatar_url']?.toString() ??
                metadata['picture']?.toString() ??
                '',
          );
    } catch (e) {
      throw AuthException('Failed to sync user details: ${e.toString()}');
    }
  }
}
