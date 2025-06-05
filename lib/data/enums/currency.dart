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

extension CurrencyCode on Currency {
  String get code {
    switch (this) {
      case Currency.INR:
        return 'INR';
      case Currency.USD:
        return 'USD';
    }
  }
}

extension CurrencyLocale on Currency {
  String get locale {
    switch (this) {
      case Currency.INR:
        return 'en_IN';
      case Currency.USD:
        return 'en_US';
    }
  }
}
