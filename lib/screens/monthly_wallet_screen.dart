import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/providers/budget_provider.dart';
import 'package:your_finance_flutter/screens/monthly_wallet_detail_screen.dart';
import 'package:your_finance_flutter/features/family_info/screens/salary_income_setup_screen.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';

class MonthlyWalletScreen extends StatefulWidget {
  const MonthlyWalletScreen({super.key});

  @override
  State<MonthlyWalletScreen> createState() => _MonthlyWalletScreenState();
}

class _MonthlyWalletScreenState extends State<MonthlyWalletScreen> {
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    // 页面加载时自动生成今年的钱包
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateYearWallets();
    });
  }

  Future<void> _generateYearWallets() async {
    final budgetProvider = context.read<BudgetProvider>();
    final salaryIncomes = budgetProvider.salaryIncomes;

    if (salaryIncomes.isNotEmpty) {
      // 使用第一个工资设置生成钱包
      await budgetProvider.generateYearlyWallets(
        salaryIncomes.first,
        _selectedYear,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            '每月工资钱包',
            style: context.textTheme.headlineMedium,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _generateYearWallets,
              icon: const Icon(Icons.refresh),
              tooltip: '重新生成钱包',
            ),
          ],
        ),
        body: Consumer<BudgetProvider>(
          builder: (context, budgetProvider, child) {
            final wallets = budgetProvider.getYearlyWallets(_selectedYear);
            final salaryIncomes = budgetProvider.salaryIncomes;

            if (salaryIncomes.isEmpty) {
              return _buildNoSalaryIncomeView();
            }

            return Column(
              children: [
                // 年份选择器
                Container(
                  padding: EdgeInsets.all(context.responsiveSpacing16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Text(
                        '选择年份:',
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: context.responsiveSpacing16),
                      Expanded(
                        child: DropdownButton<int>(
                          value: _selectedYear,
                          isExpanded: true,
                          items: List.generate(5, (index) {
                            final year = DateTime.now().year - 2 + index;
                            return DropdownMenuItem(
                              value: year,
                              child: Text('$year年'),
                            );
                          }),
                          onChanged: (year) {
                            if (year != null) {
                              setState(() => _selectedYear = year);
                              _generateYearWallets();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // 钱包列表
                Expanded(
                  child: wallets.isEmpty
                      ? _buildEmptyView()
                      : _buildWalletList(wallets),
                ),
              ],
            );
          },
        ),
      );

  Widget _buildNoSalaryIncomeView() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: context.secondaryText,
            ),
            SizedBox(height: context.responsiveSpacing16),
            Text(
              '未设置工资收入',
              style: context.textTheme.headlineMedium?.copyWith(
                color: context.secondaryText,
              ),
            ),
            SizedBox(height: context.responsiveSpacing8),
            Text(
              '请先设置工资收入信息',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.secondaryText,
              ),
            ),
            SizedBox(height: context.responsiveSpacing24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  AppAnimations.createRoute(
                    const SalaryIncomeSetupScreen(),
                  ),
                );
              },
              child: const Text('设置工资收入'),
            ),
          ],
        ),
      );

  Widget _buildEmptyView() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_view_month_outlined,
              size: 64,
              color: context.secondaryText,
            ),
            SizedBox(height: context.responsiveSpacing16),
            Text(
              '$_selectedYear年暂无工资钱包',
              style: context.textTheme.headlineMedium?.copyWith(
                color: context.secondaryText,
              ),
            ),
            SizedBox(height: context.responsiveSpacing8),
            Text(
              '点击右上角刷新按钮生成钱包',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.secondaryText,
              ),
            ),
          ],
        ),
      );

  Widget _buildWalletList(List<MonthlyWallet> wallets) => ListView.builder(
        padding: EdgeInsets.all(context.responsiveSpacing16),
        itemCount: wallets.length,
        itemBuilder: (context, index) {
          final wallet = wallets[index];
          return AppAnimations.animatedListItem(
            index: index,
            child: AppCard(
              margin: EdgeInsets.only(bottom: context.responsiveSpacing12),
              onTap: () => _navigateToWalletDetail(wallet),
              child: Container(
                padding: EdgeInsets.all(context.responsiveSpacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 月份和状态
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${wallet.year}年${wallet.month}月',
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.spacing8,
                            vertical: context.spacing4,
                          ),
                          decoration: BoxDecoration(
                            color: wallet.isPaid
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            wallet.isPaid ? '已发放' : '未发放',
                            style: context.textTheme.labelSmall?.copyWith(
                              color:
                                  wallet.isPaid ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.responsiveSpacing12),

                    // 收入明细
                    Row(
                      children: [
                        Expanded(
                          child: _buildWalletItem(
                            '税前收入',
                            wallet.grossIncome,
                            context.increaseColor,
                          ),
                        ),
                        Expanded(
                          child: _buildWalletItem(
                            '扣除金额',
                            wallet.totalDeductions,
                            context.decreaseColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.responsiveSpacing8),

                    // 到手工资
                    Container(
                      padding: EdgeInsets.all(context.responsiveSpacing12),
                      decoration: BoxDecoration(
                        color: context.primaryAction.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '到手工资',
                            style: context.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            context.formatAmount(wallet.netIncome),
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: context.primaryAction,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 奖金信息
                    if (wallet.totalBonuses > 0) ...[
                      SizedBox(height: context.responsiveSpacing8),
                      Text(
                        '奖金: ${context.formatAmount(wallet.totalBonuses)}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.secondaryText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      );

  Widget _buildWalletItem(String label, double amount, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.secondaryText,
            ),
          ),
          SizedBox(height: context.spacing4),
          Text(
            context.formatAmount(amount),
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      );

  void _navigateToWalletDetail(MonthlyWallet wallet) {
    Navigator.of(context).push(
      AppAnimations.createRoute(
        MonthlyWalletDetailScreen(wallet: wallet),
      ),
    );
  }
}
