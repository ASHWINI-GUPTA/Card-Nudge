import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  SyncService({
    required this.supabase,
    required this.bankBox,
    required this.cardBox,
    required this.paymentBox,
    required this.settingsBox,
    required this.connectivity,
  });

  // Check connectivity status
  Future<bool> isOnline() async {
    final connectivityResult = await connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Initial sync on login/reinstall
  Future<void> initialSync(String userId) async {
    if (!await isOnline()) {
      print('Offline: Skipping initial sync');
      return;
    }

    try {
      // Clear local data for fresh sync.
      await bankBox.clear();
      await cardBox.clear();
      await paymentBox.clear();
      await settingsBox.clear();

      // Fetch banks
      final banksData = await supabase
          .from('banks')
          .select()
          .eq('user_id', userId);

      for (var data in banksData) {
        final bank = BankModel(
          id: data['id'],
          userId: userId,
          name: data['name'],
          code: data['code'],
          logoPath: data['logoPath'],
          supportNumber: data['supportNumber'],
          website: data['website'],
          isFavorite: data['isFavorite'] ?? false,
          colorHex: data['colorHex'],
          priority: data['priority'],
          createdAt: DateTime.parse(data['createdAt']),
          updatedAt: DateTime.parse(data['updatedAt']),
          syncPending: false, // Synced from Supabase
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
          bankId: data['bankId'],
          last4Digits: data['last4Digits'],
          billingDate: DateTime.parse(data['billingDate']),
          dueDate: DateTime.parse(data['dueDate']),
          cardType: data['cardType'],
          creditLimit: data['creditLimit']?.toDouble(),
          currentUtilization: data['currentUtilization']?.toDouble(),
          createdAt: DateTime.parse(data['createdAt']),
          updatedAt: DateTime.parse(data['updatedAt']),
          isArchived: data['isArchived'] ?? false,
          isFavorite: data['isFavorite'] ?? false,
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
          cardId: data['cardId'],
          dueAmount: data['dueAmount']?.toDouble(),
          paymentDate:
              data['paymentDate'] != null
                  ? DateTime.parse(data['paymentDate'])
                  : null,
          isPaid: data['isPaid'] ?? false,
          createdAt: DateTime.parse(data['createdAt']),
          updatedAt: DateTime.parse(data['updatedAt']),
          minimumDueAmount: data['minimumDueAmount']?.toDouble(),
          paidAmount: data['paidAmount']?.toDouble(),
          dueDate: DateTime.parse(data['dueDate']),
          statementAmount: data['statementAmount']?.toDouble(),
          syncPending: false,
        );
        await paymentBox.put(payment.id, payment);
      }

      // Fetch settings (if syncSettings is true)
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
            themeMode: data['themeMode'],
            notificationsEnabled: data['notificationsEnabled'] ?? true,
            reminderTime: data['reminderTime'],
            syncSettings: data['syncSettings'] ?? true,
            createdAt: DateTime.parse(data['createdAt']),
            updatedAt: DateTime.parse(data['updatedAt']),
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

  // Push local changes to Supabase
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
          'logoPath': bank.logoPath,
          'supportNumber': bank.supportNumber,
          'website': bank.website,
          'isFavorite': bank.isFavorite,
          'colorHex': bank.colorHex,
          'priority': bank.priority,
          'createdAt': bank.createdAt.toIso8601String(),
          'updatedAt': bank.updatedAt.toIso8601String(),
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
          'bankId': card.bankId,
          'last4Digits': card.last4Digits,
          'billingDate': card.billingDate?.toIso8601String(),
          'dueDate': card.dueDate?.toIso8601String(),
          'cardType': card.cardType,
          'creditLimit': card.creditLimit,
          'currentUtilization': card.currentUtilization,
          'createdAt': card.createdAt.toIso8601String(),
          'updatedAt': card.updatedAt.toIso8601String(),
          'isArchived': card.isArchived,
          'isFavorite': card.isFavorite,
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
          'cardId': payment.cardId,
          'dueAmount': payment.dueAmount,
          'paymentDate': payment.paymentDate?.toIso8601String(),
          'isPaid': payment.isPaid,
          'createdAt': payment.createdAt.toIso8601String(),
          'updatedAt': payment.updatedAt.toIso8601String(),
          'minimumDueAmount': payment.minimumDueAmount,
          'paidAmount': payment.paidAmount,
          'dueDate': payment.dueDate?.toIso8601String(),
          'statementAmount': payment.statementAmount,
        };
        await supabase.from('payments').upsert(data);
        final updatedPayment = payment.copyWith(syncPending: false);
        await paymentBox.put(updatedPayment.id, updatedPayment);
      }

      // Push settings (if syncSettings is true)
      final settings = settingsBox.values.firstOrNull;
      if (settings == null) {
        throw Exception('Settings not found or syncPending is false');
      }
      if (settings.syncSettings == true && settings.syncPending == true) {
        final data = {
          'id': settings.id,
          'user_id': settings.userId,
          'language': settings.language,
          'currency': settings.currency,
          'themeMode': settings.themeMode,
          'notificationsEnabled': settings.notificationsEnabled,
          'reminderTime': settings.reminderTime,
          'syncSettings': settings.syncSettings,
          'createdAt': settings.createdAt.toIso8601String(),
          'updatedAt': settings.updatedAt.toIso8601String(),
        };

        await supabase.from('settings').upsert(data);
        final updatedSettings = settings.copyWith(syncPending: false);
        await settingsBox.put(updatedSettings.id, updatedSettings);
      }
    } catch (e) {
      print('Push local changes error: $e');
      rethrow;
    }
  }

  // Listen for connectivity changes and trigger sync
  void startConnectivityListener(Ref ref) {
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
}
