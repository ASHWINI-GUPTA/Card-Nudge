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

enum SyncState { idle, switchingUser, syncing, ready, offline, error }

class SyncService {
  final SupabaseClient supabase;
  final Box<BankModel> bankBox;
  final Box<CreditCardModel> cardBox;
  final Box<CreditCardSummaryModel> cardSummaryBox;
  final Box<PaymentModel> paymentBox;
  final Box<SettingsModel> settingsBox;
  final Connectivity connectivity;
  final Box<DeleteQueueEntry> deleteQueueBox;

  static const String defaultSettingId = '00000000-0000-0000-0000-000000000000';

  SyncState _syncState = SyncState.idle;

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

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  SyncState get syncState => _syncState;

  bool get isSwitchingUser => _syncState == SyncState.switchingUser;

  bool get isSyncing => _syncState == SyncState.syncing;

  bool get isReady => _syncState == SyncState.ready;

  void _setState(SyncState state) {
    _syncState = state;
  }

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  bool isInitialized(String? currentUserId) {
    if (currentUserId == null) {
      return false;
    }

    if (settingsBox.isEmpty) {
      return false;
    }

    final localSettings = settingsBox.values.first;

    if (localSettings.isDefaultSetting) {
      return false;
    }

    if (localSettings.userId != currentUserId) {
      return false;
    }

    // Default banks are required by the application.
    final hasDefaultBanks = bankBox.values.any((bank) => bank.isDefault);

    if (!hasDefaultBanks) {
      return false;
    }

    return true;
  }

  Future<bool> isOnline() async {
    final connectivityResult = await connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // ---------------------------------------------------------------------------
  // Main sync
  // ---------------------------------------------------------------------------

  Future<void> syncData() async {
    if (!await isOnline()) {
      debugPrint('SyncService: Offline - skipping sync.');
      _setState(SyncState.offline);
      return;
    }

    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      debugPrint('SyncService: User not authenticated - skipping sync.');
      return;
    }

    _setState(SyncState.syncing);

    try {
      /*
       * IMPORTANT:
       *
       * Default banks are reference/master data.
       * They are NOT part of the user's `banks` table.
       *
       * Therefore they must always be synchronized separately.
       */
      await _syncDefaultBanks();

      /*
       * Process pending deletes before pulling server state.
       */
      await _processDeleteQueue();

      /*
       * User-owned data.
       */
      await _syncBanks(userId);
      await _syncCards(userId);
      await _syncPayments(userId);
      await _syncCardSummaries(userId);
      await _syncSettings(userId);

      _setState(SyncState.ready);

      debugPrint('SyncService: Sync completed successfully.');
    } catch (e, stackTrace) {
      debugPrint('SyncService: Sync error: $e');
      debugPrintStack(stackTrace: stackTrace);

      _setState(SyncState.error);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Initial sync
  // ---------------------------------------------------------------------------

  Future<void> initialSync(String userId) async {
    _setState(SyncState.switchingUser);

    try {
      // Always remove whatever user/demo data is currently
      // present before initializing the requested user.
      await _clearUserData();

      // Default banks are system/reference data.
      await _syncDefaultBanks();

      if (userId == 'demo-user') {
        await _seedDemoData(userId);
        _setState(SyncState.ready);
        return;
      }

      if (!await isOnline()) {
        _setState(SyncState.offline);
        return;
      }

      await _prepareSettingsForUser(userId);
      await syncData();

      _setState(SyncState.ready);
    } catch (e) {
      _setState(SyncState.error);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // User data cleanup
  // ---------------------------------------------------------------------------

  Future<void> _clearUserData() async {
    /*
     * DEFAULT BANKS MUST NEVER BE CLEARED.
     *
     * Only remove user-owned banks.
     */
    final userBanks =
        bankBox.values
            .where((bank) => !bank.isDefault)
            .map((bank) => bank.id)
            .toList();

    for (final id in userBanks) {
      await bankBox.delete(id);
    }

    /*
     * Cards
     */
    await cardBox.clear();

    /*
     * Payments
     */
    await paymentBox.clear();

    /*
     * Card summaries
     */
    await cardSummaryBox.clear();

    /*
     * IMPORTANT:
     *
     * Do NOT clear deleteQueueBox here.
     *
     * A pending deletion belongs to the previous user and should not
     * be silently destroyed.
     *
     * However, because we're changing users, stale delete operations
     * must not be executed against the new user's account.
     *
     * The safest approach is to clear the queue only after ensuring
     * that it has been successfully processed before account switching.
     *
     * Since initialSync performs account switching, discard stale
     * pending deletes here rather than allowing them to target the
     * new account.
     */
    await deleteQueueBox.clear();
  }

  // ---------------------------------------------------------------------------
  // Delete queue
  // ---------------------------------------------------------------------------

  Future<void> _processDeleteQueue() async {
    if (deleteQueueBox.isEmpty) {
      return;
    }

    debugPrint(
      'SyncService: Processing ${deleteQueueBox.length} pending deletes.',
    );

    final grouped = <Entities, List<String>>{};

    for (final entry in deleteQueueBox.values) {
      grouped.putIfAbsent(entry.entityType, () => []).add(entry.id);
    }

    final successfullyDeleted = <dynamic>[];

    for (final group in grouped.entries) {
      final entityType = group.key;
      final idsToDelete = group.value;

      if (idsToDelete.isEmpty) {
        continue;
      }

      try {
        await supabase
            .from(entityType.table)
            .delete()
            .inFilter('id', idsToDelete);

        debugPrint(
          'SyncService: Deleted ${idsToDelete.length} '
          'records from ${entityType.table}.',
        );

        successfullyDeleted.addAll(
          deleteQueueBox.values.where(
            (entry) =>
                entry.entityType == entityType &&
                idsToDelete.contains(entry.id),
          ),
        );
      } catch (e) {
        /*
         * Do NOT remove failed operations from the queue.
         *
         * They will be retried on the next sync.
         */
        debugPrint(
          'SyncService: Failed to process delete queue '
          'for ${entityType.table}: $e',
        );

        rethrow;
      }
    }

    for (final entry in successfullyDeleted) {
      await entry.delete();
    }
  }

  // ---------------------------------------------------------------------------
  // Default banks
  // ---------------------------------------------------------------------------

  Future<void> _syncDefaultBanks() async {
    bool fetchedFromServer = false;

    /*
     * First attempt to fetch the authoritative master list.
     */
    if (await isOnline()) {
      try {
        final defaultBanksData = await supabase.from('default_banks').select();

        if (defaultBanksData.isNotEmpty) {
          for (final data in defaultBanksData) {
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

          fetchedFromServer = true;

          debugPrint(
            'SyncService: Loaded ${defaultBanksData.length} '
            'default banks from server.',
          );
        } else {
          debugPrint(
            'SyncService: default_banks table is empty. '
            'Using local fallback.',
          );
        }
      } catch (e) {
        debugPrint('SyncService: Could not fetch default banks: $e');
      }
    }

    /*
     * Local fallback.
     *
     * This guarantees that the application always has the
     * required default banks.
     */
    if (!fetchedFromServer) {
      await _seedLocalDefaultBanks();
    }

    /*
     * Final invariant check.
     */
    final hasDefaultBanks = bankBox.values.any((bank) => bank.isDefault);

    if (!hasDefaultBanks) {
      throw StateError('SyncService: No default banks are available.');
    }
  }

  Future<void> _seedLocalDefaultBanks() async {
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

    for (final data in mockBanks) {
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
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        syncPending: false,
        isDefault: true,
      );

      await bankBox.put(bank.id, bank);
    }

    debugPrint('SyncService: Loaded local fallback default banks.');
  }

  // ---------------------------------------------------------------------------
  // Banks
  // ---------------------------------------------------------------------------

  Future<void> _syncBanks(String userId) async {
    final serverBanks = await supabase
        .from('banks')
        .select()
        .eq('user_id', userId);

    /*
     * Pull server banks into Hive.
     */
    for (final serverBank in serverBanks) {
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

    /*
     * Delete local user banks that no longer exist on server.
     *
     * NEVER delete default banks.
     */
    final serverBankIds = serverBanks.map((bank) => bank['id']).toSet();

    final localBanksToDelete =
        bankBox.values
            .where(
              (bank) =>
                  !bank.isDefault &&
                  !bank.syncPending &&
                  bank.userId == userId &&
                  !serverBankIds.contains(bank.id),
            )
            .map((bank) => bank.id)
            .toList();

    for (final id in localBanksToDelete) {
      await bankBox.delete(id);
    }

    /*
     * Push local changes.
     */
    final pendingBanks =
        bankBox.values
            .where(
              (bank) =>
                  !bank.isDefault && bank.userId == userId && bank.syncPending,
            )
            .toList();

    for (final localBank in pendingBanks) {
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
        'created_at': localBank.createdAt.toUtc().toIso8601String(),
        'updated_at': localBank.updatedAt.toUtc().toIso8601String(),
      };

      await supabase.from('banks').upsert(data);

      await bankBox.put(localBank.id, localBank.copyWith(syncPending: false));
    }
  }

  // ---------------------------------------------------------------------------
  // Cards
  // ---------------------------------------------------------------------------

  Future<void> _syncCards(String userId) async {
    final serverCards = await supabase
        .from('cards')
        .select()
        .eq('user_id', userId);

    /*
     * Pull server cards.
     */
    for (final serverCard in serverCards) {
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

    /*
     * Delete local cards missing from server.
     */
    final serverCardIds = serverCards.map((card) => card['id']).toSet();

    final localCardsToDelete =
        cardBox.values
            .where(
              (card) =>
                  !card.syncPending &&
                  card.userId == userId &&
                  !serverCardIds.contains(card.id),
            )
            .map((card) => card.id)
            .toList();

    for (final id in localCardsToDelete) {
      await cardBox.delete(id);
    }

    /*
     * Push pending cards.
     */
    final pendingCards =
        cardBox.values
            .where((card) => card.userId == userId && card.syncPending)
            .toList();

    for (final localCard in pendingCards) {
      final data = {
        'id': localCard.id,
        'user_id': localCard.userId,
        'name': localCard.name,
        'bank_id': localCard.bankId,
        'last_4_digits': localCard.last4Digits,
        'billing_date': localCard.billingDate.toUtc().toIso8601String(),
        'due_date': localCard.dueDate.toUtc().toIso8601String(),
        'card_type': localCard.cardType.name,
        'credit_limit': localCard.creditLimit,
        'current_utilization': localCard.currentUtilization,
        'created_at': localCard.createdAt.toUtc().toIso8601String(),
        'updated_at': localCard.updatedAt.toUtc().toIso8601String(),
        'is_archived': localCard.isArchived,
        'is_favorite': localCard.isFavorite,
        'is_auto_debit_enabled': localCard.isAutoDebitEnabled,
        'due_grace_period_days': localCard.dueGracePeriodDays,
      };

      await supabase.from('cards').upsert(data);

      await cardBox.put(localCard.id, localCard.copyWith(syncPending: false));
    }
  }

  // ---------------------------------------------------------------------------
  // Payments
  // ---------------------------------------------------------------------------

  Future<void> _syncPayments(String userId) async {
    final serverPayments = await supabase
        .from('payments')
        .select()
        .eq('user_id', userId);

    /*
     * Pull server payments.
     */
    for (final serverPayment in serverPayments) {
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

    /*
     * Delete local payments missing from server.
     */
    final serverPaymentIds =
        serverPayments.map((payment) => payment['id']).toSet();

    final localPaymentsToDelete =
        paymentBox.values
            .where(
              (payment) =>
                  !payment.syncPending &&
                  payment.userId == userId &&
                  !serverPaymentIds.contains(payment.id),
            )
            .map((payment) => payment.id)
            .toList();

    for (final id in localPaymentsToDelete) {
      await paymentBox.delete(id);
    }

    /*
     * Push pending payments.
     */
    final pendingPayments =
        paymentBox.values
            .where((payment) => payment.userId == userId && payment.syncPending)
            .toList();

    for (final localPayment in pendingPayments) {
      final data = {
        'id': localPayment.id,
        'user_id': localPayment.userId,
        'card_id': localPayment.cardId,
        'due_amount': localPayment.dueAmount,
        'payment_date': localPayment.paymentDate?.toUtc().toIso8601String(),
        'is_paid': localPayment.isPaid,
        'created_at': localPayment.createdAt.toUtc().toIso8601String(),
        'updated_at': localPayment.updatedAt.toUtc().toIso8601String(),
        'minimum_due_amount': localPayment.minimumDueAmount,
        'paid_amount': localPayment.paidAmount,
        'due_date': localPayment.dueDate.toUtc().toIso8601String(),
        'statement_amount': localPayment.statementAmount,
      };

      await supabase.from('payments').upsert(data);

      await paymentBox.put(
        localPayment.id,
        localPayment.copyWith(syncPending: false),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Card summaries
  // ---------------------------------------------------------------------------

  Future<void> _syncCardSummaries(String userId) async {
    /*
     * We don't need to use userId directly here because summaries are
     * associated with the user's cards.
     */
    final serverCards = await supabase
        .from('cards')
        .select('id')
        .eq('user_id', userId);

    final cardIds =
        serverCards.map((card) => card['id']).whereType<String>().toList();

    /*
     * IMPORTANT:
     *
     * Don't issue an IN query with an empty list.
     */
    final List<dynamic> serverCardSummaries;

    if (cardIds.isEmpty) {
      serverCardSummaries = [];
    } else {
      serverCardSummaries = await supabase
          .from('credit_card_summaries')
          .select()
          .inFilter('card_id', cardIds);
    }

    /*
     * Delete local summaries that no longer exist.
     */
    final serverSummaryIds =
        serverCardSummaries.map((summary) => summary['id']).toSet();

    final localSummariesToDelete =
        cardSummaryBox.values
            .where((summary) => !serverSummaryIds.contains(summary.id))
            .map((summary) => summary.id)
            .toList();

    for (final id in localSummariesToDelete) {
      await cardSummaryBox.delete(id);
    }

    /*
     * Pull summaries.
     */
    for (final serverCardSummary in serverCardSummaries) {
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
  }

  // ---------------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------------

  Future<void> _prepareSettingsForUser(String userId) async {
    if (settingsBox.isEmpty) {
      return;
    }

    final currentSettings = settingsBox.values.first;

    /*
     * If these settings already belong to the user,
     * nothing needs to be done.
     */
    if (!currentSettings.isDefaultSetting && currentSettings.userId == userId) {
      return;
    }

    /*
     * IMPORTANT:
     *
     * Do NOT set syncPending=true here.
     *
     * We are changing local ownership, not modifying settings.
     *
     * If the server has settings, _syncSettings() will replace
     * these with server values.
     *
     * If the server doesn't have settings, we will use this
     * local configuration and create it on the server.
     */
    final newSettings = currentSettings.copyWith(
      userId: userId,
      syncPending: false,
    );

    await settingsBox.put(defaultSettingId, newSettings);
  }

  Future<void> _syncSettings(String userId) async {
    final serverSettings = await supabase
        .from('settings')
        .select()
        .eq('user_id', userId);

    SettingsModel? localSetting;

    if (settingsBox.isNotEmpty) {
      localSetting = settingsBox.values.first;
    }

    /*
     * Server has settings.
     */
    if (serverSettings.isNotEmpty) {
      final serverSetting = serverSettings.first;

      final serverUpdatedAt = DateTime.parse(serverSetting['updated_at']);

      /*
       * If local settings don't belong to this user,
       * server must win.
       */
      final shouldPullServer =
          localSetting == null ||
          localSetting.isDefaultSetting ||
          localSetting.userId != userId ||
          serverUpdatedAt.isAfter(localSetting.updatedAt);

      if (shouldPullServer) {
        final timeArray = serverSetting['reminder_time'].toString().split(':');

        /*
         * Server stores reminder time as UTC.
         */
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
          notificationsEnabled: serverSetting['notifications_enabled'] ?? true,
          reminderTime: reminderTime,
          syncSettings: serverSetting['sync_settings'] ?? true,
          createdAt: DateTime.parse(serverSetting['created_at']),
          updatedAt: serverUpdatedAt,
          syncPending: false,
          utilizationAlertThreshold:
              serverSetting['utilization_alert_threshold'] ?? 30,
        );

        await settingsBox.put(defaultSettingId, setting);

        return;
      }
    }

    /*
     * No server settings exist.
     *
     * If local settings exist and belong to this user,
     * upload them.
     */
    localSetting = settingsBox.isNotEmpty ? settingsBox.values.first : null;

    if (localSetting == null) {
      debugPrint('SyncService: No local settings available for $userId.');

      return;
    }

    if (localSetting.userId != userId) {
      return;
    }

    if (localSetting.syncPending) {
      await _pushSettings(localSetting);
    }
  }

  Future<void> _pushSettings(SettingsModel localSetting) async {
    final now = DateTime.now();

    /*
     * Convert local reminder time to UTC.
     */
    final localDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      localSetting.reminderTime.hour,
      localSetting.reminderTime.minute,
    );

    final utcDateTime = localDateTime.toUtc();

    final utcReminderTime =
        '${utcDateTime.hour.toString().padLeft(2, '0')}:'
        '${utcDateTime.minute.toString().padLeft(2, '0')}';

    final data = {
      'user_id': localSetting.userId,
      'language': localSetting.language.name,
      'currency': localSetting.currency.name,
      'theme_mode': localSetting.themeMode.name,
      'notifications_enabled': localSetting.notificationsEnabled,
      'reminder_time': utcReminderTime,
      'sync_settings': localSetting.syncSettings,
      'utilization_alert_threshold': localSetting.utilizationAlertThreshold,
      'created_at': localSetting.createdAt.toUtc().toIso8601String(),
      'updated_at': localSetting.updatedAt.toUtc().toIso8601String(),
    };

    await supabase.from('settings').upsert(data);

    final updatedSetting = localSetting.copyWith(syncPending: false);

    await settingsBox.put(defaultSettingId, updatedSetting);
  }

  // ---------------------------------------------------------------------------
  // Demo data
  // ---------------------------------------------------------------------------

  Future<void> _seedDemoData(String userId) async {
    final now = DateTime.now();

    /*
     * -------------------------------------------------------------------------
     * Card 1: HDFC Millennia
     * -------------------------------------------------------------------------
     */
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

    /*
     * -------------------------------------------------------------------------
     * Card 2: SBI SimplyClick
     * -------------------------------------------------------------------------
     */
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

    /*
     * -------------------------------------------------------------------------
     * Card 3: ICICI Amazon Pay
     * -------------------------------------------------------------------------
     */
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

    /*
     * -------------------------------------------------------------------------
     * HDFC Payment History
     * -------------------------------------------------------------------------
     */
    for (int i = 5; i >= 0; i--) {
      final billDate = DateTime(now.year, now.month - i, 10);

      final dueDate = billDate.add(const Duration(days: 20));

      final isCurrentMonth = i == 0;

      final dueAmount = isCurrentMonth ? 12500.0 : 10000.0 + (i * 2500.0);

      final payment = PaymentModel(
        id: const Uuid().v4(),
        userId: userId,
        cardId: card1.id,
        dueAmount: isCurrentMonth ? dueAmount : 0.0,
        statementAmount: dueAmount,
        paidAmount: isCurrentMonth ? 0.0 : dueAmount,
        minimumDueAmount: dueAmount * 0.05,
        isPaid: !isCurrentMonth,
        paymentDate:
            isCurrentMonth ? null : billDate.add(const Duration(days: 15)),
        dueDate: dueDate,
        syncPending: false,
      );

      await paymentBox.put(payment.id, payment);
    }

    /*
     * -------------------------------------------------------------------------
     * SBI Payment History
     * -------------------------------------------------------------------------
     */
    for (int i = 5; i >= 0; i--) {
      final billDate = DateTime(now.year, now.month - i, 15);

      final dueDate = billDate.add(const Duration(days: 20));

      final isCurrentMonth = i == 0;

      final dueAmount = isCurrentMonth ? 8400.0 : 6000.0 + (i * 1200.0);

      final payment = PaymentModel(
        id: const Uuid().v4(),
        userId: userId,
        cardId: card2.id,
        dueAmount: isCurrentMonth ? dueAmount : 0.0,
        statementAmount: dueAmount,
        paidAmount: isCurrentMonth ? 0.0 : dueAmount,
        minimumDueAmount: dueAmount * 0.05,
        isPaid: !isCurrentMonth,
        paymentDate:
            isCurrentMonth ? null : billDate.add(const Duration(days: 15)),
        dueDate: dueDate,
        syncPending: false,
      );

      await paymentBox.put(payment.id, payment);
    }

    /*
     * -------------------------------------------------------------------------
     * ICICI Payment History
     * -------------------------------------------------------------------------
     */
    for (int i = 5; i >= 0; i--) {
      final billDate = DateTime(now.year, now.month - i, 20);

      final dueDate = billDate.add(const Duration(days: 20));

      final dueAmount = 15000.0 + (i * 3000.0);

      final payment = PaymentModel(
        id: const Uuid().v4(),
        userId: userId,
        cardId: card3.id,
        dueAmount: 0.0,
        statementAmount: dueAmount,
        paidAmount: dueAmount,
        minimumDueAmount: dueAmount * 0.05,
        isPaid: true,
        paymentDate: billDate.add(const Duration(days: 12)),
        dueDate: dueDate,
        syncPending: false,
      );

      await paymentBox.put(payment.id, payment);
    }

    /*
     * Demo card summaries are intentionally disabled.
     *
     * They can be enabled later if the application wants to
     * demonstrate the AI-generated card summaries.
     */
  }
}
