import 'package:flutter/material.dart';
import '../theme/app_design_tokens.dart';
import '../theme/app_design_tokens.dart' show AppStyle;

/// 自定义底部导航栏
/// 支持 SharpProfessional 风格的底部指示线
class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final Color? backgroundColor;
  final double? elevation;
  final BottomNavigationBarType type;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.backgroundColor,
    this.elevation,
    this.type = BottomNavigationBarType.fixed,
  });

  @override
  Widget build(BuildContext context) {
    final currentStyle = AppDesignTokens.getCurrentStyle();
    final isSharpProfessional = currentStyle == AppStyle.SharpProfessional;

    final defaultSelectedColor =
        selectedItemColor ?? AppDesignTokens.primaryAction(context);
    final defaultUnselectedColor =
        unselectedItemColor ?? AppDesignTokens.secondaryText(context);
    final defaultBackgroundColor =
        backgroundColor ?? AppDesignTokens.surface(context);

    // 如果使用 SharpProfessional 风格，需要自定义实现以支持底部指示线
    if (isSharpProfessional) {
      return Container(
        decoration: BoxDecoration(
          color: defaultBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isSelected = index == currentIndex;

                // 获取图标 Widget（优先使用 activeIcon）
                final iconWidget = isSelected ? item.activeIcon : item.icon;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 图标（使用 IconTheme 来设置颜色）
                        IconTheme(
                          data: IconThemeData(
                            color: isSelected
                                ? defaultSelectedColor
                                : defaultUnselectedColor,
                            size: 24,
                          ),
                          child: iconWidget,
                        ),
                        const SizedBox(height: 4),
                        // 标签
                        Text(
                          item.label ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? defaultSelectedColor
                                : defaultUnselectedColor,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // 底部指示线（仅选中时显示）
                        if (isSelected)
                          Container(
                            width: 24, // 与图标宽度一致
                            height: 2,
                            decoration: BoxDecoration(
                              color: defaultSelectedColor,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          )
                        else
                          const SizedBox(height: 2),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      );
    }

    // iOS Fintech 风格：使用标准 BottomNavigationBar
    return BottomNavigationBar(
      type: type,
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
      selectedItemColor: defaultSelectedColor,
      unselectedItemColor: defaultUnselectedColor,
      backgroundColor: defaultBackgroundColor,
      elevation: elevation ?? 8,
    );
  }
}
