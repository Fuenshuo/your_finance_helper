import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/features/transaction_flow/screens/add_transaction_screen.dart';
import 'package:your_finance_flutter/features/transaction_flow/widgets/ai_smart_accounting_widget.dart';
import 'package:your_finance_flutter/screens/unified_transaction_entry_screen_v2.dart';

/// 全局FAB - 悬浮按钮
/// 在Tab 1, 2, 3显示，提供快速记账入口
class GlobalFAB extends StatefulWidget {
  const GlobalFAB({super.key});

  @override
  State<GlobalFAB> createState() => _GlobalFABState();
}

class _GlobalFABState extends State<GlobalFAB>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _onMenuItemTap(VoidCallback onTap) {
    _toggleExpanded();
    Future.delayed(const Duration(milliseconds: 150), onTap);
  }

  @override
  Widget build(BuildContext context) {
    if (_isExpanded) {
      return _buildExpandedMenu(context);
    }

    return FloatingActionButton(
      onPressed: () {
        // 直接打开统一记账入口（Super Box）
        UnifiedTransactionEntryScreenV2.show(context);
      },
      backgroundColor: context.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _buildExpandedMenu(BuildContext context) => Stack(
        children: [
          // 背景遮罩
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleExpanded,
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),

          // 菜单项
          Positioned(
            bottom: 80,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // AI语音/文本记账
                _buildMenuItem(
                  context,
                  icon: Icons.mic_outlined,
                  label: 'AI记账',
                  color: const Color(0xFF9C27B0),
                  onTap: () => _onMenuItemTap(() {
                    AiSmartAccountingWidget.show(context);
                  }),
                ),

                const SizedBox(height: 12),

                // 拍发票/流水
                _buildMenuItem(
                  context,
                  icon: Icons.camera_alt_outlined,
                  label: '拍发票',
                  color: const Color(0xFF2196F3),
                  onTap: () => _onMenuItemTap(() {
                    // TODO: 打开相机/相册选择
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('拍照功能开发中...')),
                    );
                  }),
                ),

                const SizedBox(height: 12),

                // 手动记账
                _buildMenuItem(
                  context,
                  icon: Icons.edit_outlined,
                  label: '手动记账',
                  color: const Color(0xFF4CAF50),
                  onTap: () => _onMenuItemTap(() {
                    Navigator.of(context).push<void>(
                      AppAnimations.createRoute<void>(
                        const AddTransactionScreen(),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),

                // 关闭按钮
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FloatingActionButton(
                    onPressed: _toggleExpanded,
                    backgroundColor: Colors.grey[600],
                    mini: true,
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      );
}

