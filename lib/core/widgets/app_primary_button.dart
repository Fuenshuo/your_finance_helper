import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';

/// iOS 风格主按钮
/// 特性：56pt高度、按压回弹动画、Loading状态
class AppPrimaryButton extends StatefulWidget {
  const AppPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;

  @override
  State<AppPrimaryButton> createState() => _AppPrimaryButtonState();
}

class _AppPrimaryButtonState extends State<AppPrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 获取按钮阴影（SharpProfessional: 清晰紧凑，iOS Fintech: 柔和扩散）
  List<BoxShadow> _getButtonShadow(BuildContext context) {
    final currentStyle = AppDesignTokens.getCurrentStyle();
    final isSharpProfessional = currentStyle == AppStyle.SharpProfessional;

    if (isSharpProfessional) {
      // SharpProfessional: 紧凑且略深的阴影，避免柔和的大面积扩散
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25), // 略深的阴影
          blurRadius: 8, // 紧凑的模糊半径
          offset: const Offset(0, 4), // 清晰的偏移
        ),
      ];
    } else {
      // iOS Fintech: 柔和的扩散阴影
      return [
        BoxShadow(
          color: AppDesignTokens.primaryAction(context).withValues(alpha: 0.2),
          blurRadius: 16,
          offset: const Offset(0, 8),
          spreadRadius: -2,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = !widget.isEnabled || widget.isLoading;
    final bgColor = AppDesignTokens.primaryAction(context);

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => _controller.forward(),
      onTapUp: isDisabled ? null : (_) => _controller.reverse(),
      onTapCancel: isDisabled ? null : () => _controller.reverse(),
      onTap: isDisabled ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 56,
            minWidth: 120, // 最小宽度，确保按钮不会太小
          ),
          child: IntrinsicWidth(
            child: Container(
              height: 56, // 强制高度，增加点击热区和稳重感
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ), // 水平内边距，确保按钮有合适的宽度
              decoration: BoxDecoration(
                color: isDisabled ? bgColor.withValues(alpha: 0.5) : bgColor,
                borderRadius: BorderRadius.circular(
                  AppDesignTokens.radiusMedium(context),
                ), // 16pt 圆角（iOS Fintech）或 8pt（SharpProfessional）
                boxShadow: isDisabled ? [] : _getButtonShadow(context),
              ),
              alignment: Alignment.center,
              child: widget.isLoading
                  ? const CupertinoActivityIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17, // Headline Size
                            fontWeight: FontWeight.w600, // 加粗
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 次要按钮（兼容旧代码）
class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    required this.onPressed,
    required this.label,
    super.key,
    this.icon,
    this.isEnabled = true,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: isEnabled ? onPressed : null,
        style: TextButton.styleFrom(
          foregroundColor: AppDesignTokens.primaryAction(context),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesignTokens.spacing16,
            vertical: AppDesignTokens.spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDesignTokens.radiusMedium(context)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: AppDesignTokens.spacing8),
            ],
            Text(
              label,
              style: AppDesignTokens.headline(context).copyWith(
                color: AppDesignTokens.primaryAction(context),
              ),
            ),
          ],
        ),
      );
}
