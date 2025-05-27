enum Currency { INR, USD }

extension CurrencySymbol on Currency {
  String get symbol {
    switch (this) {
      case Currency.INR:
        return '₹';
      case Currency.USD:
        return '\$';
    }
  }
}
