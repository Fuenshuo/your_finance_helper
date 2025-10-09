import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:your_finance_flutter/core/widgets/form_builder_utils.dart';

/// Demo screen to showcase flutter_form_builder capabilities
/// This demonstrates how complex forms can be built with better UX
class FormBuilderDemoScreen extends StatefulWidget {
  const FormBuilderDemoScreen({super.key});

  @override
  State<FormBuilderDemoScreen> createState() => _FormBuilderDemoScreenState();
}

class _FormBuilderDemoScreenState extends State<FormBuilderDemoScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Form Builder Demo'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section: Personal Information
              FormBuilderUtils.buildSectionHeader(
                title: '个人信息',
                subtitle: '基本信息填写',
                icon: Icons.person,
              ),

              FormBuilderUtils.buildTextField(
                name: 'fullName',
                label: '姓名',
                hintText: '请输入您的姓名',
                validator: (value) => FormBuilderUtils.requiredValidator(value, fieldName: '姓名'),
              ),

              FormBuilderUtils.buildTextField(
                name: 'email',
                label: '邮箱',
                hintText: '请输入邮箱地址',
                keyboardType: TextInputType.emailAddress,
                validator: FormBuilderUtils.emailValidator,
              ),

              FormBuilderUtils.buildTextField(
                name: 'phone',
                label: '手机号',
                hintText: '请输入手机号码',
                keyboardType: TextInputType.phone,
                validator: FormBuilderUtils.phoneValidator,
              ),

              // Section: Financial Information
              FormBuilderUtils.buildSectionHeader(
                title: '财务信息',
                subtitle: '收入和支出相关',
                icon: Icons.account_balance_wallet,
              ),

              FormBuilderUtils.buildAmountField(
                name: 'monthlyIncome',
                label: '月收入',
                validator: FormBuilderUtils.amountValidator,
              ),

              FormBuilderUtils.buildAmountField(
                name: 'monthlyExpenses',
                label: '月支出',
                validator: FormBuilderUtils.amountValidator,
              ),

              FormBuilderUtils.buildDropdown<String>(
                name: 'employmentType',
                label: '就业类型',
                items: const [
                  DropdownMenuItem(value: 'full_time', child: Text('全职')),
                  DropdownMenuItem(value: 'part_time', child: Text('兼职')),
                  DropdownMenuItem(value: 'freelance', child: Text('自由职业')),
                  DropdownMenuItem(value: 'business_owner', child: Text('企业主')),
                ],
                validator: (value) => FormBuilderUtils.requiredValidator(value, fieldName: '就业类型'),
              ),

              // Section: Preferences
              FormBuilderUtils.buildSectionHeader(
                title: '偏好设置',
                subtitle: '个性化配置',
                icon: Icons.settings,
              ),

              FormBuilderUtils.buildDateField(
                name: 'startDate',
                label: '开始日期',
                hintText: '选择开始跟踪的日期',
              ),

              FormBuilderUtils.buildCheckbox(
                name: 'enableNotifications',
                title: '启用通知',
                subtitle: '接收财务提醒和报告',
                initialValue: true,
              ),

              FormBuilderUtils.buildSwitch(
                name: 'autoBackup',
                title: '自动备份',
                subtitle: '每天自动备份数据到云端',
              ),

              FormBuilderUtils.buildSlider(
                name: 'budgetAlertThreshold',
                label: '预算提醒阈值',
                min: 50,
                max: 100,
                divisions: 10,
                initialValue: 80,
                displayFormat: '#%',
              ),

              // Form Actions
              FormBuilderUtils.buildFormActions(
                onCancel: _handleCancel,
                onSave: _handleSave,
                isLoading: _isLoading,
                saveText: '保存设置',
              ),
            ],
          ),
        ),
      ),
    );

  void _handleCancel() {
    if (_formKey.isValid()) {
      // Show confirmation dialog if form has unsaved changes
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('确认取消'),
          content: const Text('表单中有未保存的更改，确定要取消吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('继续编辑'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back
              },
              child: const Text('确认取消'),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.isValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请检查表单填写是否正确'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final formData = _formKey.getFormData();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('设置保存成功！共${formData.length}个字段'),
            backgroundColor: Colors.green,
          ),
        );

        // Print form data for demo
        debugPrint('Form Data: $formData');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
