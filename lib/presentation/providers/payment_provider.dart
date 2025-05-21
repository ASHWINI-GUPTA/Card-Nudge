import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/hive/models/payment_model.dart';
import '../../data/hive/storage/payment_storage.dart';

// Provider for the Hive box (dependency injection)
final paymentBoxProvider = Provider<Box<PaymentModel>>((ref) {
  return PaymentStorage.getBox();
});

// StateNotifierProvider for managing payment state
final paymentProvider =
    StateNotifierProvider<PaymentNotifier, List<PaymentModel>>(
      (ref) => PaymentNotifier(ref.read(paymentBoxProvider))..loadPayments(),
    );

class PaymentNotifier extends StateNotifier<List<PaymentModel>> {
  final Box<PaymentModel> _box;

  PaymentNotifier(this._box) : super([]) {
    // Listen to Hive box changes for real-time updates
    _box.listenable().addListener(_onBoxChange);
  }

  // Load payments from Hive box asynchronously
  Future<void> loadPayments() async {
    try {
      state = _box.values.toList();
    } catch (e) {
      // Handle errors (e.g., log or set empty state)
      print('Error loading payments: $e');
      state = [];
    }
  }

  // Handle box changes for real-time updates
  void _onBoxChange() {
    final newPayments = _box.values.toList();
    if (newPayments != state) {
      state = newPayments;
    }
  }

  // Get payments for a specific card
  List<PaymentModel> getPaymentsForCard(String cardId) {
    try {
      return state.where((payment) => payment.cardId == cardId).toList();
    } catch (e) {
      print('Error getting payments for card: $e');
      return [];
    }
  }

  // Get the upcoming unpaid payment for a card
  PaymentModel? getUpcomingPayment(String cardId) {
    try {
      final unpaidPayments = state.where(
        (p) => p.cardId == cardId && !p.isPaid,
      );
      return unpaidPayments.isNotEmpty ? unpaidPayments.first : null;
    } catch (e) {
      print('Error getting upcoming payment: $e');
      return null;
    }
  }

  // Add a new payment
  Future<void> addPayment(PaymentModel payment) async {
    try {
      // Validate payment
      if (payment.dueAmount <= 0) {
        throw FormatException('Due amount must be positive');
      }
      if (payment.cardId.isEmpty) {
        throw FormatException('Card ID must not be empty');
      }

      await _box.put(payment.id, payment);
      _onBoxChange(); // Trigger state update
    } catch (e) {
      print('Error adding payment: $e');
    }
  }

  // Mark a payment as paid
  Future<void> markAsPaid(String paymentId, double amount) async {
    try {
      final payment = await _box.get(paymentId);
      if (payment == null) {
        throw Exception('Payment not found');
      }

      // Validate business rules
      if (amount <= 0) {
        throw FormatException('Amount must be positive');
      }
      if (amount > payment.dueAmount) {
        throw Exception('Cannot pay more than due amount');
      }

      // Create new immutable payment state
      final updatedPayment = payment.copyWith(
        isPaid: amount == payment.dueAmount,
        dueAmount: payment.dueAmount - amount,
        paidAmount: amount,
      );

      // Persist changes
      await _box.put(paymentId, updatedPayment);
      _onBoxChange(); // Trigger state update
    } catch (e) {
      print('Error marking payment as paid: $e');
      rethrow; // Rethrow to allow UI to handle errors
    }
  }

  @override
  void dispose() {
    // Remove listener to prevent memory leaks
    _box.listenable().removeListener(_onBoxChange);
    // Note: Don't close the box here if shared via paymentBoxProvider
    super.dispose();
  }
}
