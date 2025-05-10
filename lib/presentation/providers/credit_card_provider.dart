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

  void add(CreditCardModel card) {
    final box = CreditCardStorage.getBox();
    box.add(card);
    loadCards(); // refresh list
  }

  void updateByKey(int key, CreditCardModel card) {
    final box = CreditCardStorage.getBox();
    final index = box.values.toList().indexWhere((card) => card.key == key);
    box.putAt(index, card);
    loadCards();
  }

  void deleteByKey(int key) {
    final box = CreditCardStorage.getBox();
    final index = box.values.toList().indexWhere((card) => card.key == key);
    if (index != -1) {
      box.deleteAt(index);
      loadCards();
    }
  }

  void clearCards() {
    final box = CreditCardStorage.getBox();
    box.clear();
    loadCards();
  }

  void restoreByKey(int key, CreditCardModel card) {
    final box = CreditCardStorage.getBox();
    box.put(key, card);
    loadCards();
  }
}
