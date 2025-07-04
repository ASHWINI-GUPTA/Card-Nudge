import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/enums/sync_status.dart';
import '../../data/hive/models/payment_model.dart';
import '../../data/hive/storage/payment_storage.dart';
import '../../constants/app_strings.dart';
import 'sync_provider.dart';

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

  Future<void> refresh() async {
    _onBoxChange();
  }

  void _onBoxChange() {
    // Update state only if data has changed to avoid infinite loops
    final newPayments = _box.values.toList();
    if (state.valueOrNull != newPayments) {
      state = AsyncValue.data(newPayments);
    }
  }

  Future<void> save(PaymentModel payment) async {
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

      state = const AsyncValue.loading();
      await _box.put(payment.id, payment);
      await _triggerSync();

      final updatedPayments = _box.values.toList();
      state = AsyncValue.data(updatedPayments);
      paymentSaved = true;
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

  Future<void> delete(String paymentId) async {
    print('[DEBUG] paymentProvider.delete called');
    state = const AsyncValue.loading();
    try {
      if (!_box.containsKey(paymentId)) {
        throw const FormatException(AppStrings.paymentNotFoundError);
      }
      await _box.delete(paymentId);
      state = AsyncValue.data(_box.values.toList());
      // await _triggerSync();
    } catch (e, stack) {
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
