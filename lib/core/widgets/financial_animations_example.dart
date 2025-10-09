import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';

/// 金融记账特效使用示例
/// 展示如何在实际应用中使用各种金融特效动画
class FinancialAnimationsExample extends StatefulWidget {
  const FinancialAnimationsExample({super.key});

  @override
  State<FinancialAnimationsExample> createState() =>
      _FinancialAnimationsExampleState();
}

class _FinancialAnimationsExampleState
    extends State<FinancialAnimationsExample> {
  double _balance = 1234.56;
  bool _isBalanceChanged = false;
  bool _showTransactionConfirm = false;
  bool _isBudgetCelebrating = false;
  bool _isAmountBouncing = false;
  bool _isCategorySelected = false;
  bool _showSaveConfirm = false;

  final List<String> _transactions = [
    '早餐 - ¥25.00',
    '地铁卡充值 - ¥50.00',
    '工资收入 - ¥5000.00',
  ];

  void _addTransaction() {
    setState(() {
      _transactions.insert(0, '新交易 - ¥100.00');
      _showTransactionConfirm = true;
    });

    // 重置确认动画
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showTransactionConfirm = false;
        });
      }
    });
  }

  void _removeTransaction(int index) {
    setState(() {
      _transactions.removeAt(index);
    });
  }

  void _updateBalance() {
    setState(() {
      _balance += 100.00;
      _isBalanceChanged = true;
      _isAmountBouncing = true;
    });

    // 重置动画状态
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isBalanceChanged = false;
          _isAmountBouncing = false;
        });
      }
    });
  }

  void _toggleBudgetCelebration() {
    setState(() {
      _isBudgetCelebrating = !_isBudgetCelebrating;
    });
  }

  void _toggleCategorySelection() {
    setState(() {
      _isCategorySelected = !_isCategorySelected;
    });
  }

  void _showSaveConfirmation() {
    setState(() {
      _showSaveConfirm = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSaveConfirm = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('金融记账特效演示'),
          backgroundColor: Colors.blue,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 金额变动脉冲动画
              _buildSection(
                title: '1. 金额变动脉冲动画',
                description: '金额变化时的弹性缩放和颜色过渡效果',
                child: AppAnimations.animatedAmountPulse(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '账户余额',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '¥${_balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  isPositive: true,
                ),
              ),

              const SizedBox(height: 24),

              // 2. 金额变化颜色过渡动画
              _buildSection(
                title: '2. 金额变化颜色过渡',
                description: '金额数值变化时的颜色渐变效果',
                child: AppAnimations.animatedAmountColor(
                  amount: _balance,
                  formatter: (amount) => '¥${amount.toStringAsFixed(2)}',
                ),
              ),

              const SizedBox(height: 24),

              // 3. 资产余额变动波纹效果
              _buildSection(
                title: '3. 资产余额波纹效果',
                description: '余额变化时的扩散波纹动画',
                child: AppAnimations.animatedBalanceRipple(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '资产',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  isChanged: _isBalanceChanged,
                ),
              ),

              const SizedBox(height: 24),

              // 4. 列表项插入动画
              _buildSection(
                title: '4. 列表项插入动画',
                description: '新交易记录的滑入效果',
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: _addTransaction,
                      child: const Text('添加新交易'),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) =>
                            AppAnimations.animatedListInsert(
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(child: Text(_transactions[index])),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _removeTransaction(index),
                                ),
                              ],
                            ),
                          ),
                          index: index,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 5. 交易记录确认动画
              _buildSection(
                title: '5. 交易确认动画',
                description: '交易成功时的打勾确认效果',
                child: AppAnimations.animatedTransactionConfirm(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '交易记录',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  showConfirm: _showTransactionConfirm,
                ),
              ),

              const SizedBox(height: 24),

              // 6. 预算达成庆祝动画
              _buildSection(
                title: '6. 预算庆祝动画',
                description: '预算目标达成时的庆祝效果',
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: _toggleBudgetCelebration,
                      child: Text(_isBudgetCelebrating ? '停止庆祝' : '开始庆祝'),
                    ),
                    const SizedBox(height: 16),
                    AppAnimations.animatedBudgetCelebration(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.celebration,
                              size: 48,
                              color: Colors.yellow,
                            ),
                            SizedBox(height: 8),
                            Text(
                              '预算达成！',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      isCelebrating: _isBudgetCelebrating,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 7. 金额输入跳动反馈
              _buildSection(
                title: '7. 金额输入跳动反馈',
                description: '输入金额时的弹性跳动效果',
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: _updateBalance,
                      child: const Text('更新余额'),
                    ),
                    const SizedBox(height: 16),
                    AppAnimations.animatedAmountBounce(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '¥${_balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      isPositive: _isAmountBouncing,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 8. 分类选择缩放动画
              _buildSection(
                title: '8. 分类选择缩放动画',
                description: '选择分类时的缩放和高亮效果',
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: _toggleCategorySelection,
                      child: Text(_isCategorySelected ? '取消选择' : '选择分类'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCategoryItem('餐饮', false),
                        AppAnimations.animatedCategorySelect(
                          child: _buildCategoryItem('交通', _isCategorySelected),
                          isSelected: _isCategorySelected,
                        ),
                        _buildCategoryItem('娱乐', false),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 9. 保存成功确认动画
              _buildSection(
                title: '9. 保存确认动画',
                description: '保存成功时的顶部提示动画',
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: _showSaveConfirmation,
                      child: const Text('保存数据'),
                    ),
                    const SizedBox(height: 16),
                    AppAnimations.animatedSaveConfirm(
                      child: Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            '数据表单',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      showConfirm: _showSaveConfirm,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 10. 数字键盘按键动画
              _buildSection(
                title: '10. 数字键盘按键动画',
                description: '键盘按键的按压反馈效果',
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (int i = 1; i <= 9; i++)
                      AppAnimations.animatedKeypadButton(
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              i.toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        onPressed: () {},
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildSection({
    required String title,
    required String description,
    required Widget child,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      );

  Widget _buildCategoryItem(String label, bool isSelected) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      );
}
