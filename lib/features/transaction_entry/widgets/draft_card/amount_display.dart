import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 金额显示组件
class AmountDisplay extends StatelessWidget {
  const AmountDisplay({
    required this.amount,
    super.key,
    this.currency = 'CNY',
  });
  final double? amount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (amount == null) {
      return Text(
        '未解析金额',
        style: theme.textTheme.headlineSmall?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final formattedAmount = _formatAmount(amount!);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // 货币符号
        Text(
          _getCurrencySymbol(currency),
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(width: 4),

        // 金额数字
        Text(
          formattedAmount,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontFeatures: const [FontFeature.tabularFigures()], // 等宽数字
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'zh_CN',
      symbol: '', // 不显示货币符号，我们手动添加
      decimalDigits: amount.truncateToDouble() == amount ? 0 : 2,
    );

    return formatter.format(amount);
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'CNY':
        return '¥';
      case 'USD':
        return r'$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      default:
        return currency;
    }
  }
}
