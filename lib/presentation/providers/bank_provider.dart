import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/hive/models/bank_model.dart';
import '../../data/hive/storage/bank_storage.dart';

final bankProvider = StateNotifierProvider<BankNotifier, List<BankModel>>(
  (ref) => BankNotifier()..loadBanks(),
);

class BankNotifier extends StateNotifier<List<BankModel>> {
  BankNotifier() : super([]);

  void loadBanks() {
    final box = BankStorage.getBox();
    state = box.values.toList();
  }

  static BankModel getBankInfo(String? name) {
    final box = BankStorage.getBox();
    final banks = box.values.toList();

    if (name == null || name.trim().isEmpty) {
      return banks.firstWhere((b) => b.name == 'Other');
    }

    final normalized = name.trim().toLowerCase();
    return banks.firstWhere(
      (b) =>
          b.name.toLowerCase() == normalized ||
          b.code?.toLowerCase() == normalized,
      orElse: () => banks.firstWhere((b) => b.name == 'Other'),
    );
  }

  static List<BankModel> getAllBanks() {
    final box = BankStorage.getBox();
    final banks = box.values.toList();
    final sortedBanks = List<BankModel>.from(banks)..sort((a, b) {
      if (a.name == 'Other') return 1;
      if (b.name == 'Other') return -1;
      return a.name.compareTo(b.name);
    });
    return sortedBanks;
  }

  BankModel getById(String id) {
    return state.firstWhere((bank) => bank.id == id);
  }
}
