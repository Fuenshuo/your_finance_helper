import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/providers/budget_provider.dart';
import 'package:your_finance_flutter/features/financial_planning/screens/budget_management_screen.dart';
import 'package:your_finance_flutter/core/services/chinese_mortgage_service.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/amount_input_field.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';

class MortgageCalculatorScreen extends StatefulWidget {
  const MortgageCalculatorScreen({
    super.key,
    this.propertyValue,
  });
  final double? propertyValue;

  @override
  State<MortgageCalculatorScreen> createState() =>
      _MortgageCalculatorScreenState();
}

class _MortgageCalculatorScreenState extends State<MortgageCalculatorScreen> {
  final ChineseMortgageService _mortgageService = ChineseMortgageService();
  final TextEditingController _propertyValueController =
      TextEditingController();
  final TextEditingController _downPaymentController = TextEditingController();

  // 组合贷款专用控制器
  final TextEditingController _gongjijinAmountController =
      TextEditingController();
  final TextEditingController _commercialAmountController =
      TextEditingController();

  double _propertyValue = 0;
  double _loanAmount = 0; // 总贷款额度
  double _downPaymentRatio = 0.3; // 默认首付30%
  int _loanYears = 30; // 总贷款年限
  double _interestRate = 0.0305; // 利率

  // 组合贷款专用字段
  double _gongjijinAmount = 0; // 公积金贷款额度
  int _gongjijinYears = 30; // 公积金贷款年限
  double _gongjijinRate = 0.026; // 公积金贷款利率 (2.6%)
  double _commercialAmount = 0; // 商业贷款额度
  int _commercialYears = 30; // 商业贷款年限
  double _commercialRate = 0.0305; // 商业贷款利率 (3.05%)

  MortgageType _mortgageType = MortgageType.combined; // 贷款类型
  List<MortgageRecommendation> _recommendations = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.propertyValue != null) {
      _propertyValue = widget.propertyValue!;
      _propertyValueController.text = _propertyValue.toStringAsFixed(0);
      // 根据房产总价自动计算贷款额度
      _loanAmount = _propertyValue * (1 - _downPaymentRatio);
    }
  }

  @override
  void dispose() {
    _propertyValueController.dispose();
    _downPaymentController.dispose();
    _gongjijinAmountController.dispose();
    _commercialAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          title: const Text('房贷计算器'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(context.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputSection(),
              SizedBox(height: context.spacing24),
              _buildRecommendationsSection(),
            ],
          ),
        ),
      );

  Widget _buildInputSection() => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '房产信息',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.spacing16),

            // 房产总价
            TextFormField(
              controller: _propertyValueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '房产总价（元）',
                hintText: '请输入房产总价',
                prefixIcon: const Icon(Icons.home),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                _propertyValue = double.tryParse(value) ?? 0;
                // 根据房产总价自动计算贷款额度
                _loanAmount = _propertyValue * (1 - _downPaymentRatio);
              },
            ),

            SizedBox(height: context.spacing16),

            // 贷款额度
            TextFormField(
              initialValue:
                  _loanAmount > 0 ? _loanAmount.toStringAsFixed(0) : '',
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '贷款额度（元）',
                hintText: '请输入贷款额度',
                prefixIcon: const Icon(Icons.account_balance),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                _loanAmount = double.tryParse(value) ?? 0;
                // 如果手动输入贷款额度，重新计算首付比例
                if (_propertyValue > 0) {
                  _downPaymentRatio =
                      (_propertyValue - _loanAmount) / _propertyValue;
                }
              },
            ),

            SizedBox(height: context.spacing16),

            // 首付比例
            Text(
              '首付比例',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: context.spacing8),

            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _downPaymentRatio,
                    min: 0.1,
                    max: 0.8,
                    divisions: 14,
                    label: '${(_downPaymentRatio * 100).toInt()}%',
                    onChanged: (value) {
                      setState(() {
                        _downPaymentRatio = value;
                      });
                    },
                  ),
                ),
                Text(
                  '${(_downPaymentRatio * 100).toInt()}%',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.primaryAction,
                  ),
                ),
              ],
            ),

            SizedBox(height: context.spacing16),

            // 贷款类型
            DropdownButtonFormField<MortgageType>(
              value: _mortgageType,
              decoration: InputDecoration(
                labelText: '贷款类型',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: MortgageType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _mortgageType = value;
                    // 根据贷款类型设置默认利率
                    switch (value) {
                      case MortgageType.commercial:
                        _interestRate = 0.0305; // 商业贷款3.05%
                        _commercialRate = 0.0305;
                      case MortgageType.gongjijin:
                        _interestRate = 0.026; // 公积金贷款2.6%
                        _gongjijinRate = 0.026;
                      case MortgageType.combined:
                        _interestRate = 0.029; // 组合贷款2.9%
                        // 重置组合贷款参数
                        _gongjijinAmount = 0;
                        _commercialAmount = 0;
                        _gongjijinYears = 30;
                        _commercialYears = 30;
                        _gongjijinRate = 0.026; // 重置为默认公积金利率
                        _commercialRate = 0.0305; // 重置为默认商业利率
                    }
                  });
                }
              },
            ),

            SizedBox(height: context.spacing16),

            // 组合贷款详细设置（仅在选择组合贷款时显示）
            if (_mortgageType == MortgageType.combined) ...[
              // 分割线
              Container(
                height: 1,
                color: Colors.grey[300],
                margin: EdgeInsets.symmetric(vertical: context.spacing8),
              ),

              Text(
                '组合贷款详情设置',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.primaryAction,
                ),
              ),

              SizedBox(height: context.spacing16),

              // 公积金贷款设置
              Text(
                '公积金贷款',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),

              SizedBox(height: context.spacing8),

              Row(
                children: [
                  Expanded(
                    flex: 3, // 额度输入框占3份
                    child: AmountInputField(
                      controller: _gongjijinAmountController,
                      labelText: '公积金贷款额度',
                      hintText: '请输入额度',
                      prefixIcon: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.blue,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _gongjijinAmount = double.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: context.spacing12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _gongjijinYears,
                      decoration: InputDecoration(
                        labelText: '年限',
                        labelStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                      ),
                      items: [5, 10, 15, 20, 25, 30]
                          .map(
                            (years) => DropdownMenuItem(
                              value: years,
                              child: Text('$years年'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _gongjijinYears = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.spacing16),

              // 商业贷款设置
              Text(
                '商业贷款',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[700],
                ),
              ),

              SizedBox(height: context.spacing8),

              Row(
                children: [
                  Expanded(
                    flex: 3, // 额度输入框占3份
                    child: AmountInputField(
                      controller: _commercialAmountController,
                      labelText: '商业贷款额度',
                      hintText: '请输入额度',
                      prefixIcon: const Icon(
                        Icons.business_center,
                        color: Colors.orange,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _commercialAmount = double.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: context.spacing12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _commercialYears,
                      decoration: InputDecoration(
                        labelText: '年限',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                      ),
                      items: [5, 10, 15, 20, 25, 30]
                          .map(
                            (years) => DropdownMenuItem(
                              value: years,
                              child: Text('$years年'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _commercialYears = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.spacing12),

              // 总额提示
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[700],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '组合贷款总额: ¥${(_gongjijinAmount + _commercialAmount).toStringAsFixed(0)}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.spacing16),

              // 公积金利率设置
              Text(
                '利率设置',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.primaryAction,
                ),
              ),

              SizedBox(height: context.spacing8),

              Row(
                children: [
                  Expanded(
                    flex: 3, // 公积金利率输入框占3份
                    child: TextFormField(
                      initialValue: (_gongjijinRate * 100).toStringAsFixed(2),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '公积金利率（%）',
                        hintText: '请输入利率',
                        prefixIcon: const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.blue,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _gongjijinRate = (double.tryParse(value) ?? 0) / 100;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: context.spacing12),
                  Expanded(
                    flex: 3, // 商业利率输入框占3份
                    child: TextFormField(
                      initialValue: (_commercialRate * 100).toStringAsFixed(2),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '商业利率（%）',
                        hintText: '请输入利率',
                        prefixIcon: const Icon(
                          Icons.business_center,
                          color: Colors.orange,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _commercialRate = (double.tryParse(value) ?? 0) / 100;
                        });
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.spacing16),
            ],

            // 贷款年限（仅在非组合贷款时显示）
            if (_mortgageType != MortgageType.combined) ...[
              DropdownButtonFormField<int>(
                value: _loanYears,
                decoration: InputDecoration(
                  labelText: '贷款年限',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [5, 10, 15, 20, 25, 30]
                    .map(
                      (years) => DropdownMenuItem(
                        value: years,
                        child: Text('$years年'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _loanYears = value;
                    });
                  }
                },
              ),
              SizedBox(height: context.spacing16),
            ],

            // 计算按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _propertyValue > 0 ? _calculateRecommendations : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryAction,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: context.spacing12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        '计算房贷方案',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      );

  Widget _buildRecommendationsSection() {
    if (_recommendations.isEmpty) {
      return AppCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(context.spacing32),
            child: Column(
              children: [
                Icon(
                  Icons.calculate_outlined,
                  size: 80,
                  color: context.secondaryText,
                ),
                SizedBox(height: context.spacing16),
                Text(
                  '请输入房产信息',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.secondaryText,
                  ),
                ),
                SizedBox(height: context.spacing8),
                Text(
                  '系统将为您推荐最适合的房贷方案',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '推荐方案',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: context.spacing16),
        ..._recommendations.asMap().entries.map((entry) {
          final index = entry.key;
          final recommendation = entry.value;
          return AppAnimations.animatedListItem(
            index: index,
            child: _buildRecommendationCard(recommendation),
          );
        }),
      ],
    );
  }

  Widget _buildRecommendationCard(MortgageRecommendation recommendation) =>
      Container(
        margin: EdgeInsets.only(bottom: context.spacing16),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 方案标题和评分
              Row(
                children: [
                  Expanded(
                    child: Text(
                      recommendation.title,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacing8,
                      vertical: context.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: _getScoreColor(recommendation.score),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${recommendation.score}/10',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.spacing8),

              Text(
                recommendation.description,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.secondaryText,
                ),
              ),

              SizedBox(height: context.spacing16),

              // 关键数据
              _buildKeyMetrics(recommendation.result),

              SizedBox(height: context.spacing16),

              // 优缺点
              Row(
                children: [
                  Expanded(
                    child: _buildProsCons(
                      '优点',
                      recommendation.pros,
                      Colors.green,
                      Icons.check_circle,
                    ),
                  ),
                  SizedBox(width: context.spacing16),
                  Expanded(
                    child: _buildProsCons(
                      '缺点',
                      recommendation.cons,
                      Colors.orange,
                      Icons.warning,
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.spacing16),

              // 操作按钮
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _showPaymentSchedule(recommendation.result),
                      style: OutlinedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: context.spacing8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('查看还款计划'),
                    ),
                  ),
                  SizedBox(width: context.spacing12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _createBudgetFromRecommendation(recommendation),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryAction,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(vertical: context.spacing8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('创建预算'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildKeyMetrics(MortgageCalculationResult result) => Container(
        padding: EdgeInsets.all(context.spacing12),
        decoration: BoxDecoration(
          color: context.primaryBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    '月供',
                    '¥${result.monthlyPayment.toStringAsFixed(0)}',
                    Icons.payment,
                    context.primaryAction,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    '总利息',
                    '¥${(result.totalInterest / 10000).toStringAsFixed(1)}万',
                    Icons.trending_up,
                    context.increaseColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.spacing12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    '贷款总额',
                    '¥${(result.totalAmount / 10000).toStringAsFixed(1)}万',
                    Icons.account_balance,
                    context.primaryText,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    '利率',
                    '${(result.rate * 100).toStringAsFixed(2)}%',
                    Icons.percent,
                    context.secondaryText,
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildMetricItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) =>
      Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: context.spacing4),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.secondaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      );

  Widget _buildProsCons(
    String title,
    List<String> items,
    Color color,
    IconData icon,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              SizedBox(width: context.spacing4),
              Text(
                title,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing8),
          ...items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: context.spacing4),
              child: Text(
                '• $item',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.secondaryText,
                ),
              ),
            ),
          ),
        ],
      );

  Color _getScoreColor(int score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.orange;
    return Colors.red;
  }

  Future<void> _calculateRecommendations() async {
    if (_loanAmount <= 0) return;

    setState(() => _isLoading = true);

    try {
      // 根据用户选择的参数生成推荐方案
      final recommendations = <MortgageRecommendation>[];

      switch (_mortgageType) {
        case MortgageType.commercial:
          // 纯商业贷款
          final commercialResult = _mortgageService.calculateMortgage(
            totalAmount: _loanAmount,
            type: MortgageType.commercial,
            years: _loanYears,
            commercialRate: _interestRate,
          );

          recommendations.add(
            MortgageRecommendation(
              title: '纯商业贷款',
              description:
                  '利率${(_interestRate * 100).toStringAsFixed(2)}%，$_loanYears年期',
              result: commercialResult,
              pros: ['审批简单', '额度充足', '放款快'],
              cons: ['利率较高', '总利息多'],
              score: 7,
            ),
          );

        case MortgageType.gongjijin:
          // 纯公积金贷款
          final gongjijinResult = _mortgageService.calculateMortgage(
            totalAmount: _loanAmount,
            type: MortgageType.gongjijin,
            years: _loanYears,
            gongjijinRate: _interestRate,
          );

          recommendations.add(
            MortgageRecommendation(
              title: '纯公积金贷款',
              description:
                  '利率${(_interestRate * 100).toStringAsFixed(2)}%，$_loanYears年期',
              result: gongjijinResult,
              pros: ['利率最低', '总利息少', '还款压力小'],
              cons: ['额度限制', '审批较慢'],
              score: 9,
            ),
          );

        case MortgageType.combined:
          // 组合贷款（用户自定义各部分额度）
          final totalCombinedAmount = _gongjijinAmount + _commercialAmount;

          if (_gongjijinAmount > 0 && _commercialAmount > 0) {
            // 同时有公积金和商业贷款
            final combinedResult = _mortgageService.calculateMortgage(
              totalAmount: totalCombinedAmount,
              type: MortgageType.combined,
              years: max(_commercialYears, _gongjijinYears), // 使用较长年限
              commercialAmount: _commercialAmount,
              gongjijinAmount: _gongjijinAmount,
              commercialRate: _commercialRate, // 用户设置的商业贷款利率
              gongjijinRate: _gongjijinRate, // 用户设置的公积金贷款利率
              commercialYears: _commercialYears, // 商业贷款年限
              gongjijinYears: _gongjijinYears, // 公积金贷款年限
            );

            recommendations.add(
              MortgageRecommendation(
                title: '组合贷款',
                description:
                    '公积金¥${_gongjijinAmount.toStringAsFixed(0)}($_gongjijinYears年,${(_gongjijinRate * 100).toStringAsFixed(2)}%) + 商业¥${_commercialAmount.toStringAsFixed(0)}($_commercialYears年,${(_commercialRate * 100).toStringAsFixed(2)}%)',
                result: combinedResult,
                pros: ['利率适中', '额度充足', '灵活性强', '精准计算'],
                cons: ['手续复杂', '审批时间长'],
                score: 9,
              ),
            );
          } else if (_gongjijinAmount > 0) {
            // 只有公积金贷款
            final gongjijinResult = _mortgageService.calculateMortgage(
              totalAmount: _gongjijinAmount,
              type: MortgageType.gongjijin,
              years: _gongjijinYears,
              gongjijinRate: _gongjijinRate,
            );

            recommendations.add(
              MortgageRecommendation(
                title: '公积金贷款',
                description:
                    '¥${_gongjijinAmount.toStringAsFixed(0)}，$_gongjijinYears年期，${(_gongjijinRate * 100).toStringAsFixed(2)}%',
                result: gongjijinResult,
                pros: ['利率最低', '总利息少', '还款压力小'],
                cons: ['额度限制', '审批较慢'],
                score: 8,
              ),
            );
          } else if (_commercialAmount > 0) {
            // 只有商业贷款
            final commercialResult = _mortgageService.calculateMortgage(
              totalAmount: _commercialAmount,
              type: MortgageType.commercial,
              years: _commercialYears,
              commercialRate: _commercialRate,
            );

            recommendations.add(
              MortgageRecommendation(
                title: '商业贷款',
                description:
                    '¥${_commercialAmount.toStringAsFixed(0)}，$_commercialYears年期，${(_commercialRate * 100).toStringAsFixed(2)}%',
                result: commercialResult,
                pros: ['审批简单', '额度充足', '放款快'],
                cons: ['利率较高', '总利息多'],
                score: 7,
              ),
            );
          } else {
            // 默认情况：各占一半
            final commercialAmount = _loanAmount / 2;
            final gongjijinAmount = _loanAmount / 2;

            final combinedResult = _mortgageService.calculateMortgage(
              totalAmount: _loanAmount,
              type: MortgageType.combined,
              years: _loanYears,
              commercialAmount: commercialAmount,
              gongjijinAmount: gongjijinAmount,
              commercialRate: _commercialRate,
              gongjijinRate: _gongjijinRate,
            );

            recommendations.add(
              MortgageRecommendation(
                title: '组合贷款（默认）',
                description: '各占50%，$_loanYears年期',
                result: combinedResult,
                pros: ['利率适中', '额度充足', '灵活性强'],
                cons: ['手续复杂', '审批时间长'],
                score: 7,
              ),
            );
          }

          // 也提供纯商业和纯公积金的对比
          final pureCommercialResult = _mortgageService.calculateMortgage(
            totalAmount: _loanAmount,
            type: MortgageType.commercial,
            years: _loanYears,
            commercialRate: _commercialRate,
          );

          recommendations.add(
            MortgageRecommendation(
              title: '纯商业贷款（对比）',
              description: '仅供对比参考',
              result: pureCommercialResult,
              pros: ['审批简单', '额度充足'],
              cons: ['利率较高', '总利息多'],
              score: 6,
            ),
          );
      }

      // 按评分排序
      recommendations.sort((a, b) => b.score.compareTo(a.score));

      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ 计算房贷失败: $e');
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('计算失败，请检查输入参数'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPaymentSchedule(MortgageCalculationResult result) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => PaymentScheduleScreen(result: result),
      ),
    );
  }

  Future<void> _createBudgetFromRecommendation(
    MortgageRecommendation recommendation,
  ) async {
    print(
      '💰 创建房贷预算: ${recommendation.title}, 月供: ¥${recommendation.result.monthlyPayment.toStringAsFixed(0)}',
    );

    try {
      final budgetProvider =
          Provider.of<BudgetProvider>(context, listen: false);
      final now = DateTime.now();

      // 检查是否有工资收入数据
      if (budgetProvider.salaryIncomes.isEmpty) {
        // 如果没有收入数据，先引导用户设置收入
        final shouldSetupIncome = await _showIncomeSetupDialog();
        if (!shouldSetupIncome) {
          // 用户选择跳过，直接使用默认收入计算
          print('💰 用户跳过收入设置，使用默认计算');
        } else {
          // 用户选择设置收入，导航到收入设置页面
          await _navigateToIncomeSetup();
          return; // 返回，让用户设置完收入后再创建预算
        }
      }

      // 创建月度零基预算（使用实际收入或默认计算）
      final totalIncome = budgetProvider.getTotalMonthlyIncome() > 0
          ? budgetProvider.getTotalMonthlyIncome() // 使用实际工资收入
          : recommendation.result.monthlyPayment * 2; // 默认：月供的2倍

      await budgetProvider.createMonthlyZeroBasedBudget(
        name: '房贷预算 - ${recommendation.title}',
        totalIncome: totalIncome,
        month: now,
      );

      // 创建房贷支出信封预算
      await budgetProvider.createEnvelopeBudget(
        name: '房贷月供 - ${recommendation.title}',
        category: TransactionCategory.housing,
        allocatedAmount: recommendation.result.monthlyPayment,
        period: BudgetPeriod.monthly,
        startDate: DateTime(now.year, now.month),
        endDate:
            DateTime(now.year, now.month + 1).subtract(const Duration(days: 1)),
      );

      print('✅ 房贷预算创建成功');

      // 显示成功提示并导航到预算管理页面
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '房贷预算创建成功！每月预算 ¥${recommendation.result.monthlyPayment.toStringAsFixed(0)}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: '查看预算',
              textColor: Colors.white,
              onPressed: () {
                // 导航到预算管理页面
                Navigator.of(context).push<Widget>(
                  MaterialPageRoute<Widget>(
                    builder: (context) => const BudgetManagementScreen(),
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ 创建房贷预算失败: $e');

      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('创建预算失败，请稍后重试'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // 显示收入设置对话框
  Future<bool> _showIncomeSetupDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置工资收入'),
        content: const Text(
          '为了更准确地计算预算，建议您先设置工资收入信息。这将帮助我们基于您的实际收入来规划支出分配。\n\n如果跳过此步骤，我们将使用默认的收入估算（月供的2倍）。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('跳过'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('设置收入'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // 导航到收入设置页面
  Future<void> _navigateToIncomeSetup() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BudgetManagementScreen(initialTabIndex: 3),
      ),
    );

    // 用户设置完收入后，重新尝试创建预算
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('收入设置完成！请重新点击"创建预算"'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

/// 还款计划表页面
class PaymentScheduleScreen extends StatelessWidget {
  const PaymentScheduleScreen({
    required this.result,
    super.key,
  });
  final MortgageCalculationResult result;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          title: const Text('还款计划表'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            // 汇总信息
            Container(
              margin: EdgeInsets.all(context.spacing16),
              child: AppCard(
                child: Column(
                  children: [
                    Text(
                      '还款汇总',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.spacing16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryItem(
                            context,
                            '月供',
                            '¥${result.monthlyPayment.toStringAsFixed(0)}',
                            Icons.payment,
                            Colors.blue,
                          ),
                        ),
                        Expanded(
                          child: _buildSummaryItem(
                            context,
                            '总还款',
                            '¥${(result.totalPayment / 10000).toStringAsFixed(1)}万',
                            Icons.account_balance,
                            Colors.black,
                          ),
                        ),
                        Expanded(
                          child: _buildSummaryItem(
                            context,
                            '总利息',
                            '¥${(result.totalInterest / 10000).toStringAsFixed(1)}万',
                            Icons.trending_up,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 还款计划表
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: context.spacing16),
                itemCount: result.paymentSchedule.length,
                itemBuilder: (context, index) {
                  final item = result.paymentSchedule[index];
                  return AppAnimations.animatedListItem(
                    index: index,
                    child: _buildPaymentItem(context, item),
                  );
                },
              ),
            ),
          ],
        ),
      );

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) =>
      Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      );

  Widget _buildPaymentItem(BuildContext context, PaymentScheduleItem item) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: AppCard(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '第${item.month}期',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      '¥${item.monthlyPayment.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '本金: ¥${item.principalPayment.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '利息: ¥${item.interestPayment.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '余额: ¥${(item.remainingPrincipal / 10000).toStringAsFixed(1)}万',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
