import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_design_tokens.dart';
import '../amount_input_field.dart';

/// 输入框+操作按钮组合组件
/// 用于需要输入框旁边有操作按钮的场景（如基本工资+历史按钮）
class InputWithActionButton extends StatelessWidget {
  const InputWithActionButton({
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.actionButton,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.unitText = '元',
    super.key,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? actionButton; // 操作按钮（如历史按钮）
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final String unitText; // 单位文本（如"元"）

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AmountInputField(
            controller: controller,
            labelText: labelText,
            hintText: hintText,
            prefixIcon: prefixIcon,
            validator: validator,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            unitText: unitText,
          ),
        ),
        if (actionButton != null) ...[
          SizedBox(width: AppDesignTokens.spacing12),
          // 按钮容器，确保与输入框对齐
          Padding(
            padding: EdgeInsets.only(top: AppDesignTokens.spacing24), // 对齐label
            child: actionButton!,
          ),
        ],
      ],
    );
  }
}
