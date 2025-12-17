import 'package:equatable/equatable.dart';

/// Represents daily budget tracking and spending progress.
class BudgetData extends Equatable {
  // Budget date

  const BudgetData({
    required this.budgetAmount,
    required this.spentAmount,
    required this.date,
  });
  final double budgetAmount; // Total daily budget (e.g., ¥200)
  final double spentAmount; // Amount spent today (e.g., ¥112)
  final DateTime date;

  // Calculated properties
  double get remainingAmount => budgetAmount - spentAmount;
  double get progressRatio =>
      budgetAmount > 0 ? spentAmount / budgetAmount : 0.0;
  bool get isOverspent => spentAmount > budgetAmount;

  // Validation
  bool get isValid => budgetAmount >= 0 && spentAmount >= 0;

  @override
  List<Object?> get props => [budgetAmount, spentAmount, date];
}
