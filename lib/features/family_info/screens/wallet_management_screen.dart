import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/features/family_info/screens/account_detail_screen.dart';
import 'package:your_finance_flutter/features/family_info/screens/add_wallet_screen.dart';

/// 钱包管理屏幕
class WalletManagementScreen extends StatefulWidget {
  const WalletManagementScreen({super.key});

  @override
  State<WalletManagementScreen> createState() => _WalletManagementScreenState();
}

class _WalletManagementScreenState extends State<WalletManagementScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          title: Text(
            '钱包管理',
            style: context.textTheme.headlineMedium,
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _navigateToAddWallet(context),
              tooltip: '添加钱包',
            ),
          ],
        ),
        body: Consumer2<AccountProvider, TransactionProvider>(
          builder: (context, accountProvider, transactionProvider, child) =>
              RefreshIndicator(
            onRefresh: () => accountProvider.refresh(),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.responsiveSpacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 模块介绍
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💰 钱包管理',
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: context.spacing8),
                        Text(
                          '统一管理您的银行账户、现金、投资账户等资金载体',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: context.spacing16),

                  // 账户统计
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📊 账户总览',
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: context.spacing16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                context,
                                label: '总资产',
                                amount: accountProvider.calculateTotalAssets(
                                  transactionProvider.transactions,
                                ),
                                color: const Color(0xFF4CAF50),
                              ),
                            ),
                            SizedBox(width: context.spacing12),
                            Expanded(
                              child: _buildStatItem(
                                context,
                                label: '总负债',
                                amount:
                                    accountProvider.calculateTotalLiabilities(
                                  transactionProvider.transactions,
                                ),
                                color: const Color(0xFFF44336),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.spacing12),
                        Container(
                          padding: EdgeInsets.all(context.responsiveSpacing12),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF2196F3).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              context.responsiveSpacing8,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.account_balance_wallet,
                                color: Color(0xFF2196F3),
                                size: 20,
                              ),
                              SizedBox(width: context.spacing8),
                              Expanded(
                                child: Text(
                                  '净资产：¥${accountProvider.calculateNetWorth(transactionProvider.transactions).toStringAsFixed(2)}',
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF2196F3),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: context.spacing16),

                  // 账户列表
                  if (accountProvider.accounts.isEmpty)
                    _buildEmptyState(context)
                  else
                    _buildAccountList(
                        context, accountProvider, transactionProvider),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required double amount,
    required Color color,
  }) =>
      Container(
        padding: EdgeInsets.all(context.responsiveSpacing12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(context.responsiveSpacing8),
        ),
        child: Column(
          children: [
            Text(
              '¥${amount.toStringAsFixed(2)}',
              style: context.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.spacing4),
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.secondaryText,
              ),
            ),
          ],
        ),
      );

  Widget _buildEmptyState(BuildContext context) => AppCard(
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 64,
                color: context.secondaryText.withValues(alpha: 0.5),
              ),
              SizedBox(height: context.spacing16),
              Text(
                '暂无钱包账户',
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.secondaryText,
                ),
              ),
              SizedBox(height: context.spacing8),
              Text(
                '添加您的第一个钱包账户，开始财务管理',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.secondaryText.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.spacing24),
              ElevatedButton.icon(
                onPressed: () => _navigateToAddWallet(context),
                icon: const Icon(Icons.add),
                label: const Text('添加钱包'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryAction,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildAccountList(
    BuildContext context,
    AccountProvider accountProvider,
    TransactionProvider transactionProvider,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💳 我的钱包',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: context.spacing16),

          // 资产账户
          if (accountProvider.assetAccounts.isNotEmpty) ...[
            _buildAccountSection(
              context,
              title: '资产账户',
              accounts: accountProvider.assetAccounts,
              accountProvider: accountProvider,
              transactionProvider: transactionProvider,
            ),
            SizedBox(height: context.spacing16),
          ],

          // 负债账户
          if (accountProvider.liabilityAccounts.isNotEmpty) ...[
            _buildAccountSection(
              context,
              title: '负债账户',
              accounts: accountProvider.liabilityAccounts,
              accountProvider: accountProvider,
              transactionProvider: transactionProvider,
            ),
          ],
        ],
      );

  Widget _buildAccountSection(
    BuildContext context, {
    required String title,
    required List<Account> accounts,
    required AccountProvider accountProvider,
    required TransactionProvider transactionProvider,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: context.spacing12),
          ...accounts.map(
            (account) => AppAnimations.animatedListItem(
              index: accounts.indexOf(account),
              child: _buildAccountCard(
                  context, account, accountProvider, transactionProvider),
            ),
          ),
        ],
      );

  Widget _buildAccountCard(
    BuildContext context,
    Account account,
    AccountProvider accountProvider,
    TransactionProvider transactionProvider,
  ) =>
      AppCard(
        margin: EdgeInsets.only(bottom: context.spacing12),
        onTap: () => _showAccountDetail(context, account),
        child: Padding(
          padding: EdgeInsets.all(context.responsiveSpacing16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      _getAccountTypeColor(account.type).withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(context.responsiveSpacing12),
                ),
                child: Icon(
                  _getAccountTypeIcon(account.type),
                  color: _getAccountTypeColor(account.type),
                  size: 24,
                ),
              ),
              SizedBox(width: context.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            account.name,
                            style: context.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (account.isDefault)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.responsiveSpacing8,
                              vertical: context.spacing4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  context.primaryAction.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                context.responsiveSpacing12,
                              ),
                            ),
                            child: Text(
                              '默认',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.primaryAction,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (account.description != null) ...[
                      SizedBox(height: context.spacing4),
                      Text(
                        account.description!,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.secondaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: context.spacing4),
                    Text(
                      account.bankName ?? account.type.displayName,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: context.spacing16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Builder(
                    builder: (context) {
                      final realBalance = accountProvider.getAccountBalance(
                        account.id,
                        transactionProvider.transactions,
                      );
                      final displayBalance =
                          account.type.isLiability ? -realBalance : realBalance;
                      return Text(
                        '¥${displayBalance.toStringAsFixed(2)}',
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: account.type.isLiability
                              ? context.decreaseColor
                              : context.increaseColor,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  if (account.type == AccountType.creditCard &&
                      account.creditLimit != null) ...[
                    SizedBox(height: context.spacing4),
                    Builder(
                      builder: (context) {
                        final realBalance = accountProvider.getAccountBalance(
                          account.id,
                          transactionProvider.transactions,
                        );
                        final availableBalance =
                            account.creditLimit! - realBalance;
                        return Text(
                          '可用 ¥${availableBalance.toStringAsFixed(2)}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.secondaryText,
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );

  IconData _getAccountTypeIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Icons.money;
      case AccountType.bank:
        return Icons.account_balance;
      case AccountType.creditCard:
        return Icons.credit_card;
      case AccountType.investment:
        return Icons.trending_up;
      case AccountType.loan:
        return Icons.account_balance_wallet;
      case AccountType.asset:
        return Icons.business;
      case AccountType.liability:
        return Icons.warning;
    }
  }

  Color _getAccountTypeColor(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return const Color(0xFF4CAF50); // 绿色
      case AccountType.bank:
        return const Color(0xFF2196F3); // 蓝色
      case AccountType.creditCard:
        return const Color(0xFFFF9800); // 橙色
      case AccountType.investment:
        return const Color(0xFF9C27B0); // 紫色
      case AccountType.loan:
        return const Color(0xFFF44336); // 红色
      case AccountType.asset:
        return const Color(0xFF00BCD4); // 青色
      case AccountType.liability:
        return const Color(0xFFFF5722); // 深橙色
    }
  }

  void _navigateToAddWallet(BuildContext context) {
    Navigator.of(context).push(
      AppAnimations.createRoute<void>(
        const AddWalletScreen(),
      ),
    );
  }

  void _showAccountDetail(BuildContext context, Account account) {
    Navigator.of(context).push(
      AppAnimations.createRoute<void>(
        AccountDetailScreen(account: account),
      ),
    );
  }
}
