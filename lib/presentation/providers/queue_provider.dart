import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/hive/models/delete_queue_entry.dart';
import '../../data/hive/storage/delete_queue_entry_storage.dart';

final deleteQueueBoxProvider = Provider<Box<DeleteQueueEntry>>((ref) {
  return DeleteQueueEntryStorage.getBox();
});
