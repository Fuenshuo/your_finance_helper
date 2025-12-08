import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/utils/unified_notifications.dart';

/// 统一提示系统演示页面
/// 展示各种提示类型的用法和效果
class NotificationSystemDemo extends StatefulWidget {
  const NotificationSystemDemo({super.key});

  @override
  State<NotificationSystemDemo> createState() => _NotificationSystemDemoState();
}

class _NotificationSystemDemoState extends State<NotificationSystemDemo> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    unifiedNotifications.showSuccess(context, '计数器已更新: $_counter');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('统一提示系统演示'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎯 提示类型演示',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 基础提示演示
            _buildSection(
              '基础提示',
              [
                _buildDemoButton(
                  '信息提示',
                  () => unifiedNotifications.showInfo(context, '这是一条普通信息提示'),
                  Colors.blue,
                ),
                _buildDemoButton(
                  '成功提示',
                  () => unifiedNotifications.showSuccess(context, '操作执行成功！'),
                  Colors.green,
                ),
                _buildDemoButton(
                  '警告提示',
                  () => unifiedNotifications.showWarning(context, '请注意这个警告信息'),
                  Colors.orange,
                ),
                _buildDemoButton(
                  '错误提示',
                  () => unifiedNotifications.showError(context, '发生了一个错误，请重试'),
                  Colors.red,
                ),
              ],
            ),

            // 特殊提示演示
            _buildSection(
              '特殊提示',
              [
                _buildDemoButton(
                  '开发中提示',
                  () => unifiedNotifications.showDevelopment(context, '高级搜索功能'),
                  Colors.purple,
                ),
                _buildDemoButton(
                  '严重错误',
                  () => unifiedNotifications.showCritical(
                    context,
                    '这是一个严重错误，需要用户确认后才能继续操作。',
                    actionLabel: '我知道了',
                    actionCallback: () => unifiedNotifications.showInfo(context, '用户已确认'),
                  ),
                  Colors.red.shade800,
                ),
              ],
            ),

            // 带操作的提示演示
            _buildSection(
              '带操作的提示',
              [
                _buildDemoButton(
                  '可撤销的操作',
                  () => unifiedNotifications.showSuccess(
                    context,
                    '数据已保存',
                    actionLabel: '撤销',
                    actionCallback: () => unifiedNotifications.showInfo(context, '操作已撤销'),
                  ),
                  Colors.teal,
                ),
                _buildDemoButton(
                  '带链接的提示',
                  () => unifiedNotifications.showInfo(
                    context,
                    '新功能上线了，点击查看详情',
                    actionLabel: '查看详情',
                    actionCallback: () => unifiedNotifications.showInfo(context, '跳转到详情页面'),
                  ),
                  Colors.indigo,
                ),
              ],
            ),

            // 确认对话框演示
            _buildSection(
              '确认对话框',
              [
                _buildDemoButton(
                  '通用确认',
                  () async {
                    final result = await unifiedNotifications.showConfirmation(
                      context,
                      title: '确认操作',
                      message: '您确定要执行这个操作吗？',
                    );
                    if (result ?? false) {
                      unifiedNotifications.showSuccess(context, '操作已确认');
                    }
                  },
                  Colors.cyan,
                ),
                _buildDemoButton(
                  '删除确认',
                  () async {
                    final result = await unifiedNotifications.showDeleteConfirmation(
                      context,
                      '重要文件',
                    );
                    if (result ?? false) {
                      unifiedNotifications.showSuccess(context, '文件已删除');
                    }
                  },
                  Colors.red,
                ),
              ],
            ),

            // 智能路由演示
            _buildSection(
              '智能路由演示',
              [
                const Text(
                  '系统会根据当前上下文自动选择最佳的提示显示方式：\n'
                  '• 在模态框中 → AlertDialog\n'
                  '• 键盘可见时 → AlertDialog\n'
                  '• 横屏模式 → AlertDialog\n'
                  '• 其他情况 → GlassNotification',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                _buildDemoButton(
                  '测试智能路由',
                  () => unifiedNotifications.showInfo(context, '观察提示的显示方式'),
                  Colors.grey,
                ),
              ],
            ),

            // 性能测试
            _buildSection(
              '性能测试',
              [
                _buildDemoButton(
                  '批量提示',
                  () {
                    for (var i = 0; i < 3; i++) {
                      Future.delayed(Duration(milliseconds: i * 500), () {
                        unifiedNotifications.showInfo(context, '提示 ${i + 1}');
                      });
                    }
                  },
                  Colors.amber,
                ),
                _buildDemoButton(
                  '计数器演示',
                  _incrementCounter,
                  Colors.lightGreen,
                ),
              ],
            ),

            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 使用提示',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• 统一API: 所有提示都通过 unifiedNotifications 调用\n'
                    '• 智能路由: 系统自动选择最佳显示方式\n'
                    '• 类型安全: 使用枚举确保提示类型正确\n'
                    '• 队列管理: 多个提示会按顺序显示\n'
                    '• 上下文感知: 根据页面状态调整显示策略',
                    style: TextStyle(fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  Widget _buildSection(String title, List<Widget> buttons) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: buttons,
        ),
        const SizedBox(height: 24),
      ],
    );

  Widget _buildDemoButton(String text, VoidCallback onPressed, Color color) => ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
}
