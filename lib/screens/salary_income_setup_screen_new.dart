import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/models/bonus_item.dart';
import 'package:your_finance_flutter/providers/budget_provider.dart';
import 'package:your_finance_flutter/services/salary_calculation_service.dart';
import 'package:your_finance_flutter/theme/app_theme.dart';
import 'package:your_finance_flutter/widgets/amount_input_field.dart';
import 'package:your_finance_flutter/widgets/app_animations.dart';
import 'package:your_finance_flutter/widgets/app_card.dart';
import 'package:your_finance_flutter/widgets/bonus_management_widget.dart';
import 'package:your_finance_flutter/widgets/salary_basic_info_widget.dart';
import 'package:your_finance_flutter/widgets/salary_history_widget.dart';
import 'package:your_finance_flutter/widgets/salary_summary_widget.dart';
import 'package:your_finance_flutter/widgets/tax_deductions_widget.dart';

class SalaryIncomeSetupScreen extends StatefulWidget {
  const SalaryIncomeSetupScreen({super.key});

  @override
  State<SalaryIncomeSetupScreen> createState() =>
      _SalaryIncomeSetupScreenState();
}

class _SalaryIncomeSetupScreenState extends State<SalaryIncomeSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Basic controllers
  final _nameController = TextEditingController();
  final _basicSalaryController = TextEditingController();

  // Allowance controllers
  final _housingAllowanceController = TextEditingController();
  final _mealAllowanceController = TextEditingController();
  final _transportationAllowanceController = TextEditingController();
  final _otherAllowanceController = TextEditingController();

  // Deduction controllers
  final _personalIncomeTaxController = TextEditingController();
  final _socialInsuranceController = TextEditingController();
  final _housingFundController = TextEditingController();
  final _otherDeductionsController = TextEditingController();
  final _specialDeductionController = TextEditingController();
  final _otherTaxFreeIncomeController = TextEditingController();

  // State variables
  bool _isLoading = false;
  bool _autoCalculateTax = true;
  int _salaryDay = 15;
  bool _isMidYearMode = false;
  bool _useAutoCalculation = false;
  double _specialDeductionMonthly = 5000;

  // Data collections
  final List<BonusItem> _bonuses = [];
  final Map<DateTime, double> _salaryHistory = {};

  // Mid-year mode data
  int _completedMonths = 9;
  double _cumulativeIncome = 0;
  double _cumulativeTax = 0;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _initializeControllers() {
    _specialDeductionController.text = _specialDeductionMonthly.toString();
  }

  void _disposeControllers() {
    _nameController.dispose();
    _basicSalaryController.dispose();
    _housingAllowanceController.dispose();
    _mealAllowanceController.dispose();
    _transportationAllowanceController.dispose();
    _otherAllowanceController.dispose();
    _personalIncomeTaxController.dispose();
    _socialInsuranceController.dispose();
    _housingFundController.dispose();
    _otherDeductionsController.dispose();
    _specialDeductionController.dispose();
    _otherTaxFreeIncomeController.dispose();
  }

  void _calculateAutoCumulative() {
    if (!_isMidYearMode) return;

    final result = SalaryCalculationService.calculateAutoCumulative(
      completedMonths: _completedMonths,
      salaryHistory: _salaryHistory,
      basicSalary: double.tryParse(_basicSalaryController.text) ?? 0,
      housingAllowance: double.tryParse(_housingAllowanceController.text) ?? 0,
      mealAllowance: double.tryParse(_mealAllowanceController.text) ?? 0,
      transportationAllowance:
          double.tryParse(_transportationAllowanceController.text) ?? 0,
      otherAllowance: double.tryParse(_otherAllowanceController.text) ?? 0,
      performanceBonus: 0,
      socialInsurance: double.tryParse(_socialInsuranceController.text) ?? 0,
      housingFund: double.tryParse(_housingFundController.text) ?? 0,
      specialDeductionMonthly: _specialDeductionMonthly,
      otherTaxFreeIncome:
          double.tryParse(_otherTaxFreeIncomeController.text) ?? 0,
      bonuses: _bonuses,
    );

    setState(() {
      _cumulativeIncome = result.totalIncome;
      _cumulativeTax = result.totalTax;
    });
  }

  void _calculateTax() {
    if (!_autoCalculateTax) return;

    final monthlyIncome = _getMonthlyIncome();
    final monthlyDeductions = _getMonthlyDeductions();

    if (monthlyIncome > 0) {
      final tax = SalaryCalculationService.calculateMonthlyTax(
        monthlyIncome: monthlyIncome,
        monthlyDeductions: monthlyDeductions,
        isMidYearMode: _isMidYearMode,
        cumulativeIncome: _cumulativeIncome,
        cumulativeTax: _cumulativeTax,
        remainingMonths: 12 - _completedMonths,
        specialDeductionMonthly: _specialDeductionMonthly,
        otherTaxFreeMonthly:
            (double.tryParse(_otherTaxFreeIncomeController.text) ?? 0) / 12,
      );

      _personalIncomeTaxController.text = tax.toStringAsFixed(0);
    }
  }

  double _getMonthlyIncome() {
    final basicSalary = double.tryParse(_basicSalaryController.text) ?? 0;
    final housingAllowance =
        double.tryParse(_housingAllowanceController.text) ?? 0;
    final mealAllowance = double.tryParse(_mealAllowanceController.text) ?? 0;
    final transportationAllowance =
        double.tryParse(_transportationAllowanceController.text) ?? 0;
    final otherAllowance = double.tryParse(_otherAllowanceController.text) ?? 0;

    return basicSalary +
        housingAllowance +
        mealAllowance +
        transportationAllowance +
        otherAllowance;
  }

  double _getMonthlyDeductions() {
    final socialInsurance =
        double.tryParse(_socialInsuranceController.text) ?? 0;
    final housingFund = double.tryParse(_housingFundController.text) ?? 0;
    return socialInsurance + housingFund;
  }

  void _onSpecialDeductionChanged(double value) {
    if (value != _specialDeductionMonthly) {
      setState(() {
        _specialDeductionMonthly = value.clamp(0, 5000);
        _calculateTax();
      });
    }
  }

  Future<void> _saveIncome() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final budgetProvider =
          Provider.of<BudgetProvider>(context, listen: false);

      await budgetProvider.createSalaryIncome(
        name: _nameController.text.trim(),
        basicSalary: double.parse(_basicSalaryController.text),
        salaryDay: _salaryDay,
        housingAllowance:
            double.tryParse(_housingAllowanceController.text) ?? 0,
        mealAllowance: double.tryParse(_mealAllowanceController.text) ?? 0,
        transportationAllowance:
            double.tryParse(_transportationAllowanceController.text) ?? 0,
        otherAllowance: double.tryParse(_otherAllowanceController.text) ?? 0,
        salaryHistory: _salaryHistory,
        bonuses: _bonuses,
        personalIncomeTax:
            double.tryParse(_personalIncomeTaxController.text) ?? 0,
        socialInsurance: double.tryParse(_socialInsuranceController.text) ?? 0,
        housingFund: double.tryParse(_housingFundController.text) ?? 0,
        otherDeductions: double.tryParse(_otherDeductionsController.text) ?? 0,
        description: '每月 $_salaryDay 日发放',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('工资收入设置成功！'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败：$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          title: const Text('设置工资收入'),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            TextButton(
              onPressed: _saveIncome,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('保存'),
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.spacing16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information Section
                  SalaryBasicInfoWidget(
                    nameController: _nameController,
                    basicSalaryController: _basicSalaryController,
                    salaryDay: _salaryDay,
                    isMidYearMode: _isMidYearMode,
                    useAutoCalculation: _useAutoCalculation,
                    onSalaryDayChanged: (value) =>
                        setState(() => _salaryDay = value),
                    onMidYearModeChanged: (value) =>
                        setState(() => _isMidYearMode = value),
                    onAutoCalculationChanged: (value) {
                      setState(() => _useAutoCalculation = value);
                      if (value) {
                        _calculateAutoCumulative();
                      }
                    },
                  ),

                  SizedBox(height: context.spacing16),

                  // Mid-year mode cumulative data input
                  if (_isMidYearMode) ...[
                    AppAnimations.animatedListItem(
                      index: 1,
                      child: AppCard(
                        child: Padding(
                          padding: EdgeInsets.all(context.spacing16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '累计数据（今年已收工资情况）',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              SizedBox(height: context.spacing16),

                              // 已完成月份数
                              Text(
                                '已收工资月份数',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              SizedBox(height: context.spacing8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month,
                                    color: Colors.orange,
                                  ),
                                  SizedBox(width: context.spacing12),
                                  Text(
                                    '今年已收',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Expanded(
                                    child: Slider(
                                      value: _completedMonths.toDouble(),
                                      min: 1,
                                      max: 12,
                                      divisions: 11,
                                      label: '$_completedMonths个月',
                                      onChanged: (value) {
                                        setState(() {
                                          _completedMonths = value.toInt();
                                          _calculateTax();
                                        });
                                      },
                                    ),
                                  ),
                                  Text(
                                    '$_completedMonths个月',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: context.primaryAction,
                                        ),
                                  ),
                                ],
                              ),

                              if (_useAutoCalculation) ...[
                                SizedBox(height: context.spacing16),
                                Container(
                                  padding: EdgeInsets.all(context.spacing12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.blue.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.auto_fix_high,
                                            color: Colors.blue,
                                            size: 20,
                                          ),
                                          SizedBox(width: context.spacing8),
                                          Text(
                                            '自动计算结果（仅供参考）',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.blue.shade700,
                                                ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: context.spacing8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '预计累计收入：¥${_cumulativeIncome.toStringAsFixed(0)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              '预计累计个税：¥${_cumulativeTax.toStringAsFixed(0)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              SizedBox(height: context.spacing16),

                              // 累计收入
                              AmountInputField(
                                controller: TextEditingController(
                                  text: _cumulativeIncome.toStringAsFixed(0),
                                ),
                                labelText: '累计收入总额',
                                hintText: _useAutoCalculation
                                    ? '可修改自动计算结果'
                                    : '今年已收到的工资总和',
                                prefixIcon: const Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.green,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _cumulativeIncome =
                                        double.tryParse(value ?? '0') ?? 0;
                                    _calculateTax();
                                  });
                                },
                              ),
                              SizedBox(height: context.spacing16),

                              // 累计个税扣除
                              AmountInputField(
                                controller: TextEditingController(
                                  text: _cumulativeTax.toStringAsFixed(0),
                                ),
                                labelText: '累计个税扣除',
                                hintText: _useAutoCalculation
                                    ? '可修改自动计算结果'
                                    : '今年已扣除的个税总和',
                                prefixIcon: const Icon(Icons.receipt,
                                    color: Colors.red),
                                onChanged: (value) {
                                  setState(() {
                                    _cumulativeTax =
                                        double.tryParse(value ?? '0') ?? 0;
                                    _calculateTax();
                                  });
                                },
                              ),

                              SizedBox(height: context.spacing12),
                              Container(
                                padding: EdgeInsets.all(context.spacing12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.orange.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
                                    SizedBox(width: context.spacing8),
                                    Expanded(
                                      child: Text(
                                        '系统将基于您输入的累计数据，计算剩余月份每月应预扣的个税金额。',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.orange.shade700,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: context.spacing16),
                  ],

                  // 工资构成
                  AppAnimations.animatedListItem(
                    index: 2,
                    child: AppCard(
                      child: Padding(
                        padding: EdgeInsets.all(context.spacing16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '工资构成',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            SizedBox(height: context.spacing16),

                            // 住房补贴
                            AmountInputField(
                              controller: _housingAllowanceController,
                              labelText: '住房补贴',
                              hintText: '每月住房补贴',
                              prefixIcon:
                                  const Icon(Icons.home, color: Colors.blue),
                            ),
                            SizedBox(height: context.spacing16),

                            // 餐补
                            AmountInputField(
                              controller: _mealAllowanceController,
                              labelText: '餐补',
                              hintText: '每月餐补金额',
                              prefixIcon: const Icon(
                                Icons.restaurant,
                                color: Colors.orange,
                              ),
                            ),
                            SizedBox(height: context.spacing16),

                            // 交通补贴
                            AmountInputField(
                              controller: _transportationAllowanceController,
                              labelText: '交通补贴',
                              hintText: '每月交通补贴',
                              prefixIcon: const Icon(
                                Icons.directions_car,
                                color: Colors.purple,
                              ),
                            ),
                            SizedBox(height: context.spacing16),

                            // 其他补贴
                            AmountInputField(
                              controller: _otherAllowanceController,
                              labelText: '其他补贴',
                              hintText: '其他补贴总额',
                              prefixIcon: const Icon(
                                Icons.add_circle,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: context.spacing16),

                  // Salary History Section
                  SalaryHistoryWidget(
                    basicSalaryController: _basicSalaryController,
                    salaryHistory: _salaryHistory,
                    onHistoryChanged: (history) =>
                        setState(() => _salaryHistory.addAll(history)),
                  ),

                  SizedBox(height: context.spacing16),

                  // Bonus Management Section
                  BonusManagementWidget(
                    bonuses: _bonuses,
                    onBonusesChanged: (bonuses) =>
                        setState(() => _bonuses.clear()..addAll(bonuses)),
                  ),

                  SizedBox(height: context.spacing16),

                  // Tax and Deductions Section
                  TaxDeductionsWidget(
                    personalIncomeTaxController: _personalIncomeTaxController,
                    socialInsuranceController: _socialInsuranceController,
                    housingFundController: _housingFundController,
                    otherDeductionsController: _otherDeductionsController,
                    specialDeductionController: _specialDeductionController,
                    otherTaxFreeIncomeController: _otherTaxFreeIncomeController,
                    autoCalculateTax: _autoCalculateTax,
                    specialDeductionMonthly: _specialDeductionMonthly,
                    onAutoCalculateTaxChanged: (value) =>
                        setState(() => _autoCalculateTax = value),
                    onSpecialDeductionChanged: _onSpecialDeductionChanged,
                  ),

                  SizedBox(height: context.spacing24),

                  // Income Summary Section
                  SalarySummaryWidget(
                    basicSalary:
                        double.tryParse(_basicSalaryController.text) ?? 0,
                    housingAllowance:
                        double.tryParse(_housingAllowanceController.text) ?? 0,
                    mealAllowance:
                        double.tryParse(_mealAllowanceController.text) ?? 0,
                    transportationAllowance: double.tryParse(
                            _transportationAllowanceController.text) ??
                        0,
                    otherAllowance:
                        double.tryParse(_otherAllowanceController.text) ?? 0,
                    performanceBonus: 0,
                    otherBonuses:
                        double.tryParse(_otherAllowanceController.text) ?? 0,
                    personalIncomeTax:
                        double.tryParse(_personalIncomeTaxController.text) ?? 0,
                    socialInsurance:
                        double.tryParse(_socialInsuranceController.text) ?? 0,
                    housingFund:
                        double.tryParse(_housingFundController.text) ?? 0,
                    otherDeductions:
                        double.tryParse(_otherDeductionsController.text) ?? 0,
                    bonuses: _bonuses,
                    salaryDay: _salaryDay,
                  ),

                  SizedBox(height: context.spacing32),
                ],
              ),
            ),
          ),
        ),
      );
}
