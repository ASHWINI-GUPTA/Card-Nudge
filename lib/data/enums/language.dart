enum Language { English, Hindi }

extension LanguageLocale on Language {
  String get locale {
    switch (this) {
      case Language.English:
        return 'en_US';
      case Language.Hindi:
        return 'hi_IN';
    }
  }
}
