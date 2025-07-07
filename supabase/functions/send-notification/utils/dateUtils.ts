/**
 * Calculates the number of days between two dates, ignoring the time component.
 * @param d1 The first date.
 * @param d2 The second date.
 * @returns The number of full days between d1 and d2. A positive number means d2 is after d1.
 */
export function getDaysDifference(d1: Date, d2: Date): number {
  const MS_PER_DAY = 1000 * 60 * 60 * 24;
  // Discard the time and time-zone information for a pure date comparison.
  const utc1 = Date.UTC(d1.getFullYear(), d1.getMonth(), d1.getDate());
  const utc2 = Date.UTC(d2.getFullYear(), d2.getMonth(), d2.getDate());

  return Math.floor((utc2 - utc1) / MS_PER_DAY);
}
