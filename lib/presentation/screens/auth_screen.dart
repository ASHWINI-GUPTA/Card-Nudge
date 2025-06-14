import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_strings.dart';
import '../providers/supabase_provider.dart';
import '../widgets/credit_card_color_dot_indicator.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabaseProvider = ref.read(supabaseServiceProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated App Logo
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  builder:
                      (context, scale, child) =>
                          Transform.scale(scale: scale, child: child),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.blue.shade50,
                    child: Image.asset(
                      'assets/icons/card_nudge.png',
                      width: 64,
                      height: 64,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 800),
                  child: Column(
                    children: [
                      Text(
                        'Welcome to Card Nudge 🔔',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[900],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your Credit Card Companion!',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: Colors.blueGrey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const CreditCardColorDotIndicator(animate: false),
                const SizedBox(height: 30),

                // Google Sign-In Button
                _buildExternalOAuthButton(
                  onPressed: () => supabaseProvider.signInWithGoogle(),
                  icon: SvgPicture.asset(
                    'assets/icons/google_icon.svg',
                    width: 24,
                    height: 24,
                  ),
                  text: 'Continue with Google',
                ),
                const SizedBox(height: 20),

                // GitHub Sign-In Button
                _buildExternalOAuthButton(
                  onPressed: () => supabaseProvider.signInWithGitHub(),
                  icon: SvgPicture.asset(
                    'assets/icons/github_icon.svg',
                    width: 24,
                    height: 24,
                  ),
                  text: 'Continue with GitHub',
                ),
                const SizedBox(height: 30),

                // Info Section
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(
                      height: 32,
                      thickness: 1,
                      color: Colors.black12,
                    ),

                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            '${AppStrings.appVersion}: ${snapshot.data!.version}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text(
                            '${AppStrings.versionError}: ${snapshot.error}',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 13,
                            ),
                          );
                        }
                        return const Text(
                          AppStrings.loadingVersion,
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          'Made with ',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                        ),
                        const Icon(Icons.favorite, color: Colors.red, size: 16),
                        Text(
                          ' in Bharat',
                          style: TextStyle(
                            color: Colors.deepOrange[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap:
                          () => launchUrl(
                            Uri.parse(
                              'https://github.com/ASHWINI-GUPTA/Card-Nudge',
                            ),
                          ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/github_icon.svg',
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Open Source',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExternalOAuthButton({
    required VoidCallback onPressed,
    required Widget icon,
    required String text,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        minimumSize: const Size(double.infinity, 50),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _creditCardColorDot(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.5),
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
