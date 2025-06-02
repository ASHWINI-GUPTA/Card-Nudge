// sync_service.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/enums/card_type.dart';
import '../data/enums/sync_status.dart';
import '../data/hive/models/bank_model.dart';
import '../data/hive/models/credit_card_model.dart';
import '../data/hive/models/payment_model.dart';
import '../data/hive/models/settings_model.dart';
import '../presentation/providers/sync_provider.dart';

class SyncService {
  final SupabaseClient supabase;
  final Box<BankModel> bankBox;
  final Box<CreditCardModel> cardBox;
  final Box<PaymentModel> paymentBox;
  final Box<SettingsModel> settingsBox;
  final Connectivity connectivity;
  Timer? _pollingTimer;

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

  Future<void> initialSync(String userId) async {
    if (!await isOnline()) {
      print('Offline: Skipping initial sync');
      return;
    }

    try {
      await bankBox.clear();
      await cardBox.clear();
      await paymentBox.clear();
      await settingsBox.clear();

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

      // Fetch user banks
      final userBanksData = await supabase
          .from('banks')
          .select()
          .eq('user_id', userId);
      for (var data in userBanksData) {
        final bank = BankModel(
          id: data['id'],
          userId: userId,
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
          isDefault: false,
        );
        await bankBox.put(bank.id, bank);
      }

      // Fetch cards
      final cardsData = await supabase
          .from('cards')
          .select()
          .eq('user_id', userId);
      for (var data in cardsData) {
        final card = CreditCardModel(
          id: data['id'],
          userId: userId,
          name: data['name'],
          bankId: data['bank_id'],
          last4Digits: data['last_4_digits'],
          billingDate: DateTime.parse(data['billing_date']),
          dueDate: DateTime.parse(data['due_date']),
          cardType: CardType.values.firstWhere(
            (e) => e.name == data['card_type'],
          ),
          creditLimit: data['credit_limit']?.toDouble(),
          currentUtilization: data['current_utilization']?.toDouble(),
          createdAt: DateTime.parse(data['created_at']),
          updatedAt: DateTime.parse(data['updated_at']),
          isArchived: data['is_archived'] ?? false,
          isFavorite: data['is_favorite'] ?? false,
          syncPending: false,
        );
        await cardBox.put(card.id, card);
      }

      // Fetch payments
      final paymentsData = await supabase
          .from('payments')
          .select()
          .eq('user_id', userId);
      for (var data in paymentsData) {
        final payment = PaymentModel(
          id: data['id'],
          userId: userId,
          cardId: data['card_id'],
          dueAmount: data['due_amount']?.toDouble(),
          paymentDate:
              data['payment_date'] != null
                  ? DateTime.parse(data['payment_date'])
                  : null,
          isPaid: data['is_paid'] ?? false,
          createdAt: DateTime.parse(data['created_at']),
          updatedAt: DateTime.parse(data['updated_at']),
          minimumDueAmount: data['minimum_due_amount']?.toDouble(),
          paidAmount: data['paid_amount']?.toDouble(),
          dueDate: DateTime.parse(data['due_date']),
          statementAmount: data['statement_amount']?.toDouble(),
          syncPending: false,
        );
        await paymentBox.put(payment.id, payment);
      }

      // Fetch settings
      final settings = settingsBox.values.firstOrNull;
      final syncSettings = settings?.syncSettings ?? true;
      if (syncSettings) {
        final settingsData = await supabase
            .from('settings')
            .select()
            .eq('user_id', userId);
        if (settingsData.isNotEmpty) {
          final data = settingsData.first;
          final setting = SettingsModel(
            id: data['id'],
            userId: userId,
            language: data['language'],
            currency: data['currency'],
            themeMode: data['theme_mode'],
            notificationsEnabled: data['notifications_enabled'] ?? true,
            reminderTime: data['reminder_time'],
            syncSettings: data['sync_settings'] ?? true,
            createdAt: DateTime.parse(data['created_at']),
            updatedAt: DateTime.parse(data['updated_at']),
            syncPending: false,
          );
          await settingsBox.put(setting.id, setting);
        }
      }
    } catch (e) {
      print('Initial sync error: $e');
      rethrow;
    }
  }

  Future<void> pushLocalChanges() async {
    if (!await isOnline()) {
      print('Offline: Changes queued in Hive');
      return;
    }

    try {
      // Push banks
      for (var bank in bankBox.values.where((b) => b.syncPending)) {
        final data = {
          'id': bank.id,
          'user_id': bank.userId,
          'name': bank.name,
          'code': bank.code,
          'logo_path': bank.logoPath,
          'support_number': bank.supportNumber,
          'website': bank.website,
          'is_favorite': bank.isFavorite,
          'color_hex': bank.colorHex,
          'priority': bank.priority,
          'created_at': bank.createdAt.toIso8601String(),
          'updated_at': bank.updatedAt.toIso8601String(),
        };
        await supabase.from('banks').upsert(data);
        final updatedBank = bank.copyWith(syncPending: false);
        await bankBox.put(updatedBank.id, updatedBank);
      }

      // Push cards
      for (var card in cardBox.values.where((c) => c.syncPending)) {
        final data = {
          'id': card.id,
          'user_id': card.userId,
          'name': card.name,
          'bank_id': card.bankId,
          'last_4_digits': card.last4Digits,
          'billing_date': card.billingDate.toIso8601String(),
          'due_date': card.dueDate.toIso8601String(),
          'card_type': card.cardType.name,
          'credit_limit': card.creditLimit,
          'current_utilization': card.currentUtilization,
          'created_at': card.createdAt.toIso8601String(),
          'updated_at': card.updatedAt.toIso8601String(),
          'is_archived': card.isArchived,
          'is_favorite': card.isFavorite,
        };
        await supabase.from('cards').upsert(data);
        final updatedCard = card.copyWith(syncPending: false);
        await cardBox.put(updatedCard.id, updatedCard);
      }

      // Push payments
      for (var payment in paymentBox.values.where((p) => p.syncPending)) {
        final data = {
          'id': payment.id,
          'user_id': payment.userId,
          'card_id': payment.cardId,
          'due_amount': payment.dueAmount,
          'payment_date': payment.paymentDate?.toIso8601String(),
          'is_paid': payment.isPaid,
          'created_at': payment.createdAt.toIso8601String(),
          'updated_at': payment.updatedAt.toIso8601String(),
          'minimum_due_amount': payment.minimumDueAmount,
          'paid_amount': payment.paidAmount,
          'due_date': payment.dueDate.toIso8601String(),
          'statement_amount': payment.statementAmount,
        };
        await supabase.from('payments').upsert(data);
        final updatedPayment = payment.copyWith(syncPending: false);
        await paymentBox.put(updatedPayment.id, updatedPayment);
      }

      // Push settings
      // final settings = settingsBox.values.firstOrNull;
      // if (settings?.syncSettings == true && settings?.syncPending == true) {
      //   final data = {
      //     'id': settings.id,
      //     'user_id': settings.userId,
      //     'language': settings.language,
      //     'currency': settings.currency,
      //     'theme_mode': settings.themeMode,
      //     'notifications_enabled': settings.notificationsEnabled,
      //     'reminder_time': settings.reminderTime,
      //     'sync_settings': settings.syncSettings,
      //     'created_at': settings.createdAt.toIso8601String(),
      //     'updated_at': settings.updatedAt.toIso8601String(),
      //   };
      //   await supabase.from('settings').upsert(data);
      //   final updatedSettings = settings.copyWith(syncPending: false);
      //   await settingsBox.put(updatedSettings.id, updatedSettings);
      // }
    } catch (e) {
      print('Push local changes error: $e');
      rethrow;
    }
  }

  void startConnectivityListener(WidgetRef ref) {
    connectivity.onConnectivityChanged.listen((connectivityResult) async {
      if (connectivityResult != ConnectivityResult.none) {
        print('Online: Triggering sync');
        ref.read(syncStatusProvider.notifier).state = SyncStatus.syncing;
        try {
          await pushLocalChanges();
          ref.read(syncStatusProvider.notifier).state = SyncStatus.idle;
        } catch (e) {
          ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
        }
      }
    });
  }

  void startPolling(String userId, WidgetRef ref) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(Duration(seconds: 30), (timer) async {
      if (await isOnline()) {
        ref.read(syncStatusProvider.notifier).state = SyncStatus.polling;
        try {
          final banksData = await supabase
              .from('banks')
              .select()
              .eq('user_id', userId);
          await _handleRealtimeBanks(banksData, ref);

          final defaultBanksData =
              await supabase.from('default_banks').select();
          await _handleRealtimeDefaultBanks(defaultBanksData, ref);

          final cardsData = await supabase
              .from('cards')
              .select()
              .eq('user_id', userId);
          await _handleRealtimeCards(cardsData, ref);

          final paymentsData = await supabase
              .from('payments')
              .select()
              .eq('user_id', userId);
          await _handleRealtimePayments(paymentsData, ref);

          final settings = settingsBox.values.firstOrNull;
          if (settings?.syncSettings ?? true) {
            final settingsData = await supabase
                .from('settings')
                .select()
                .eq('user_id', userId);
            await _handleRealtimeSettings(settingsData, ref);
          }

          ref.read(syncStatusProvider.notifier).state = SyncStatus.idle;
        } catch (e) {
          print('Polling error: $e');
          ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
        }
      }
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
  }

  void startRealtimeSubscriptions(String userId, WidgetRef ref) {
    supabase
        .from('banks:user_id=eq.$userId')
        .stream(primaryKey: ['id'])
        .listen(
          (List<Map<String, dynamic>> data) async {
            await _handleRealtimeBanks(data, ref);
            ref.read(syncStatusProvider.notifier).state =
                SyncStatus.realtimeConnected;
          },
          onError: (e) {
            print('Banks Realtime error: $e');
            ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
          },
        );

    supabase
        .from('default_banks')
        .stream(primaryKey: ['id'])
        .listen(
          (List<Map<String, dynamic>> data) async {
            await _handleRealtimeDefaultBanks(data, ref);
            ref.read(syncStatusProvider.notifier).state =
                SyncStatus.realtimeConnected;
          },
          onError: (e) {
            print('Default Banks Realtime error: $e');
            ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
          },
        );

    supabase
        .from('cards:user_id=eq.$userId')
        .stream(primaryKey: ['id'])
        .listen(
          (List<Map<String, dynamic>> data) async {
            await _handleRealtimeCards(data, ref);
            ref.read(syncStatusProvider.notifier).state =
                SyncStatus.realtimeConnected;
          },
          onError: (e) {
            print('Cards Realtime error: $e');
            ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
          },
        );

    supabase
        .from('payments:user_id=eq.$userId')
        .stream(primaryKey: ['id'])
        .listen(
          (List<Map<String, dynamic>> data) async {
            await _handleRealtimePayments(data, ref);
            ref.read(syncStatusProvider.notifier).state =
                SyncStatus.realtimeConnected;
          },
          onError: (e) {
            print('Payments Realtime error: $e');
            ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
          },
        );

    final settings = settingsBox.values.firstOrNull;
    if (settings?.syncSettings ?? true) {
      supabase
          .from('settings:user_id=eq.$userId')
          .stream(primaryKey: ['id'])
          .listen(
            (List<Map<String, dynamic>> data) async {
              await _handleRealtimeSettings(data, ref);
              ref.read(syncStatusProvider.notifier).state =
                  SyncStatus.realtimeConnected;
            },
            onError: (e) {
              print('Settings Realtime error: $e');
              ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
            },
          );
    }
  }

  Future<void> _handleRealtimeBanks(
    List<Map<String, dynamic>> data,
    WidgetRef ref,
  ) async {
    for (var item in data) {
      final remote = BankModel(
        id: item['id'],
        userId: item['user_id'],
        name: item['name'],
        code: item['code'],
        logoPath: item['logo_path'],
        supportNumber: item['support_number'],
        website: item['website'],
        isFavorite: item['is_favorite'] ?? false,
        colorHex: item['color_hex'],
        priority: item['priority'],
        createdAt: DateTime.parse(item['created_at']),
        updatedAt: DateTime.parse(item['updated_at']),
        syncPending: false,
        isDefault: false,
      );
      final local = bankBox.get(remote.id);
      if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
        await bankBox.put(remote.id, remote);
      }
    }
  }

  Future<void> _handleRealtimeDefaultBanks(
    List<Map<String, dynamic>> data,
    WidgetRef ref,
  ) async {
    for (var item in data) {
      final remote = BankModel(
        id: item['id'],
        userId: '',
        name: item['name'],
        code: item['code'],
        logoPath: item['logo_path'],
        supportNumber: item['support_number'],
        website: item['website'],
        isFavorite: item['is_favorite'] ?? false,
        colorHex: item['color_hex'],
        priority: item['priority'],
        createdAt: DateTime.parse(item['created_at']),
        updatedAt: DateTime.parse(item['updated_at']),
        syncPending: false,
        isDefault: true,
      );
      final local = bankBox.get(remote.id);
      if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
        await bankBox.put(remote.id, remote);
      }
    }
  }

  Future<void> _handleRealtimeCards(
    List<Map<String, dynamic>> data,
    WidgetRef ref,
  ) async {
    for (var item in data) {
      final remote = CreditCardModel(
        id: item['id'],
        userId: item['user_id'],
        name: item['name'],
        bankId: item['bank_id'],
        last4Digits: item['last_4_digits'],
        billingDate: DateTime.parse(item['billing_date']),
        dueDate: DateTime.parse(item['due_date']),
        cardType: CardType.values.firstWhere(
          (e) => e.name == item['card_type'],
        ),
        creditLimit: item['credit_limit']?.toDouble(),
        currentUtilization: item['current_utilization']?.toDouble(),
        createdAt: DateTime.parse(item['created_at']),
        updatedAt: DateTime.parse(item['updated_at']),
        isArchived: item['is_archived'] ?? false,
        isFavorite: item['is_favorite'] ?? false,
        syncPending: false,
      );
      final local = cardBox.get(remote.id);
      if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
        await cardBox.put(remote.id, remote);
      }
    }
  }

  Future<void> _handleRealtimePayments(
    List<Map<String, dynamic>> data,
    WidgetRef ref,
  ) async {
    for (var item in data) {
      final remote = PaymentModel(
        id: item['id'],
        userId: item['user_id'],
        cardId: item['card_id'],
        dueAmount: item['due_amount']?.toDouble(),
        paymentDate:
            item['payment_date'] != null
                ? DateTime.parse(item['payment_date'])
                : null,
        isPaid: item['is_paid'] ?? false,
        createdAt: DateTime.parse(item['created_at']),
        updatedAt: DateTime.parse(item['updated_at']),
        minimumDueAmount: item['minimum_due_amount']?.toDouble(),
        paidAmount: item['paid_amount']?.toDouble(),
        dueDate: DateTime.parse(item['due_date']),
        statementAmount: item['statement_amount']?.toDouble(),
        syncPending: false,
      );
      final local = paymentBox.get(remote.id);
      if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
        await paymentBox.put(remote.id, remote);
      }
    }
  }

  Future<void> _handleRealtimeSettings(
    List<Map<String, dynamic>> data,
    WidgetRef ref,
  ) async {
    if (data.isNotEmpty) {
      final item = data.first;
      final remote = SettingsModel(
        id: item['id'],
        userId: item['user_id'],
        language: item['language'],
        currency: item['currency'],
        themeMode: item['theme_mode'],
        notificationsEnabled: item['notifications_enabled'] ?? true,
        reminderTime: item['reminder_time'],
        syncSettings: item['sync_settings'] ?? true,
        createdAt: DateTime.parse(item['created_at']),
        updatedAt: DateTime.parse(item['updated_at']),
        syncPending: false,
      );
      final local = settingsBox.get(remote.id);
      if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
        await settingsBox.put(remote.id, remote);
      }
    }
  }
}
