import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';

/// A utility class for retrieving localized month names.
///
/// Example:
/// ```dart
/// final months = MonthNameHelper.getMonthNames(l10n);
/// print(months); // ["January", "February", ...] depending on locale
/// ```
class CalenderHelper {
  // Cache month names per locale for performance.
  static final Map<String, List<String>> _cache = {};

  /// Returns a list of 12 month names for the given [AppLocalizations].
  ///
  /// You can specify [abbreviated] to get short names ("Jan", "Feb", ...).
  /// Defaults to full names ("January", "February", ...).
  static List<String> getMonthNames(
    AppLocalizations l10n, {
    bool abbreviated = false,
  }) {
    final locale = l10n.localeName;
    final cacheKey = '$locale-${abbreviated ? "short" : "full"}';

    // Return cached list if available
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    final formatter = DateFormat(abbreviated ? 'MMM' : 'MMMM', locale);

    // Generate months using 2024 to avoid DateTime(0, ...)
    final months = List<String>.generate(12, (i) {
      final date = DateTime(2024, i + 1, 1);
      return formatter.format(date);
    });

    _cache[cacheKey] = months;
    return months;
  }
}
