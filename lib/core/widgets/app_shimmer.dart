import 'package:flutter/material.dart';
import '../theme/app_design_tokens.dart';

/// 现代骨架屏效果
/// 使用 LinearGradient 实现流光效果
class AppShimmer extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const AppShimmer({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  // 预设：圆形骨架（头像）
  factory AppShimmer.circle({required double size}) {
    return AppShimmer(width: size, height: size, radius: size / 2);
  }

  // 预设：文本行骨架
  factory AppShimmer.text(
      {double width = double.infinity, double height = 16}) {
    return AppShimmer(width: width, height: height, radius: 4);
  }

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // 调整深色模式下的骨架颜色，防止太刺眼
    final baseColor =
        isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);
    final highlightColor =
        isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF2F2F7);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.1, 0.5, 0.9],
              // 核心：通过 transform 移动渐变，产生流动感
              transform: _SlidingGradientTransform(_controller.value),
            ),
          ),
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
        bounds.width * slidePercent * 2 - bounds.width, 0.0, 0.0);
  }
}

/// 预定义的Shimmer组件（兼容旧代码）
class AppShimmerWidgets {
  AppShimmerWidgets._();

  /// 卡片骨架屏
  static Widget card(BuildContext context, {double? height}) => AppShimmer(
        width: double.infinity,
        height: height ?? 120,
        radius: AppDesignTokens.radiusMedium(context),
      );

  /// 列表项骨架屏
  static Widget listItem(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppDesignTokens.spacing16),
        child: Row(
          children: [
            AppShimmer.circle(size: 48),
            const SizedBox(width: AppDesignTokens.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppShimmer.text(width: double.infinity, height: 16),
                  const SizedBox(height: AppDesignTokens.spacing8),
                  AppShimmer.text(width: 120, height: 12),
                ],
              ),
            ),
          ],
        ),
      );

  /// 文本骨架屏
  static Widget text(
    BuildContext context, {
    double? width,
    double height = 16,
  }) =>
      AppShimmer.text(width: width ?? double.infinity, height: height);

  /// 按钮骨架屏
  static Widget button(BuildContext context, {double? width}) => AppShimmer(
        width: width ?? double.infinity,
        height: AppDesignTokens.buttonHeight,
        radius: AppDesignTokens.radiusMedium(context),
      );
}
