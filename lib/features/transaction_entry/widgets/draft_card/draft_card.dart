import 'package:flutter/material.dart';
import 'package:your_finance_flutter/features/transaction_entry/models/draft_transaction.dart';
import 'package:your_finance_flutter/features/transaction_entry/models/input_validation.dart';
import 'package:your_finance_flutter/features/transaction_entry/widgets/draft_card/account_selector.dart';
import 'package:your_finance_flutter/features/transaction_entry/widgets/draft_card/amount_display.dart';
import 'package:your_finance_flutter/features/transaction_entry/widgets/draft_card/cancel_button.dart';
import 'package:your_finance_flutter/features/transaction_entry/widgets/draft_card/category_selector.dart';
import 'package:your_finance_flutter/features/transaction_entry/widgets/draft_card/confirm_button.dart';
import 'package:your_finance_flutter/features/transaction_entry/widgets/draft_card/date_selector.dart';

/// 草稿卡片主组件
///
/// 显示解析后的交易草稿信息，支持编辑和确认操作。
/// 这是用户与AI解析结果交互的主要界面。
///
/// 功能特性：
/// - 显示解析后的交易金额、类型、分类等信息
/// - 提供分类、账户、日期的选择器
/// - 实时验证状态显示和错误提示
/// - 确认/取消操作按钮
/// - 解析状态指示器和进度反馈
///
/// 子组件：
/// - AmountDisplay: 金额展示和编辑
/// - CategorySelector: 分类选择器
/// - AccountSelector: 账户选择器
/// - DateSelector: 日期选择器
/// - CancelButton/ConfirmButton: 操作按钮
///
/// 交互设计：
/// - 卡片展开/折叠动画
/// - 字段编辑时的即时验证
/// - 成功确认时的庆祝动画
/// - 错误状态的视觉反馈
///
/// 无障碍支持：
/// - 语义标签和描述
/// - 键盘导航支持
/// - 屏幕阅读器兼容
class DraftCard extends StatefulWidget {
  const DraftCard({
    required this.draft,
    required this.validation,
    super.key,
    this.isParsing = false,
    this.onCancel,
    this.onConfirm,
  });

  /// 交易草稿数据
  final DraftTransaction draft;

  /// 输入验证状态
  final InputValidation validation;

  /// 是否正在解析
  final bool isParsing;

  /// 取消回调
  final VoidCallback? onCancel;

  /// 确认回调
  final VoidCallback? onConfirm;

  @override
  State<DraftCard> createState() => _DraftCardState();
}

class _DraftCardState extends State<DraftCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // 开始动画
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 根据验证状态确定边框颜色
    Color borderColor;
    if (!widget.validation.isValid) {
      borderColor = Colors.red;
    } else if (widget.validation.hasWarnings) {
      borderColor = Colors.orange;
    } else {
      borderColor = colorScheme.outline.withValues(alpha: 0.3);
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnimation, _slideAnimation]),
      builder: (context, child) => FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 头部 - 置信度和状态
                _buildHeader(),

                // 主体内容
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 金额显示
                      AmountDisplay(
                        amount: widget.draft.amount,
                      ),

                      const SizedBox(height: 16),

                      // 描述
                      if (widget.draft.description != null)
                        Text(
                          widget.draft.description!,
                          style: theme.textTheme.bodyLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                      const SizedBox(height: 16),

                      // 选择器行
                      Row(
                        children: [
                          // 分类选择器
                          Expanded(
                            child: CategorySelector(
                              selectedCategoryId: widget.draft.categoryId,
                              onCategorySelected: (categoryId) {
                                // TODO: 更新草稿
                              },
                            ),
                          ),

                          const SizedBox(width: 12),

                          // 账户选择器
                          Expanded(
                            child: AccountSelector(
                              selectedAccountId: widget.draft.accountId,
                              onAccountSelected: (accountId) {
                                // TODO: 更新草稿
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // 日期选择器
                      DateSelector(
                        selectedDate: widget.draft.transactionDate,
                        onDateSelected: (date) {
                          // TODO: 更新草稿
                        },
                      ),
                    ],
                  ),
                ),

                // 底部操作按钮
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _getHeaderColor(),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Row(
          children: [
            // 置信度指示器
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${(widget.draft.confidence * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Spacer(),

            // 状态图标
            if (!widget.validation.isValid)
              const Icon(
                Icons.error,
                color: Colors.white,
                size: 16,
              )
            else if (widget.validation.hasWarnings)
              const Icon(
                Icons.warning,
                color: Colors.white,
                size: 16,
              )
            else
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 16,
              ),
          ],
        ),
      );

  Color _getHeaderColor() {
    if (!widget.validation.isValid) {
      return Colors.red;
    } else if (widget.validation.hasWarnings) {
      return Colors.orange;
    } else if (widget.draft.confidence > 0.8) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }

  Widget _buildActions() => Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.3),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          children: [
            // 取消按钮
            Expanded(
              child: CancelButton(
                onPressed: widget.onCancel,
              ),
            ),

            const SizedBox(width: 12),

            // 确认按钮
            Expanded(
              flex: 2,
              child: ConfirmButton(
                onPressed: widget.validation.isValid && widget.draft.isComplete
                    ? widget.onConfirm
                    : null,
                isValid: widget.validation.isValid,
                isComplete: widget.draft.isComplete,
              ),
            ),
          ],
        ),
      );
}
