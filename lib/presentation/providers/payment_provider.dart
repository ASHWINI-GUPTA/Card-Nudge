import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/hive/models/payment_model.dart';
import '../../data/hive/storage/payment_storage.dart';

class PaymentNotifier extends StateNotifier<List<PaymentModel>> {
  PaymentNotifier() : super([]);

  void loadInitialData() {
    final box = PaymentStorage.getBox();
    state = box.values.toList();
  }

  List<PaymentModel> getPaymentsForCard(String cardId) {
    return state..where((payment) => payment.cardId == cardId).toList();
  }

  PaymentModel? getUpcomingPayment(String cardId) {
    try {
      return state.firstWhere(
        (p) =>
            p.cardId == cardId &&
            !p.isPaid &&
            p.paymentDate.isAfter(DateTime.now()),
      );
    } catch (error) {
      return null;
    }
  }
}

final paymentProvider =
    StateNotifierProvider<PaymentNotifier, List<PaymentModel>>(
      (ref) => PaymentNotifier()..loadInitialData(),
    );
