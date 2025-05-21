import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/hive/models/bank_model.dart';
import '../../data/hive/storage/bank_storage.dart';

// Provider for the Hive box (dependency injection)
final bankBoxProvider = Provider<Box<BankModel>>((ref) {
  // Ensure the box is opened asynchronously and reused
  return BankStorage.getBox();
});

// StateNotifierProvider for managing bank state
final bankProvider = StateNotifierProvider<BankNotifier, List<BankModel>>(
  (ref) => BankNotifier(ref.read(bankBoxProvider))..loadBanks(),
);

class BankNotifier extends StateNotifier<List<BankModel>> {
  final Box<BankModel> _box;

  BankNotifier(this._box) : super([]) {
    // Listen to Hive box changes for real-time updates
    _box.listenable().addListener(_onBoxChange);
  }

  // Load banks from Hive box asynchronously
  Future<void> loadBanks() async {
    try {
      state = _box.values.toList();
    } catch (e) {
      // Handle errors (e.g., log or show default state)
      state = [];
    }
  }

  // React to Hive box changes
  void _onBoxChange() {
    // Only update state if data has changed to avoid unnecessary rebuilds
    final newBanks = _box.values.toList();
    if (newBanks != state) {
      state = newBanks;
    }
  }

  // Get bank info by name or code, with fallback to 'Other'
  BankModel getBankInfo(String? name) {
    if (name == null || name.trim().isEmpty) {
      return state.firstWhere((b) => b.name == 'Other');
    }

    final normalized = name.trim().toLowerCase();
    return state.firstWhere(
      (b) =>
          b.name.toLowerCase() == normalized ||
          b.code?.toLowerCase() == normalized,
      orElse: () => state.firstWhere((b) => b.name == 'Other'),
    );
  }

  // Get all banks, sorted with 'Other' at the end
  List<BankModel> getAllBanks() {
    final sortedBanks = List<BankModel>.from(state)..sort((a, b) {
      if (a.name == 'Other') return 1;
      if (b.name == 'Other') return -1;
      return a.name.compareTo(b.name);
    });
    return sortedBanks;
  }

  // Get bank by ID
  BankModel getById(String id) {
    return state.firstWhere((bank) => bank.id == id);
  }

  @override
  void dispose() {
    // Remove listener to prevent memory leaks
    _box.listenable().removeListener(_onBoxChange);
    // Note: Don't close the box here if it's shared via bankBoxProvider
    super.dispose();
  }
}
