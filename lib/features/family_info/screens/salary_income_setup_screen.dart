import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';
import 'package:your_finance_flutter/core/models/bonus_item.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/providers/budget_provider.dart';
import 'package:your_finance_flutter/core/services/salary_calculation_service.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/amount_input_field.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/features/family_info/widgets/bonus_management_widget.dart';
import 'package:your_finance_flutter/features/family_info/widgets/salary_basic_info_widget.dart';
import 'package:your_finance_flutter/features/family_info/widgets/salary_history_widget.dart';
import 'package:your_finance_flutter/features/family_info/widgets/tax_deductions_widget.dart';
import 'package:your_finance_flutter/core/services/ai/payroll_recognition_service.dart';
import 'package:your_finance_flutter/core/services/ai/image_processing_service.dart';

class SalaryIncomeSetupScreen extends StatefulWidget {
  const SalaryIncomeSetupScreen({
    super.key,
    this.salaryIncomeToEdit,
  });
  final SalaryIncome? salaryIncomeToEdit;

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
  final _personalIncomeTaxController = TextEditingController(); // 个税控制器
  final _socialInsuranceController = TextEditingController();
  final _housingFundController = TextEditingController();
  final _otherDeductionsController = TextEditingController();
  final _specialDeductionController = TextEditingController();
  final _otherTaxFreeIncomeController = TextEditingController();
  final _otherTaxDeductionsController = TextEditingController(); // 其他税收扣除

  int _salaryDay = 10;
  bool _isMidYearMode = false;
  bool _useAutoCalculation = false;
  bool _isLoading = false;
  double _specialDeductionMonthly = 0;
  int _completedMonths = 0; // 添加缺失的变量

  // Salary history
  final Map<DateTime, double> _salaryHistory = {};

  // Bonuses
  final List<BonusItem> _bonuses = [];

  // Monthly allowances
  final Map<int, AllowanceRecord> _monthlyAllowances = {};

  @override
  void initState() {
    super.initState();
    Logger.debug('📝 SalaryIncomeSetupScreen initState called');

    if (widget.salaryIncomeToEdit != null) {
      Logger.debug(
          '📝 Initializing with existing salary income: ${widget.salaryIncomeToEdit!.name}');
      Logger.debug(
          '📝 Initial bonuses count: ${widget.salaryIncomeToEdit!.bonuses.length}');
      for (var i = 0; i < widget.salaryIncomeToEdit!.bonuses.length; i++) {
        final bonus = widget.salaryIncomeToEdit!.bonuses[i];
        Logger.debug(
            '  Bonus $i: ${bonus.name}, type: ${bonus.type}, amount: ${bonus.amount}');
      }

      final salaryIncome = widget.salaryIncomeToEdit!;

      _nameController.text = salaryIncome.name;
      _basicSalaryController.text = salaryIncome.basicSalary.toString();
      _housingAllowanceController.text =
          salaryIncome.housingAllowance.toString();
      _mealAllowanceController.text = salaryIncome.mealAllowance.toString();
      _transportationAllowanceController.text =
          salaryIncome.transportationAllowance.toString();
      _otherAllowanceController.text = salaryIncome.otherAllowance.toString();
      _personalIncomeTaxController.text =
          salaryIncome.personalIncomeTax.toString();
      _socialInsuranceController.text = salaryIncome.socialInsurance.toString();
      _housingFundController.text = salaryIncome.housingFund.toString();
      _otherDeductionsController.text = salaryIncome.otherDeductions.toString();
      _specialDeductionController.text =
          salaryIncome.specialDeductionMonthly.toString();
      _otherTaxDeductionsController.text =
          salaryIncome.otherTaxDeductions.toString(); // 其他税收扣除
      _salaryDay = salaryIncome.salaryDay;

      if (salaryIncome.salaryHistory != null) {
        _salaryHistory.addAll(salaryIncome.salaryHistory!);
      }

      _bonuses.addAll(salaryIncome.bonuses);

      // 初始化月度津贴记录
      if (salaryIncome.monthlyAllowances != null) {
        _monthlyAllowances.addAll(salaryIncome.monthlyAllowances!);
      }
    }
  }

  @override
  void dispose() {
    Logger.debug('📝 SalaryIncomeSetupScreen dispose called with bonuses: $_bonuses');
    _disposeControllers();
    super.dispose();
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
    _otherTaxDeductionsController.dispose(); // 其他税收扣除
  }

  Future<void> _updateCumulativeIncome() async {
    // 计算累积收入（用于中年度模式）
    await SalaryCalculationService.calculateAutoCumulative(
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
      otherTaxFreeMonthly:
          double.tryParse(_otherTaxFreeIncomeController.text) ?? 0,
      bonuses: _bonuses,
    );
  }

  /// 自动计算月度个税
  Future<void> _calculateMonthlyTax() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 计算月度平均税费（基于年度累积预扣法）
      final result = await SalaryCalculationService.calculateAutoCumulative(
        completedMonths: 12, // 计算全年平均
        salaryHistory: _salaryHistory,
        basicSalary: double.tryParse(_basicSalaryController.text) ?? 0,
        housingAllowance:
            double.tryParse(_housingAllowanceController.text) ?? 0,
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
        otherTaxFreeMonthly: 0,
        bonuses: _bonuses,
        monthlyAllowances:
            _monthlyAllowances.isNotEmpty ? _monthlyAllowances : null,
      );

      // 月度平均税费 = 年度总税费 / 12
      final monthlyTax = result.totalTax / 12;
      _personalIncomeTaxController.text = monthlyTax.toStringAsFixed(0);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('自动计算完成：月均个税 ¥${monthlyTax.toStringAsFixed(0)}'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Logger.debug('❌ 自动计算税费失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text('自动计算失败，请手动填写'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSpecialDeductionChanged(double value) {
    if (value != _specialDeductionMonthly) {
      setState(() {
        _specialDeductionMonthly = value.clamp(0, 5000);
      });
    }
  }

  /// 识别工资条
  Future<void> _recognizePayroll() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // 1. 选择图片
      final imageService = ImageProcessingService.getInstance();
      final imageFile = await imageService.pickImageFromGallery();
      if (imageFile == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 2. 保存图片
      final imagePath = await imageService.saveImageToAppDirectory(imageFile);

      // 3. 识别工资条
      final service = await PayrollRecognitionService.getInstance();
      final result = await service.recognizePayroll(imagePath: imagePath);

      // 4. 转换为SalaryIncome并填充表单
      final salaryIncome = result.toSalaryIncome(
        name: _nameController.text.isNotEmpty
            ? _nameController.text
            : '工资收入',
        salaryDay: _salaryDay,
      );

      // 5. 填充基本工资字段（实发金额）
      setState(() {
        _basicSalaryController.text =
            salaryIncome.basicSalary.toStringAsFixed(2);
        // 如果识别到了发薪日期，更新salaryDay
        if (result.salaryDate != null) {
          _salaryDay = result.salaryDate!.day;
        }
        _isLoading = false;
      });

      // 6. 显示识别结果摘要（简化版）
      if (mounted) {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('识别成功'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('实发金额: ¥${result.netIncome.toStringAsFixed(2)}'),
                Text('置信度: ${(result.confidence * 100).toStringAsFixed(0)}%'),
                if (result.salaryDate != null)
                  Text('发薪日期: ${result.salaryDate!.toString().substring(0, 10)}'),
                const SizedBox(height: 8),
                const Text(
                  '提示: 已自动填充基本工资，其他字段请手动补充',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('确定'),
              ),
            ],
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '识别成功！实发金额: ¥${result.netIncome.toStringAsFixed(2)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      Logger.debug('❌ 工资条识别失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('识别失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveIncome() async {
    Logger.debug('📝 Saving income with bonuses: $_bonuses');
    if (!_formKey.currentState!.validate()) {
      Logger.debug('❌ Form validation failed');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final budgetProvider =
          Provider.of<BudgetProvider>(context, listen: false);

      if (widget.salaryIncomeToEdit != null) {
        Logger.debug('📝 Updating existing salary income');
        Logger.debug('📝 Original salary income ID: ${widget.salaryIncomeToEdit!.id}');
        // 编辑模式：更新现有工资收入
        final updatedIncome = widget.salaryIncomeToEdit!.copyWith(
          name: _nameController.text.trim(),
          basicSalary: double.parse(_basicSalaryController.text),
          salaryDay: _salaryDay,
          housingAllowance:
              double.tryParse(_housingAllowanceController.text) ?? 0,
          mealAllowance: double.tryParse(_mealAllowanceController.text) ?? 0,
          transportationAllowance:
              double.tryParse(_transportationAllowanceController.text) ?? 0,
          otherAllowance: double.tryParse(_otherAllowanceController.text) ?? 0,
          monthlyAllowances: _monthlyAllowances.isNotEmpty
              ? _monthlyAllowances
              : null, // 月度津贴记录
          personalIncomeTax:
              double.tryParse(_personalIncomeTaxController.text) ?? 0,
          socialInsurance:
              double.tryParse(_socialInsuranceController.text) ?? 0,
          housingFund: double.tryParse(_housingFundController.text) ?? 0,
          otherDeductions:
              double.tryParse(_otherDeductionsController.text) ?? 0,
          specialDeductionMonthly: _specialDeductionMonthly,
          otherTaxDeductions:
              double.tryParse(_otherTaxDeductionsController.text) ??
                  0, // 其他税收扣除
          salaryHistory:
              _salaryHistory.isNotEmpty ? _salaryHistory : null, // 工资历史
          bonuses: _bonuses,
          updateDate: DateTime.now(),
        );
        await budgetProvider.updateSalaryIncome(updatedIncome);
        Logger.debug('✅ Salary income updated successfully');
      } else {
        Logger.debug('📝 Creating new salary income');
        // 创建模式：创建新工资收入
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
          monthlyAllowances: _monthlyAllowances.isNotEmpty
              ? _monthlyAllowances
              : null, // 月度津贴记录
          personalIncomeTax:
              double.tryParse(_personalIncomeTaxController.text) ?? 0,
          socialInsurance:
              double.tryParse(_socialInsuranceController.text) ?? 0,
          housingFund: double.tryParse(_housingFundController.text) ?? 0,
          otherDeductions:
              double.tryParse(_otherDeductionsController.text) ?? 0,
          specialDeductionMonthly: _specialDeductionMonthly,
          otherTaxDeductions:
              double.tryParse(_otherTaxDeductionsController.text) ??
                  0, // 其他税收扣除
          salaryHistory:
              _salaryHistory.isNotEmpty ? _salaryHistory : null, // 工资历史
          bonuses: _bonuses,
        );
        Logger.debug('✅ New salary income created successfully');
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // 返回上一页
        Navigator.of(context).pop();
      }
    } catch (e) {
      Logger.debug('❌ Error saving salary income: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存失败，请重试')),
        );
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
            IconButton(
              icon: const Icon(Icons.camera_alt),
              tooltip: '拍照识别工资条',
              onPressed: _isLoading ? null : _recognizePayroll,
            ),
            TextButton(
              onPressed: () {
                Logger.debug('📝 Save button pressed in app bar');
                _saveIncome();
              },
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
                        _updateCumulativeIncome();
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
                                  SizedBox(width: context.spacing8),
                                  Text(
                                    '$_completedMonths / 12 个月',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  SizedBox(width: context.spacing8),
                                  Expanded(
                                    child: Slider(
                                      value: _completedMonths.toDouble(),
                                      max: 12,
                                      divisions: 12,
                                      label: _completedMonths.toString(),
                                      onChanged: _useAutoCalculation
                                          ? (value) => setState(
                                                () => _completedMonths =
                                                    value.toInt(),
                                              )
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: context.spacing16),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: context.spacing16),
                  ],

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
                    onBonusesChanged: (bonuses) {
                      Logger.debug(
                          '📝 onBonusesChanged called with ${bonuses.length} bonuses');
                      for (var i = 0; i < bonuses.length; i++) {
                        final bonus = bonuses[i];
                        Logger.debug(
                            '  Bonus ${i + 1}: ${bonus.name} - ${bonus.quarterlyPaymentMonths}');
                      }
                      setState(() {
                        _bonuses.clear();
                        _bonuses.addAll(bonuses);
                      });
                    },
                  ),

                  SizedBox(height: context.spacing16),

                  // Monthly Allowance Section
                  AppCard(
                    child: Padding(
                      padding: EdgeInsets.all(context.spacing16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '月度津贴',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          SizedBox(height: context.spacing16),
                          Text(
                            '住房津贴',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          SizedBox(height: context.spacing8),
                          AmountInputField(
                            controller: _housingAllowanceController,
                            labelText: '住房津贴',
                            hintText: '请输入住房津贴金额',
                            prefixIcon: const Icon(
                              Icons.home,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(height: context.spacing16),
                          Text(
                            '餐补',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          SizedBox(height: context.spacing8),
                          AmountInputField(
                            controller: _mealAllowanceController,
                            labelText: '餐补',
                            hintText: '请输入餐补金额',
                            prefixIcon: const Icon(
                              Icons.restaurant,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(height: context.spacing16),
                          Text(
                            '交通补贴',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          SizedBox(height: context.spacing8),
                          AmountInputField(
                            controller: _transportationAllowanceController,
                            labelText: '交通补贴',
                            hintText: '请输入交通补贴金额',
                            prefixIcon: const Icon(
                              Icons.directions_car,
                              color: Colors.orange,
                            ),
                          ),
                          SizedBox(height: context.spacing16),
                          Text(
                            '其他津贴',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          SizedBox(height: context.spacing8),
                          AmountInputField(
                            controller: _otherAllowanceController,
                            labelText: '其他津贴',
                            hintText: '请输入其他津贴金额',
                            prefixIcon: const Icon(
                              Icons.money,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                    otherTaxDeductionsController:
                        _otherTaxDeductionsController, // 其他税收扣除
                    specialDeductionMonthly: _specialDeductionMonthly,
                    onSpecialDeductionChanged: _onSpecialDeductionChanged,
                    onCalculateTax: _calculateMonthlyTax,
                  ),

                  SizedBox(height: context.spacing24),

                  // Save Button
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveIncome,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.spacing24,
                          vertical: context.spacing12,
                        ),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('保存工资信息'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
