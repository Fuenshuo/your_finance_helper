import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../widgets/app_animations.dart';
import '../widgets/app_card.dart';

class CreateBudgetScreen extends StatefulWidget {
  final BudgetType budgetType;

  const CreateBudgetScreen({
    super.key,
    required this.budgetType,
  });

  @override
  State<CreateBudgetScreen> createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends State<CreateBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  TransactionCategory _selectedCategory = TransactionCategory.food;
  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  double _warningThreshold = 80.0;
  double _limitThreshold = 100.0;
  bool _isEssential = false;
  String? _selectedColor;
  List<String> _tags = [];

  final List<String> _colorOptions = [
    '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7',
    '#DDA0DD', '#98D8C8', '#F7DC6F', '#BB8FCE', '#85C1E9',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.primaryBackground,
      appBar: AppBar(
        title: Text('创建${widget.budgetType.displayName}'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveBudget,
            child: Text(
              '保存',
              style: TextStyle(
                color: context.primaryAction,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 基本信息卡片
              AppAnimations.animatedListItem(
                index: 0,
                child: _buildBasicInfoCard(),
              ),
              SizedBox(height: context.spacing16),

              // 预算设置卡片
              AppAnimations.animatedListItem(
                index: 1,
                child: _buildBudgetSettingsCard(),
              ),
              SizedBox(height: context.spacing16),

              // 时间设置卡片
              AppAnimations.animatedListItem(
                index: 2,
                child: _buildTimeSettingsCard(),
              ),
              SizedBox(height: context.spacing16),

              // 高级设置卡片
              AppAnimations.animatedListItem(
                index: 3,
                child: _buildAdvancedSettingsCard(),
              ),
              SizedBox(height: context.spacing16),

              // 颜色和标签卡片
              AppAnimations.animatedListItem(
                index: 4,
                child: _buildColorAndTagsCard(),
              ),
              SizedBox(height: context.spacing32),

              // 保存按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveBudget,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: context.spacing16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.borderRadius),
                    ),
                  ),
                  child: Text(
                    '创建${widget.budgetType.displayName}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 基本信息卡片
  Widget _buildBasicInfoCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '基本信息',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: context.spacing16),

          // 预算名称
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: '预算名称',
              hintText: '例如：餐饮预算',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.borderRadius),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入预算名称';
              }
              return null;
            },
          ),
          SizedBox(height: context.spacing16),

          // 预算描述
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: '描述（可选）',
              hintText: '添加预算说明',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.borderRadius),
              ),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  // 预算设置卡片
  Widget _buildBudgetSettingsCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '预算设置',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: context.spacing16),

          // 分类选择
          DropdownButtonFormField<TransactionCategory>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: '预算分类',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.borderRadius),
              ),
            ),
            items: TransactionCategory.values.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Row(
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      size: 20,
                      color: context.primaryAction,
                    ),
                    SizedBox(width: context.spacing8),
                    Text(category.displayName),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedCategory = value;
                });
              }
            },
          ),
          SizedBox(height: context.spacing16),

          // 预算金额
          TextFormField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: '预算金额',
              hintText: '0.00',
              prefixText: '¥ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.borderRadius),
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入预算金额';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return '请输入有效的金额';
              }
              return null;
            },
          ),
          SizedBox(height: context.spacing16),

          // 预算周期
          DropdownButtonFormField<BudgetPeriod>(
            value: _selectedPeriod,
            decoration: InputDecoration(
              labelText: '预算周期',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.borderRadius),
              ),
            ),
            items: BudgetPeriod.values.map((period) {
              return DropdownMenuItem(
                value: period,
                child: Text(period.displayName),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedPeriod = value;
                  _updateEndDate();
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // 时间设置卡片
  Widget _buildTimeSettingsCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '时间设置',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: context.spacing16),

          // 开始日期
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.calendar_today_outlined,
              color: context.primaryAction,
            ),
            title: const Text('开始日期'),
            subtitle: Text(
              '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _selectDate(true),
          ),
          Divider(color: context.dividerColor),
          
          // 结束日期
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.event_outlined,
              color: context.primaryAction,
            ),
            title: const Text('结束日期'),
            subtitle: Text(
              '${_endDate.year}-${_endDate.month.toString().padLeft(2, '0')}-${_endDate.day.toString().padLeft(2, '0')}',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _selectDate(false),
          ),
        ],
      ),
    );
  }

  // 高级设置卡片
  Widget _buildAdvancedSettingsCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '高级设置',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: context.spacing16),

          // 必需支出开关
          SwitchListTile(
            title: const Text('必需支出'),
            subtitle: const Text('标记为必需支出，超支时优先提醒'),
            value: _isEssential,
            onChanged: (value) {
              setState(() {
                _isEssential = value;
              });
            },
            activeColor: context.primaryAction,
          ),
          Divider(color: context.dividerColor),

          // 警告阈值
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('警告阈值: ${_warningThreshold.toInt()}%'),
            subtitle: Slider(
              value: _warningThreshold,
              min: 50,
              max: 95,
              divisions: 9,
              activeColor: context.primaryAction,
              onChanged: (value) {
                setState(() {
                  _warningThreshold = value;
                });
              },
            ),
          ),
          Divider(color: context.dividerColor),

          // 限制阈值
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('限制阈值: ${_limitThreshold.toInt()}%'),
            subtitle: Slider(
              value: _limitThreshold,
              min: 90,
              max: 120,
              divisions: 6,
              activeColor: context.primaryAction,
              onChanged: (value) {
                setState(() {
                  _limitThreshold = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // 颜色和标签卡片
  Widget _buildColorAndTagsCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '外观设置',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: context.spacing16),

          // 颜色选择
          Text(
            '选择颜色',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: context.spacing8),
          Wrap(
            spacing: context.spacing8,
            runSpacing: context.spacing8,
            children: _colorOptions.map((color) {
              final isSelected = _selectedColor == color;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(int.parse(color.replaceFirst('#', '0xff'))),
                    shape: BoxShape.circle,
                    border: isSelected 
                      ? Border.all(color: context.primaryAction, width: 3)
                      : null,
                  ),
                  child: isSelected
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 选择日期
  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          _updateEndDate();
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // 更新结束日期
  void _updateEndDate() {
    switch (_selectedPeriod) {
      case BudgetPeriod.weekly:
        _endDate = _startDate.add(const Duration(days: 7));
        break;
      case BudgetPeriod.monthly:
        _endDate = DateTime(_startDate.year, _startDate.month + 1, _startDate.day);
        break;
      case BudgetPeriod.quarterly:
        _endDate = DateTime(_startDate.year, _startDate.month + 3, _startDate.day);
        break;
      case BudgetPeriod.yearly:
        _endDate = DateTime(_startDate.year + 1, _startDate.month, _startDate.day);
        break;
    }
  }

  // 获取分类图标
  IconData _getCategoryIcon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return Icons.restaurant_outlined;
      case TransactionCategory.transport:
        return Icons.directions_car_outlined;
      case TransactionCategory.shopping:
        return Icons.shopping_bag_outlined;
      case TransactionCategory.entertainment:
        return Icons.movie_outlined;
      case TransactionCategory.healthcare:
        return Icons.local_hospital_outlined;
      case TransactionCategory.education:
        return Icons.school_outlined;
      case TransactionCategory.housing:
        return Icons.home_outlined;
      case TransactionCategory.utilities:
        return Icons.electrical_services_outlined;
      case TransactionCategory.insurance:
        return Icons.security_outlined;
      case TransactionCategory.investment:
        return Icons.trending_up_outlined;
      case TransactionCategory.salary:
        return Icons.work_outlined;
      case TransactionCategory.bonus:
        return Icons.card_giftcard_outlined;
      case TransactionCategory.freelance:
        return Icons.work_outline;
      case TransactionCategory.otherIncome:
        return Icons.attach_money_outlined;
      case TransactionCategory.otherExpense:
        return Icons.receipt_outlined;
      case TransactionCategory.gift:
        return Icons.card_giftcard_outlined;
    }
  }

  // 保存预算
  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final amount = double.parse(_amountController.text);

    try {
      if (widget.budgetType == BudgetType.envelope) {
        // 创建信封预算
        final envelope = EnvelopeBudget(
          name: _nameController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          category: _selectedCategory,
          allocatedAmount: amount,
          period: _selectedPeriod,
          startDate: _startDate,
          endDate: _endDate,
          color: _selectedColor,
          isEssential: _isEssential,
          warningThreshold: _warningThreshold,
          limitThreshold: _limitThreshold,
          tags: _tags,
        );

        await budgetProvider.addEnvelopeBudget(envelope);
      } else if (widget.budgetType == BudgetType.zeroBased) {
        // 创建零基预算
        final zeroBased = ZeroBasedBudget(
          name: _nameController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          totalIncome: amount,
          period: _selectedPeriod,
          startDate: _startDate,
          endDate: _endDate,
        );

        await budgetProvider.addZeroBasedBudget(zeroBased);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.budgetType.displayName}创建成功！'),
            backgroundColor: context.decreaseColor,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('创建失败：$e'),
            backgroundColor: context.increaseColor,
          ),
        );
      }
    }
  }
}
