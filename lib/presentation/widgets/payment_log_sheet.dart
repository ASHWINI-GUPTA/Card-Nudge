import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/hive/models/payment_model.dart';
import '../providers/payment_provider.dart';

enum PaymentOption { totalDue, minDue, custom }

class LogPaymentBottomSheet extends ConsumerStatefulWidget {
  final PaymentModel payment;

  const LogPaymentBottomSheet({super.key, required this.payment});

  @override
  ConsumerState<LogPaymentBottomSheet> createState() =>
      _LogPaymentBottomSheetState();
}

class _LogPaymentBottomSheetState extends ConsumerState<LogPaymentBottomSheet> {
  PaymentOption _selectedOption = PaymentOption.totalDue;
  final TextEditingController _customAmountController = TextEditingController();

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  void _logPayment() {
    double amount;

    switch (_selectedOption) {
      case PaymentOption.totalDue:
        amount = widget.payment.dueAmount;
        break;
      case PaymentOption.minDue:
        amount = widget.payment.minimumDueAmount!;
        break;
      case PaymentOption.custom:
        amount =
            double.tryParse(_customAmountController.text.replaceAll(',', '')) ??
            0.0;
        break;
    }

    if (amount <= 0) return;

    ref.read(paymentProvider.notifier).markAsPaid(widget.payment.id, amount);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    var payments = ref
        .read(paymentProvider.notifier)
        .getPaymentsForCard(widget.payment.id);

    final unPaidPayment = payments.last;

    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Log Payment',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          RadioListTile<PaymentOption>(
            value: PaymentOption.totalDue,
            groupValue: _selectedOption,
            onChanged: (value) => setState(() => _selectedOption = value!),
            title: Text(
              'Total Due (${currencyFormat.format(unPaidPayment.dueAmount)})',
            ),
          ),

          if (unPaidPayment.minimumDueAmount != null)
            RadioListTile<PaymentOption>(
              value: PaymentOption.minDue,
              groupValue: _selectedOption,
              onChanged: (value) => setState(() => _selectedOption = value!),
              title: Text(
                'Minimum Due (${currencyFormat.format(unPaidPayment.minimumDueAmount)})',
              ),
            ),
          RadioListTile<PaymentOption>(
            value: PaymentOption.custom,
            groupValue: _selectedOption,
            onChanged: (value) => setState(() => _selectedOption = value!),
            title: const Text('Custom Amount'),
          ),
          if (_selectedOption == PaymentOption.custom)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _customAmountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: 'Enter custom amount',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _logPayment,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Log Payment'),
          ),
        ],
      ),
    );
  }
}
