import 'dart:async';
import 'package:card_nudge/data/enums/entities.dart';
import 'package:card_nudge/data/hive/models/delete_queue_entry.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../data/enums/card_type.dart';
import '../data/enums/currency.dart';
import '../data/enums/language.dart';
import '../data/hive/models/bank_model.dart';
import '../data/hive/models/credit_card_model.dart';
import '../data/hive/models/credit_card_summary_model.dart';
import '../data/hive/models/payment_model.dart';
import '../data/hive/models/settings_model.dart';

class SyncService {
  final SupabaseClient supabase;
  final Box<BankModel> bankBox;
  final Box<CreditCardModel> cardBox;
  final Box<CreditCardSummaryModel> cardSummaryBox;
  final Box<PaymentModel> paymentBox;
  final Box<SettingsModel> settingsBox;
  final Connectivity connectivity;
  final Box<DeleteQueueEntry> deleteQueueBox;
  final defaultSettingId = '00000000-0000-0000-0000-000000000000';

  SyncService({
    required this.supabase,
    required this.bankBox,
    required this.cardBox,
    required this.cardSummaryBox,
    required this.paymentBox,
    required this.settingsBox,
    required this.connectivity,
    required this.deleteQueueBox,
  });

  /// Returns true only if both settings are properly configured (non-default userId)
  /// AND bank data exists locally. Since initialSync always fetches default banks,
  /// an empty bankBox means the sync never completed — we must go through AuthProgress.
  bool get isInitialized =>
      settingsBox.isNotEmpty &&
      !settingsBox.values.first.isDefaultSetting &&
      bankBox.isNotEmpty;

  Future<bool> isOnline() async {
    final connectivityResult = await connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> syncData() async {
    if (!await isOnline()) {
      print('Offline: Skipping sync');
      return;
    }

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      print('User not authenticated: Skipping sync');
      return;
    }

    try {
      // Before pulling server data, clear entities from server based on local delete queue
      if (deleteQueueBox.isNotEmpty) {
        print('Processing delete queue with ${deleteQueueBox.length} entries.');

        final grouped = <Entities, List<dynamic>>{};

        for (var entry in deleteQueueBox.values) {
          grouped.putIfAbsent(entry.entityType, () => []).add(entry.id);
        }

        for (final entry in grouped.entries) {
          final entityType = entry.key;
          final idsToDelete = entry.value;

          if (idsToDelete.isNotEmpty) {
            await supabase
                .from(entityType.table)
                .delete()
                .inFilter('id', idsToDelete);

            print('Deleted ${idsToDelete.length} from ${entityType.table}');
          }
        }
      }

      // Now, Pull server changes
      final serverBanks = await supabase
          .from('banks')
          .select()
          .eq('user_id', userId);

      final serverCards = await supabase
          .from('cards')
          .select()
          .eq('user_id', userId);

      final serverPayments = await supabase
          .from('payments')
          .select()
          .eq('user_id', userId);

      final serverSettings = await supabase
          .from('settings')
          .select()
          .eq('user_id', userId);

      final serverCardSummaries = await supabase
          .from('credit_card_summaries')
          .select()
          .inFilter('card_id', serverCards.map((card) => card['id']).toList());

      // Sync banks
      for (var serverBank in serverBanks) {
        final localBank = bankBox.get(serverBank['id']);
        final serverUpdatedAt = DateTime.parse(serverBank['updated_at']);
        if (localBank == null || serverUpdatedAt.isAfter(localBank.updatedAt)) {
          final bank = BankModel(
            id: serverBank['id'],
            userId: serverBank['user_id'],
            name: serverBank['name'],
            code: serverBank['code'],
            logoPath: serverBank['logo_path'],
            supportNumber: serverBank['support_number'],
            website: serverBank['website'],
            isFavorite: serverBank['is_favorite'] ?? false,
            colorHex: serverBank['color_hex'],
            priority: serverBank['priority'],
            createdAt: DateTime.parse(serverBank['created_at']),
            updatedAt: serverUpdatedAt,
            syncPending: false,
            isDefault: false,
          );
          await bankBox.put(bank.id, bank);
        }
      }
      for (final localBank in bankBox.values.where((b) => b.syncPending)) {
        final data = {
          'id': localBank.id,
          'user_id': localBank.userId,
          'name': localBank.name,
          'code': localBank.code,
          'logo_path': localBank.logoPath,
          'support_number': localBank.supportNumber,
          'website': localBank.website,
          'is_favorite': localBank.isFavorite,
          'color_hex': localBank.colorHex,
          'priority': localBank.priority,
          'created_at': localBank.createdAt.toIso8601String(),
          'updated_at': localBank.updatedAt.toIso8601String(),
        };
        await supabase.from('banks').upsert(data);
        final updatedBank = localBank.copyWith(syncPending: false);
        await bankBox.put(updatedBank.id, updatedBank);
      }

      // Sync cards
      for (var serverCard in serverCards) {
        final localCard = cardBox.get(serverCard['id']);
        final serverUpdatedAt = DateTime.parse(serverCard['updated_at']);
        if (localCard == null || serverUpdatedAt.isAfter(localCard.updatedAt)) {
          final card = CreditCardModel(
            id: serverCard['id'],
            userId: serverCard['user_id'],
            name: serverCard['name'],
            bankId: serverCard['bank_id'],
            last4Digits: serverCard['last_4_digits'],
            billingDate: DateTime.parse(serverCard['billing_date']),
            dueDate: DateTime.parse(serverCard['due_date']),
            cardType: CardType.values.firstWhere(
              (e) => e.name == serverCard['card_type'],
            ),
            creditLimit: serverCard['credit_limit']?.toDouble(),
            currentUtilization: serverCard['current_utilization']?.toDouble(),
            createdAt: DateTime.parse(serverCard['created_at']),
            updatedAt: serverUpdatedAt,
            isArchived: serverCard['is_archived'] ?? false,
            isFavorite: serverCard['is_favorite'] ?? false,
            isAutoDebitEnabled: serverCard['is_auto_debit_enabled'] ?? false,
            benefitSummary: serverCard['benefit_summary'],
            dueGracePeriodDays: serverCard['due_grace_period_days'] ?? 20,
            syncPending: false,
          );
          await cardBox.put(card.id, card);
        }
      }
      for (final localCard in cardBox.values.where((c) => c.syncPending)) {
        final data = {
          'id': localCard.id,
          'user_id': localCard.userId,
          'name': localCard.name,
          'bank_id': localCard.bankId,
          'last_4_digits': localCard.last4Digits,
          'billing_date': localCard.billingDate.toIso8601String(),
          'due_date': localCard.dueDate.toIso8601String(),
          'card_type': localCard.cardType.name,
          'credit_limit': localCard.creditLimit,
          'current_utilization': localCard.currentUtilization,
          'created_at': localCard.createdAt.toIso8601String(),
          'updated_at': localCard.updatedAt.toIso8601String(),
          'is_archived': localCard.isArchived,
          'is_favorite': localCard.isFavorite,
          'is_auto_debit_enabled': localCard.isAutoDebitEnabled,
          'due_grace_period_days': localCard.dueGracePeriodDays,
        };
        await supabase.from('cards').upsert(data);
        final updatedCard = localCard.copyWith(syncPending: false);
        await cardBox.put(updatedCard.id, updatedCard);
      }

      // Delete any local card summaries that are no longer present on the server
      for (final localCardSummary in cardSummaryBox.values) {
        if (!serverCardSummaries.any((s) => s['id'] == localCardSummary.id)) {
          await cardSummaryBox.delete(localCardSummary.id);
        }
      }

      // Sync Card Summary
      for (var serverCardSummary in serverCardSummaries) {
        final localCardSummary = cardSummaryBox.get(serverCardSummary['id']);
        final serverUpdatedAt = DateTime.parse(serverCardSummary['updated_at']);
        if (localCardSummary == null ||
            serverUpdatedAt.isAfter(localCardSummary.updatedAt)) {
          final cardSummary = CreditCardSummaryModel(
            id: serverCardSummary['id'],
            cardId: serverCardSummary['card_id'],
            markdownSummary: serverCardSummary['markdown_summary'],
            createdAt: DateTime.parse(serverCardSummary['created_at']),
            updatedAt: serverUpdatedAt,
            status: serverCardSummary['status'],
            userLiked: serverCardSummary['user_liked'] ?? false,
          );
          await cardSummaryBox.put(cardSummary.id, cardSummary);
        }
      }

      // Sync payments
      for (var serverPayment in serverPayments) {
        final localPayment = paymentBox.get(serverPayment['id']);
        final serverUpdatedAt = DateTime.parse(serverPayment['updated_at']);
        if (localPayment == null ||
            serverUpdatedAt.isAfter(localPayment.updatedAt)) {
          final payment = PaymentModel(
            id: serverPayment['id'],
            userId: serverPayment['user_id'],
            cardId: serverPayment['card_id'],
            dueAmount: serverPayment['due_amount']?.toDouble(),
            paymentDate:
                serverPayment['payment_date'] != null
                    ? DateTime.parse(serverPayment['payment_date'])
                    : null,
            isPaid: serverPayment['is_paid'] ?? false,
            createdAt: DateTime.parse(serverPayment['created_at']),
            updatedAt: serverUpdatedAt,
            minimumDueAmount: serverPayment['minimum_due_amount']?.toDouble(),
            paidAmount: serverPayment['paid_amount']?.toDouble(),
            dueDate: DateTime.parse(serverPayment['due_date']),
            statementAmount: serverPayment['statement_amount']?.toDouble(),
            syncPending: false,
          );
          await paymentBox.put(payment.id, payment);
        }
      }
      for (final localPayment in paymentBox.values.where(
        (p) => p.syncPending,
      )) {
        final data = {
          'id': localPayment.id,
          'user_id': localPayment.userId,
          'card_id': localPayment.cardId,
          'due_amount': localPayment.dueAmount,
          'payment_date': localPayment.paymentDate?.toIso8601String(),
          'is_paid': localPayment.isPaid,
          'created_at': localPayment.createdAt.toIso8601String(),
          'updated_at': localPayment.updatedAt.toIso8601String(),
          'minimum_due_amount': localPayment.minimumDueAmount,
          'paid_amount': localPayment.paidAmount,
          'due_date': localPayment.dueDate.toIso8601String(),
          'statement_amount': localPayment.statementAmount,
        };
        await supabase.from('payments').upsert(data);
        final updatedPayment = localPayment.copyWith(syncPending: false);
        await paymentBox.put(updatedPayment.id, updatedPayment);
      }

      // Sync settings
      if (serverSettings.isNotEmpty) {
        final serverSetting = serverSettings.first;
        final localSetting = settingsBox.values.first;
        final serverUpdatedAt = DateTime.parse(serverSetting['updated_at']);
        if (localSetting.isDefaultSetting ||
            serverUpdatedAt.isAfter(localSetting.updatedAt)) {
          final timeArray = serverSetting['reminder_time'].toString().split(
            ':',
          );
          // Convert UTC time from server to local time
          final utcTime = TimeOfDay(
            hour: int.parse(timeArray[0]),
            minute: int.parse(timeArray[1]),
          );
          final now = DateTime.now();
          final utcDateTime = DateTime.utc(
            now.year,
            now.month,
            now.day,
            utcTime.hour,
            utcTime.minute,
          );
          final localDateTime = utcDateTime.toLocal();
          final reminderTime = TimeOfDay(
            hour: localDateTime.hour,
            minute: localDateTime.minute,
          );

          final setting = SettingsModel(
            userId: serverSetting['user_id'],
            language: Language.values.firstWhere(
              (e) => e.name == serverSetting['language'],
            ),
            currency: Currency.values.firstWhere(
              (e) => e.name == serverSetting['currency'],
            ),
            themeMode: ThemeMode.values.firstWhere(
              (e) => e.name == serverSetting['theme_mode'],
            ),
            notificationsEnabled:
                serverSetting['notifications_enabled'] ?? true,
            reminderTime: reminderTime,
            syncSettings: serverSetting['sync_settings'] ?? true,
            createdAt: DateTime.parse(serverSetting['created_at']),
            updatedAt: serverUpdatedAt,
            syncPending: false,
            utilizationAlertThreshold:
                serverSetting['utilization_alert_threshold'] ?? 30,
          );
          await settingsBox.put(defaultSettingId, setting);
        }
      }
      final localSetting = settingsBox.values.first;
      if (localSetting.syncPending && !localSetting.isDefaultSetting) {
        // Convert local reminderTime to UTC before sending to server
        final now = DateTime.now();
        final localDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          localSetting.reminderTime.hour,
          localSetting.reminderTime.minute,
        );
        final utcDateTime = localDateTime.toUtc();
        final utcReminderTime =
            '${utcDateTime.hour.toString().padLeft(2, '0')}:${utcDateTime.minute.toString().padLeft(2, '0')}';

        final data = {
          'user_id': localSetting.userId,
          'language': localSetting.language.name,
          'currency': localSetting.currency.name,
          'theme_mode': localSetting.themeMode.name,
          'notifications_enabled': localSetting.notificationsEnabled,
          'reminder_time': utcReminderTime,
          'sync_settings': localSetting.syncSettings,
          'utilization_alert_threshold': localSetting.utilizationAlertThreshold,
          'created_at': localSetting.createdAt.toIso8601String(),
          'updated_at': localSetting.updatedAt.toIso8601String(),
        };
        await supabase.from('settings').upsert(data);
        final updatedSetting = localSetting.copyWith(syncPending: false);
        await settingsBox.put(defaultSettingId, updatedSetting);
      }
    } catch (e) {
      print('Sync error: $e');
      rethrow;
    }
  }

  Future<void> initialSync(String userId) async {
    if (userId == 'demo-user') {
      try {
        await bankBox.clear();
        await cardBox.clear();
        await paymentBox.clear();
        await deleteQueueBox.clear();

        // Update settings with correct userId so isInitialized becomes true
        if (settingsBox.isNotEmpty) {
          final currentSettings = settingsBox.values.first;
          final newSettings = currentSettings.copyWith(
            userId: userId,
            syncPending: false,
          );
          await settingsBox.put(defaultSettingId, newSettings);
        }

        // Fetch default banks if online, otherwise seed mocks
        bool fetchedBanks = false;
        if (await isOnline()) {
          try {
            final defaultBanksData =
                await supabase.from('default_banks').select();
            if (defaultBanksData.isNotEmpty) {
              for (var data in defaultBanksData) {
                final bank = BankModel(
                  id: data['id'],
                  userId: '',
                  name: data['name'],
                  code: data['code'],
                  logoPath: data['logo_path'],
                  supportNumber: data['support_number'],
                  website: data['website'],
                  isFavorite: data['is_favorite'] ?? false,
                  colorHex: data['color_hex'],
                  priority: data['priority'],
                  createdAt: DateTime.parse(data['created_at']),
                  updatedAt: DateTime.parse(data['updated_at']),
                  syncPending: false,
                  isDefault: true,
                );
                await bankBox.put(bank.id, bank);
              }
              fetchedBanks = true;
            } else {
              print('default_banks is empty (possibly due to RLS), falling back to mock banks');
            }
          } catch (e) {
            print(
              'Could not fetch public default_banks from Supabase in demo mode, falling back to local mocks: $e',
            );
          }
        }

        if (!fetchedBanks) {
          final mockBanks = [
            {
              'id': '66fd4a8d-6dcd-482b-baea-26f1d6ab4b97',
              'name': 'HDFC Bank',
              'code': 'HDFC',
              'logo_path': 'assets/bank_icons/HDFC.svg',
              'support_number': '1800 202 6161',
              'website': 'https://www.hdfcbank.com',
              'color_hex': 'FF0066B2',
              'priority': 1,
            },
            {
              'id': '127e2473-92dd-4ea3-9322-37dc2199781c',
              'name': 'ICICI Bank',
              'code': 'ICICI',
              'logo_path': 'assets/bank_icons/ICICI.svg',
              'support_number': '1800 1080',
              'website': 'https://www.icicibank.com',
              'color_hex': 'FFFF7E00',
              'priority': 2,
            },
            {
              'id': 'fddafe1f-9315-46cf-9785-16abe47d5e52',
              'name': 'SBI Card',
              'code': 'SBI',
              'logo_path': 'assets/bank_icons/SBI.svg',
              'support_number': '1800 1234',
              'website': 'https://www.onlinesbi.com',
              'color_hex': 'FF1F5D36',
              'priority': 3,
            },
          ];
          for (var data in mockBanks) {
            final bank = BankModel(
              id: data['id'] as String,
              userId: '',
              name: data['name'] as String,
              code: data['code'] as String,
              logoPath: data['logo_path'] as String,
              supportNumber: data['support_number'] as String,
              website: data['website'] as String,
              isFavorite: false,
              colorHex: data['color_hex'] as String,
              priority: data['priority'] as int,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              syncPending: false,
              isDefault: true,
            );
            await bankBox.put(bank.id, bank);
          }
        }

        // Seed Credit Cards
        final now = DateTime.now();

        // Card 1: HDFC Millennia
        final card1BillingDate = DateTime(now.year, now.month, 10);
        final card1DueDate = card1BillingDate.add(const Duration(days: 20));
        final hdfcCardId = const Uuid().v4();
        final card1 = CreditCardModel(
          id: hdfcCardId,
          userId: userId,
          name: 'Millennia',
          bankId: '66fd4a8d-6dcd-482b-baea-26f1d6ab4b97',
          last4Digits: '4321',
          billingDate: card1BillingDate,
          dueDate: card1DueDate,
          cardType: CardType.Visa,
          creditLimit: 150000.0,
          currentUtilization: 12500.0,
          isFavorite: true,
          syncPending: false,
        );
        await cardBox.put(card1.id, card1);

        // Card 2: SBI SimplyClick
        final card2BillingDate = DateTime(now.year, now.month, 15);
        final card2DueDate = card2BillingDate.add(const Duration(days: 20));
        final sbiCardId = const Uuid().v4();
        final card2 = CreditCardModel(
          id: sbiCardId,
          userId: userId,
          name: 'SimplyClick',
          bankId: 'fddafe1f-9315-46cf-9785-16abe47d5e52',
          last4Digits: '9876',
          billingDate: card2BillingDate,
          dueDate: card2DueDate,
          cardType: CardType.MasterCard,
          creditLimit: 100000.0,
          currentUtilization: 8400.0,
          isFavorite: false,
          syncPending: false,
        );
        await cardBox.put(card2.id, card2);

        // Card 3: ICICI Amazon Pay
        final card3BillingDate = DateTime(now.year, now.month, 20);
        final card3DueDate = card3BillingDate.add(const Duration(days: 20));
        final iciciCardId = const Uuid().v4();
        final card3 = CreditCardModel(
          id: iciciCardId,
          userId: userId,
          name: 'Amazon Pay',
          bankId: '127e2473-92dd-4ea3-9322-37dc2199781c',
          last4Digits: '5544',
          billingDate: card3BillingDate,
          dueDate: card3DueDate,
          cardType: CardType.Visa,
          creditLimit: 250000.0,
          currentUtilization: 0.0,
          isFavorite: false,
          syncPending: false,
        );
        await cardBox.put(card3.id, card3);

        // Seed Payments
        // Millennia Payment History (past 6 months)
        for (int i = 5; i >= 0; i--) {
          final billDate = DateTime(now.year, now.month - i, 10);
          final dueDate = billDate.add(const Duration(days: 20));
          final isCurrentMonth = (i == 0);
          final dueAmt = isCurrentMonth ? 12500.0 : (10000.0 + (i * 2500.0));

          final payment = PaymentModel(
            id: const Uuid().v4(),
            userId: userId,
            cardId: card1.id,
            dueAmount: isCurrentMonth ? dueAmt : 0.0,
            statementAmount: dueAmt,
            paidAmount: isCurrentMonth ? 0.0 : dueAmt,
            minimumDueAmount: dueAmt * 0.05,
            isPaid: !isCurrentMonth,
            paymentDate:
                isCurrentMonth ? null : billDate.add(const Duration(days: 15)),
            dueDate: dueDate,
            syncPending: false,
          );
          await paymentBox.put(payment.id, payment);
        }

        // SBI SimplyClick Payment History (past 6 months)
        for (int i = 5; i >= 0; i--) {
          final billDate = DateTime(now.year, now.month - i, 15);
          final dueDate = billDate.add(const Duration(days: 20));
          final isCurrentMonth = (i == 0);
          final dueAmt = isCurrentMonth ? 8400.0 : (6000.0 + (i * 1200.0));

          final payment = PaymentModel(
            id: const Uuid().v4(),
            userId: userId,
            cardId: card2.id,
            dueAmount: isCurrentMonth ? dueAmt : 0.0,
            statementAmount: dueAmt,
            paidAmount: isCurrentMonth ? 0.0 : dueAmt,
            minimumDueAmount: dueAmt * 0.05,
            isPaid: !isCurrentMonth,
            paymentDate:
                isCurrentMonth ? null : billDate.add(const Duration(days: 15)),
            dueDate: dueDate,
            syncPending: false,
          );
          await paymentBox.put(payment.id, payment);
        }

        // ICICI Amazon Pay Payment History (past 6 months)
        for (int i = 5; i >= 0; i--) {
          final billDate = DateTime(now.year, now.month - i, 20);
          final dueDate = billDate.add(const Duration(days: 20));
          final dueAmt = 15000.0 + (i * 3000.0);

          final payment = PaymentModel(
            id: const Uuid().v4(),
            userId: userId,
            cardId: card3.id,
            dueAmount: 0.0,
            statementAmount: dueAmt,
            paidAmount: dueAmt,
            minimumDueAmount: dueAmt * 0.05,
            isPaid: true,
            paymentDate: billDate.add(const Duration(days: 12)),
            dueDate: dueDate,
            syncPending: false,
          );
          await paymentBox.put(payment.id, payment);
        }

        // Seed Credit Card Summaries
        /*
        await cardSummaryBox.clear();
        await cardSummaryBox.put('summary-hdfc', CreditCardSummaryModel(
          id: 'summary-hdfc',
          cardId: card1.id,
          markdownSummary: '### HDFC Millennia Card Summary\n'
              '- **Cashback**: 5% on Amazon, Flipkart, Myntra, Swiggy, Zomato.\n'
              '- **Other Spends**: 1% cashback on all other online/offline spends.\n'
              '- **Lounge Access**: 4 complimentary domestic lounge visits per calendar year.\n'
              '- **Fee Waiver**: Annual fee waived on spending ₹1,00,000 in a year.',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          status: 1,
          userLiked: false,
        ));
        await cardSummaryBox.put('summary-sbi', CreditCardSummaryModel(
          id: 'summary-sbi',
          cardId: card2.id,
          markdownSummary: '### SBI SimplyClick Card Summary\n'
              '- **Rewards**: 10X Reward Points on online partners (Apollo, Cleartrip, EazyDiner, Lenskart, Netmeds).\n'
              '- **Other Online Spends**: 5X Reward Points on all other online spends.\n'
              '- **Welcome Gift**: Amazon Gift Voucher worth ₹500.\n'
              '- **Milestone Benefit**: Cleartrip e-voucher worth ₹2,000 on annual online spends of ₹1,00,000.',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          status: 1,
          userLiked: false,
        ));
        await cardSummaryBox.put('summary-icici', CreditCardSummaryModel(
          id: 'summary-icici',
          cardId: card3.id,
          markdownSummary: '### ICICI Amazon Pay Card Summary\n'
              '- **Amazon Spends**: 5% reward points for Amazon Prime members (3% for non-prime).\n'
              '- **Partner Spends**: 2% reward points on flights, bill payments, and recharge via Amazon.\n'
              '- **Other Spends**: 1% reward points on all other online/offline payments.\n'
              '- **Pricing**: Lifetime free card with no joining or annual fees.',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          status: 1,
          userLiked: false,
        ));
        */
      } catch (e) {
        print('Initial demo sync error: $e');
        rethrow;
      }
      return;
    }

    if (!await isOnline()) {
      print('Offline: Skipping initial sync');
      return;
    }

    try {
      await bankBox.clear();
      await cardBox.clear();
      await paymentBox.clear();
      await deleteQueueBox.clear();

      // Update settings with correct userId so isInitialized becomes true
      if (settingsBox.isNotEmpty) {
        final currentSettings = settingsBox.values.first;
        if (currentSettings.isDefaultSetting) {
          final newSettings = currentSettings.copyWith(
            userId: userId,
            syncPending: true,
          );
          await settingsBox.put(defaultSettingId, newSettings);
        }
      }

      // Fetch default banks
      final defaultBanksData = await supabase.from('default_banks').select();
      for (var data in defaultBanksData) {
        final bank = BankModel(
          id: data['id'],
          userId: '',
          name: data['name'],
          code: data['code'],
          logoPath: data['logo_path'],
          supportNumber: data['support_number'],
          website: data['website'],
          isFavorite: data['is_favorite'] ?? false,
          colorHex: data['color_hex'],
          priority: data['priority'],
          createdAt: DateTime.parse(data['created_at']),
          updatedAt: DateTime.parse(data['updated_at']),
          syncPending: false,
          isDefault: true,
        );
        await bankBox.put(bank.id, bank);
      }
      await syncData();
    } catch (e) {
      print('Initial sync error: $e');
      rethrow;
    }
  }
}
