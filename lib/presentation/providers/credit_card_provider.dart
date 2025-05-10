import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/hive/models/credit_card_model.dart';
import '../../data/hive/storage/credit_card_storage.dart';

final creditCardListProvider =
    StateNotifierProvider<CreditCardNotifier, List<CreditCardModel>>(
      (ref) => CreditCardNotifier()..loadCards(),
    );

class CreditCardNotifier extends StateNotifier<List<CreditCardModel>> {
  CreditCardNotifier() : super([]);

  void loadCards() {
    final box = CreditCardStorage.getBox();
    state = box.values.toList();
  }

  void addCard(CreditCardModel card) {
    final box = CreditCardStorage.getBox();
    box.add(card);
    loadCards(); // refresh list
  }
}
