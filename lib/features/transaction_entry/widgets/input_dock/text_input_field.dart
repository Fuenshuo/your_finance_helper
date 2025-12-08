import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 文本输入框组件
class TextInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;

  const TextInputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField>
    with SingleTickerProviderStateMixin {

  late final AnimationController _focusAnimationController;
  late final Animation<double> _borderAnimation;

  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _borderAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _focusAnimationController,
      curve: Curves.easeInOut,
    ));

    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _focusAnimationController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_focusNode.hasFocus) {
      _focusAnimationController.forward();
    } else {
      _focusAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _borderAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isFocused
                  ? colorScheme.primary.withValues(alpha: 0.6)
                  : colorScheme.outline.withValues(alpha: 0.3),
              width: _borderAnimation.value,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            maxLines: 3,
            minLines: 1,
            textInputAction: TextInputAction.send,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted != null
                ? (_) => widget.onSubmitted!()
                : null,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: widget.enabled
                  ? colorScheme.onSurface
                  : colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              isDense: true,
            ),
            inputFormatters: [
              // 限制输入长度
              LengthLimitingTextInputFormatter(500),
              // 过滤无效字符
              FilteringTextInputFormatter.deny(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]')),
            ],
          ),
        );
      },
    );
  }
}

