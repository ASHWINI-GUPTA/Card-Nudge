enum Language { en, hi }

extension LanguageLocale on Language {
  String get locale {
    switch (this) {
      case Language.en:
        return 'en_US';
      case Language.hi:
        return 'hi_IN';
    }
  }
}
