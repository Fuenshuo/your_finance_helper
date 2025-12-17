import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/bonus_item.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/providers/budget_provider.dart';
import 'package:your_finance_flutter/core/services/logging_service.dart';
import 'package:your_finance_flutter/core/services/salary_calculation_service.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/features/family_info/widgets/salary_summary_widget.dart';

class SalaryPreviewScreen extends StatefulWidget {
  const SalaryPreviewScreen({
    required this.salaryIncome,
    super.key,
  });

  final SalaryIncome salaryIncome;

  @override
  State<SalaryPreviewScreen> createState() => _SalaryPreviewScreenState();
}

class _SalaryPreviewScreenState extends State<SalaryPreviewScreen> {
  late SalaryCalculationResult _calculationResult;
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _calculateSalary();
  }

  void _calculateSalary() async {
    setState(() {
      _isCalculating = true;
    });

    final logger = LoggingService();
    await logger.initialize();

    await logger.log('🧮 开始计算工资: 年度累积模式');
    await logger.log(
      '💼 基本信息: 基本工资=${widget.salaryIncome.basicSalary}, 奖金数量=${widget.salaryIncome.bonuses.length}',
    );

    // 打印奖金详情
    for (var i = 0; i < widget.salaryIncome.bonuses.length; i++) {
      final bonus = widget.salaryIncome.bonuses[i];
      await logger.log(
        '🎁 奖金${i + 1}: ${bonus.name}, 类型=${bonus.type}, 金额=${bonus.amount}, 频率=${bonus.frequency}, 开始日期=${bonus.startDate}',
      );
      if (bonus.type == BonusType.quarterlyBonus) {
        await logger.log('  季度奖金发放月份: ${bonus.quarterlyPaymentMonths}');
      }
    }

    // 使用年度累积预扣法进行计算
    await logger.log('📊 使用年度累积预扣法计算');

    _calculationResult =
        await SalaryCalculationService.calculateAutoCumulative(
      completedMonths: 12, // 固定计算12个月（一年）
      salaryHistory: widget.salaryIncome.salaryHistory ?? {},
      basicSalary: widget.salaryIncome.basicSalary,
      housingAllowance: widget.salaryIncome.housingAllowance,
      mealAllowance: widget.salaryIncome.mealAllowance,
      transportationAllowance: widget.salaryIncome.transportationAllowance,
      otherAllowance: widget.salaryIncome.otherAllowance,
      performanceBonus: 0, // 暂时不支持
      socialInsurance: widget.salaryIncome.socialInsurance,
      housingFund: widget.salaryIncome.housingFund,
      specialDeductionMonthly: widget.salaryIncome.specialDeductionMonthly,
      otherTaxFreeIncome: 0, // 暂时不支持
      otherTaxFreeMonthly: 0,
      bonuses: widget.salaryIncome.bonuses,
      monthlyAllowances: widget.salaryIncome.monthlyAllowances, // 月度津贴记录
    );
    await logger.log(
      '✅ 年度累积计算完成: 基本收入=${_calculationResult.basicIncome}, 津贴收入=${_calculationResult.allowanceIncome}, 奖金收入=${_calculationResult.bonusIncome}, 总收入=${_calculationResult.totalIncome}, 总税费=${_calculationResult.totalTax}, 净收入=${_calculationResult.netIncome}',
    );

    setState(() {
      _isCalculating = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            '工资核算结果',
            style: context.textTheme.headlineMedium,
          ),
          centerTitle: true,
          actions: [],
        ),
        body: _isCalculating
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(context.responsiveSpacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 步骤指示器
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStepIndicator('填写收入', true),
                        _buildStepConnector(),
                        _buildStepIndicator('选择模式', true),
                        _buildStepConnector(),
                        _buildStepIndicator('查看结果', true),
                      ],
                    ),

                    SizedBox(height: context.responsiveSpacing24),

                    // 计算模式信息
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '计算模式',
                            style: context.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: context.responsiveSpacing8),
                          Text(
                            '年度累积预扣法',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(height: context.responsiveSpacing4),
                          Text(
                            '按照年度收入累积计算个人所得税，提供更准确的税费预扣',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: context.responsiveSpacing16),

                    // 可展开的薪资计算详情
                    SalarySummaryWidget(
                      basicSalary: widget.salaryIncome.basicSalary,
                      housingAllowance: widget.salaryIncome.housingAllowance,
                      mealAllowance: widget.salaryIncome.mealAllowance,
                      transportationAllowance:
                          widget.salaryIncome.transportationAllowance,
                      otherAllowance: widget.salaryIncome.otherAllowance,
                      performanceBonus: 0, // 暂时不支持
                      otherBonuses: _calculationResult.bonusIncome,
                      personalIncomeTax: _calculationResult.totalTax,
                      socialInsurance: widget.salaryIncome.socialInsurance,
                      housingFund: widget.salaryIncome.housingFund,
                      otherDeductions:
                          widget.salaryIncome.specialDeductionMonthly,
                      otherTaxDeductions:
                          widget.salaryIncome.otherTaxDeductions, // 其他税收扣除
                      bonuses: widget.salaryIncome.bonuses,
                      salaryDay: widget.salaryIncome.salaryDay,
                      monthlyAllowances:
                          widget.salaryIncome.monthlyAllowances, // 月度津贴记录
                    ),

                    SizedBox(height: context.responsiveSpacing32),

                    // 操作按钮
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: context.responsiveSpacing16,
                              ),
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              '返回修改',
                              style: context.textTheme.bodyLarge,
                            ),
                          ),
                        ),
                        SizedBox(width: context.responsiveSpacing16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveSalaryIncome,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: context.responsiveSpacing16,
                              ),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              '保存设置',
                              style: context.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: context.responsiveSpacing32),
                  ],
                ),
              ),
      );

  Widget _buildStepIndicator(String title, bool isCompleted) => Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? Colors.blue : Colors.grey[300],
            ),
            child: Icon(
              isCompleted ? Icons.check : Icons.circle,
              color: Colors.white,
              size: 16,
            ),
          ),
          SizedBox(height: context.responsiveSpacing4),
          Text(
            title,
            style: context.textTheme.bodySmall?.copyWith(
              color: isCompleted ? Colors.blue : context.secondaryText,
              fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      );

  Widget _buildStepConnector() => Container(
        width: 40,
        height: 2,
        color: Colors.grey[300],
        margin: EdgeInsets.symmetric(horizontal: context.responsiveSpacing8),
      );


  void _saveSalaryIncome() async {
    try {
      // Get the budget provider
      final budgetProvider =
          Provider.of<BudgetProvider>(context, listen: false);

      // Save the updated salary income (widget.salaryIncome already has the updated bonuses)
      await budgetProvider.updateSalaryIncome(widget.salaryIncome);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('工资收入设置已保存')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存失败，请重试')),
      );
    }
  }
}
