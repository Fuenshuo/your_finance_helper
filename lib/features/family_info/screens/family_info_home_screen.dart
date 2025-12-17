import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/services/storage_service.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/utils/notification_manager.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/features/family_info/screens/asset_management_screen.dart';
import 'package:your_finance_flutter/features/family_info/screens/clearance_home_screen.dart';
import 'package:your_finance_flutter/features/family_info/screens/salary_income_setup_screen.dart';
import 'package:your_finance_flutter/features/family_info/screens/wallet_management_screen.dart';

/// 家庭信息维护主页
class FamilyInfoHomeScreen extends StatefulWidget {
  const FamilyInfoHomeScreen({super.key});

  @override
  State<FamilyInfoHomeScreen> createState() => _FamilyInfoHomeScreenState();
}

class _FamilyInfoHomeScreenState extends State<FamilyInfoHomeScreen> {
  List<SalaryIncome> _salaryIncomes = [];

  @override
  void initState() {
    super.initState();
    _loadSalaryIncomes();
  }

  Future<void> _loadSalaryIncomes() async {
    try {
      final storageService = await StorageService.getInstance();
      final salaries = await storageService.loadSalaryIncomes();

      setState(() {
        _salaryIncomes = salaries;
      });
    } catch (e) {
      // Handle error if needed
    }
  }

  void _navigateToSalaryIncomeSetup() {
    // 如果有现有的工资收入数据，传递第一个进行编辑；否则创建新的
    final salaryIncomeToEdit =
        _salaryIncomes.isNotEmpty ? _salaryIncomes.first : null;

    // 导航逻辑

    Navigator.of(context)
        .push(
      AppAnimations.createRoute<void>(
        SalaryIncomeSetupScreen(
          salaryIncomeToEdit: salaryIncomeToEdit,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(context.responsiveSpacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 模块介绍
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          color: context.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '统一管理您的工资收入、资产配置和钱包账户等静态财务信息',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.spacing16),

              // 功能卡片网格
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: context.responsiveSpacing12,
                crossAxisSpacing: context.responsiveSpacing12,
                children: [
                  // 工资管理卡片
                  _buildFeatureCard(
                    context,
                    icon: Icons.monetization_on_outlined,
                    title: '工资管理',
                    subtitle: '薪资结构与奖金设置',
                    color: const Color(0xFFFF6B6B),
                    onTap: _navigateToSalaryIncomeSetup,
                  ),

                  // 资产管理卡片
                  _buildFeatureCard(
                    context,
                    icon: Icons.account_balance_outlined,
                    title: '资产管理',
                    subtitle: '房产、股票、理财等资产',
                    color: const Color(0xFF4ECDC4),
                    onTap: () {
                      Navigator.of(context).push(
                        AppAnimations.createRoute<void>(
                          const AssetManagementScreen(),
                        ),
                      );
                    },
                  ),

                  // 钱包管理卡片
                  _buildFeatureCard(
                    context,
                    icon: Icons.account_balance_wallet_outlined,
                    title: '钱包管理',
                    subtitle: '银行卡、电子钱包等账户',
                    color: const Color(0xFF45B7D1),
                    onTap: () {
                      Navigator.of(context).push(
                        AppAnimations.createRoute<void>(
                          const WalletManagementScreen(),
                        ),
                      );
                    },
                  ),

                  // 清账管理卡片
                  _buildFeatureCard(
                    context,
                    icon: Icons.checklist_outlined,
                    title: '清账管理',
                    subtitle: '余额盘点与动账核销',
                    color: const Color(0xFF9B59B6),
                    onTap: () {
                      Navigator.of(context).push(
                        AppAnimations.createRoute<void>(
                          ClearanceHomeScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: context.spacing32),

              // 快速操作
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚡ 快速操作',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.spacing16),

                    // 快速操作按钮
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionButton(
                            context,
                            icon: Icons.add_circle_outline,
                            label: '添加资产',
                            onTap: () {
                              // TODO: 导航到添加资产页面
                            },
                          ),
                        ),
                        SizedBox(width: context.spacing12),
                        Expanded(
                          child: _buildQuickActionButton(
                            context,
                            icon: Icons.account_balance_outlined,
                            label: '添加钱包',
                            onTap: () {
                              // TODO: 导航到添加钱包页面
                              // 测试毛玻璃通知功能
                              NotificationManager().showNotification(
                                context,
                                message: '🎉 毛玻璃通知已优化完成！\n现在背景透明且不影响操作',
                                icon: Icons.auto_awesome,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.responsiveSpacing12),
        child: AppCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(context.responsiveSpacing12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              SizedBox(height: context.spacing12),
              Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.spacing4),
              Text(
                subtitle,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.secondaryText,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.primaryBackground,
          foregroundColor: context.primaryText,
          elevation: 0,
          side: BorderSide(color: context.dividerColor),
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveSpacing16,
            vertical: context.responsiveSpacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.responsiveSpacing8),
          ),
        ),
      );
}
