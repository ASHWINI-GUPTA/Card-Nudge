import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/hive/models/payment_model.dart';
import '../../data/hive/storage/payment_storage.dart';
import '../../constants/app_strings.dart';

final paymentBoxProvider = Provider<Box<PaymentModel>>((ref) {
  return PaymentStorage.getBox();
});

final paymentProvider =
    AsyncNotifierProvider<PaymentNotifier, List<PaymentModel>>(
      PaymentNotifier.new,
    );

class PaymentNotifier extends AsyncNotifier<List<PaymentModel>> {
  Box<PaymentModel> get _box => ref.read(paymentBoxProvider);

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
    try {
      // Validate payment
      if (payment.dueAmount <= 0) {
        throw const FormatException(AppStrings.invalidAmountError);
      }
      if (payment.cardId.isEmpty) {
        throw const FormatException(AppStrings.requiredFieldError);
      }
      if (payment.minimumDueAmount != null &&
          payment.minimumDueAmount! > payment.dueAmount) {
        throw const FormatException(AppStrings.minimumDueExceedsError);
      }
      if (payment.isPaid &&
          (payment.paidAmount <= 0 || payment.paidAmount > payment.dueAmount)) {
        throw const FormatException(AppStrings.invalidCustomAmountError);
      }

      if (_box.containsKey(payment.id)) {
        // Update existing payment
        await _box.put(payment.id, payment);
      } else {
        // Add new payment
        await _box.put(payment.id, payment);
      }

      // Update state with new data
      final updatedPayments = _box.values.toList();
      state = AsyncValue.data(updatedPayments);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow; // Allow widgets to handle errors
    }
  }

  Future<void> markAsPaid(String paymentId, double amount) async {
    state = const AsyncValue.loading();
    try {
      final payment = state.value!.firstWhere(
        (p) => p.id == paymentId,
        orElse:
            () => throw const FormatException(AppStrings.paymentNotFoundError),
      );
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
      );

      await _box.put(paymentId, updatedPayment);
      state = AsyncValue.data(_box.values.toList());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
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
