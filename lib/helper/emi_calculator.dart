import 'dart:math';
import '../data/models/emi_calculation_model.dart';

class EmiCalculator {
  static const double standardGstRate = 0.18; // 18% GST

  /// Calculates reducing-balance monthly EMI given principal, annual interest rate (e.g. 17.25), and tenure in months.
  static double calculateMonthlyEmi({
    required double principal,
    required double annualRatePercent,
    required int tenureMonths,
  }) {
    if (principal <= 0 || tenureMonths <= 0) return 0.0;
    if (annualRatePercent <= 0) {
      return principal / tenureMonths;
    }

    final double monthlyRate = annualRatePercent / 12.0 / 100.0;
    final double compoundFactor = pow(1.0 + monthlyRate, tenureMonths).toDouble();
    final double emi = principal * monthlyRate * compoundFactor / (compoundFactor - 1.0);
    return emi;
  }

  /// Calculates the principal required to produce a specific target EMI.
  /// Used by Amazon/Flipkart No-Cost EMI to discount the order upfront by the bank interest.
  static double calculatePrincipalForTargetEmi({
    required double targetEmi,
    required double annualRatePercent,
    required int tenureMonths,
  }) {
    if (targetEmi <= 0 || tenureMonths <= 0) return 0.0;
    if (annualRatePercent <= 0) {
      return targetEmi * tenureMonths;
    }

    final double monthlyRate = annualRatePercent / 12.0 / 100.0;
    final double compoundFactor = pow(1.0 + monthlyRate, tenureMonths).toDouble();
    final double principal = targetEmi * (compoundFactor - 1.0) / (monthlyRate * compoundFactor);
    return principal;
  }

  /// Finds the statement billing date and payment due date for a cycle.
  static DateTime getStatementDate({
    required DateTime referenceDate,
    required int billingStatementDay,
  }) {
    // Clamp billingStatementDay to 1..28 for safety across all months
    final int safeDay = billingStatementDay.clamp(1, 28);
    return DateTime(referenceDate.year, referenceDate.month, safeDay);
  }

  /// Computes the first billing statement date on or after the booking date.
  static DateTime getFirstStatementDate({
    required DateTime bookingDate,
    required int billingStatementDay,
  }) {
    final int safeDay = billingStatementDay.clamp(1, 28);
    if (bookingDate.day <= safeDay) {
      return DateTime(bookingDate.year, bookingDate.month, safeDay);
    } else {
      return DateTime(bookingDate.year, bookingDate.month + 1, safeDay);
    }
  }

  /// Performs full EMI calculation including No-Cost EMI discount, amortization schedule,
  /// 1st-EMI date proration, taxes, and fees.
  static EmiResult calculate({
    required double productAmount,
    double instantBankDiscount = 0.0,
    required double annualInterestRate,
    required int tenureMonths,
    required DateTime bookingDate,
    required int billingStatementDay,
    int dueGracePeriodDays = 20,
    bool isNoCostEmi = true,
    bool isCreditCard = true,
    double processingFee = 0.0,
  }) {
    final double netAfterInstantDiscount = (productAmount - instantBankDiscount).clamp(0.0, double.infinity);
    final double monthlyRate = annualInterestRate / 12.0 / 100.0;

    double netPrincipal;
    double noCostDiscount = 0.0;
    double standardMonthlyEmi;

    if (isNoCostEmi && annualInterestRate > 0 && tenureMonths > 0) {
      // In No-Cost EMI, the merchant gives an upfront discount equal to the interest.
      // Target monthly EMI that customer was expecting to pay:
      final double targetEmi = netAfterInstantDiscount / tenureMonths;
      
      // Calculate loan principal that generates targetEmi:
      netPrincipal = calculatePrincipalForTargetEmi(
        targetEmi: targetEmi,
        annualRatePercent: annualInterestRate,
        tenureMonths: tenureMonths,
      );

      noCostDiscount = netAfterInstantDiscount - netPrincipal;
      // Recalculate standard monthly EMI on netPrincipal
      standardMonthlyEmi = calculateMonthlyEmi(
        principal: netPrincipal,
        annualRatePercent: annualInterestRate,
        tenureMonths: tenureMonths,
      );
    } else {
      netPrincipal = netAfterInstantDiscount;
      standardMonthlyEmi = calculateMonthlyEmi(
        principal: netPrincipal,
        annualRatePercent: annualInterestRate,
        tenureMonths: tenureMonths,
      );
    }

    final double totalStandardInterest = (standardMonthlyEmi * tenureMonths) - netPrincipal;

    // Build Amortization Schedule
    final List<AmortizationEntry> schedule = [];
    double remainingBalance = netPrincipal;
    final DateTime firstStatementDate = getFirstStatementDate(
      bookingDate: bookingDate,
      billingStatementDay: billingStatementDay,
    );

    double adjustedFirstEmi = standardMonthlyEmi;
    double firstEmiInterest = 0.0;
    int firstCycleDays = 30;

    for (int month = 1; month <= tenureMonths; month++) {
      // Calculate statement date and PDD for month i
      final DateTime statementDate = DateTime(
        firstStatementDate.year,
        firstStatementDate.month + (month - 1),
        firstStatementDate.day,
      );
      final DateTime pdd = statementDate.add(Duration(days: dueGracePeriodDays));

      double interest;
      double principalPart;
      double emiAmount;

      if (month == 1) {
        // Difference between Merchant EMI booking date and first PDD
        firstCycleDays = pdd.difference(bookingDate).inDays;
        
        // Standard 30-day interest on initial principal
        final double standardInterest30 = remainingBalance * monthlyRate;
        
        // Revised interest based on actual days (SBI Card rule)
        if (firstCycleDays != 30 && firstCycleDays > 0) {
          firstEmiInterest = standardInterest30 / 30.0 * firstCycleDays;
        } else {
          firstEmiInterest = standardInterest30;
        }

        interest = firstEmiInterest;
        principalPart = standardMonthlyEmi - standardInterest30;
        emiAmount = principalPart + interest;
        adjustedFirstEmi = emiAmount;
      } else if (month == tenureMonths) {
        // Last month: interest is on remaining balance, principal is exact remaining balance
        interest = remainingBalance * monthlyRate;
        principalPart = remainingBalance;
        emiAmount = principalPart + interest;
      } else {
        interest = remainingBalance * monthlyRate;
        principalPart = standardMonthlyEmi - interest;
        emiAmount = standardMonthlyEmi;
      }

      remainingBalance = (remainingBalance - principalPart).clamp(0.0, double.infinity);
      final double gst = isCreditCard ? (interest * standardGstRate) : 0.0;

      schedule.add(
        AmortizationEntry(
          monthNumber: month,
          billingDate: statementDate,
          dueDate: pdd,
          emiAmount: _round2(emiAmount),
          interestAmount: _round2(interest),
          principalAmount: _round2(principalPart),
          balancePrincipal: _round2(remainingBalance),
          gstTax: _round2(gst),
          daysInCycle: month == 1 ? firstCycleDays : 30,
        ),
      );
    }

    final double totalActualInterest = schedule.fold(0.0, (sum, e) => sum + e.interestAmount);
    final double totalGstOnInterest = schedule.fold(0.0, (sum, e) => sum + e.gstTax);
    final double gstOnProcessingFee = isCreditCard ? _round2(processingFee * standardGstRate) : 0.0;
    final double totalPayableToBank = netPrincipal + totalActualInterest;
    final double totalOutOfPocketCost = totalPayableToBank + totalGstOnInterest + processingFee + gstOnProcessingFee;

    return EmiResult(
      originalAmount: _round2(productAmount),
      instantBankDiscount: _round2(instantBankDiscount),
      noCostDiscount: _round2(noCostDiscount),
      netPrincipal: _round2(netPrincipal),
      annualInterestRate: annualInterestRate,
      tenureMonths: tenureMonths,
      standardMonthlyEmi: _round2(standardMonthlyEmi),
      totalStandardInterest: _round2(totalStandardInterest),
      adjustedFirstEmi: _round2(adjustedFirstEmi),
      firstEmiInterest: _round2(firstEmiInterest),
      firstCycleDays: firstCycleDays,
      totalActualInterest: _round2(totalActualInterest),
      totalGstOnInterest: _round2(totalGstOnInterest),
      processingFee: _round2(processingFee),
      gstOnProcessingFee: gstOnProcessingFee,
      totalPayableToBank: _round2(totalPayableToBank),
      totalOutOfPocketCost: _round2(totalOutOfPocketCost),
      isNoCostEmi: isNoCostEmi,
      isCreditCard: isCreditCard,
      schedule: schedule,
    );
  }

  /// Simulates early foreclosure of the loan as per SBI Card guidelines.
  static ForeclosureResult calculateForeclosure({
    required EmiResult emiResult,
    required DateTime foreclosureDate,
    required DateTime bookingDate,
    double foreclosureFeePercent = 3.0,
    double gstRate = 0.18,
  }) {
    final schedule = emiResult.schedule;
    if (schedule.isEmpty) {
      return ForeclosureResult(
        afterEmiNumber: 0,
        foreclosureDate: foreclosureDate,
        outstandingPrincipal: 0.0,
        foreclosureFeeRate: foreclosureFeePercent,
        foreclosureFee: 0.0,
        gstOnForeclosureFee: 0.0,
        interestAdjustment: 0.0,
        isInterestDebit: false,
        totalPayableToClose: 0.0,
        calculationNotes: 'No amortization schedule available.',
      );
    }

    final entry1 = schedule.first;
    final DateTime b1 = entry1.billingDate;
    final DateTime pdd1 = entry1.dueDate;

    double outstandingPrincipal = emiResult.netPrincipal;
    int afterEmiNumber = 0;
    double interestAdjustment = 0.0;
    bool isDebit = false;
    String notes = '';

    if (foreclosureDate.isBefore(b1)) {
      // Scenario a: FRD is before First Bill Date (B1)
      // Cardholder debited interest for days between EBD & FRD:
      // {1st EMI Interest / (PDD1 - EBD)} * (FRD - EBD)
      final int totalDays = pdd1.difference(bookingDate).inDays;
      final int activeDays = foreclosureDate.difference(bookingDate).inDays.clamp(0, totalDays);
      if (totalDays > 0) {
        interestAdjustment = (entry1.interestAmount / totalDays) * activeDays;
      }
      isDebit = true;
      notes = 'Foreclosure before 1st bill: Pro-rata interest debited for $activeDays days between booking date and foreclosure request date.';
    } else if (foreclosureDate.isBefore(pdd1)) {
      // Scenario b: FRD is after B1 & before PDD1
      // Cardholders credited interest for days between FRD & PDD1:
      // {1st EMI Interest / (PDD1 - EBD)} * (PDD1 - FRD)
      final int totalDays = pdd1.difference(bookingDate).inDays;
      final int remainingDays = pdd1.difference(foreclosureDate).inDays.clamp(0, totalDays);
      if (totalDays > 0) {
        interestAdjustment = (entry1.interestAmount / totalDays) * remainingDays;
      }
      isDebit = false;
      notes = 'Foreclosure before 1st due date: Pro-rata interest credited for $remainingDays days between foreclosure date and payment due date.';
    } else {
      // Subsequent EMIs: locate which month the foreclosure falls into
      int activeMonthIndex = 1;
      for (int i = 1; i < schedule.length; i++) {
        if (foreclosureDate.isAfter(schedule[i - 1].dueDate)) {
          activeMonthIndex = i;
          afterEmiNumber = i;
          outstandingPrincipal = schedule[i - 1].balancePrincipal;
        }
      }

      if (activeMonthIndex < schedule.length) {
        final currentEntry = schedule[activeMonthIndex];
        final prevEntry = schedule[activeMonthIndex - 1];
        final DateTime bCur = currentEntry.billingDate;
        final DateTime pddCur = currentEntry.dueDate;
        final DateTime pddPrev = prevEntry.dueDate;
        final int cycleSpan = pddCur.difference(pddPrev).inDays;

        if (foreclosureDate.isBefore(bCur)) {
          // Scenario c: FRD is after Prev PDD & before Cur Bill Date
          // Debited interest for days between Prev PDD and FRD
          final int activeDays = foreclosureDate.difference(pddPrev).inDays.clamp(0, cycleSpan);
          if (cycleSpan > 0) {
            interestAdjustment = (currentEntry.interestAmount / cycleSpan) * activeDays;
          }
          isDebit = true;
          notes = 'Foreclosure before statement date: Pro-rata interest debited for $activeDays days after previous due date.';
        } else {
          // Scenario d: FRD is after Cur Bill Date & before Cur PDD
          // Credited interest for days between FRD and Cur PDD
          final int remainingDays = pddCur.difference(foreclosureDate).inDays.clamp(0, cycleSpan);
          if (cycleSpan > 0) {
            interestAdjustment = (currentEntry.interestAmount / cycleSpan) * remainingDays;
          }
          isDebit = false;
          notes = 'Foreclosure before due date: Pro-rata interest credited for $remainingDays days remaining in cycle.';
        }
      } else {
        outstandingPrincipal = 0.0;
        notes = 'Loan is already fully repaid.';
      }
    }

    final double fee = _round2(outstandingPrincipal * (foreclosureFeePercent / 100.0));
    final double gstOnFee = _round2(fee * gstRate);
    final double netInterestPart = isDebit ? interestAdjustment : -interestAdjustment;
    final double totalToClose = _round2((outstandingPrincipal + fee + gstOnFee + netInterestPart).clamp(0.0, double.infinity));

    return ForeclosureResult(
      afterEmiNumber: afterEmiNumber,
      foreclosureDate: foreclosureDate,
      outstandingPrincipal: _round2(outstandingPrincipal),
      foreclosureFeeRate: foreclosureFeePercent,
      foreclosureFee: fee,
      gstOnForeclosureFee: gstOnFee,
      interestAdjustment: _round2(interestAdjustment),
      isInterestDebit: isDebit,
      totalPayableToClose: totalToClose,
      calculationNotes: notes,
    );
  }

  static double _round2(double val) {
    return (val * 100.0).roundToDouble() / 100.0;
  }
}
