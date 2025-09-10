import 'package:flutter/material.dart';
import 'package:your_finance_flutter/services/chinese_mortgage_service.dart';
import 'package:your_finance_flutter/theme/app_theme.dart';
import 'package:your_finance_flutter/widgets/app_animations.dart';
import 'package:your_finance_flutter/widgets/app_card.dart';

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

  double _propertyValue = 0;
  double _downPaymentRatio = 0.3; // 默认首付30%
  List<MortgageRecommendation> _recommendations = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.propertyValue != null) {
      _propertyValue = widget.propertyValue!;
      _propertyValueController.text = _propertyValue.toStringAsFixed(0);
      _calculateRecommendations();
    }
  }

  @override
  void dispose() {
    _propertyValueController.dispose();
    _downPaymentController.dispose();
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
    if (_propertyValue <= 0) return;

    setState(() => _isLoading = true);

    try {
      final recommendations = _mortgageService.getMortgageRecommendations(
        propertyValue: _propertyValue,
        downPaymentRatio: _downPaymentRatio,
      );

      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showPaymentSchedule(MortgageCalculationResult result) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => PaymentScheduleScreen(result: result),
      ),
    );
  }

  void _createBudgetFromRecommendation(MortgageRecommendation recommendation) {
    // TODO: 实现创建预算功能
    // 静默创建预算，不显示提示框
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
