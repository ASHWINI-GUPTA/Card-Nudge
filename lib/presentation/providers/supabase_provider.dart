import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/supabase_service.dart';

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService(ref);
});

final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.authStateChanges;
});
