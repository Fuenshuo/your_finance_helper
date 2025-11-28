import 'package:intl/intl.dart';

/// Currency formatting utility using intl package
/// Provides consistent formatting for monetary values across the app
class CurrencyFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'zh_CN',
    symbol: '¥',
    decimalDigits: 0, // No decimals for cleaner display
  );

  /// Format amount as currency string (¥1,234)
  static String format(double amount) {
    try {
      return _currencyFormat.format(amount);
    } catch (e) {
      // Fallback for invalid amounts
      return '¥${amount.toStringAsFixed(0)}';
    }
  }

  /// Format amount with decimals for precision display (¥1,234.56)
  static String formatWithDecimals(double amount) {
    try {
      final formatWithDecimals = NumberFormat.currency(
        locale: 'zh_CN',
        symbol: '¥',
        decimalDigits: 2,
      );
      return formatWithDecimals.format(amount);
    } catch (e) {
      // Fallback for invalid amounts
      return '¥${amount.toStringAsFixed(2)}';
    }
  }

  /// Parse currency string back to double
  static double? parse(String currencyString) {
    try {
      // Remove currency symbol and commas
      final cleanString = currencyString
          .replaceAll('¥', '')
          .replaceAll(',', '')
          .trim();

      return double.tryParse(cleanString);
    } catch (e) {
      return null;
    }
  }

  /// Check if string is valid currency format
  static bool isValidCurrency(String value) {
    return parse(value) != null;
  }
}
