import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/hive/models/payment_model.dart';
import 'payment_provider.dart';

/// Provides utility methods to compute spend totals grouped by year and card.
final spendAnalysisProvider = Provider<SpendAnalysisService>((ref) {
  return SpendAnalysisService(ref);
});

class SpendAnalysisService {
  final Ref ref;
  SpendAnalysisService(this.ref);

  /// Returns a map of cardId -> total spent in the given [year].
  /// Spent is computed as the sum of `paidAmount` for payments whose
  /// paymentDate falls in the given year. If paymentDate is null but
  /// payment is marked paid, it uses UTC now year as a fallback.
  Map<String, double> getSpendByYear(int year) {
    final payments = ref.read(paymentProvider).valueOrNull ?? [];
    final Map<String, double> totals = {};

    for (final PaymentModel p in payments) {
      if (!p.isPaid)
        continue; // only consider paid amounts for historical spend

      final date = p.paymentDate ?? DateTime.now().toUtc();
      if (date.year != year) continue;

      totals[p.cardId] = (totals[p.cardId] ?? 0) + (p.paidAmount);
    }

    return totals;
  }

  /// Returns a map of cardId -> list of 12 monthly spends (index 0=Jan ... 11=Dec)
  /// for the given [year]. Monthly spend is the sum of `paidAmount` for payments
  /// whose paymentDate month falls in that month of the year.
  /// If paymentDate is null but payment is marked paid and year matches, it uses
  /// UTC now month as a fallback.
  Map<String, List<double>> getMonthlySpend(int year) {
    final payments = ref.read(paymentProvider).valueOrNull ?? [];
    final Map<String, List<double>> monthly = {};

    for (final PaymentModel p in payments) {
      if (!p.isPaid) continue;

      final date = p.paymentDate ?? DateTime.now().toUtc();
      if (date.year != year) continue;

      final cardId = p.cardId;
      monthly[cardId] ??= List.filled(12, 0.0);
      final monthIndex = date.month - 1;
      monthly[cardId]![monthIndex] += p.paidAmount;
    }

    return monthly;
  }

  /// Returns the list of years present in payments (paid payments) for quick selection.
  List<int> availableYears() {
    final payments = ref.read(paymentProvider).valueOrNull ?? [];
    final years = <int>{};
    for (final p in payments) {
      if (!p.isPaid) continue;
      final date = p.paymentDate ?? DateTime.now().toUtc();
      years.add(date.year);
    }
    final list = years.toList()..sort((a, b) => b.compareTo(a));
    return list;
  }
}
