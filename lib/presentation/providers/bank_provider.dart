import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../constants/app_strings.dart';
import '../../data/enums/sync_status.dart';
import '../../data/hive/models/bank_model.dart';
import '../../data/hive/storage/bank_storage.dart';
import 'sync_provider.dart';

final bankBoxProvider = Provider<Box<BankModel>>((ref) {
  return BankStorage.getBox();
});

final bankProvider = AsyncNotifierProvider<BankNotifier, List<BankModel>>(
  BankNotifier.new,
);

class BankNotifier extends AsyncNotifier<List<BankModel>> {
  Box<BankModel> get _box => ref.read(bankBoxProvider);

  Future<void> _triggerSync() async {
    final syncService = ref.read(syncServiceProvider);
    if (await syncService.isOnline()) {
      ref.read(syncStatusProvider.notifier).state = SyncStatus.syncing;
      try {
        await syncService.pushLocalChanges();
        ref.read(syncStatusProvider.notifier).state = SyncStatus.idle;
      } catch (e) {
        ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
        rethrow;
      }
    }
  }

  @override
  Future<List<BankModel>> build() async {
    try {
      _box.listenable().addListener(_onBoxChange);
      final banks =
          _box.values.toList()..sort((a, b) {
            if (a.name == 'Other') return 1;
            if (b.name == 'Other') return -1;
            return a.name.compareTo(b.name);
          });
      return banks;
    } catch (e) {
      throw Exception('${AppStrings.bankDetailsLoadError}: $e');
    }
  }

  void _onBoxChange() {
    try {
      final newBanks =
          _box.values.toList()..sort((a, b) {
            if (a.name == 'Other') return 1;
            if (b.name == 'Other') return -1;
            return a.name.compareTo(b.name);
          });
      if (state.valueOrNull != newBanks) {
        state = AsyncValue.data(newBanks);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  BankModel get(String id) {
    final banks = state.valueOrNull ?? [];
    return banks.firstWhere(
      (bank) => bank.id == id,
      orElse: () => throw Exception(AppStrings.invalidBankError),
    );
  }

  Future<void> refresh() async {
    _onBoxChange();
  }

  Future<void> save(BankModel bank) async {
    state = const AsyncValue.loading();
    bool bankSaved = false;
    try {
      await _box.put(bank.id, bank);
      _onBoxChange();
      await _triggerSync();
      bankSaved = true;
    } catch (e, stack) {
      if (bankSaved) {
        await _box.delete(bank.id);
        _onBoxChange();
      }
      state = AsyncValue.error(e, stack);
      ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
    }
  }

  Future<void> deleteBank(String id) async {
    state = const AsyncValue.loading();
    try {
      await _box.delete(id);
      _onBoxChange();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  reset() {
    state = const AsyncValue.loading();
    _box.listenable().removeListener(_onBoxChange);
    _box.clear();
    state = AsyncValue.data([]);
  }
}
