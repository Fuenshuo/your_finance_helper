import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/financial_animations_example.dart';

/// 动画演示页面 - 用于验证所有动画特效的运行效果
class AnimationDemoPage extends StatelessWidget {
  const AnimationDemoPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('动画特效演示'),
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
              icon: const Icon(Icons.fullscreen),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FinancialAnimationsExample(),
                  ),
                );
              },
              tooltip: '完整演示',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🎨 金融记账动画特效验证',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '点击下方按钮测试各种动画效果',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),

              // ===== 1. 输入反馈动画 =====
              _buildTestSection(
                title: '📝 输入反馈动画',
                description: '用户输入时的即时视觉反馈，提升输入体验',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildQuickTestButton(
                      context: context,
                      label: '跳动反馈',
                      icon: Icons.vibration,
                      color: Colors.pink,
                      onPressed: () => _showBounceDemo(context),
                    ),
                    _buildQuickTestButton(
                      context: context,
                      label: '键盘按键',
                      icon: Icons.dialpad,
                      color: Colors.indigo,
                      onPressed: () => _showKeypadDemo(context),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.responsiveSpacing16),

              // ===== 2. 状态变化动画 =====
              _buildTestSection(
                title: '💰 状态变化动画',
                description: '金额、余额、进度等数据的变化可视化反馈',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildQuickTestButton(
                      context: context,
                      label: '金额脉冲',
                      icon: Icons.flash_on,
                      color: Colors.green,
                      onPressed: () => _showAmountPulseDemo(context),
                    ),
                    _buildQuickTestButton(
                      context: context,
                      label: '金额颜色',
                      icon: Icons.color_lens,
                      color: Colors.blue,
                      onPressed: () => _showAmountColorDemo(context),
                    ),
                    _buildQuickTestButton(
                      context: context,
                      label: '波纹效果',
                      icon: Icons.waves,
                      color: Colors.purple,
                      onPressed: () => _showRippleDemo(context),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.responsiveSpacing16),

              // ===== 3. 列表操作动画 =====
              _buildTestSection(
                title: '📋 列表操作动画',
                description: '列表项增删改查操作的流畅体验',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildQuickTestButton(
                      context: context,
                      label: '列表插入',
                      icon: Icons.playlist_add,
                      color: Colors.orange,
                      onPressed: () => _showListInsertDemo(context),
                    ),
                    _buildQuickTestButton(
                      context: context,
                      label: '列表删除',
                      icon: Icons.delete_sweep,
                      color: Colors.red,
                      onPressed: () => _showListDeleteDemo(context),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.responsiveSpacing16),

              // ===== 4. 交互选择动画 =====
              _buildTestSection(
                title: '🎯 交互选择动画',
                description: '用户选择、切换、筛选的视觉反馈',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildQuickTestButton(
                      context: context,
                      label: '分类选择',
                      icon: Icons.category,
                      color: Colors.cyan,
                      onPressed: () => _showCategorySelectDemo(context),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.responsiveSpacing16),

              // ===== 5. 成功确认动画 =====
              _buildTestSection(
                title: '✅ 成功确认动画',
                description: '操作成功后的庆祝和成就感反馈',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildQuickTestButton(
                      context: context,
                      label: '交易确认',
                      icon: Icons.check_circle,
                      color: Colors.teal,
                      onPressed: () => _showTransactionConfirmDemo(context),
                    ),
                    _buildQuickTestButton(
                      context: context,
                      label: '预算庆祝',
                      icon: Icons.celebration,
                      color: Colors.amber,
                      onPressed: () => _showBudgetCelebrationDemo(context),
                    ),
                    _buildQuickTestButton(
                      context: context,
                      label: '保存确认',
                      icon: Icons.save,
                      color: Colors.green,
                      onPressed: () => _showSaveConfirmDemo(context),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.responsiveSpacing16),

              // ===== 6. 通用组件动画 =====
              _buildTestSection(
                title: '🔧 通用组件动画',
                description: '通用UI组件的动画效果',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildQuickTestButton(
                      context: context,
                      label: '按钮动画',
                      icon: Icons.smart_button,
                      color: Colors.deepPurple,
                      onPressed: () => _showButtonDemo(context),
                    ),
                    _buildQuickTestButton(
                      context: context,
                      label: '数字滚动',
                      icon: Icons.exposure,
                      color: Colors.grey,
                      onPressed: () => _showNumberDemo(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 状态信息
              _buildTestSection(
                title: '📊 验证状态',
                description: '动画系统运行状态',
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '✅ 动画系统正常',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              '所有动画特效已成功加载并可正常使用',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 使用说明
              _buildTestSection(
                title: '📖 使用说明',
                description: '如何在你的应用中使用这些动画',
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '在你的组件中使用动画：',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '1. 导入动画库：',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "import 'package:your_finance_flutter/core/widgets/app_animations.dart';",
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '2. 包装你的组件：',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'AppAnimations.animatedAmountPulse(\n  child: YourWidget(),\n  isPositive: true,\n);',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildTestSection({
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

  Widget _buildQuickTestButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) =>
      SizedBox(
        width: 100,
        height: 80,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  // ===== 1. 输入反馈动画演示 =====

  // ===== 新增的演示方法 =====

  void _showButtonDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('按钮动画演示'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppAnimations.animatedButton(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '测试按钮',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onPressed: () {},
            ),
            const SizedBox(height: 16),
            const Text('点击按钮查看缩放反馈动画'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showNumberDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('数字滚动动画'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppAnimations.animatedNumber(
              value: 1234.56,
              duration: const Duration(seconds: 2),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            const Text('数字会从0开始滚动到目标值'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showListDeleteDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('列表项删除动画'),
        content: SizedBox(
          width: double.maxFinite,
          height: 200,
          child: ListView(
            children: [
              AppAnimations.animatedListDelete(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Text('滑动删除此项'),
                ),
                onDelete: () {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showAmountBounceDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('金额脉冲动画'),
        content: AppAnimations.animatedAmountPulse(
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
            child: const Text(
              '¥1,234.56',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          isPositive: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showAmountColorDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('金额颜色过渡动画'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppAnimations.animatedAmountColor(
              amount: 1234.56,
              formatter: (value) => '¥${value.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 16),
            const Text(
              '金额会根据变化自动变色',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showRippleDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('资产余额波纹效果'),
        content: AppAnimations.animatedBalanceRipple(
          child: Container(
            width: 100,
            height: 100,
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
          isChanged: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showListInsertDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('列表项插入动画'),
        content: SizedBox(
          width: double.maxFinite,
          height: 200,
          child: ListView(
            shrinkWrap: true,
            children: [
              AppAnimations.animatedListInsert(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Text('新插入的交易记录'),
                ),
                index: 0,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showTransactionConfirmDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('交易记录确认动画'),
        content: AppAnimations.animatedTransactionConfirm(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                '交易记录',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          showConfirm: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showBudgetCelebrationDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('预算达成庆祝动画'),
        content: AppAnimations.animatedBudgetCelebration(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
          isCelebrating: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showBounceDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _BounceDemoDialog(),
    );
  }

  void _showCategorySelectDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _CategorySelectDemoDialog(),
    );
  }

  void _showSaveConfirmDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('保存成功确认动画'),
        content: SizedBox(
          width: double.maxFinite,
          child: AppAnimations.animatedSaveConfirm(
            child: Container(
              height: 80,
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
            showConfirm: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showKeypadDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('数字键盘按键动画'),
        content: SizedBox(
          width: double.maxFinite,
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
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

// 跳动反馈演示对话框
class _BounceDemoDialog extends StatefulWidget {
  const _BounceDemoDialog();

  @override
  State<_BounceDemoDialog> createState() => _BounceDemoDialogState();
}

class _BounceDemoDialogState extends State<_BounceDemoDialog> {
  bool _isBouncing = false;

  void _triggerBounce() {
    setState(() => _isBouncing = true);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _isBouncing = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('金额输入跳动反馈'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppAnimations.animatedAmountBounce(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Text(
                  '¥1,234.56',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              isPositive: _isBouncing,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _triggerBounce,
              child: const Text('点击触发跳动反馈'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      );
}

// 分类选择演示对话框
class _CategorySelectDemoDialog extends StatefulWidget {
  const _CategorySelectDemoDialog();

  @override
  State<_CategorySelectDemoDialog> createState() =>
      _CategorySelectDemoDialogState();
}

class _CategorySelectDemoDialogState extends State<_CategorySelectDemoDialog> {
  int _selectedIndex = -1;
  final List<String> _categories = ['餐饮', '交通', '娱乐', '购物', '医疗'];

  void _selectCategory(int index) {
    setState(() => _selectedIndex = index);
  }

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

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('分类选择缩放动画'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '点击下方分类选项查看动画效果：',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: List.generate(
                  _categories.length,
                  (index) => GestureDetector(
                    onTap: () => _selectCategory(index),
                    child: AppAnimations.animatedCategorySelect(
                      child: _buildCategoryItem(
                        _categories[index],
                        _selectedIndex == index,
                      ),
                      isSelected: _selectedIndex == index,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      );
}

void _showAmountPulseDemo(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('金额脉冲动画'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppAnimations.animatedAmountPulse(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '¥1,234.56',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            isPositive: true,
          ),
          const SizedBox(height: 16),
          const Text(
            '金额增加时的脉冲效果',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    ),
  );
}
