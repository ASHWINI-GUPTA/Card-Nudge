import 'package:card_nudge/data/hive/models/delete_queue_entry.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../adapters/card_type_adapter.dart';

class DeleteQueueEntryStorage {
  static Box<DeleteQueueEntry>? _box;

  static Box<DeleteQueueEntry> getBox() {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Hive box not initialized. Call initHive() first.');
    }
    return _box!;
  }

  static Future<void> initHive() async {
    Hive.registerAdapter(DeleteQueueEntryAdapter());
    Hive.registerAdapter(EntitiesAdapter());

    _box = await Hive.openBox<DeleteQueueEntry>('delete_queue');
  }
}
