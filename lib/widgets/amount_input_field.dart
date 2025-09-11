import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 金额输入组件 - 带单位显示的金额输入框
class AmountInputField extends StatefulWidget {
  const AmountInputField({
    super.key,
    this.labelText,
    this.hintText,
    this.controller,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.prefixIcon,
    this.unitText = '元',
    this.unitTextSize,
    this.unitTextColor,
    this.contentPadding,
    this.borderRadius = 8.0,
    this.fillColor,
    this.showBorder = true,
    this.width,
    this.height,
  });
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final String unitText;
  final double? unitTextSize;
  final Color? unitTextColor;
  final EdgeInsetsGeometry? contentPadding;
  final double borderRadius;
  final Color? fillColor;
  final bool showBorder;
  final double? width;
  final double? height;

  @override
  State<AmountInputField> createState() => _AmountInputFieldState();
}

class _AmountInputFieldState extends State<AmountInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void didUpdateWidget(AmountInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller = widget.controller ?? TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: TextFormField(
        controller: _controller,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType ??
            const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: widget.inputFormatters ??
            [
              // 只允许数字和一个小数点
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          labelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
            fontSize: 14,
          ),
          prefixIcon: widget.prefixIcon,
          suffixIcon: _buildUnitSuffix(),
          contentPadding: widget.contentPadding ??
              const EdgeInsets.only(
                left: 16,
                top: 12,
                bottom: 12,
                right: 40, // 为36px宽度的单位块预留空间
              ),
          filled: true,
          fillColor:
              widget.fillColor ?? Colors.grey.withOpacity(0.03), // 更浅的灰色背景
          border: widget.showBorder
              ? OutlineInputBorder(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ), // 右边无圆角，与单位块衔接
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                )
              : InputBorder.none,
          enabledBorder: widget.showBorder
              ? OutlineInputBorder(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ), // 右边无圆角，与单位块衔接
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                )
              : InputBorder.none,
          focusedBorder: widget.showBorder
              ? OutlineInputBorder(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ), // 右边无圆角，与单位块衔接
                  borderSide: BorderSide(
                    color: theme.primaryColor,
                    width: 2,
                  ),
                )
              : InputBorder.none,
          errorBorder: widget.showBorder
              ? OutlineInputBorder(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ), // 右边无圆角，与单位块衔接
                  borderSide: BorderSide(
                    color: theme.colorScheme.error,
                  ),
                )
              : InputBorder.none,
          focusedErrorBorder: widget.showBorder
              ? OutlineInputBorder(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ), // 右边无圆角，与单位块衔接
                  borderSide: BorderSide(
                    color: theme.colorScheme.error,
                    width: 2,
                  ),
                )
              : InputBorder.none,
        ),
        onChanged: widget.onChanged,
        validator: widget.validator,
      ),
    );
  }

  Widget _buildUnitSuffix() {
    if (widget.unitText.isEmpty) return const SizedBox.shrink();

    return Container(
      width: 36, // 适当宽度
      padding: const EdgeInsets.symmetric(vertical: 12), // 垂直内边距
      alignment: Alignment.center, // 让"元"字居中
      margin: EdgeInsets.zero, // 移除所有边距，让它紧贴右边缘
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08), // 浅灰色背景
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8), // 与输入框圆角匹配
          bottomRight: Radius.circular(8),
        ), // 只在右侧有圆角
      ),
      child: Text(
        widget.unitText,
        style: TextStyle(
          fontSize: widget.unitTextSize ?? 13,
          fontWeight: FontWeight.w500,
          color: widget.unitTextColor ?? Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // 如果是内部创建的控制器，则释放它
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }
}

/// 简化的金额输入组件 - 用于内联使用
class SimpleAmountInput extends StatelessWidget {
  const SimpleAmountInput({
    required this.controller,
    super.key,
    this.hintText = '请输入金额',
    this.onChanged,
    this.width,
    this.showBorder = true,
  });
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final double? width;
  final bool showBorder;

  @override
  Widget build(BuildContext context) => AmountInputField(
        controller: controller,
        hintText: hintText,
        onChanged: onChanged,
        width: width,
        showBorder: showBorder,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );
}
