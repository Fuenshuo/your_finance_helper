import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/amount_input_field.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';

/// 账户编辑页面
class AccountEditScreen extends StatefulWidget {
  const AccountEditScreen({
    required this.account,
    super.key,
  });

  final Account account;

  @override
  State<AccountEditScreen> createState() => _AccountEditScreenState();
}

class _AccountEditScreenState extends State<AccountEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _initialBalanceController;

  late AccountType _selectedType;
  late AccountStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account.name);
    _descriptionController =
        TextEditingController(text: widget.account.description ?? '');
    _initialBalanceController =
        TextEditingController(text: widget.account.initialBalance.toString());

    _selectedType = widget.account.type;
    _selectedStatus = widget.account.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('编辑账户'),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _saveAccount,
              child: const Text('保存'),
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
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '基本信息',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: context.spacing16),

                      // 账户名称
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: '账户名称',
                          hintText: '请输入账户名称',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return '请输入账户名称';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: context.spacing16),

                      // 账户类型
                      DropdownButtonFormField<AccountType>(
                        initialValue: _selectedType,
                        decoration: const InputDecoration(
                          labelText: '账户类型',
                          border: OutlineInputBorder(),
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
                            setState(() => _selectedType = value);
                          }
                        },
                      ),
                      SizedBox(height: context.spacing16),

                      // 账户状态
                      DropdownButtonFormField<AccountStatus>(
                        initialValue: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: '账户状态',
                          border: OutlineInputBorder(),
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
                            setState(() => _selectedStatus = value);
                          }
                        },
                      ),
                      SizedBox(height: context.spacing16),

                      // 初始余额
                      AmountInputField(
                        controller: _initialBalanceController,
                        labelText: '初始余额',
                        hintText: '设置账户的初始余额',
                      ),
                      SizedBox(height: context.spacing16),

                      // 描述
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: '描述（可选）',
                          hintText: '请输入账户描述',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final initialBalance =
          double.tryParse(_initialBalanceController.text) ?? 0.0;

      final updatedAccount = widget.account.copyWith(
        name: _nameController.text.trim(),
        type: _selectedType,
        status: _selectedStatus,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        initialBalance: initialBalance,
        updateDate: DateTime.now(),
      );

      final accountProvider = context.read<AccountProvider>();
      await accountProvider.updateAccount(updatedAccount);

      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('账户已更新')),
      );

      Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: $e')),
      );
      }
    }
  }
}
