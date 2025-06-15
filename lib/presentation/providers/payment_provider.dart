import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/enums/sync_status.dart';
import '../../data/hive/models/payment_model.dart';
import '../../data/hive/storage/payment_storage.dart';
import '../../constants/app_strings.dart';
import 'credit_card_provider.dart';
import 'setting_provider.dart';
import 'sync_provider.dart';
import '../../services/notification_service.dart';

final paymentBoxProvider = Provider<Box<PaymentModel>>((ref) {
  return PaymentStorage.getBox();
});

final paymentProvider =
    AsyncNotifierProvider<PaymentNotifier, List<PaymentModel>>(
      PaymentNotifier.new,
    );

class PaymentNotifier extends AsyncNotifier<List<PaymentModel>> {
  Box<PaymentModel> get _box => ref.read(paymentBoxProvider);

  Future<void> _triggerSync() async {
    final syncService = ref.read(syncServiceProvider);
    if (await syncService.isOnline()) {
      ref.read(syncStatusProvider.notifier).state = SyncStatus.syncing;
      try {
        await syncService.syncData();
        ref.read(syncStatusProvider.notifier).state = SyncStatus.idle;
      } catch (e) {
        ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
        rethrow;
      }
    }
  }

  @override
  Future<List<PaymentModel>> build() async {
    // Listen to box changes for real-time updates
    _box.listenable().addListener(_onBoxChange);
    return _box.values.toList();
  }

  void _onBoxChange() {
    // Update state only if data has changed to avoid infinite loops
    final newPayments = _box.values.toList();
    if (state.valueOrNull != newPayments) {
      state = AsyncValue.data(newPayments);
    }
  }

  Future<void> save(PaymentModel payment) async {
    state = const AsyncValue.loading();
    bool paymentSaved = false;
    try {
      // Validate payment
      if (payment.dueAmount < 0) {
        throw const FormatException(AppStrings.invalidAmountError);
      }
      if (payment.cardId.isEmpty) {
        throw const FormatException(AppStrings.validationRequired);
      }
      if (payment.minimumDueAmount != null &&
          payment.minimumDueAmount! > payment.dueAmount) {
        throw const FormatException(AppStrings.minimumDueExceedsError);
      }
      if (!payment.isPaid && payment.dueAmount == 0) {
        throw const FormatException(AppStrings.invalidAmountError);
      }

      if (_box.containsKey(payment.id)) {
        // Update existing payment
        await _box.put(payment.id, payment);
      } else {
        // Add new payment
        await _box.put(payment.id, payment);
      }

      final updatedPayments = _box.values.toList();
      state = AsyncValue.data(updatedPayments);
      await _triggerSync();
      paymentSaved = true;

      // Reschedule notifications for this card
      final cards = ref.read(creditCardListProvider.notifier).sortedOnDueDate;
      final settings = ref.read(settingsProvider);
      await NotificationService().rescheduleAllNotifications(
        cards: cards,
        payments: updatedPayments,
        reminderTime: settings.reminderTime,
      );
    } catch (e, stack) {
      if (paymentSaved) {
        await _box.delete(payment.id);
        state = AsyncValue.data(_box.values.toList());
      }

      state = AsyncValue.error(e, stack);
      ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
      rethrow;
    }
  }

  Future<void> markAsPaid(String paymentId, double amount) async {
    state = const AsyncValue.loading();
    try {
      final payment = state.value!.firstWhere((p) => p.id == paymentId);

      if (amount <= 0) {
        throw const FormatException(AppStrings.invalidCustomAmountError);
      }

      if (amount > payment.dueAmount) {
        throw const FormatException(AppStrings.amountExceedsDueError);
      }

      final updatedPayment = payment.copyWith(
        isPaid: true,
        paidAmount: amount,
        dueAmount: payment.dueAmount - amount,
        paymentDate: DateTime.now().toUtc(),
        syncPending: true,
      );

      await _box.put(paymentId, updatedPayment);
      state = AsyncValue.data(_box.values.toList());
      await _triggerSync();

      // Reschedule notifications for this card
      final cards = ref.read(creditCardListProvider.notifier).sortedOnDueDate;
      final settings = ref.read(settingsProvider);
      await NotificationService().rescheduleAllNotifications(
        cards: cards,
        payments: _box.values.toList(),
        reminderTime: settings.reminderTime,
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
      rethrow;
    }
  }

  PaymentModel? getUpcomingPayment(String cardId) {
    try {
      return state.value?.firstWhere((p) => p.cardId == cardId && !p.isPaid);
    } catch (_) {
      return null;
    }
  }

  List<PaymentModel> getPaymentsForCard(String cardId) {
    return state.value?.where((p) => p.cardId == cardId).toList() ?? [];
  }

  reset() {
    state = const AsyncValue.loading();
    _box.listenable().removeListener(_onBoxChange);
    _box.clear();
    state = AsyncValue.data([]);
  }
}
