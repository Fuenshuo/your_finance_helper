import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_design_tokens.dart';

/// iOS 风格输入框
/// 特性：无边框、灰色填充背景、大圆角、内容居中
class AppTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final String? helperText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.errorText,
    this.helperText,
    this.controller,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.inputFormatters,
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction,
    this.maxLines = 1,
    this.validator,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStyle = AppDesignTokens.getCurrentStyle();
    final isSharpProfessional = currentStyle == AppStyle.SharpProfessional;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              widget.labelText!,
              style: AppDesignTokens.label(context), // 使用标签样式（12pt）
            ),
          ),
        ],
        GestureDetector(
          onTap: widget.readOnly && widget.onTap != null ? widget.onTap : null,
          child: Container(
            decoration: BoxDecoration(
              // SharpProfessional: 无填充色，仅底部线条
              // iOS Fintech: 使用标准填充色
              color: isSharpProfessional
                  ? Colors.transparent
                  : AppDesignTokens.inputFill(context),
              borderRadius: BorderRadius.circular(
                isSharpProfessional
                    ? 8
                    : 12, // SharpProfessional: 8pt, iOS Fintech: 12pt
              ),
              // 错误状态下显示红色边框
              border: widget.errorText != null
                  ? Border.all(color: const Color(0xFFFF3B30), width: 1.5)
                  : null,
            ),
            child: Stack(
              children: [
                TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: widget.keyboardType,
                  obscureText: widget.obscureText,
                  enabled: widget.enabled,
                  readOnly: widget.readOnly,
                  inputFormatters: widget.inputFormatters,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onFieldSubmitted,
                  textInputAction: widget.textInputAction,
                  maxLines: widget.maxLines,
                  style: AppDesignTokens.body(context).copyWith(height: 1.2),
                  cursorColor: AppDesignTokens.primaryAction(context),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      color:
                          AppDesignTokens.body(context).color!.withOpacity(0.4),
                      fontSize: 17,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isSharpProfessional
                          ? 0
                          : 18, // SharpProfessional: 无水平padding（由全局边距控制）
                      vertical: 16,
                    ),
                    prefixIcon: widget.prefixIcon != null
                        ? IconTheme(
                            data: IconThemeData(
                                color: AppDesignTokens.primaryAction(context)),
                            child: widget.prefixIcon!)
                        : null,
                    suffixIcon: widget.suffixIcon,
                  ),
                ),
                // SharpProfessional: 底部 2px 线条，聚焦时切换为主题色，两端有 8pt 圆角
                if (isSharpProfessional && widget.errorText == null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: _isFocused
                            ? AppDesignTokens.primaryAction(context) // 聚焦时：主题色
                            : AppDesignTokens.dividerColor(
                                context), // 未聚焦时：分割线颜色
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8), // 8pt 圆角
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6),
            child: Text(
              widget.errorText!,
              style: const TextStyle(
                color: Color(0xFFFF3B30),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ] else if (widget.helperText != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6),
            child: Text(
              widget.helperText!,
              style: AppDesignTokens.caption(context),
            ),
          ),
        ],
      ],
    );
  }
}
