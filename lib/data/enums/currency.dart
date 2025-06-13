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

  String get code {
    switch (this) {
      case Currency.INR:
        return 'INR';
      case Currency.USD:
        return 'USD';
    }
  }

  String get locale {
    switch (this) {
      case Currency.INR:
        return 'en_IN';
      case Currency.USD:
        return 'en_US';
    }
  }

  String get symbolWithCode {
    switch (this) {
      case Currency.INR:
        return '₹ INR';
      case Currency.USD:
        return '\$ USD';
    }
  }
}
