import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../data/hive/models/credit_card_summary_model.dart';

final creditCardSummaryBoxProvider = Provider<Box<CreditCardSummaryModel>>((
  ref,
) {
  return Hive.box<CreditCardSummaryModel>('credit_card_summaries');
});

final creditCardSummariesProvider = StateNotifierProvider<
  CreditCardSummaryNotifier,
  List<CreditCardSummaryModel>
>((ref) {
  final box = ref.watch(creditCardSummaryBoxProvider);
  return CreditCardSummaryNotifier(box);
});

class CreditCardSummaryNotifier
    extends StateNotifier<List<CreditCardSummaryModel>> {
  final Box<CreditCardSummaryModel> box;

  CreditCardSummaryNotifier(this.box) : super(box.values.toList());

  CreditCardSummaryModel? getSummaryByCardId(String cardId) {
    return box.values.where((summary) => summary.cardId == cardId).firstOrNull;
  }

  void reset() {
    box.clear();
    state = [];
  }
}
