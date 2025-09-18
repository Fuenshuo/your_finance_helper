import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/utils/notification_manager.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/features/transaction_flow/screens/transaction_records_screen.dart';

/// 交易流水主页
class TransactionFlowHomeScreen extends StatefulWidget {
  const TransactionFlowHomeScreen({super.key});

  @override
  State<TransactionFlowHomeScreen> createState() =>
      _TransactionFlowHomeScreenState();
}

class _TransactionFlowHomeScreenState extends State<TransactionFlowHomeScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            '交易流水',
            style: context.textTheme.headlineMedium,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _showAddTransactionDialog,
              icon: const Icon(Icons.add),
              tooltip: '添加交易',
            ),
          ],
        ),
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
                    Text(
                      '💳 交易流水',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.spacing8),
                    Text(
                      '查看所有交易记录，与财务计划智能关联，掌握资金流动情况',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.spacing16),

              // 本月统计
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '📊 本月统计',
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '2024年9月',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.secondaryText,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.spacing16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMonthStat(
                            context,
                            label: '收入',
                            amount: '+¥25,000',
                            count: '12笔',
                            color: const Color(0xFF4CAF50),
                          ),
                        ),
                        SizedBox(width: context.spacing12),
                        Expanded(
                          child: _buildMonthStat(
                            context,
                            label: '支出',
                            amount: '-¥18,500',
                            count: '28笔',
                            color: const Color(0xFFF44336),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.spacing12),
                    Container(
                      padding: EdgeInsets.all(context.responsiveSpacing12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(context.responsiveSpacing8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.trending_up,
                            color: Color(0xFF4CAF50),
                            size: 20,
                          ),
                          SizedBox(width: context.spacing8),
                          Expanded(
                            child: Text(
                              '本月结余：+¥6,500',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF4CAF50),
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

              // 快速操作
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.receipt_long_outlined,
                      title: '交易记录',
                      subtitle: '查看所有交易',
                      color: const Color(0xFF2196F3),
                      onTap: () {
                        Navigator.of(context).push(
                          AppAnimations.createRoute(
                            const TransactionRecordsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: context.spacing12),
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.search,
                      title: '交易搜索',
                      subtitle: '查找特定交易',
                      color: const Color(0xFFFF9800),
                      onTap: () {
                        // TODO: 导航到交易搜索页面
                        NotificationManager().showDevelopmentHint(
                          context,
                          '交易搜索',
                          additionalInfo: '智能搜索和筛选功能即将上线',
                        );
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.spacing24),

              // 最近交易
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '🕒 最近交易',
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: 查看全部交易
                          },
                          child: Text(
                            '查看全部',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.spacing16),

                    // 示例交易记录
                    _buildTransactionItem(
                      context,
                      title: '工资收入',
                      subtitle: '中国银行 · 工资',
                      amount: '+¥25,000.00',
                      time: '今天 09:30',
                      type: 'income',
                      isAuto: true,
                    ),

                    SizedBox(height: context.spacing12),

                    _buildTransactionItem(
                      context,
                      title: '房贷还款',
                      subtitle: '中国银行 → 房贷账户',
                      amount: '-¥8,500.00',
                      time: '昨天 15:00',
                      type: 'expense',
                      isAuto: true,
                    ),

                    SizedBox(height: context.spacing12),

                    _buildTransactionItem(
                      context,
                      title: '超市购物',
                      subtitle: '微信支付',
                      amount: '-¥156.80',
                      time: '昨天 12:30',
                      type: 'expense',
                      isAuto: false,
                    ),

                    SizedBox(height: context.spacing12),

                    _buildTransactionItem(
                      context,
                      title: '股票分红',
                      subtitle: '招商证券',
                      amount: '+¥2,340.00',
                      time: '前天 10:15',
                      type: 'income',
                      isAuto: false,
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.spacing24),

              // 智能建议
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 智能建议',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.spacing16),
                    Container(
                      padding: EdgeInsets.all(context.responsiveSpacing12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3).withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(context.responsiveSpacing8),
                        border: Border.all(
                          color: const Color(0xFF2196F3).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            color: Color(0xFF2196F3),
                            size: 24,
                          ),
                          SizedBox(width: context.spacing12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '重复交易提醒',
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: context.spacing4),
                                Text(
                                  '检测到您连续2个月在同一家超市消费，建议创建定期支出计划',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: context.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // TODO: 创建支出计划
                            },
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildMonthStat(
    BuildContext context, {
    required String label,
    required String amount,
    required String count,
    required Color color,
  }) =>
      Container(
        padding: EdgeInsets.all(context.responsiveSpacing12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(context.responsiveSpacing8),
        ),
        child: Column(
          children: [
            Text(
              amount,
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
            SizedBox(height: context.spacing2),
            Text(
              count,
              style: context.textTheme.bodySmall?.copyWith(
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );

  Widget _buildQuickActionCard(
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
            children: [
              Container(
                padding: EdgeInsets.all(context.responsiveSpacing12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              SizedBox(height: context.spacing8),
              Text(
                title,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.spacing2),
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

  Widget _buildTransactionItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String amount,
    required String time,
    required String type,
    required bool isAuto,
  }) {
    final isIncome = type == 'income';
    final color = isIncome ? const Color(0xFF4CAF50) : const Color(0xFFF44336);

    return Container(
      padding: EdgeInsets.all(context.responsiveSpacing12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.02),
        borderRadius: BorderRadius.circular(context.responsiveSpacing8),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.responsiveSpacing8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome ? Icons.trending_up : Icons.trending_down,
              color: color,
              size: 16,
            ),
          ),
          SizedBox(width: context.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isAuto)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.responsiveSpacing6,
                          vertical: context.spacing2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(context.responsiveSpacing8),
                        ),
                        child: Text(
                          '自动',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF2196F3),
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: context.spacing2),
                Text(
                  subtitle,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: context.spacing12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: context.spacing2),
              Text(
                time,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.secondaryText,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog() {
    // TODO: 显示添加交易对话框
    NotificationManager().showDevelopmentHint(
      context,
      '添加交易',
      additionalInfo: '快速录入和自动分类功能即将推出',
    );
  }
}
