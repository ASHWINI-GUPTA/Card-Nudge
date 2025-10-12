import 'package:card_nudge/helper/app_localizations_extension.dart';
import 'package:card_nudge/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/supabase_provider.dart';
import '../widgets/credit_card_color_dot_indicator.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabaseProvider = ref.watch(supabaseServiceProvider);

    ref.listen<AsyncValue<AuthState>>(authStateChangesProvider, (
      previous,
      next,
    ) {
      next.when(
        data: (authState) {
          if (authState.session != null) {
            NavigationService.goToRoute(context, '/sync');
          }
        },
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Authentication error: $error')),
          );
        },
        loading: () {
          CreditCardColorDotIndicator();
        },
      );
    });

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
                  child: Image.asset(
                    'assets/icons/card_nudge.png',
                    width: 128,
                    height: 128,
                    semanticLabel: 'Card Nudge Logo',
                  ),
                ),
                const SizedBox(height: 18),
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 800),
                  child: Column(
                    children: [
                      Text(
                        context.l10n.welcomeTitle,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[900],
                        ),
                        textAlign: TextAlign.center,
                        semanticsLabel: context.l10n.welcomeTitle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.welcomeSubtitle,
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
                  context: context,
                  ref: ref,
                  onPressed: () async {
                    try {
                      await supabaseProvider.signInWithGoogle();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Google Sign-In failed: $e')),
                      );
                    }
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/google_icon.svg',
                    width: 24,
                    height: 24,
                    semanticsLabel: 'Google Icon',
                  ),
                  text: 'Continue with Google',
                ),
                const SizedBox(height: 20),

                // GitHub Sign-In Button
                _buildExternalOAuthButton(
                  context: context,
                  ref: ref,
                  onPressed: () async {
                    try {
                      await supabaseProvider.signInWithGitHub();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('GitHub Sign-In failed: $e')),
                      );
                    }
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/github_icon.svg',
                    width: 24,
                    height: 24,
                    semanticsLabel: 'GitHub Icon',
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
                            '${context.l10n.appVersion}: ${snapshot.data!.version}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text(
                            '${context.l10n.versionError}: ${snapshot.error}',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 13,
                            ),
                          );
                        }
                        return Text(
                          context.l10n.loadingVersion,
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
                      onTap: () async {
                        final url = Uri.parse(
                          'https://github.com/ASHWINI-GUPTA/Card-Nudge',
                        );
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not open GitHub link'),
                            ),
                          );
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/github_icon.svg',
                            width: 20,
                            height: 20,
                            semanticsLabel: 'GitHub Icon',
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
    required BuildContext context,
    required WidgetRef ref,
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
            semanticsLabel: text,
          ),
        ],
      ),
    );
  }
}
