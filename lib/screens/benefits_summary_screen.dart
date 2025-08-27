import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/credit_card_summary_provider.dart';

class BenefitsSummaryScreen extends ConsumerWidget {
  final String cardId;

  BenefitsSummaryScreen({required this.cardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryNotifier = ref.watch(creditCardSummariesProvider.notifier);
    final summary = summaryNotifier.getSummaryByCardId(cardId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Benefits Summary'),
      ),
      body: summary == null
          ? Center(child: Text('No summary found.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(summary.markdownSummary),
            ),
    );
  }
}