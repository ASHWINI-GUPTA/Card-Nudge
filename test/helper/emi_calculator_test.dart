import 'package:flutter_test/flutter_test.dart';
import 'package:card_nudge/helper/emi_calculator.dart';

void main() {
  group('EmiCalculator Tests', () {
    test('Standard EMI formula calculation', () {
      // Principal 16,328.19 at 17.25% for 3 months
      final emi = EmiCalculator.calculateMonthlyEmi(
        principal: 16328.19,
        annualRatePercent: 17.25,
        tenureMonths: 3,
      );
      expect((emi - 5599.95).abs() < 0.1, isTrue);
    });

    test('Amazon No-Cost EMI Calculation matches user breakdown', () {
      final result = EmiCalculator.calculate(
        productAmount: 19797.00,
        instantBankDiscount: 3000.00,
        annualInterestRate: 17.25,
        tenureMonths: 3,
        bookingDate: DateTime(2026, 10, 15),
        billingStatementDay: 13,
        dueGracePeriodDays: 20,
        isNoCostEmi: true,
        isCreditCard: true,
        processingFee: 169.00,
      );

      // Verify No-Cost EMI discount around 468.81 - 471.59 (within ₹3 margin of real invoice)
      expect((result.noCostDiscount - 468.81).abs() < 3.0, isTrue);
      // Net Principal financed by bank around 16,325.41 - 16,328.19
      expect((result.netPrincipal - 16328.19).abs() < 3.0, isTrue);
      // Standard monthly EMI around 5,599.00 - 5,599.95
      expect((result.standardMonthlyEmi - 5599.95).abs() < 1.0, isTrue);
      // Processing fee
      expect(result.processingFee, 169.00);
      expect(result.gstOnProcessingFee, 30.42);

      // Verify Amortization schedule has 3 entries
      expect(result.schedule.length, 3);
      final entry1 = result.schedule[0];
      final entry2 = result.schedule[1];
      final entry3 = result.schedule[2];

      // Month 1 adjusted interest (around 375.53 - 383.31 depending on 48/49 calendar day count)
      expect((entry1.interestAmount - 383.31).abs() < 10.0, isTrue);
      // Month 2 interest ~ 157.59
      expect((entry2.interestAmount - 157.59).abs() < 1.0, isTrue);
      // Month 3 interest ~ 79.36
      expect((entry3.interestAmount - 79.36).abs() < 1.0, isTrue);
      // Final balance must be 0
      expect(entry3.balancePrincipal, 0.0);
    });

    test('Foreclosure calculation works correctly', () {
      final result = EmiCalculator.calculate(
        productAmount: 16328.19,
        annualInterestRate: 17.25,
        tenureMonths: 3,
        bookingDate: DateTime(2026, 10, 15),
        billingStatementDay: 13,
        dueGracePeriodDays: 20,
        isNoCostEmi: false,
        isCreditCard: true,
      );

      // Foreclose on Nov 1 (before B1 on Nov 13)
      final foreclosure = EmiCalculator.calculateForeclosure(
        emiResult: result,
        foreclosureDate: DateTime(2026, 11, 1),
        bookingDate: DateTime(2026, 10, 15),
      );

      expect(foreclosure.outstandingPrincipal, result.netPrincipal);
      expect(foreclosure.isInterestDebit, isTrue);
      expect(foreclosure.foreclosureFee > 0, isTrue);
      expect(foreclosure.totalPayableToClose > result.netPrincipal, isTrue);
    });
  });
}
