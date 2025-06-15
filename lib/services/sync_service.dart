// sync_service.dart
import 'dart:async';
import 'package:card_nudge/data/enums/currency.dart';
import 'package:card_nudge/data/enums/language.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
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
        } else if (localBank.syncPending) {
          // Push local changes if they are newer
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
        } else if (localCard.syncPending) {
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
        } else if (localPayment.syncPending) {
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
          final reminderTime = TimeOfDay(
            hour: int.parse(timeArray[0]),
            minute: int.parse(timeArray[1]),
          );

          final setting = SettingsModel(
            id: serverSetting['id'],
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
          );
          await settingsBox.put(setting.id, setting);
        } else if (localSetting.syncPending) {
          await supabase.from('settings').upsert(localSetting);
          final updatedSetting = localSetting.copyWith(syncPending: false);
          await settingsBox.put(updatedSetting.id, updatedSetting);
        }
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

      // Fetch settings
      final settingsData = await supabase
          .from('settings')
          .select()
          .eq('user_id', userId);
      if (settingsData.isEmpty) {
        final setting = settingsBox.values.first;
        await supabase.from('settings').upsert(setting);
      }
    } catch (e) {
      print('Initial sync error: $e');
      rethrow;
    }
  }

  void startConnectivityListener(WidgetRef ref) {
    connectivity.onConnectivityChanged.listen((connectivityResult) async {
      if (connectivityResult != ConnectivityResult.none) {
        print('Online: Triggering sync');
        ref.read(syncStatusProvider.notifier).state = SyncStatus.syncing;
        try {
          await syncData();
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
      if (await isOnline() && ref.context.mounted) {
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
