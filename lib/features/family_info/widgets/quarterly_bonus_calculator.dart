/// Business logic calculator for quarterly bonuses
class QuarterlyBonusCalculator {
  /// Custom quarterly months that user can configure (deprecated - moved to BonusItem)
  @deprecated
  static List<int> customQuarterlyMonths = [3, 6, 9, 12];

  /// Check if quarterly months configuration is valid for calculations
  @deprecated
  static bool isValidForCalculation() => const [3, 6, 9, 12].isNotEmpty;

  /// Calculate payment dates based on count (new approach)
  static List<DateTime> calculatePaymentDatesFromCount(
    DateTime startDate,
    int paymentCount,
  ) {
    const defaultQuarterlyMonths = [3, 6, 9, 12];
    return calculatePaymentDatesFromCountWithMonths(
      startDate,
      paymentCount,
      defaultQuarterlyMonths,
    );
  }

  /// Calculate end date based on start date and payment count
  static DateTime calculateEndDate(DateTime startDate, int paymentCount) {
    if (paymentCount <= 1) return startDate;

    final paymentDates =
        calculatePaymentDatesFromCount(startDate, paymentCount);
    return paymentDates.isNotEmpty ? paymentDates.last : startDate;
  }

  /// Calculate payment dates based on count with specific quarterly months
  static List<DateTime> calculatePaymentDatesFromCountWithMonths(
    DateTime startDate,
    int paymentCount,
    List<int> quarterlyMonths,
  ) {
    final dates = <DateTime>[];

    // If no quarterly months are configured, use defaults
    final effectiveMonths =
        quarterlyMonths.isNotEmpty ? quarterlyMonths : [3, 6, 9, 12];

    // Ensure start date is a quarterly month, adjust if necessary
    final startQuarterIndex = effectiveMonths.indexOf(startDate.month);
    var currentQuarterIndex = startQuarterIndex;

    // If start date is not a quarterly month, find the next quarterly month
    if (currentQuarterIndex == -1) {
      final currentMonth = startDate.month;
      // Find the next quarterly month
      for (var i = 0; i < effectiveMonths.length; i++) {
        if (effectiveMonths[i] > currentMonth) {
          currentQuarterIndex = i;
          break;
        }
      }
      // If no next quarterly month this year, start from January next year
      if (currentQuarterIndex == -1) {
        currentQuarterIndex = 0;
      }
    }

    var currentYear = startDate.year;
    // If we moved to next year, increment year
    if (currentQuarterIndex == 0 &&
        startQuarterIndex == -1 &&
        startDate.month > effectiveMonths.last) {
      currentYear++;
    }

    for (var i = 0; i < paymentCount; i++) {
      final month = effectiveMonths[currentQuarterIndex];
      dates.add(DateTime(currentYear, month, 15));

      // Move to next quarter
      currentQuarterIndex++;
      if (currentQuarterIndex >= effectiveMonths.length) {
        currentQuarterIndex = 0;
        currentYear++;
      }
    }

    return dates;
  }

  /// Calculate end date based on start date and payment count with specific months
  static DateTime calculateEndDateWithMonths(
    DateTime startDate,
    int paymentCount,
    List<int> quarterlyMonths,
  ) {
    if (paymentCount <= 1) return startDate;

    final paymentDates = calculatePaymentDatesFromCountWithMonths(
      startDate,
      paymentCount,
      quarterlyMonths,
    );
    return paymentDates.isNotEmpty ? paymentDates.last : startDate;
  }

  /// Get the next quarterly date from given date with specific months
  static DateTime getNextQuarterlyDateWithMonths(
    DateTime fromDate,
    List<int> quarterlyMonths,
  ) {
    final currentMonth = fromDate.month;

    // Check if we have any quarterly months configured
    final effectiveMonths =
        quarterlyMonths.isNotEmpty ? quarterlyMonths : [3, 6, 9, 12];
    if (effectiveMonths.isEmpty) {
      return fromDate; // Return original date if no months configured
    }

    // Find the next quarterly month
    for (final month in effectiveMonths) {
      if (month >= currentMonth) {
        return DateTime(fromDate.year, month, 15);
      }
    }

    // If current month is past the last quarterly month, return next year's first quarterly month
    return DateTime(fromDate.year + 1, effectiveMonths.first, 15);
  }

  /// Check if can add more quarterly months (max 4)
  @deprecated
  static bool canAddQuarterlyMonth() => const [3, 6, 9, 12].length < 4;

  /// Check if can add more quarterly months for specific months list
  static bool canAddQuarterlyMonthForMonths(List<int> quarterlyMonths) =>
      quarterlyMonths.length < 4;

  /// Get the next quarterly date from given date
  static DateTime getNextQuarterlyDate(DateTime fromDate) {
    const defaultQuarterlyMonths = [3, 6, 9, 12];
    final currentMonth = fromDate.month;

    // Find the next quarterly month
    for (final month in defaultQuarterlyMonths) {
      if (month >= currentMonth) {
        return DateTime(fromDate.year, month, 15);
      }
    }

    // If current month is past the last quarterly month, return next year's first quarterly month
    return DateTime(fromDate.year + 1, defaultQuarterlyMonths.first, 15);
  }

  /// Legacy method for backward compatibility
  static List<DateTime> calculatePaymentDates(
    DateTime startDate,
    int durationYears,
  ) {
    const defaultQuarterlyMonths = [3, 6, 9, 12];
    final dates = <DateTime>[];

    for (var year = 0; year < durationYears; year++) {
      for (final month in defaultQuarterlyMonths) {
        final paymentDate = DateTime(startDate.year + year, month, 15);

        // Ensure date is not before start date
        if (paymentDate.isAtSameMomentAs(startDate) ||
            paymentDate.isAfter(startDate)) {
          dates.add(paymentDate);
        }
      }
    }

    return dates;
  }
}
