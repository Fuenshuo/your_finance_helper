import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';
import 'package:your_finance_flutter/core/models/bonus_item.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/providers/budget_provider.dart';
import 'package:your_finance_flutter/core/services/personal_income_tax_service.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/amount_input_field.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/core/widgets/app_primary_button.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';
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
  // 以下变量保留用于数据兼容性，但UI中不再使用（预测功能已移除）
  // bool _isMidYearMode = false;
  // bool _useAutoCalculation = false;
  bool _isLoading = false;
  double _specialDeductionMonthly = 0;
  // int _completedMonths = 0;

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

  // 已移除：年中模式相关的累积收入计算（预测功能已移除）
  // Future<void> _updateCumulativeIncome() async { ... }

  /// 预测下个月个税（基于当前数据，假设下个月收入稳定）
  Future<void> _predictNextMonthTax() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final currentMonth = now.month;
      final currentYear = now.year;
      
      // 计算当前月收入（基本工资 + 津贴）
      final basicSalary = double.tryParse(_basicSalaryController.text) ?? 0;
      final housingAllowance = double.tryParse(_housingAllowanceController.text) ?? 0;
      final mealAllowance = double.tryParse(_mealAllowanceController.text) ?? 0;
      final transportationAllowance = double.tryParse(_transportationAllowanceController.text) ?? 0;
      final otherAllowance = double.tryParse(_otherAllowanceController.text) ?? 0;
      
      // 计算当前月津贴（考虑月度津贴变化）
      double currentMonthAllowance;
      if (_monthlyAllowances.containsKey(currentMonth)) {
        currentMonthAllowance = _monthlyAllowances[currentMonth]!.totalAllowance;
      } else {
        currentMonthAllowance = housingAllowance + mealAllowance + 
                                transportationAllowance + otherAllowance;
      }
      
      // 计算当前月奖金（排除年终奖，年终奖单独计税）
      var currentMonthBonus = 0.0;
      for (final bonus in _bonuses) {
        if (bonus.type != BonusType.yearEndBonus) {
          final monthlyBonus = bonus.calculateMonthlyBonus(currentYear, currentMonth);
          currentMonthBonus += monthlyBonus;
        }
      }
      
      // 当前月总收入
      final currentMonthIncome = basicSalary + currentMonthAllowance + currentMonthBonus;
      
      // 当前月扣除项
      final socialInsurance = double.tryParse(_socialInsuranceController.text) ?? 0;
      final housingFund = double.tryParse(_housingFundController.text) ?? 0;
      final monthlyDeductions = socialInsurance + housingFund;
      
      // 假设下个月收入稳定（与当前月相同）
      final nextMonthIncome = currentMonthIncome;
      
      // 计算本年累计应纳税所得额（到当前月）
      var cumulativeTaxableIncome = 0.0;
      var cumulativeTax = 0.0;
      
      // 计算1月到当前月的累计
      for (var month = 1; month <= currentMonth; month++) {
        // 计算指定月份的津贴
        double monthAllowance;
        if (_monthlyAllowances.containsKey(month)) {
          monthAllowance = _monthlyAllowances[month]!.totalAllowance;
        } else {
          monthAllowance = housingAllowance + mealAllowance + 
                          transportationAllowance + otherAllowance;
        }
        
        // 计算指定月份的奖金（排除年终奖）
        var monthBonus = 0.0;
        for (final bonus in _bonuses) {
          if (bonus.type != BonusType.yearEndBonus) {
            final monthlyBonus = bonus.calculateMonthlyBonus(currentYear, month);
            monthBonus += monthlyBonus;
          }
        }
        
        final monthIncome = basicSalary + monthAllowance + monthBonus;
        final monthTaxableIncome = PersonalIncomeTaxService.calculateTaxableIncome(
          monthIncome,
          monthlyDeductions,
          _specialDeductionMonthly,
          0,
        );
        
        cumulativeTaxableIncome += monthTaxableIncome;
        
        // 计算年度累计应纳税额
        final annualTax = PersonalIncomeTaxService.calculateAnnualTax(cumulativeTaxableIncome);
        
        // 计算当月应预扣税额
        final monthTax = annualTax - cumulativeTax;
        cumulativeTax += monthTax;
      }
      
      // 预测下个月：假设下个月收入与当前月相同
      final nextMonthTaxableIncome = PersonalIncomeTaxService.calculateTaxableIncome(
        nextMonthIncome,
        monthlyDeductions,
        _specialDeductionMonthly,
        0,
      );
      
      // 下个月的累计应纳税所得额
      final nextMonthCumulativeTaxableIncome = cumulativeTaxableIncome + nextMonthTaxableIncome;
      
      // 计算下个月的年度累计应纳税额
      final nextMonthAnnualTax = PersonalIncomeTaxService.calculateAnnualTax(
        nextMonthCumulativeTaxableIncome,
      );
      
      // 计算下个月应预扣税额
      final nextMonthTax = nextMonthAnnualTax - cumulativeTax;
      
      // 填入预测值（作为建议）
      _personalIncomeTaxController.text = nextMonthTax.toStringAsFixed(0);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '预测完成：下个月个税约 ¥${nextMonthTax.toStringAsFixed(0)}（假设收入稳定）',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      Logger.debug('❌ 预测下个月个税失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text('预测失败，请手动填写'),
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
            padding: EdgeInsets.all(AppDesignTokens.spacing16),
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
                    onSalaryDayChanged: (value) =>
                        setState(() => _salaryDay = value),
                  ),

                  SizedBox(height: AppDesignTokens.spacing16),

                  // Salary History Section
                  SalaryHistoryWidget(
                    basicSalaryController: _basicSalaryController,
                    salaryHistory: _salaryHistory,
                    onHistoryChanged: (history) =>
                        setState(() => _salaryHistory.addAll(history)),
                  ),

                  SizedBox(height: AppDesignTokens.spacing16),

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

                  SizedBox(height: AppDesignTokens.spacing16),

                  // Monthly Allowance Section
                  AppCard(
                    child: Padding(
                      padding: EdgeInsets.all(AppDesignTokens.spacing16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '月度津贴',
                            style: AppDesignTokens.title1(context),
                          ),
                          SizedBox(height: AppDesignTokens.spacing16),
                          AmountInputField(
                            controller: _housingAllowanceController,
                            labelText: '住房津贴',
                            hintText: '请输入住房津贴金额',
                            prefixIcon: Icon(
                              Icons.home,
                              color: AppDesignTokens.primaryAction(context),
                            ),
                          ),
                          SizedBox(height: AppDesignTokens.spacing16),
                          AmountInputField(
                            controller: _mealAllowanceController,
                            labelText: '餐补',
                            hintText: '请输入餐补金额',
                            prefixIcon: Icon(
                              Icons.restaurant,
                              color: AppDesignTokens.successColor(context),
                            ),
                          ),
                          SizedBox(height: AppDesignTokens.spacing16),
                          AmountInputField(
                            controller: _transportationAllowanceController,
                            labelText: '交通补贴',
                            hintText: '请输入交通补贴金额',
                            prefixIcon: Icon(
                              Icons.directions_car,
                              color: AppDesignTokens.warningColor,
                            ),
                          ),
                          SizedBox(height: AppDesignTokens.spacing16),
                          AmountInputField(
                            controller: _otherAllowanceController,
                            labelText: '其他津贴',
                            hintText: '请输入其他津贴金额',
                            prefixIcon: Icon(
                              Icons.money,
                              color: AppDesignTokens.secondaryText(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: AppDesignTokens.spacing16),

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
                  ),

                  SizedBox(height: AppDesignTokens.spacing16),

                  // Tax Prediction Section (独立预测区域)
                  AppCard(
                    child: Padding(
                      padding: EdgeInsets.all(AppDesignTokens.spacing16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                color: AppDesignTokens.primaryAction(context),
                              ),
                              SizedBox(width: AppDesignTokens.spacing8),
                              Text(
                                '下个月个税预测',
                                style: AppDesignTokens.title1(context),
                              ),
                            ],
                          ),
                          SizedBox(height: AppDesignTokens.spacing12),
                          Text(
                            '基于当前录入的数据，预测下个月的个税（假设收入稳定）',
                            style: AppDesignTokens.caption(context),
                          ),
                          SizedBox(height: AppDesignTokens.spacing16),
                          AppPrimaryButton(
                            label: '预测下个月个税',
                            icon: Icons.calculate,
                            onPressed: _isLoading ? null : _predictNextMonthTax,
                            isLoading: _isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: AppDesignTokens.spacing24),

                  // Save Button
                  Center(
                    child: AppPrimaryButton(
                      label: '保存工资信息',
                      icon: Icons.check,
                      onPressed: _isLoading ? null : _saveIncome,
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
