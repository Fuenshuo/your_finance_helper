import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';
import 'package:your_finance_flutter/features/insights/models/budget_data.dart';

/// Daily Budget Velocity Widget
///
/// Displays daily spending progress with:
/// - Thin LinearProgressIndicator (4px height)
/// - Progress ratio visualization
/// - Remaining amount display
/// - Zero-budget empty state handling
///
/// Usage:
/// ```dart
/// DailyBudgetVelocity(
///   budgetData: BudgetData(
///     budgetAmount: 200.0,
///     spentAmount: 112.0,
///     date: DateTime.now(),
///   ),
/// )
/// ```
class DailyBudgetVelocity extends StatelessWidget {
  const DailyBudgetVelocity({
    super.key,
    this.budgetData,
  });
  final BudgetData? budgetData;

  @override
  Widget build(BuildContext context) {
    // Handle zero/null budget case
    if (budgetData == null || budgetData!.budgetAmount == 0) {
      return _buildEmptyState(context);
    }

    final data = budgetData!;
    final progressRatio =
        data.progressRatio.clamp(0.0, 1.0); // Clamp to valid range
    final isOverspent = data.isOverspent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        Container(
          height: 4, // Thin progress indicator
          decoration: BoxDecoration(
            color: AppDesignTokens.inputFill(context),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progressRatio,
            child: Container(
              decoration: BoxDecoration(
                color: isOverspent
                    ? AppDesignTokens.amountNegativeColor(
                        context,
                      ) // Red for overspend
                    : AppDesignTokens.amountPositiveColor(
                        context,
                      ), // Green for normal
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Amount display
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Spent: ¥${data.spentAmount.toStringAsFixed(0)}',
              style: AppDesignTokens.body(context),
            ),
            Text(
              data.isOverspent
                  ? 'Over: ¥${(-data.remainingAmount).toStringAsFixed(0)}'
                  : 'Left: ¥${data.remainingAmount.toStringAsFixed(0)}',
              style: AppDesignTokens.body(context).copyWith(
                color: data.isOverspent
                    ? AppDesignTokens.amountNegativeColor(context)
                    : AppDesignTokens.amountPositiveColor(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) => Container(
        height: 60, // Minimum touch target
        alignment: Alignment.center,
        child: Text(
          'Set a budget to see velocity',
          style: AppDesignTokens.caption(context).copyWith(
            color: AppDesignTokens.secondaryText(context),
          ),
          textAlign: TextAlign.center,
        ),
      );
}
