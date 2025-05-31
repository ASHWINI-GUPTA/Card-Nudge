import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../constants/app_strings.dart';
import '../../data/enums/sync_status.dart';
import '../../data/hive/models/credit_card_model.dart';
import '../../data/hive/storage/credit_card_storage.dart';
import '../../services/notification_service.dart';
import 'payment_provider.dart';
import 'sync_provider.dart';

final creditCardBoxProvider = Provider<Box<CreditCardModel>>((ref) {
  return CreditCardStorage.getBox();
});

final creditCardListProvider =
    AsyncNotifierProvider<CreditCardNotifier, List<CreditCardModel>>(
      CreditCardNotifier.new,
    );

class CreditCardNotifier extends AsyncNotifier<List<CreditCardModel>> {
  Box<CreditCardModel> get _box => ref.read(creditCardBoxProvider);

  Future<void> _triggerSync() async {
    final syncService = ref.read(syncServiceProvider);
    if (await syncService.isOnline()) {
      ref.read(syncStatusProvider.notifier).state = SyncStatus.syncing;
      try {
        await syncService.pushLocalChanges();
        ref.read(syncStatusProvider.notifier).state = SyncStatus.idle;
      } catch (e) {
        ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
        rethrow;
      }
    }
  }

  @override
  Future<List<CreditCardModel>> build() async {
    _box.listenable().addListener(_onBoxChange);
    return _box.values.where((card) => !card.isArchived).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  Future<void> save(CreditCardModel card) async {
    state = const AsyncValue.loading();
    bool cardSaved = false;
    try {
      await _box.put(card.id, card);
      await loadCards();
      await _triggerSync();
      cardSaved = true;
    } catch (e, stack) {
      if (cardSaved) {
        await _box.delete(card.id);
        await loadCards();
      }
      state = AsyncValue.error(e, stack);
      ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
      rethrow;
    }
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy');
    return formatter.format(date);
  }

  // Schedule notifications for a card
  Future<void> _scheduleNotifications(CreditCardModel card) async {
    final dueDate = card.dueDate;

    try {
      // Cancel existing notifications
      await NotificationService.cancelNotifications(card.key);

      // Schedule reminders 3 days before due date
      for (int i = 3; i > 0; i--) {
        await NotificationService.scheduleNotification(
          id: _generateNotificationId(card.key, i),
          title: '📅 Payment Reminder!',
          body:
              '💳 ${card.name} is due on ${_formatDate(dueDate)}. Don\'t miss it!',
          scheduledDate: dueDate.subtract(Duration(days: i)),
        );
      }

      // Notify on due date to prompt amount entry
      await NotificationService.scheduleNotification(
        id: _generateNotificationId(card.key, 0),
        title: '📝 Add Your Due Amount',
        body: '💳 How much do you owe on ${card.name}? Let\'s keep it updated!',
        scheduledDate: dueDate,
      );

      // Schedule limited overdue reminders (e.g., 7 days instead of 30)
      for (int i = 1; i <= 7; i++) {
        await NotificationService.scheduleNotification(
          id: _generateNotificationId(card.key, 100 + i),
          title: '⏰ Overdue Payment Reminder!',
          body:
              '💳 ${card.name} payment is overdue since ${_formatDate(dueDate)}. Please pay it as soon as possible!',
          scheduledDate: dueDate.add(Duration(days: i)),
        );
      }
    } catch (e) {
      // Handle notification scheduling errors (e.g., log error)
      print('Error scheduling notifications: $e');
    }
  }

  // Generate unique notification ID to avoid collisions
  int _generateNotificationId(int cardKey, int offset) {
    return (cardKey * 31 + offset).hashCode; // Simple but robust ID generation
  }

  // Load cards from Hive box asynchronously
  Future<void> loadCards() async {
    state = AsyncValue.data(_box.values.toList());
  }

  // Handle box changes for real-time updates
  void _onBoxChange() {
    final newCards =
        _box.values.toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    if (newCards != state) {
      state = AsyncValue.data(newCards);
    }
  }

  Future<void> add(CreditCardModel card) async {
    try {
      await _box.put(card.id, card);
      await _scheduleNotifications(card);
      _onBoxChange();
      await _triggerSync();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
      rethrow;
    }
  }

  Future<void> delete(String cardId) async {
    state = const AsyncValue.loading();
    try {
      if (!_box.containsKey(cardId)) {
        throw const FormatException(AppStrings.cardNotFoundError);
      }
      final card = _box.get(cardId)!;
      await _box.delete(cardId);
      // Delete associated payments
      final payments = ref.read(paymentProvider.notifier);
      final cardPayments = payments.getPaymentsForCard(card.id);
      for (var payment in cardPayments) {
        await ref.read(paymentBoxProvider).delete(payment.id);
      }
      state = AsyncValue.data(_box.values.toList());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
      rethrow;
    }
  }

  Future<void> clearCards() async {
    try {
      for (final card in _box.values) {
        await NotificationService.cancelNotifications(card.key);
      }
      await _box.clear();
      _onBoxChange();
      await _triggerSync();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
      rethrow;
    }
  }

  // Get sorted cards (use state directly)
  List<CreditCardModel> get sortedOnDueDate => state.value ?? [];

  markArchive(String cardId) {}

  reset() {
    state = const AsyncValue.loading();
    _box.listenable().removeListener(_onBoxChange);
    _box.clear();
    state = AsyncValue.data([]);
  }
}
