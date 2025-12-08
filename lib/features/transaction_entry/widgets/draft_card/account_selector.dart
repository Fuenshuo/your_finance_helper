import 'package:flutter/material.dart';

/// 账户选择器组件
class AccountSelector extends StatelessWidget {
  final String? selectedAccountId;
  final ValueChanged<String?> onAccountSelected;

  const AccountSelector({
    super.key,
    this.selectedAccountId,
    required this.onAccountSelected,
  });

  // 临时账户数据
  static const List<Map<String, dynamic>> _accounts = [
    {'id': 'cash', 'name': '现金', 'icon': Icons.money, 'color': Colors.green},
    {'id': 'card', 'name': '银行卡', 'icon': Icons.credit_card, 'color': Colors.blue},
    {'id': 'alipay', 'name': '支付宝', 'icon': Icons.account_balance_wallet, 'color': Colors.blue},
    {'id': 'wechat', 'name': '微信', 'icon': Icons.chat, 'color': Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final selectedAccount = _accounts.firstWhere(
      (acc) => acc['id'] == selectedAccountId,
      orElse: () => _accounts.first,
    );

    return InkWell(
      onTap: () => _showAccountPicker(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedAccountId != null
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              selectedAccount['icon'] as IconData,
              size: 20,
              color: selectedAccountId != null
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedAccountId != null
                    ? selectedAccount['name'] as String
                    : '选择账户',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: selectedAccountId != null
                      ? colorScheme.onSurface
                      : colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _accounts.map((account) {
            final isSelected = account['id'] == selectedAccountId;
            return ListTile(
              leading: Icon(
                account['icon'] as IconData,
                color: account['color'] as Color,
              ),
              title: Text(account['name'] as String),
              selected: isSelected,
              onTap: () {
                onAccountSelected(account['id'] as String);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

