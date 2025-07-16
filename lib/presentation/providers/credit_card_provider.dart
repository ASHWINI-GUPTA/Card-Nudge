import 'package:card_nudge/helper/date_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../constants/app_strings.dart';
import '../../data/enums/sync_status.dart';
import '../../data/hive/models/credit_card_model.dart';
import '../../data/hive/storage/credit_card_storage.dart';
import 'payment_provider.dart';
import 'sync_provider.dart';

final creditCardBoxProvider = Provider<Box<CreditCardModel>>((ref) {
  return CreditCardStorage.getBox();
});

final creditCardProvider =
    AsyncNotifierProvider<CreditCardNotifier, List<CreditCardModel>>(
      CreditCardNotifier.new,
    );

class CreditCardNotifier extends AsyncNotifier<List<CreditCardModel>> {
  Box<CreditCardModel> get _box => ref.read(creditCardBoxProvider);

  Future<void> _triggerSync() async {
    final syncService = ref.read(syncServiceProvider);
    if (await syncService.isOnline()) {
      ref.read(syncStatusProvider.notifier).state = SyncStatus.syncing;
      try {
        await syncService.syncData();
        ref.read(syncStatusProvider.notifier).state = SyncStatus.idle;
      } catch (e) {
        ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
        rethrow;
      }
    }
  }

  @override
  Future<List<CreditCardModel>> build() async {
    _box.listenable().addListener(_onBoxChange);
    return _box.values.where((card) => !card.isArchived).toList()..sort((a, b) {
      final dueDateComparison = a.dueDate.differenceInDaysCeil(b.dueDate);
      if (dueDateComparison != 0) {
        return dueDateComparison;
      }
      return a.billingDate.differenceInDaysCeil(b.billingDate);
    });
  }

  Future<void> refresh() async {
    _onBoxChange();
  }

  Future<void> save(CreditCardModel card) async {
    print('[DEBUG] creditCardProvider.save called');
    state = const AsyncValue.loading();
    bool cardSaved = false;
    try {
      await _box.put(card.id, card);
      await _triggerSync();
      await loadCards();

      cardSaved = true;
    } catch (e, stack) {
      if (cardSaved) {
        await _box.delete(card.id);
        await loadCards();
      }
      state = AsyncValue.error(e, stack);
      ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
      rethrow;
    }
  }

  // Load cards from Hive box asynchronously
  Future<void> loadCards() async {
    state = AsyncValue.data(_box.values.toList());
  }

  // Handle box changes for real-time updates
  void _onBoxChange() {
    final newCards =
        _box.values.toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    if (newCards != state) {
      state = AsyncValue.data(newCards);
    }
  }

  Future<void> add(CreditCardModel card) async {
    try {
      await _box.put(card.id, card);
      _onBoxChange();
      await _triggerSync();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
      rethrow;
    }
  }

  Future<void> delete(String cardId) async {
    print('[DEBUG] creditCardProvider.delete called');
    state = const AsyncValue.loading();
    try {
      if (!_box.containsKey(cardId)) {
        throw const FormatException(AppStrings.cardNotFoundError);
      }
      final card = _box.get(cardId)!;
      await _box.delete(cardId);
      final cardPayments =
          ref
              .read(paymentBoxProvider)
              .values
              .where((p) => p.cardId == card.id)
              .toList();
      for (var payment in cardPayments) {
        await ref.read(paymentBoxProvider).delete(payment.id);
      }
      state = AsyncValue.data(_box.values.toList());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
      rethrow;
    }
  }

  Future<void> clearCards() async {
    try {
      await _box.clear();
      _onBoxChange();
      await _triggerSync();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
      rethrow;
    }
  }

  // Get sorted cards (use state directly)
  List<CreditCardModel> get sortedOnDueDate => state.value ?? [];

  markArchive(String cardId) async {
    state = const AsyncValue.loading();
    try {
      if (!_box.containsKey(cardId)) {
        throw const FormatException(AppStrings.cardNotFoundError);
      }
      final card = _box.get(cardId)!;
      var archivedCard = card.copyWith(isArchived: true, syncPending: true);

      _box.put(card.id, archivedCard);
      _onBoxChange();
      ref.read(syncStatusProvider.notifier).state = SyncStatus.syncing;
      _triggerSync();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
      rethrow;
    }
  }

  reset() {
    state = const AsyncValue.loading();
    _box.listenable().removeListener(_onBoxChange);
    _box.clear();
    state = AsyncValue.data([]);
  }
}
