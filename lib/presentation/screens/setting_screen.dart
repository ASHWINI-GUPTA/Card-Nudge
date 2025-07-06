import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_strings.dart';
import '../../data/enums/currency.dart';
import '../../data/enums/language.dart';
import '../../services/navigation_service.dart';
import '../providers/credit_card_provider.dart';
import '../providers/payment_provider.dart';
import '../providers/setting_provider.dart';
import '../providers/supabase_provider.dart';
import '../providers/sync_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/utilization_slider.dart';
import '../widgets/version_list_tile_widget.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _heightBetweenSection = 10.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.settingsScreenTitle),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Consumer(
                builder: (context, ref, child) {
                  final user = ref.watch(userProvider);
                  final theme = Theme.of(context);
                  final name =
                      user != null
                          ? '${user.firstName} ${user.lastName}'.trim()
                          : 'User';
                  final email = user?.email ?? '';

                  return ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(16, 16, 4, 16),
                    leading: CircleAvatar(
                      backgroundImage:
                          user?.avatarLink != null
                              ? NetworkImage(user!.avatarLink!)
                              : null,
                      child:
                          user?.avatarLink == null
                              ? Text(() {
                                final parts = name.trim().split(' ');
                                if (parts.length >= 2) {
                                  return (parts[0][0] + parts[1][0])
                                      .toUpperCase();
                                } else if (parts.isNotEmpty &&
                                    parts[0].isNotEmpty) {
                                  return parts[0][0].toUpperCase();
                                }
                                return '?';
                              }())
                              : null,
                    ),
                    title: Text(name, style: theme.textTheme.titleMedium),
                    subtitle: Text(email),
                    trailing: Semantics(
                      label: AppStrings.logout,
                      child: IconButton(
                        tooltip: AppStrings.logout,
                        icon: Icon(
                          Icons.logout,
                          color: theme.colorScheme.error,
                        ),
                        onPressed: () async {
                          await ref.read(supabaseServiceProvider).signOut();
                          NavigationService.goToRoute(context, '/auth');
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: _heightBetweenSection),

            // General Settings Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Text(AppStrings.language),
                    leading: Icon(
                      Icons.language,
                      color: theme.colorScheme.primary,
                    ),
                    trailing: Consumer(
                      builder: (context, ref, child) {
                        final settings = ref.watch(settingsProvider);
                        return DropdownButton<Language>(
                          value: settings.language,
                          items:
                              Language.values.map((lang) {
                                return DropdownMenuItem(
                                  value: lang,
                                  child: Text(
                                    lang == Language.English
                                        ? AppStrings.english
                                        : AppStrings.hindi,
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              ref
                                  .read(settingsProvider.notifier)
                                  .updateLanguage(value);
                            }
                          },
                        );
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(AppStrings.currency),
                    leading: Icon(
                      Icons.currency_rupee_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    trailing: Consumer(
                      builder: (context, ref, child) {
                        final settings = ref.watch(settingsProvider);
                        return DropdownButton<Currency>(
                          value: settings.currency,
                          items:
                              Currency.values.map((currency) {
                                return DropdownMenuItem(
                                  value: currency,
                                  child: Text(
                                    currency == Currency.INR
                                        ? 'INR (₹)'
                                        : 'USD (\$)',
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              ref
                                  .read(settingsProvider.notifier)
                                  .updateCurrency(value);
                            }
                          },
                        );
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(AppStrings.theme),
                    leading: Icon(
                      Icons.color_lens,
                      color: theme.colorScheme.primary,
                    ),
                    trailing: Consumer(
                      builder: (context, ref, child) {
                        final settings = ref.watch(settingsProvider);
                        return DropdownButton<ThemeMode>(
                          value: settings.themeMode,
                          items:
                              ThemeMode.values.map((mode) {
                                String text;
                                switch (mode) {
                                  case ThemeMode.light:
                                    text = AppStrings.light;
                                    break;
                                  case ThemeMode.dark:
                                    text = AppStrings.dark;
                                    break;
                                  case ThemeMode.system:
                                    text = AppStrings.system;
                                }
                                return DropdownMenuItem(
                                  value: mode,
                                  child: Text(text),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              ref
                                  .read(settingsProvider.notifier)
                                  .updateTheme(value);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: _heightBetweenSection),
            // Notifications Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(AppStrings.paymentReminders),
                    value: settings.notificationsEnabled,
                    onChanged: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .updateNotifications(value);
                    },
                  ),
                  ListTile(
                    title: Text(AppStrings.reminderTime),
                    leading: Icon(
                      Icons.alarm,
                      color: theme.colorScheme.primary,
                    ),
                    trailing: Text(
                      settings.reminderTime.format(context),
                      style: theme.textTheme.bodyLarge,
                    ),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: settings.reminderTime,
                      );
                      if (time != null) {
                        ref
                            .read(settingsProvider.notifier)
                            .updateReminderTime(time);
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.utilizationAlert,
                          style: theme.textTheme.bodyLarge,
                        ),
                        UtilizationSlider(
                          initialValue:
                              settings.utilizationAlertThreshold ?? 30,
                          onChanged: (value) {
                            ref
                                .read(settingsProvider.notifier)
                                .updateUtilizationAlertThreshold(value);
                          },
                        ),
                        Text(
                          AppStrings.utilizationAlertDescription,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: _heightBetweenSection),
            // Data Management Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(AppStrings.syncPreference),
                    value: settings.syncSettings,
                    subtitle: Text(AppStrings.syncPreferenceSubtitle),
                    onChanged: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .updateSyncPreference(value);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.sync),
                    title: Text(
                      AppStrings.syncData,
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                    onTap: () async {
                      await ref.read(syncServiceProvider).syncData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppStrings.syncDataSuccess)),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.cleaning_services,
                      color: theme.colorScheme.error,
                    ),
                    title: Text(
                      AppStrings.clearData,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    onTap: () => _showClearDataDialog(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: _heightBetweenSection),
            // About Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  VersionListTile(),
                  ListTile(
                    title: Text('Website'),
                    subtitle: const Text('https://card.fnlsg.in'),
                    onTap: () {
                      launchUrl(Uri.parse('https://card.fnlsg.in'));
                    },
                  ),
                  ListTile(
                    title: Text('Developer Email'),
                    subtitle: const Text('ashwini@fnlsg.in'),
                    onTap: () {
                      launchUrl(
                        Uri(scheme: 'mailto', path: 'ashwini@fnlsg.in'),
                      );
                    },
                  ),
                  ListTile(
                    title: Text(AppStrings.termsConditions),
                    onTap: () {
                      launchUrl(Uri.parse('https://card.fnlsg.in/terms'));
                    },
                  ),
                  ListTile(
                    title: Text(AppStrings.privacyPolicy),
                    onTap: () {
                      launchUrl(Uri.parse('https://card.fnlsg.in/privacy'));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: _heightBetweenSection),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppStrings.clearData),
            content: Text(AppStrings.clearDataConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppStrings.cancel),
              ),
              TextButton(
                onPressed: () {
                  ref.watch(paymentProvider.notifier).reset();
                  ref.watch(creditCardProvider.notifier).reset();

                  // TODO: Clear from Supabase too?

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppStrings.clearDataSuccess)),
                  );
                },
                child: Text(
                  AppStrings.delete,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
    );
  }
}
