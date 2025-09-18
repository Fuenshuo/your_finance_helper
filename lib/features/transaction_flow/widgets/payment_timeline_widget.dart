import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';

/// Simple payment timeline widget that displays payment dates in a grid
class PaymentTimelineWidget extends StatelessWidget {
  const PaymentTimelineWidget({
    required this.paymentDates,
    required this.amountPerPayment,
    super.key,
  });
  final List<DateTime> paymentDates;
  final double amountPerPayment;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(context.spacing8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            // Timeline header
            Row(
              children: [
                Icon(Icons.timeline, color: Colors.green.shade600, size: 16),
                SizedBox(width: context.spacing8),
                Text(
                  '发放时间轴',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.green.shade700,
                      ),
                ),
              ],
            ),
            SizedBox(height: context.spacing8),

            // Timeline nodes in a simple grid
            Wrap(
              spacing: context.spacing8,
              runSpacing: context.spacing8,
              children: paymentDates
                  .take(8)
                  .map(
                    (date) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing8,
                        vertical: context.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '¥${amountPerPayment.toStringAsFixed(0)}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                          ),
                          SizedBox(height: context.spacing4),
                          Text(
                            '${date.month}月',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 10,
                                      color: Colors.grey.shade700,
                                    ),
                          ),
                          Text(
                            '${date.year}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 9,
                                      color: Colors.grey.shade500,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),

            if (paymentDates.length > 8)
              Padding(
                padding: EdgeInsets.only(top: context.spacing8),
                child: Text(
                  '... 还有${paymentDates.length - 8}次发放',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                      ),
                ),
              ),
          ],
        ),
      );
}
