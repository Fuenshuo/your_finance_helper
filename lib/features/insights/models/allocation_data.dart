import 'package:equatable/equatable.dart';

/// Represents spending allocation breakdown between fixed and flexible expenses.
class AllocationData extends Equatable {
  // Time period for this allocation

  const AllocationData({
    required this.fixedAmount,
    required this.flexibleAmount,
    required this.period,
  });
  final double fixedAmount; // Fixed expenses (rent, bills, etc.)
  final double flexibleAmount; // Flexible expenses (discretionary spending)
  final DateTime period;

  // Calculated properties
  double get totalAmount => fixedAmount + flexibleAmount;
  double get flexibleRatio =>
      totalAmount > 0 ? flexibleAmount / totalAmount : 0.0;

  // Validation
  bool get isValid => fixedAmount >= 0 && flexibleAmount >= 0;

  @override
  List<Object?> get props => [fixedAmount, flexibleAmount, period];
}
