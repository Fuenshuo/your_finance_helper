import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/services/loan_calculation_service.dart';

class LoanDetailScreen extends StatefulWidget {
  const LoanDetailScreen({
    required this.account,
    super.key,
    this.onAccountSaved,
  });
  final Account account;
  final void Function(Account)? onAccountSaved;

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen> {
  late Account _account;
  final _formKey = GlobalKey<FormState>();
  final _loanCalculationService = LoanCalculationService();

  // 表单控制器
  late TextEditingController _nameController;
  late TextEditingController _loanAmountController;
  late TextEditingController _interestRateController;
  late TextEditingController _secondInterestRateController;
  late TextEditingController _loanTermController;
  late TextEditingController _monthlyPaymentController;
  late TextEditingController _remainingPrincipalController;

  // 状态变量
  late LoanType _loanType;
  late RepaymentMethod _repaymentMethod;
  late DateTime? _firstPaymentDate;
  late bool _isRecurringPayment;
  late bool _isCombinedLoan;

  // 计算结果
  LoanCalculationResult? _calculationResult;

  @override
  void initState() {
    super.initState();
    _account = widget.account;
    _initializeControllers();
    _calculateLoan();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: _account.name);
    _loanAmountController = TextEditingController(
      text: _account.loanAmount?.toString() ?? '',
    );
    _interestRateController = TextEditingController(
      text: _account.interestRate?.toString() ?? '',
    );
    _secondInterestRateController = TextEditingController(
      text: _account.secondInterestRate?.toString() ?? '',
    );
    _loanTermController = TextEditingController(
      text: _account.loanTerm?.toString() ?? '',
    );
    _monthlyPaymentController = TextEditingController(
      text: _account.monthlyPayment?.toString() ?? '',
    );
    _remainingPrincipalController = TextEditingController(
      text: _account.remainingPrincipal?.toString() ?? '',
    );

    _loanType = _account.loanType ?? LoanType.mortgage;
    _repaymentMethod =
        _account.repaymentMethod ?? RepaymentMethod.equalPrincipalAndInterest;
    _firstPaymentDate = _account.firstPaymentDate;
    _isRecurringPayment = _account.isRecurringPayment;
    _isCombinedLoan = _account.loanType == LoanType.combinedMortgage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _loanAmountController.dispose();
    _interestRateController.dispose();
    _secondInterestRateController.dispose();
    _loanTermController.dispose();
    _monthlyPaymentController.dispose();
    _remainingPrincipalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('贷款详情'),
          actions: [
            TextButton(
              onPressed: _saveAccount,
              child: const Text(
                '保存',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBasicInfoSection(),
                const SizedBox(height: 24),
                _buildLoanInfoSection(),
                const SizedBox(height: 24),
                _buildPaymentSettingsSection(),
                const SizedBox(height: 24),
                if (_calculationResult != null) ...[
                  _buildCalculationResultSection(),
                  const SizedBox(height: 24),
                ],
                _buildPaymentScheduleSection(),
              ],
            ),
          ),
        ),
      );

  Widget _buildBasicInfoSection() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '基本信息',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '贷款名称',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入贷款名称';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      );

  Widget _buildLoanInfoSection() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '贷款信息',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<LoanType>(
                initialValue: _loanType,
                decoration: const InputDecoration(
                  labelText: '贷款类型',
                  border: OutlineInputBorder(),
                ),
                items: LoanType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _loanType = value!;
                    _isCombinedLoan = value == LoanType.combinedMortgage;
                  });
                  _calculateLoan();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _loanAmountController,
                decoration: const InputDecoration(
                  labelText: '贷款总额 (¥)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入贷款总额';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return '请输入有效的金额';
                  }
                  return null;
                },
                onChanged: (_) => _calculateLoan(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _interestRateController,
                decoration: const InputDecoration(
                  labelText: '年利率 (%)',
                  border: OutlineInputBorder(),
                  helperText: '例如：4.5 表示年利率4.5%',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入年利率';
                  }
                  final rate = double.tryParse(value);
                  if (rate == null || rate < 0) {
                    return '请输入有效的利率';
                  }
                  return null;
                },
                onChanged: (_) => _calculateLoan(),
              ),
              if (_isCombinedLoan) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _secondInterestRateController,
                  decoration: const InputDecoration(
                    labelText: '第二利率 (%)',
                    border: OutlineInputBorder(),
                    helperText: '组合贷的第二部分利率',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _calculateLoan(),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _loanTermController,
                decoration: const InputDecoration(
                  labelText: '贷款期限 (月)',
                  border: OutlineInputBorder(),
                  helperText: '例如：360 表示30年',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入贷款期限';
                  }
                  final term = int.tryParse(value);
                  if (term == null || term <= 0) {
                    return '请输入有效的期限';
                  }
                  return null;
                },
                onChanged: (_) => _calculateLoan(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RepaymentMethod>(
                initialValue: _repaymentMethod,
                decoration: const InputDecoration(
                  labelText: '还款方式',
                  border: OutlineInputBorder(),
                ),
                items: RepaymentMethod.values
                    .map(
                      (method) => DropdownMenuItem(
                        value: method,
                        child: Text(method.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _repaymentMethod = value!;
                  });
                  _calculateLoan();
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectFirstPaymentDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: '首次还款日期',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _firstPaymentDate != null
                        ? '${_firstPaymentDate!.year}-${_firstPaymentDate!.month.toString().padLeft(2, '0')}-${_firstPaymentDate!.day.toString().padLeft(2, '0')}'
                        : '请选择首次还款日期',
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildPaymentSettingsSection() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '还款设置',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _monthlyPaymentController,
                decoration: const InputDecoration(
                  labelText: '月还款额 (¥)',
                  border: OutlineInputBorder(),
                  helperText: '系统自动计算，可手动调整',
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculateLoan(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _remainingPrincipalController,
                decoration: const InputDecoration(
                  labelText: '剩余本金 (¥)',
                  border: OutlineInputBorder(),
                  helperText: '当前剩余未还本金',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入剩余本金';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 0) {
                    return '请输入有效的金额';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('设置为周期性交易'),
                subtitle: const Text('每月自动记录还款交易'),
                value: _isRecurringPayment,
                onChanged: (value) {
                  setState(() {
                    _isRecurringPayment = value;
                  });
                },
              ),
            ],
          ),
        ),
      );

  Widget _buildCalculationResultSection() {
    if (_calculationResult == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '计算结果',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildValueRow('月还款额', _calculationResult!.monthlyPayment),
            _buildValueRow('总利息', _calculationResult!.totalInterest),
            _buildValueRow('总还款额', _calculationResult!.totalPayment),
            _buildValueRow(
              '利息占比',
              _calculationResult!.totalInterest /
                  _calculationResult!.totalPayment *
                  100,
              isPercentage: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentScheduleSection() {
    if (_calculationResult == null ||
        _calculationResult!.paymentSchedule.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '还款计划',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: _calculationResult!.paymentSchedule.length,
                itemBuilder: (context, index) {
                  final item = _calculationResult!.paymentSchedule[index];
                  return ListTile(
                    title: Text('第${item.period}期'),
                    subtitle: Text(
                      '${item.paymentDate.year}-${item.paymentDate.month.toString().padLeft(2, '0')}-${item.paymentDate.day.toString().padLeft(2, '0')}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '¥${item.totalPayment.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '本金:¥${item.principal.toStringAsFixed(0)} 利息:¥${item.interest.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueRow(
    String label,
    double value, {
    bool isPercentage = false,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              isPercentage
                  ? '${value.toStringAsFixed(1)}%'
                  : '¥${value.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );

  Future<void> _selectFirstPaymentDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _firstPaymentDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        _firstPaymentDate = date;
      });
      _calculateLoan();
    }
  }

  void _calculateLoan() {
    if (_loanAmountController.text.isEmpty ||
        _interestRateController.text.isEmpty ||
        _loanTermController.text.isEmpty ||
        _firstPaymentDate == null) {
      return;
    }

    try {
      final loanAmount = double.parse(_loanAmountController.text);
      final interestRate = double.parse(_interestRateController.text);
      final loanTerm = int.parse(_loanTermController.text);
      final secondRate =
          _isCombinedLoan && _secondInterestRateController.text.isNotEmpty
              ? double.parse(_secondInterestRateController.text)
              : null;

      final tempAccount = _account.copyWith(
        loanType: _loanType,
        loanAmount: loanAmount,
        interestRate: interestRate,
        secondInterestRate: secondRate,
        loanTerm: loanTerm,
        repaymentMethod: _repaymentMethod,
        firstPaymentDate: _firstPaymentDate,
      );

      _calculationResult =
          _loanCalculationService.calculateLoanSchedule(tempAccount);

      // 更新月还款额显示
      _monthlyPaymentController.text =
          _calculationResult!.monthlyPayment.toStringAsFixed(0);

      setState(() {});
    } catch (e) {
      // 计算失败，忽略错误
    }
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final updatedAccount = _account.copyWith(
        name: _nameController.text,
        loanType: _loanType,
        loanAmount: double.tryParse(_loanAmountController.text),
        interestRate: double.tryParse(_interestRateController.text),
        secondInterestRate:
            _isCombinedLoan && _secondInterestRateController.text.isNotEmpty
                ? double.tryParse(_secondInterestRateController.text)
                : null,
        loanTerm: int.tryParse(_loanTermController.text),
        repaymentMethod: _repaymentMethod,
        firstPaymentDate: _firstPaymentDate,
        monthlyPayment: double.tryParse(_monthlyPaymentController.text),
        remainingPrincipal: double.tryParse(_remainingPrincipalController.text),
        isRecurringPayment: _isRecurringPayment,
        updateDate: DateTime.now(),
      );

      // 如果有回调函数，使用回调函数（用于添加新账户）
      if (widget.onAccountSaved != null) {
        widget.onAccountSaved!(updatedAccount);
      } else {
        // 否则使用Provider更新现有账户
        final accountProvider =
            Provider.of<AccountProvider>(context, listen: false);
        await accountProvider.updateAccount(updatedAccount);
      }

      if (mounted) {
        // 静默处理，不显示提示框
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        // 静默处理错误，不显示提示框
      }
    }
  }
}
