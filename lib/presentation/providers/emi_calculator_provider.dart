import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/emi_calculation_model.dart';
import '../../helper/emi_calculator.dart';
import 'credit_card_provider.dart';

class EmiCalculatorState {
  final double productAmount;
  final double instantBankDiscount;
  final double annualInterestRate;
  final int tenureMonths;
  final DateTime bookingDate;
  final String? selectedCardId;
  final int customBillingStatementDay;
  final int customGracePeriodDays;
  final bool isNoCostEmi;
  final bool isCreditCard;
  final double processingFee;
  final EmiResult? result;

  const EmiCalculatorState({
    required this.productAmount,
    required this.instantBankDiscount,
    required this.annualInterestRate,
    required this.tenureMonths,
    required this.bookingDate,
    this.selectedCardId,
    required this.customBillingStatementDay,
    required this.customGracePeriodDays,
    required this.isNoCostEmi,
    required this.isCreditCard,
    required this.processingFee,
    this.result,
  });

  EmiCalculatorState copyWith({
    double? productAmount,
    double? instantBankDiscount,
    double? annualInterestRate,
    int? tenureMonths,
    DateTime? bookingDate,
    String? selectedCardId,
    bool clearSelectedCard = false,
    int? customBillingStatementDay,
    int? customGracePeriodDays,
    bool? isNoCostEmi,
    bool? isCreditCard,
    double? processingFee,
    EmiResult? result,
  }) {
    return EmiCalculatorState(
      productAmount: productAmount ?? this.productAmount,
      instantBankDiscount: instantBankDiscount ?? this.instantBankDiscount,
      annualInterestRate: annualInterestRate ?? this.annualInterestRate,
      tenureMonths: tenureMonths ?? this.tenureMonths,
      bookingDate: bookingDate ?? this.bookingDate,
      selectedCardId:
          clearSelectedCard ? null : (selectedCardId ?? this.selectedCardId),
      customBillingStatementDay:
          customBillingStatementDay ?? this.customBillingStatementDay,
      customGracePeriodDays:
          customGracePeriodDays ?? this.customGracePeriodDays,
      isNoCostEmi: isNoCostEmi ?? this.isNoCostEmi,
      isCreditCard: isCreditCard ?? this.isCreditCard,
      processingFee: processingFee ?? this.processingFee,
      result: result ?? this.result,
    );
  }
}

final emiCalculatorProvider = StateNotifierProvider.autoDispose<
  EmiCalculatorNotifier,
  EmiCalculatorState
>((ref) {
  return EmiCalculatorNotifier(ref);
});

class EmiCalculatorNotifier extends StateNotifier<EmiCalculatorState> {
  final Ref ref;

  EmiCalculatorNotifier(this.ref)
    : super(
        EmiCalculatorState(
          productAmount: 19797.0,
          instantBankDiscount: 3000.0,
          annualInterestRate: 17.25,
          tenureMonths: 3,
          bookingDate: DateTime.now(),
          customBillingStatementDay: 13,
          customGracePeriodDays: 20,
          isNoCostEmi: true,
          isCreditCard: true,
          processingFee: 169.0,
        ),
      ) {
    _autoSelectCardIfAvailable();
    calculate();
  }

  void _autoSelectCardIfAvailable() {
    final cardsAsync = ref.read(creditCardProvider);
    final cards = cardsAsync.valueOrNull;
    if (cards != null && cards.isNotEmpty) {
      final activeCards = cards.where((c) => !c.isArchived).toList();
      if (activeCards.isNotEmpty) {
        selectCard(activeCards.first.id);
      }
    }
  }

  void selectCard(String? cardId) {
    if (cardId == null) {
      state = state.copyWith(clearSelectedCard: true);
    } else {
      final cards = ref.read(creditCardProvider).valueOrNull ?? [];
      final card = cards.where((c) => c.id == cardId).firstOrNull;
      if (card != null) {
        state = state.copyWith(
          selectedCardId: cardId,
          customBillingStatementDay: card.billingDate.day,
          customGracePeriodDays: card.dueGracePeriodDays,
        );
      } else {
        state = state.copyWith(selectedCardId: cardId);
      }
    }
    calculate();
  }

  void updateProductAmount(double amount) {
    state = state.copyWith(productAmount: amount);
    calculate();
  }

  void updateInstantDiscount(double discount) {
    state = state.copyWith(instantBankDiscount: discount);
    calculate();
  }

  void updateInterestRate(double rate) {
    state = state.copyWith(annualInterestRate: rate);
    calculate();
  }

  void updateTenure(int months) {
    state = state.copyWith(tenureMonths: months);
    calculate();
  }

  void updateBookingDate(DateTime date) {
    state = state.copyWith(bookingDate: date);
    calculate();
  }

  void updateBillingStatementDay(int day) {
    state = state.copyWith(customBillingStatementDay: day);
    calculate();
  }

  void updateGracePeriod(int days) {
    state = state.copyWith(customGracePeriodDays: days);
    calculate();
  }

  void toggleNoCostEmi(bool value) {
    state = state.copyWith(isNoCostEmi: value);
    calculate();
  }

  void toggleCreditCard(bool value) {
    state = state.copyWith(isCreditCard: value);
    calculate();
  }

  void updateProcessingFee(double fee) {
    state = state.copyWith(processingFee: fee);
    calculate();
  }

  void calculate() {
    int billingDay = state.customBillingStatementDay;
    int graceDays = state.customGracePeriodDays;

    if (state.selectedCardId != null) {
      final cards = ref.read(creditCardProvider).valueOrNull ?? [];
      final card = cards.where((c) => c.id == state.selectedCardId).firstOrNull;
      if (card != null) {
        billingDay = card.billingDate.day;
        graceDays = card.dueGracePeriodDays;
      }
    }

    final result = EmiCalculator.calculate(
      productAmount: state.productAmount,
      instantBankDiscount: state.instantBankDiscount,
      annualInterestRate: state.annualInterestRate,
      tenureMonths: state.tenureMonths,
      bookingDate: state.bookingDate,
      billingStatementDay: billingDay,
      dueGracePeriodDays: graceDays,
      isNoCostEmi: state.isNoCostEmi,
      isCreditCard: state.isCreditCard,
      processingFee: state.processingFee,
    );

    state = state.copyWith(result: result);
  }
}
