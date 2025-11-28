import 'package:equatable/equatable.dart';

/// Represents weekly spending trend data points for chart visualization.
class TrendData extends Equatable {
  final DateTime date;           // Data point date
  final double amount;          // Spending amount for this day
  final String dayLabel;        // Display label (e.g., "Mon", "Tue")

  const TrendData({
    required this.date,
    required this.amount,
    required this.dayLabel,
  });

  // Validation
  bool get isValid => amount >= 0 && dayLabel.isNotEmpty;

  @override
  List<Object?> get props => [date, amount, dayLabel];
}
