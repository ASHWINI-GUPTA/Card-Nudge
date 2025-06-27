// providers.dart
import 'package:card_nudge/data/enums/sync_status.dart';
import 'package:card_nudge/data/hive/storage/payment_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/hive/storage/bank_storage.dart';
import '../../data/hive/storage/credit_card_storage.dart';
import '../../data/hive/storage/setting_storage.dart';
import '../../services/sync_service.dart';

final syncStatusProvider = StateProvider<SyncStatus>((ref) => SyncStatus.idle);

final syncServiceProvider = Provider<SyncService>((ref) {
  final supabase = Supabase.instance.client;
  final bankBox = BankStorage.getBox();
  final cardBox = CreditCardStorage.getBox();
  final paymentBox = PaymentStorage.getBox();
  final settingsBox = SettingStorage.getBox();
  final connectivity = Connectivity();
  return SyncService(
    supabase: supabase,
    bankBox: bankBox,
    cardBox: cardBox,
    paymentBox: paymentBox,
    settingsBox: settingsBox,
    connectivity: connectivity,
  );
});

final connectivityStatusProvider = StreamProvider<List<ConnectivityResult>>((
  ref,
) {
  final connectivity = Connectivity();
  return connectivity.onConnectivityChanged;
});
