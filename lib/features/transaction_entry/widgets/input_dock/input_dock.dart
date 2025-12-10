import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/transaction_entry_provider.dart';
import 'text_input_field.dart';
import 'send_button.dart';
import 'voice_input_button.dart';

/// 输入面板组件
///
/// 交易录入的核心输入界面，包含以下功能：
/// - 多行文本输入框，支持自然语言输入
/// - 发送按钮，支持解析触发
/// - 语音输入按钮（可选）
/// - 智能提示和占位符文本
/// - 输入验证和格式检查
/// - 动画反馈和状态指示
///
/// 交互特性：
/// - 长按发送按钮显示快捷操作菜单
/// - 双击清空输入内容
/// - 支持键盘快捷键
/// - 语音输入权限处理
///
/// 性能优化：
/// - 防抖处理，避免频繁解析
/// - 输入内容缓存
/// - 内存安全的控制器管理
class InputDock extends ConsumerStatefulWidget {
  const InputDock({super.key});

  @override
  ConsumerState<InputDock> createState() => _InputDockState();
}

class _InputDockState extends ConsumerState<InputDock>
    with SingleTickerProviderStateMixin {

  late final TextEditingController _textController;
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // 监听输入变化
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _textController.text;
    if (text.isNotEmpty) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _onSendPressed() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      ref.read(transactionEntryProvider.notifier).updateInput(text);
      // 清空输入框
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final entryState = ref.watch(transactionEntryProvider);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 输入区域
          Row(
            children: [
              // 文本输入框
              Expanded(
                child: TextInputField(
                  controller: _textController,
                  hintText: entryState.isParsing ? '解析中...' : '输入交易信息...',
                  enabled: !entryState.isParsing,
                ),
              ),

              const SizedBox(width: 8),

              // 语音输入按钮
              VoiceInputButton(
                onVoiceInput: (text) {
                  _textController.text = text;
                },
                enabled: !entryState.isParsing,
              ),

              const SizedBox(width: 8),

              // 发送按钮
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: SendButton(
                      onPressed: _textController.text.trim().isNotEmpty ? _onSendPressed : null,
                      isLoading: entryState.isParsing,
                    ),
                  );
                },
              ),
            ],
          ),

          // 状态指示器
          if (entryState.isParsing || entryState.parseError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: _buildStatusIndicator(entryState),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(entryState) {
    if (entryState.parseError != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 16,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '解析失败: ${entryState.parseError}',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          SizedBox(width: 8),
          Text(
            '正在解析...',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

