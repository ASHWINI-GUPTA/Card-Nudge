/**
 * A cache to store Intl.NumberFormat instances to avoid recreating them on every call.
 * This improves performance, especially when formatting many numbers in a loop.
 */
const formatterCache = new Map<string, Intl.NumberFormat>();

/**
 * Formats a number as a currency string using the Intl.NumberFormat API.
 * It uses a cache to reuse formatter instances for performance.
 * @param amount The number to format.
 * @param currencyCode The ISO 4217 currency code (e.g., "USD", "INR").
 * @param lang The BCP 47 language tag (e.g., "en-US", "hi-IN") to determine formatting conventions.
 * @returns A localized currency string (e.g., "$1,234", "₹1,234").
 */
export function formatCurrency(
  amount: number,
  currencyCode: string,
  lang: string,
): string {
  try {
    // Use Intl.NumberFormat for robust, localized currency formatting.
    return getNumberFormatter(lang, currencyCode).format(amount);
  } catch (e) {
    // Fallback for invalid currency codes or other errors.
    // Ensuring the function doesn't crash.
    console.warn(
      `Could not format currency for code ${currencyCode} and lang ${lang}. Using fallback.`,
      e,
    );
    return `${amount.toLocaleString(lang)} ${currencyCode.toUpperCase()}`;
  }
}

/**
 * Creates and caches an Intl.NumberFormat instance for a given language and currency.
 * This avoids the overhead of creating a new formatter for every call.
 *
 * @param lang The BCP 47 language tag (e.g., "en", "hi").
 * @param currencyCode The ISO 4217 currency code (e.g., "INR", "USD").
 * @returns An Intl.NumberFormat instance.
 */
function getNumberFormatter(
  lang: string,
  currencyCode: string,
): Intl.NumberFormat {
  const cacheKey = `${lang}-${currencyCode}`;
  if (formatterCache.has(cacheKey)) {
    return formatterCache.get(cacheKey)!;
  }

  const formatter = new Intl.NumberFormat(lang, {
    style: "currency",
    currency: currencyCode,
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });

  formatterCache.set(cacheKey, formatter);
  return formatter;
}
