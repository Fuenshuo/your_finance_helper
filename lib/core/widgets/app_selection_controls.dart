import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';

/// iOS 风格开关
/// 封装 CupertinoSwitch 以保持全平台一致的优雅手感
class AppSwitch extends StatelessWidget {
  const AppSwitch({
    required this.value,
    required this.onChanged,
    super.key,
  });
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppDesignTokens.primaryAction(context),
      );
}

/// iOS 风格复选框
/// 这是一个自定义动画组件，因为 iOS 原生没有 Checkbox
/// 样式：圆形，选中变蓝，带有微小的缩放动画
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    required this.value,
    required this.onChanged,
    super.key,
    this.label,
  });
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = AppDesignTokens.primaryAction(context);
    final inactiveBorderColor = isDark ? Colors.white38 : Colors.black26;

    final Widget checkbox = GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: value ? activeColor : Colors.transparent,
          border: Border.all(
            color: value ? activeColor : inactiveBorderColor,
            width: 2,
          ),
        ),
        child: value
            ? const Icon(
                CupertinoIcons.checkmark_alt,
                size: 16,
                color: Colors.white,
              )
            : null,
      ),
    );

    if (label != null) {
      return GestureDetector(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            checkbox,
            const SizedBox(width: 8),
            Text(
              label!,
              style: AppDesignTokens.body(context),
            ),
          ],
        ),
      );
    }

    return checkbox;
  }
}

/// 分段控制器 (用于切换 日/周/月)
/// 封装 CupertinoSlidingSegmentedControl
class AppSegmentedControl<T extends Object> extends StatelessWidget {
  const AppSegmentedControl({
    required this.children,
    required this.groupValue,
    required this.onValueChanged,
    super.key,
  });
  final Map<T, Widget> children;
  final T? groupValue;
  final ValueChanged<T?> onValueChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IntrinsicWidth(
      child: CupertinoSlidingSegmentedControl<T>(
        children: children.map(
          (key, value) => MapEntry(
            key,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: DefaultTextStyle(
                style: AppDesignTokens.headline(context).copyWith(
                  fontSize: 13,
                  color: groupValue == key
                      ? (isDark ? Colors.white : Colors.black) // 选中态颜色
                      : (isDark ? Colors.white60 : Colors.black54), // 未选中态颜色
                ),
                child: value,
              ),
            ),
          ),
        ),
        groupValue: groupValue,
        onValueChanged: onValueChanged,
        backgroundColor: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : const Color(0xFFEEEEF2),
        thumbColor: isDark ? const Color(0xFF636366) : Colors.white,
        // 为选中项添加阴影，增加立体感
        padding: EdgeInsets.zero,
      ),
    );
  }
}
