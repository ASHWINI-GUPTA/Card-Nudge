import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../data/hive/models/credit_card_model.dart';
import '../../data/hive/storage/credit_card_storage.dart';
import '../../services/notification_service.dart';

final creditCardBoxProvider = Provider<Box<CreditCardModel>>((ref) {
  return CreditCardStorage.getBox();
});

final creditCardListProvider =
    AsyncNotifierProvider<CreditCardNotifier, List<CreditCardModel>>(
      CreditCardNotifier.new,
    );

class CreditCardNotifier extends AsyncNotifier<List<CreditCardModel>> {
  Box<CreditCardModel> get _box => ref.read(creditCardBoxProvider);

  @override
  Future<List<CreditCardModel>> build() async {
    _box.listenable().addListener(_onBoxChange);
    return _box.values.toList();
  }

  Future<void> save(CreditCardModel card) async {
    state = const AsyncValue.loading();
    try {
      if (state.value!.any((c) => c.id == card.id && c.key != card.key)) {
        await _box.put(card.key, card);
        state = AsyncValue.data([
          ...state.value!.where((c) => c.key != card.key),
          card,
        ]);
      } else {
        await _box.add(card);
        state = AsyncValue.data([...state.value!, card]);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow; // Allow widgets to catch errors
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

  // Add a new card
  Future<void> add(CreditCardModel card) async {
    try {
      await _box.add(card);
      await _scheduleNotifications(card);
      _onBoxChange(); // Trigger state update
    } catch (e) {
      print('Error adding card: $e');
    }
  }

  // Update a card by key
  Future<void> updateByKey(int key, CreditCardModel card) async {
    try {
      final index = _box.values.toList().indexWhere((c) => c.key == key);
      if (index != -1) {
        await _box.putAt(index, card);
        await _scheduleNotifications(card);
        _onBoxChange();
      }
    } catch (e) {
      print('Error updating card: $e');
    }
  }

  // Delete a card by key
  Future<void> deleteByKey(int key) async {
    try {
      final index = _box.values.toList().indexWhere((card) => card.key == key);
      if (index != -1) {
        final card = _box.getAt(index);
        if (card != null) {
          await NotificationService.cancelNotifications(card.key);
        }
        await _box.deleteAt(index);
        _onBoxChange();
      }
    } catch (e) {
      print('Error deleting card: $e');
    }
  }

  // Clear all cards
  Future<void> clearCards() async {
    try {
      for (final card in _box.values) {
        await NotificationService.cancelNotifications(card.key);
      }
      await _box.clear();
      _onBoxChange();
    } catch (e) {
      print('Error clearing cards: $e');
    }
  }

  // Restore a card by key
  Future<void> restoreByKey(int key, CreditCardModel card) async {
    try {
      await _box.put(key, card);
      await _scheduleNotifications(card);
      _onBoxChange();
    } catch (e) {
      print('Error restoring card: $e');
    }
  }

  // Get sorted cards (use state directly)
  List<CreditCardModel> get sortedOnDueDate => state.value ?? [];

  // Get card by ID
  CreditCardModel? getById(String cardId) {
    try {
      return _box.values.firstWhere((card) => card.id == cardId);
    } catch (e) {
      print('Error getting card by ID: $e');
      return null;
    }
  }
}
