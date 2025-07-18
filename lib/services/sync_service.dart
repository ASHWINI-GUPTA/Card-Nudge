import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/enums/card_type.dart';
import '../data/enums/currency.dart';
import '../data/enums/language.dart';
import '../data/hive/models/bank_model.dart';
import '../data/hive/models/credit_card_model.dart';
import '../data/hive/models/payment_model.dart';
import '../data/hive/models/settings_model.dart';

class SyncService {
  final SupabaseClient supabase;
  final Box<BankModel> bankBox;
  final Box<CreditCardModel> cardBox;
  final Box<PaymentModel> paymentBox;
  final Box<SettingsModel> settingsBox;
  final Connectivity connectivity;
  final defaultSettingId = '00000000-0000-0000-0000-000000000000';

  SyncService({
    required this.supabase,
    required this.bankBox,
    required this.cardBox,
    required this.paymentBox,
    required this.settingsBox,
    required this.connectivity,
  });

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
      // Pull server changes
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
        };
        await supabase.from('cards').upsert(data);
        final updatedCard = localCard.copyWith(syncPending: false);
        await cardBox.put(updatedCard.id, updatedCard);
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
        if (serverUpdatedAt.isAfter(localSetting.updatedAt)) {
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
    if (!await isOnline()) {
      print('Offline: Skipping initial sync');
      return;
    }

    try {
      await bankBox.clear();
      await cardBox.clear();
      await paymentBox.clear();
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
