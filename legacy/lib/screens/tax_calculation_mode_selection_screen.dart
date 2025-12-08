import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/features/family_info/screens/salary_preview_screen.dart';

enum TaxCalculationMode {
  annualCumulative('年度累积预扣法', '根据全年收入累计计算每月预扣税，适合全年收入相对稳定的情况'),
  monthlyIndependent('每月独立计算', '每月单独计算当月税费，适合收入波动较大的情况');

  const TaxCalculationMode(this.title, this.description);

  final String title;
  final String description;
}

class TaxCalculationModeSelectionScreen extends StatefulWidget {
  const TaxCalculationModeSelectionScreen({
    required this.salaryIncome,
    super.key,
  });

  final SalaryIncome salaryIncome;

  @override
  State<TaxCalculationModeSelectionScreen> createState() =>
      _TaxCalculationModeSelectionScreenState();
}

class _TaxCalculationModeSelectionScreenState
    extends State<TaxCalculationModeSelectionScreen> {
  TaxCalculationMode _selectedMode = TaxCalculationMode.annualCumulative;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            '税收计算模式',
            style: context.textTheme.headlineMedium,
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // 步骤指示器
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveSpacing24,
                  vertical: context.responsiveSpacing16,
                ),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStepIndicator('填写收入', true),
                    _buildStepConnector(),
                    _buildStepIndicator('选择模式', true),
                    _buildStepConnector(),
                    _buildStepIndicator('查看结果', false),
                  ],
                ),
              ),

              // 主内容
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(context.responsiveSpacing24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题区域
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '选择税收计算模式',
                              style: context.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: context.primaryText,
                              ),
                            ),
                            SizedBox(height: context.spacing8),
                            Text(
                              '不同的计算模式会影响最终的税费结果，请根据您的收入特点选择最适合的计算方式',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.secondaryText,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: context.responsiveSpacing24),

                      // 计算模式选项
                      ...TaxCalculationMode.values.map(
                        (mode) => Padding(
                          padding: EdgeInsets.only(
                            bottom: context.responsiveSpacing16,
                          ),
                          child: _buildModeOption(mode),
                        ),
                      ),

                      SizedBox(height: context.responsiveSpacing32),

                      // 说明文本
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '💡 计算模式说明',
                              style: context.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: context.responsiveSpacing12),
                            Text(
                              '• 年度累积预扣法：适合全年收入相对稳定的情况，能更准确地反映实际税负\n• 每月独立计算：适合收入波动较大的情况，每个月独立计算税费',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.secondaryText,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: context.responsiveSpacing32),
                    ],
                  ),
                ),
              ),

              // 底部操作按钮
              Container(
                padding: EdgeInsets.all(context.responsiveSpacing24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: context.dividerColor,
                      width: 0.5,
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: context.responsiveSpacing16,
                            ),
                            side: BorderSide(color: context.dividerColor),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(context.borderRadius),
                            ),
                          ),
                          child: Text(
                            '返回修改',
                            style: context.textTheme.labelLarge?.copyWith(
                              color: context.primaryText,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: context.responsiveSpacing16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _continueToPreview,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: context.responsiveSpacing16,
                            ),
                            backgroundColor: context.primaryAction,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(context.borderRadius),
                            ),
                          ),
                          child: Text(
                            '查看结果',
                            style: context.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
          SizedBox(height: context.spacing4),
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

  Widget _buildModeOption(TaxCalculationMode mode) {
    final isSelected = _selectedMode == mode;

    return AppAnimations.animatedListItem(
      index: mode.index,
      child: AppCard(
        onTap: () => setState(() => _selectedMode = mode),
        child: Container(
          padding: EdgeInsets.all(context.responsiveSpacing16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? context.primaryAction : context.dividerColor,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(context.borderRadius),
            color: isSelected
                ? context.primaryAction.withOpacity(0.05)
                : Colors.white,
          ),
          child: Row(
            children: [
              // 选择指示器
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? context.primaryAction
                        : context.dividerColor,
                    width: 1.5,
                  ),
                  color: isSelected ? context.primaryAction : Colors.white,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      )
                    : null,
              ),

              SizedBox(width: context.responsiveSpacing16),

              // 内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          mode.title,
                          style: context.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? context.primaryAction
                                : context.primaryText,
                          ),
                        ),
                        if (mode == TaxCalculationMode.annualCumulative) ...[
                          SizedBox(width: context.spacing8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.spacing4,
                              vertical: context.spacing4,
                            ),
                            decoration: BoxDecoration(
                              color: context.increaseColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '推荐',
                              style: context.textTheme.labelLarge?.copyWith(
                                fontSize: 10,
                                color: context.increaseColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: context.spacing8),
                    Text(
                      mode.description,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.secondaryText,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // 推荐图标
              if (mode == TaxCalculationMode.annualCumulative)
                Icon(
                  Icons.star,
                  color: context.increaseColor,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _continueToPreview() {
    Navigator.of(context).pushReplacement(
      AppAnimations.createRoute(
        SalaryPreviewScreen(
          salaryIncome: widget.salaryIncome,
          calculationMode: _selectedMode,
        ),
      ),
    );
  }
}
