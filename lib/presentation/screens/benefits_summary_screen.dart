import 'package:card_nudge/helper/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../data/hive/models/credit_card_model.dart';

class BenefitsSummaryScreen extends StatelessWidget {
  final CreditCardModel card;

  const BenefitsSummaryScreen({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('${card.name} ${context.l10n.cardBenefits}')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              card.benefitSummary != null && card.benefitSummary!.isNotEmpty
                  ? Markdown(
                    data: card.benefitSummary!,
                    styleSheet: MarkdownStyleSheet(
                      h1: theme.textTheme.headlineMedium,
                      h2: theme.textTheme.titleLarge,
                      h3: theme.textTheme.titleMedium,
                      p: theme.textTheme.bodyLarge,
                    ),
                  )
                  : Center(
                    child: Text(
                      context.l10n.noBenefitsSummaryAvailable,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
        ),
      ),
    );
  }
}
