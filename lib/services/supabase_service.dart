import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../presentation/providers/user_provider.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;
  final Ref _ref;

  SupabaseService(this._ref);

  // Sign in with GitHub
  Future<void> signInWithGitHub() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.github,
      redirectTo: 'https://card.fnlsg.in/login-callback',
    );
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: dotenv.env['GOOGLE_IOS_CLIENT_ID'],
      serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
      scopes: const ['email', 'profile'],
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
    await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'https://card.fnlsg.in/login-callback',
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  bool get isAuthenticated => _client.auth.currentSession != null;

  Future<void> syncUserDetails() async {
    final user = _client.auth.currentSession!.user;
    final metadata = user.userMetadata ?? {};
    await _ref
        .read(userProvider.notifier)
        .saveUserDetails(
          id: user.id,
          firstName:
              metadata['first_name']?.toString() ??
              metadata['name']?.toString().split(' ').first ??
              '',
          lastName:
              metadata['last_name']?.toString() ??
              metadata['name']?.toString().split(' ').last ??
              '',
          email: user.email ?? metadata['email']?.toString() ?? '',
          avatarLink:
              metadata['avatar_url']?.toString() ??
              metadata['picture']?.toString(),
        );
  }
}
