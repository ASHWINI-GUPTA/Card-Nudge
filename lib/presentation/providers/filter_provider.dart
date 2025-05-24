import 'package:flutter_riverpod/flutter_riverpod.dart';

final filterProvider = StateProvider<Map<String, dynamic>>(
  (ref) => {'sort': 'asc', 'range': 'all'},
);
