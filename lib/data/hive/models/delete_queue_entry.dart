import 'package:hive/hive.dart';

import '../../enums/entities.dart';

part 'delete_queue_entry.g.dart';

@HiveType(typeId: 21)
class DeleteQueueEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final Entities entityType;

  @HiveField(2)
  final DateTime createdAt;

  DeleteQueueEntry({required this.id, required this.entityType})
    : this.createdAt = DateTime.now().toUtc();
}
