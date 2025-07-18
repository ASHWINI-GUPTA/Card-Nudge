import 'dart:io';

import 'package:card_nudge/presentation/providers/setting_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await removeDeviceToken();
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

      // BUG: It will have the default settings.
      await _ref.read(settingsProvider.notifier).updateUserId(user.id);

      await initializeNotifications();
    } catch (e) {
      throw AuthException('Failed to sync user details: ${e.toString()}');
    }
  }

  Future<bool> isIosSimulator() async {
    if (!Platform.isIOS) return false;

    final deviceInfo = DeviceInfoPlugin();
    final iosInfo = await deviceInfo.iosInfo;

    return iosInfo.isPhysicalDevice == false;
  }

  Future<void> initializeNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permissions
    await messaging.requestPermission();

    // Get the FCM token
    bool isSimulator = await isIosSimulator();
    final token =
        isSimulator
            ? await messaging.getAPNSToken()
            : await messaging.getToken();

    final userId = _client.auth.currentUser?.id;
    final platform = Platform.operatingSystem;

    if (token != null && userId != null) {
      // Check if the token already exists for the user
      // If it does not exist, insert it into the database
      // If it exists, we do not need to insert it again
      final existingToken =
          await _client
              .from('device_tokens')
              .select()
              .eq('user_id', userId)
              .eq('device_token', token)
              .maybeSingle();

      if (existingToken == null) {
        await _client.from('device_tokens').upsert({
          'user_id': userId,
          'device_token': token,
          'platform': platform,
        });
      }
    }

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      if (userId != null) {
        final existingToken =
            await _client
                .from('device_tokens')
                .select()
                .eq('user_id', userId)
                .eq('device_token', newToken)
                .maybeSingle();

        if (existingToken == null) {
          await _client.from('device_tokens').upsert({
            'user_id': userId,
            'device_token': newToken,
            'platform': platform,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          });
        }
      }
    });
  }

  Future<void> removeDeviceToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    final userId = _client.auth.currentUser?.id;
    final token = await messaging.getToken();
    if (token == null) {
      return; // No token to remove
    }

    if (userId != null) {
      await _client
          .from('device_tokens')
          .delete()
          .eq('user_id', userId)
          .eq('device_token', token);
    }
  }

  SupabaseClient get client => _client;
}
