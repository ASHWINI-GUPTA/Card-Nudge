enum Entities { card, payment }

// Extension to get table name from Entities enum
extension EntitiesExtension on Entities {
  String get table {
    switch (this) {
      case Entities.card:
        return 'cards';
      case Entities.payment:
        return 'payments';
    }
  }
}
