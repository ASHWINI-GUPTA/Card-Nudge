import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Provider for SupabaseService
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Check if user is authenticated
  bool get isAuthenticated => _client.auth.currentSession != null;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Sign in with GitHub
  Future<void> signInWithGitHub() async {
    // await _client.auth.signInWithOAuth(
    //   OAuthProvider.github,
    //   redirectTo: 'io.supabase.flutterquickstart://login-callback/',
    // );
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: dotenv.env['GOOGLE_IOS_CLIENT_ID'],
      serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
    );

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw const AuthException('Google Sign-In cancelled.');
    }

    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;
    if (accessToken == null) {
      throw 'No Access Token found.';
    }
    if (idToken == null) {
      throw 'No ID Token found.';
    }
    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  // Sign in with Apple
  Future<void> signInWithApple() async {
    // await _client.auth.signInWithOAuth(
    //   OAuthProvider.apple,
    //   redirectTo: 'io.supabase.flutterquickstart://login-callback/',
    // );
  }

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
