import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/hive/models/credit_card_model.dart';
import '../../data/hive/storage/credit_card_storage.dart';
import '../../notification_service.dart';

final creditCardListProvider =
    StateNotifierProvider<CreditCardNotifier, List<CreditCardModel>>(
      (ref) => CreditCardNotifier()..loadCards(),
    );

class CreditCardNotifier extends StateNotifier<List<CreditCardModel>> {
  CreditCardNotifier() : super([]);

  String _formatDate(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy');
    return formatter.format(date);
  }

  Future<void> _scheduleNotifications(CreditCardModel card) async {
    final dueDate = card.dueDate;

    // Cancel existing notifications for this card
    await NotificationService.cancelNotifications(card.key);

    // Start notifications 3 days before the due date
    for (int i = 3; i > 0; i--) {
      await NotificationService.scheduleNotification(
        id: card.key.hashCode ^ i,
        title: '📅 Payment Reminder!',
        body:
            '💳 ${card.name} is due on ${_formatDate(dueDate)}. Don\'t miss it!',
        scheduledDate: dueDate.subtract(Duration(days: i)),
      );
    }

    // Notify on due date to prompt user to enter amount
    await NotificationService.scheduleNotification(
      id: card.key.hashCode ^ 2,
      title: '📝 Add Your Due Amount',
      body: '💳 How much do you owe on ${card.name}? Let\'s keep it updated!',
      scheduledDate: dueDate,
    );

    // Notify every day after the due date until marked as paid
    for (int i = 1; i <= 30; i++) {
      await NotificationService.scheduleNotification(
        id: card.key.hashCode ^ (100 + i),
        title: '⏰ Overdue Payment Reminder!',
        body:
            '💳 ${card.name} payment is overdue since ${_formatDate(dueDate)}. Please pay it as soon as possible!',
        scheduledDate: dueDate.add(Duration(days: i)),
      );
    }
  }

  void loadCards() {
    final box = CreditCardStorage.getBox();
    state = box.values.toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  Future<void> add(CreditCardModel card) async {
    final box = CreditCardStorage.getBox();
    box.add(card);
    await _scheduleNotifications(card);
    loadCards(); // refresh list
  }

  Future<void> updateByKey(int key, CreditCardModel card) async {
    final box = CreditCardStorage.getBox();
    final index = box.values.toList().indexWhere((c) => c.key == key);
    if (index != -1) {
      box.putAt(index, card);
      await _scheduleNotifications(card);
      loadCards();
    }
  }

  Future<void> deleteByKey(int key) async {
    final box = CreditCardStorage.getBox();
    final index = box.values.toList().indexWhere((card) => card.key == key);
    if (index != -1) {
      final card = box.getAt(index);
      if (card != null) {
        await NotificationService.cancelNotifications(card.key);
      }
      box.deleteAt(index);
      loadCards();
    }
  }

  void clearCards() {
    final box = CreditCardStorage.getBox();
    for (final card in box.values) {
      NotificationService.cancelNotifications(card.key);
    }
    box.clear();
    loadCards();
  }

  Future<void> restoreByKey(int key, CreditCardModel card) async {
    final box = CreditCardStorage.getBox();
    box.put(key, card);
    await _scheduleNotifications(card);
    loadCards();
  }

  List<CreditCardModel> get sortedOnDueDate {
    if (state.isEmpty) {
      return [];
    }

    final sortedList = List<CreditCardModel>.from(state);
    sortedList.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return sortedList;
  }
}
