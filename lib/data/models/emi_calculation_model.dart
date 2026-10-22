class AmortizationEntry {
  final int monthNumber;
  final DateTime billingDate;
  final DateTime dueDate;
  final double emiAmount; // MRA (Monthly Repayment Amount)
  final double interestAmount;
  final double principalAmount;
  final double balancePrincipal;
  final double gstTax; // 18% GST on interest
  final int daysInCycle;

  const AmortizationEntry({
    required this.monthNumber,
    required this.billingDate,
    required this.dueDate,
    required this.emiAmount,
    required this.interestAmount,
    required this.principalAmount,
    required this.balancePrincipal,
    required this.gstTax,
    required this.daysInCycle,
  });

  double get totalMonthlyOutflow => emiAmount + gstTax;
}

class EmiResult {
  final double originalAmount;
  final double instantBankDiscount;
  final double noCostDiscount;
  final double netPrincipal; // Loan amount sanctioned/billed
  final double annualInterestRate;
  final int tenureMonths;
  final double standardMonthlyEmi;
  final double totalStandardInterest;
  final double adjustedFirstEmi;
  final double firstEmiInterest;
  final int firstCycleDays;
  final double totalActualInterest;
  final double totalGstOnInterest;
  final double processingFee;
  final double gstOnProcessingFee;
  final double totalPayableToBank;
  final double totalOutOfPocketCost;
  final bool isNoCostEmi;
  final bool isCreditCard;
  final List<AmortizationEntry> schedule;

  const EmiResult({
    required this.originalAmount,
    required this.instantBankDiscount,
    required this.noCostDiscount,
    required this.netPrincipal,
    required this.annualInterestRate,
    required this.tenureMonths,
    required this.standardMonthlyEmi,
    required this.totalStandardInterest,
    required this.adjustedFirstEmi,
    required this.firstEmiInterest,
    required this.firstCycleDays,
    required this.totalActualInterest,
    required this.totalGstOnInterest,
    required this.processingFee,
    required this.gstOnProcessingFee,
    required this.totalPayableToBank,
    required this.totalOutOfPocketCost,
    required this.isNoCostEmi,
    required this.isCreditCard,
    required this.schedule,
  });

  /// Hidden cost customer pays that is NOT waived by No-Cost EMI
  double get totalHiddenCharges =>
      totalGstOnInterest + processingFee + gstOnProcessingFee;

  /// Effective cost above the initial product price (after instant discount)
  double get netAdditionalCost =>
      totalOutOfPocketCost - (originalAmount - instantBankDiscount);
}

class ForeclosureResult {
  final int afterEmiNumber;
  final DateTime foreclosureDate;
  final double outstandingPrincipal;
  final double foreclosureFeeRate; // e.g. 3.0 %
  final double foreclosureFee;
  final double gstOnForeclosureFee; // 18%
  final double interestAdjustment; // positive for debit, negative for credit
  final bool isInterestDebit;
  final double totalPayableToClose;
  final String calculationNotes;

  const ForeclosureResult({
    required this.afterEmiNumber,
    required this.foreclosureDate,
    required this.outstandingPrincipal,
    required this.foreclosureFeeRate,
    required this.foreclosureFee,
    required this.gstOnForeclosureFee,
    required this.interestAdjustment,
    required this.isInterestDebit,
    required this.totalPayableToClose,
    required this.calculationNotes,
  });
}
