import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';

/// 添加钱包屏幕
class AddWalletScreen extends StatefulWidget {
  const AddWalletScreen({super.key});

  @override
  State<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _balanceController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _interestRateController = TextEditingController();

  AccountType _selectedType = AccountType.bank;
  AccountStatus _selectedStatus = AccountStatus.active;
  String _selectedCurrency = 'CNY';
  DateTime? _selectedOpenDate;

  bool _isDefault = false;
  bool _isHidden = false;
  bool _isRecurringPayment = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _balanceController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _cardNumberController.dispose();
    _creditLimitController.dispose();
    _interestRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          title: Text(
            '添加钱包',
            style: context.textTheme.headlineMedium,
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.responsiveSpacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 基本信息
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📝 基本信息',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: context.spacing16),

                      // 账户名称
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: '账户名称 *',
                          hintText: '如：工商银行储蓄卡',
                          prefixIcon: Icon(Icons.account_balance_wallet),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入账户名称';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: context.spacing16),

                      // 账户类型
                      DropdownButtonFormField<AccountType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: '账户类型 *',
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: AccountType.values
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
                              _selectedType = value;
                            });
                          }
                        },
                      ),

                      SizedBox(height: context.spacing16),

                      // 账户状态
                      DropdownButtonFormField<AccountStatus>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: '账户状态',
                          prefixIcon: Icon(Icons.info),
                        ),
                        items: AccountStatus.values
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status.displayName),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedStatus = value;
                            });
                          }
                        },
                      ),

                      SizedBox(height: context.spacing16),

                      // 描述
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: '描述',
                          hintText: '可选的账户描述',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.spacing16),

                // 财务信息
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💰 财务信息',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: context.spacing16),

                      // 当前余额
                      TextFormField(
                        controller: _balanceController,
                        decoration: const InputDecoration(
                          labelText: '当前余额 *',
                          hintText: '0.00',
                          prefixIcon: Icon(Icons.attach_money),
                          prefixText: '¥',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入当前余额';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null) {
                            return '请输入有效的金额';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: context.spacing16),

                      // 币种
                      DropdownButtonFormField<String>(
                        value: _selectedCurrency,
                        decoration: const InputDecoration(
                          labelText: '币种',
                          prefixIcon: Icon(Icons.currency_exchange),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'CNY', child: Text('人民币 (CNY)')),
                          DropdownMenuItem(
                              value: 'USD', child: Text('美元 (USD)')),
                          DropdownMenuItem(
                              value: 'EUR', child: Text('欧元 (EUR)')),
                          DropdownMenuItem(
                              value: 'JPY', child: Text('日元 (JPY)')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCurrency = value;
                            });
                          }
                        },
                      ),

                      // 信用卡特有字段
                      if (_selectedType == AccountType.creditCard) ...[
                        SizedBox(height: context.spacing16),
                        TextFormField(
                          controller: _creditLimitController,
                          decoration: const InputDecoration(
                            labelText: '信用额度',
                            hintText: '0.00',
                            prefixIcon: Icon(Icons.credit_card),
                            prefixText: '¥',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: context.spacing16),

                // 银行信息（银行账户和信用卡）
                if (_selectedType == AccountType.bank ||
                    _selectedType == AccountType.creditCard)
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🏦 银行信息',
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: context.spacing16),

                        // 银行名称
                        TextFormField(
                          controller: _bankNameController,
                          decoration: const InputDecoration(
                            labelText: '银行名称',
                            hintText: '如：中国工商银行',
                            prefixIcon: Icon(Icons.business),
                          ),
                        ),

                        SizedBox(height: context.spacing16),

                        // 账户号码
                        TextFormField(
                          controller: _accountNumberController,
                          decoration: const InputDecoration(
                            labelText: '账户号码',
                            hintText: '银行卡号或账户号',
                            prefixIcon: Icon(Icons.numbers),
                          ),
                          keyboardType: TextInputType.number,
                        ),

                        // 信用卡特有字段
                        if (_selectedType == AccountType.creditCard)
                          SizedBox(height: context.spacing16),

                        if (_selectedType == AccountType.creditCard)
                          TextFormField(
                            controller: _cardNumberController,
                            decoration: const InputDecoration(
                              labelText: '卡号',
                              hintText: '信用卡卡号',
                              prefixIcon: Icon(Icons.credit_card),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                      ],
                    ),
                  ),

                // 贷款账户特有字段
                if (_selectedType == AccountType.loan)
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🏠 贷款信息',
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: context.spacing16),

                        // 贷款类型
                        DropdownButtonFormField<LoanType>(
                          decoration: const InputDecoration(
                            labelText: '贷款类型',
                            prefixIcon: Icon(Icons.home_work),
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
                            // 处理贷款类型选择
                          },
                        ),

                        SizedBox(height: context.spacing16),

                        // 利率
                        TextFormField(
                          controller: _interestRateController,
                          decoration: const InputDecoration(
                            labelText: '年利率 (%)',
                            hintText: '4.9',
                            prefixIcon: Icon(Icons.percent),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: context.spacing16),

                // 设置选项
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚙️ 设置选项',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: context.spacing16),

                      // 是否设为默认账户
                      SwitchListTile(
                        title: const Text('设为默认账户'),
                        subtitle: const Text('设为此账户为默认收支账户'),
                        value: _isDefault,
                        onChanged: (value) {
                          setState(() {
                            _isDefault = value;
                          });
                        },
                      ),

                      // 是否隐藏账户
                      SwitchListTile(
                        title: const Text('隐藏账户'),
                        subtitle: const Text('在列表中隐藏此账户'),
                        value: _isHidden,
                        onChanged: (value) {
                          setState(() {
                            _isHidden = value;
                          });
                        },
                      ),

                      // 是否自动还款（贷款账户）
                      if (_selectedType == AccountType.loan)
                        SwitchListTile(
                          title: const Text('自动还款'),
                          subtitle: const Text('每月自动创建还款交易'),
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

                SizedBox(height: context.spacing32),

                // 保存按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryAction,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          vertical: context.responsiveSpacing16),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(context.responsiveSpacing12),
                      ),
                    ),
                    child: const Text('保存账户'),
                  ),
                ),

                SizedBox(height: context.spacing32),
              ],
            ),
          ),
        ),
      );

  void _saveAccount() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final account = Account(
      name: _nameController.text.trim(),
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      type: _selectedType,
      status: _selectedStatus,
      balance: double.tryParse(_balanceController.text) ?? 0.0,
      currency: _selectedCurrency,
      bankName: _bankNameController.text.isNotEmpty
          ? _bankNameController.text.trim()
          : null,
      accountNumber: _accountNumberController.text.isNotEmpty
          ? _accountNumberController.text.trim()
          : null,
      cardNumber: _cardNumberController.text.isNotEmpty
          ? _cardNumberController.text.trim()
          : null,
      creditLimit: _creditLimitController.text.isNotEmpty
          ? double.tryParse(_creditLimitController.text)
          : null,
      interestRate: _interestRateController.text.isNotEmpty
          ? double.tryParse(_interestRateController.text)
          : null,
      isDefault: _isDefault,
      isHidden: _isHidden,
      isRecurringPayment: _isRecurringPayment,
    );

    // 保存账户
    final accountProvider = context.read<AccountProvider>();
    accountProvider.addAccount(account);

    // 返回上一页
    Navigator.of(context).pop();

    // 显示成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('账户添加成功'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

