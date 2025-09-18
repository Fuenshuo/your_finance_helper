import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/providers/budget_provider.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';

class MonthlyWalletDetailScreen extends StatefulWidget {
  const MonthlyWalletDetailScreen({
    required this.wallet,
    super.key,
  });

  final MonthlyWallet wallet;

  @override
  State<MonthlyWalletDetailScreen> createState() =>
      _MonthlyWalletDetailScreenState();
}

class _MonthlyWalletDetailScreenState extends State<MonthlyWalletDetailScreen> {
  late MonthlyWallet _wallet;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  // 编辑用的控制器
  late final TextEditingController _basicSalaryController;
  late final TextEditingController _housingAllowanceController;
  late final TextEditingController _mealAllowanceController;
  late final TextEditingController _transportationAllowanceController;
  late final TextEditingController _otherAllowanceController;
  late final TextEditingController _socialInsuranceController;
  late final TextEditingController _housingFundController;
  late final TextEditingController _otherDeductionsController;
  late final TextEditingController _specialDeductionController;
  late final TextEditingController _adjustmentReasonController;

  @override
  void initState() {
    super.initState();
    _wallet = widget.wallet;
    _initializeControllers();
  }

  void _initializeControllers() {
    _basicSalaryController =
        TextEditingController(text: _wallet.basicSalary.toString());
    _housingAllowanceController =
        TextEditingController(text: _wallet.housingAllowance.toString());
    _mealAllowanceController =
        TextEditingController(text: _wallet.mealAllowance.toString());
    _transportationAllowanceController =
        TextEditingController(text: _wallet.transportationAllowance.toString());
    _otherAllowanceController =
        TextEditingController(text: _wallet.otherAllowance.toString());
    _socialInsuranceController =
        TextEditingController(text: _wallet.socialInsurance.toString());
    _housingFundController =
        TextEditingController(text: _wallet.housingFund.toString());
    _otherDeductionsController =
        TextEditingController(text: _wallet.otherDeductions.toString());
    _specialDeductionController =
        TextEditingController(text: _wallet.specialDeductionMonthly.toString());
    _adjustmentReasonController =
        TextEditingController(text: _wallet.adjustmentReason ?? '');
  }

  @override
  void dispose() {
    _basicSalaryController.dispose();
    _housingAllowanceController.dispose();
    _mealAllowanceController.dispose();
    _transportationAllowanceController.dispose();
    _otherAllowanceController.dispose();
    _socialInsuranceController.dispose();
    _housingFundController.dispose();
    _otherDeductionsController.dispose();
    _specialDeductionController.dispose();
    _adjustmentReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            '${_wallet.year}年${_wallet.month}月工资详情',
            style: context.textTheme.headlineMedium,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _toggleEditMode,
              icon: Icon(_isEditing ? Icons.check : Icons.edit),
              tooltip: _isEditing ? '保存修改' : '编辑',
            ),
            if (_isEditing)
              IconButton(
                onPressed: _cancelEdit,
                icon: const Icon(Icons.close),
                tooltip: '取消',
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.responsiveSpacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 状态信息
                AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '发放状态',
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.spacing8,
                          vertical: context.spacing4,
                        ),
                        decoration: BoxDecoration(
                          color: _wallet.isPaid
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _wallet.isPaid ? '已发放' : '未发放',
                          style: context.textTheme.labelSmall?.copyWith(
                            color:
                                _wallet.isPaid ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.responsiveSpacing16),

                // 收入明细
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '收入明细',
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '税前总收入: ${context.formatAmount(_wallet.grossIncome)}',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.responsiveSpacing16),
                      _buildEditableField(
                        '基本工资',
                        _basicSalaryController,
                        '请输入基本工资金额',
                      ),
                      _buildEditableField(
                        '住房补贴',
                        _housingAllowanceController,
                        '请输入住房补贴金额',
                      ),
                      _buildEditableField(
                        '餐费补贴',
                        _mealAllowanceController,
                        '请输入餐费补贴金额',
                      ),
                      _buildEditableField(
                        '交通补贴',
                        _transportationAllowanceController,
                        '请输入交通补贴金额',
                      ),
                      _buildEditableField(
                        '其他补贴',
                        _otherAllowanceController,
                        '请输入其他补贴金额',
                      ),
                      if (_wallet.bonuses.isNotEmpty) ...[
                        Divider(height: context.responsiveSpacing24),
                        Text(
                          '奖金明细',
                          style: context.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: context.responsiveSpacing8),
                        ..._wallet.bonuses.map(
                          (bonus) => Padding(
                            padding: EdgeInsets.only(bottom: context.spacing8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  bonus.name,
                                  style: context.textTheme.bodyMedium,
                                ),
                                Text(
                                  context.formatAmount(bonus.amount),
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: context.responsiveSpacing16),

                // 扣除明细
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '扣除明细',
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: context.responsiveSpacing16),
                      _buildEditableField(
                        '五险',
                        _socialInsuranceController,
                        '请输入五险金额',
                      ),
                      _buildEditableField(
                        '公积金',
                        _housingFundController,
                        '请输入公积金金额',
                      ),
                      _buildEditableField(
                        '其他扣除',
                        _otherDeductionsController,
                        '请输入其他扣除金额',
                      ),
                      _buildEditableField(
                        '专项附加扣除',
                        _specialDeductionController,
                        '请输入专项附加扣除金额',
                      ),
                      Divider(height: context.responsiveSpacing24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '应纳税所得额',
                            style: context.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            context.formatAmount(_calculateTaxableIncome()),
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: context.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.spacing8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '个人所得税',
                            style: context.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            context.formatAmount(_wallet.calculatedTax),
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: context.decreaseColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.responsiveSpacing16),

                // 调整原因
                if (_isEditing)
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '调整原因',
                          style: context.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: context.responsiveSpacing8),
                        TextFormField(
                          controller: _adjustmentReasonController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: '请说明本次调整的原因（可选）',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 最终结果
                AppCard(
                  child: Container(
                    padding: EdgeInsets.all(context.responsiveSpacing16),
                    decoration: BoxDecoration(
                      color: context.primaryAction.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '到手工资',
                              style: context.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              context.formatAmount(_wallet.netIncome),
                              style: context.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: context.primaryAction,
                              ),
                            ),
                          ],
                        ),
                        if (_wallet.adjustmentReason != null &&
                            _wallet.adjustmentReason!.isNotEmpty) ...[
                          SizedBox(height: context.responsiveSpacing8),
                          Text(
                            '调整原因: ${_wallet.adjustmentReason}',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.secondaryText,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: context.responsiveSpacing32),

                // 操作按钮
                if (!_isEditing)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _togglePaidStatus,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: context.responsiveSpacing16,
                            ),
                            side: BorderSide(
                              color: _wallet.isPaid
                                  ? Colors.green
                                  : context.primaryAction,
                            ),
                          ),
                          child: Text(
                            _wallet.isPaid ? '标记为未发放' : '标记为已发放',
                            style: context.textTheme.labelLarge?.copyWith(
                              color: _wallet.isPaid
                                  ? Colors.green
                                  : context.primaryAction,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    String hint,
  ) =>
      Padding(
        padding: EdgeInsets.only(bottom: context.responsiveSpacing12),
        child: _isEditing
            ? TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: label,
                  hintText: hint,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入$label';
                  }
                  final number = double.tryParse(value);
                  if (number == null || number < 0) {
                    return '请输入有效的金额';
                  }
                  return null;
                },
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: context.textTheme.bodyMedium,
                  ),
                  Text(
                    context.formatAmount(double.tryParse(controller.text) ?? 0),
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      );

  double _calculateTaxableIncome() {
    final grossIncome = (double.tryParse(_basicSalaryController.text) ?? 0) +
        (double.tryParse(_housingAllowanceController.text) ?? 0) +
        (double.tryParse(_mealAllowanceController.text) ?? 0) +
        (double.tryParse(_transportationAllowanceController.text) ?? 0) +
        (double.tryParse(_otherAllowanceController.text) ?? 0) +
        _wallet.totalBonuses;

    final deductions = (double.tryParse(_socialInsuranceController.text) ?? 0) +
        (double.tryParse(_housingFundController.text) ?? 0) +
        (double.tryParse(_otherDeductionsController.text) ?? 0) +
        (double.tryParse(_specialDeductionController.text) ?? 0);

    return grossIncome - deductions - 5000; // 减去起征点
  }

  Future<void> _toggleEditMode() async {
    if (_isEditing) {
      // 保存修改
      if (_formKey.currentState?.validate() ?? false) {
        await _saveChanges();
      }
    } else {
      // 进入编辑模式
      setState(() => _isEditing = true);
    }
  }

  Future<void> _saveChanges() async {
    try {
      final updatedWallet = _wallet.copyWith(
        basicSalary: double.tryParse(_basicSalaryController.text) ?? 0,
        housingAllowance:
            double.tryParse(_housingAllowanceController.text) ?? 0,
        mealAllowance: double.tryParse(_mealAllowanceController.text) ?? 0,
        transportationAllowance:
            double.tryParse(_transportationAllowanceController.text) ?? 0,
        otherAllowance: double.tryParse(_otherAllowanceController.text) ?? 0,
        socialInsurance: double.tryParse(_socialInsuranceController.text) ?? 0,
        housingFund: double.tryParse(_housingFundController.text) ?? 0,
        otherDeductions: double.tryParse(_otherDeductionsController.text) ?? 0,
        specialDeductionMonthly:
            double.tryParse(_specialDeductionController.text) ?? 0,
        adjustmentReason: _adjustmentReasonController.text.trim().isEmpty
            ? null
            : _adjustmentReasonController.text.trim(),
      );

      // 重新计算税费
      final recalculatedWallet = await _recalculateTaxes(updatedWallet);

      await context
          .read<BudgetProvider>()
          .updateMonthlyWallet(recalculatedWallet);

      setState(() {
        _wallet = recalculatedWallet;
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('工资信息已更新')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }

  Future<MonthlyWallet> _recalculateTaxes(MonthlyWallet wallet) async {
    // 这里使用简化的税费计算，实际应该调用PersonalIncomeTaxService
    final taxableIncome = wallet.grossIncome - wallet.totalDeductions - 5000;

    final taxRate = taxableIncome <= 0
        ? 0.0
        : taxableIncome <= 36000
            ? 0.03
            : taxableIncome <= 144000
                ? 0.1
                : taxableIncome <= 300000
                    ? 0.2
                    : 0.25;

    final taxDeduction = taxableIncome <= 0
        ? 0.0
        : taxableIncome <= 36000
            ? 0
            : taxableIncome <= 144000
                ? 2520
                : taxableIncome <= 300000
                    ? 16920
                    : 31920;

    final calculatedTax =
        taxableIncome <= 0 ? 0.0 : (taxableIncome * taxRate - taxDeduction);

    final netIncome =
        wallet.grossIncome - wallet.totalDeductions - calculatedTax;

    return wallet.copyWith(
      calculatedTax: calculatedTax,
      netIncome: netIncome,
    );
  }

  void _cancelEdit() {
    // 重新初始化控制器
    _initializeControllers();
    setState(() => _isEditing = false);
  }

  Future<void> _togglePaidStatus() async {
    try {
      final updatedWallet = _wallet.copyWith(isPaid: !_wallet.isPaid);
      await context.read<BudgetProvider>().updateMonthlyWallet(updatedWallet);

      setState(() => _wallet = updatedWallet);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已标记为${updatedWallet.isPaid ? '已发放' : '未发放'}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }
}
