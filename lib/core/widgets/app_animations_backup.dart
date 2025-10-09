import 'package:flutter/material.dart';
import 'animations/input_animations.dart';
import 'animations/state_animations.dart';
import 'animations/list_animations.dart';
import 'animations/selection_animations.dart';
import 'animations/success_animations.dart';
import 'animations/component_animations.dart';

// 动画实现类已通过import语句导入

// 动画相关枚举定义
enum StatusType { loading, success, error, warning, info }

enum PriorityLevel { low, medium, high, urgent }

enum DrawerPosition { left, right, top, bottom }

/// 金融记账应用动画库
/// 提供专门为金融、记账、金额变动、列表操作等场景设计的特效动画
///
/// 按功能分类：
/// 1. 📝 输入反馈动画 - 用户输入时的即时视觉反馈
/// 2. 💰 状态变化动画 - 金额、余额、进度等数据变化的可视化
/// 3. 📋 列表操作动画 - 列表项的增删改查操作体验
/// 4. 🎯 交互选择动画 - 用户选择、切换、筛选的视觉反馈
/// 5. ✅ 成功确认动画 - 操作成功后的庆祝和成就感反馈
/// 6. 🔧 通用组件动画 - 通用UI组件的动画效果
///
/// 使用示例：
/// ```dart
/// // 金额变动脉冲效果
/// AppAnimations.animatedAmountPulse(
///   child: Text('¥1,234.56'),
///   isPositive: true,
/// );
///
/// // 列表项插入动画
/// AppAnimations.animatedListInsert(
///   child: transactionItem,
///   index: 0,
/// );
///
/// // 预算达成庆祝
/// AppAnimations.animatedBudgetCelebration(
///   child: budgetCard,
///   showCelebration: true,
/// );
/// ```

class AppAnimations {
  // ===== 通用组件动画 =====

  /// 按钮基础动画
  static Widget animatedButton({
    required Widget child,
    required VoidCallback onPressed,
    Duration duration = const Duration(milliseconds: 200),
  }) =>
      _AnimatedButton(
        child: child,
        onPressed: onPressed,
        duration: duration,
      );

  /// 数字滚动动画
  static Widget animatedNumber({
    required double value,
    required Duration duration,
    required TextStyle style,
  }) =>
      _AnimatedNumber(
        value: value,
        duration: duration,
        style: style,
      );

  /// 金额输入跳动反馈动画
  static Widget animatedAmountBounce({
    required Widget child,
    required bool isBouncing,
    Duration duration = const Duration(milliseconds: 400),
  }) =>
      _AnimatedAmountBounce(
        isBouncing: isBouncing,
        duration: duration,
        child: child,
      );

  /// 数字键盘按键动画
  static Widget animatedKeypadButton({
    required Widget child,
    required VoidCallback onPressed,
    Duration duration = const Duration(milliseconds: 200),
  }) =>
      _AnimatedKeypadButton(
        child: child,
        onPressed: onPressed,
        duration: duration,
      );

  /// 金额脉冲动画
  static Widget animatedAmountPulse({
    required Widget child,
    required bool isPositive,
    Duration duration = const Duration(milliseconds: 800),
    double scaleFactor = 1.1,
  }) =>
      _AnimatedAmountPulse(
        child: child,
        isPositive: isPositive,
        duration: duration,
        scaleFactor: scaleFactor,
      );

  /// 金额颜色渐变动画
  static Widget animatedAmountColor({
    required double amount,
    required String Function(double) formatter,
    required bool isPositive,
    Duration duration = const Duration(milliseconds: 800),
  }) =>
      _AnimatedAmountColor(
        amount: amount,
        formatter: formatter,
        isPositive: isPositive,
        duration: duration,
      );

  /// 资产余额涟漪效果
  static Widget animatedBalanceRipple({
    required Widget child,
    required bool hasChanged,
    Duration duration = const Duration(milliseconds: 1500),
    int rippleCount = 3,
  }) =>
      _AnimatedBalanceRipple(
        child: child,
        hasChanged: hasChanged,
        duration: duration,
        rippleCount: rippleCount,
      );

  /// 列表项插入动画
  static Widget animatedListInsert({
    required Widget child,
    required int index,
    Duration duration = const Duration(milliseconds: 600),
  }) =>
      _AnimatedListInsert(
        child: child,
        index: index,
        duration: duration,
      );

  /// 列表项删除动画
  static Widget animatedListDelete({
    required Widget child,
    required VoidCallback onDelete,
    Duration duration = const Duration(milliseconds: 400),
  }) =>
      _AnimatedListDelete(
        child: child,
        onDelete: onDelete,
        duration: duration,
      );

  /// 基础列表项动画
  static Widget animatedListItem({
    required Widget child,
    required int index,
    Duration duration = const Duration(milliseconds: 500),
  }) =>
      _AnimatedListItem(
        child: child,
        index: index,
        duration: duration,
      );

  /// 分类选择缩放动画
  static Widget animatedCategorySelect({
    required Widget child,
    required bool isSelected,
    Duration duration = const Duration(milliseconds: 200),
    double scaleFactor = 1.05,
  }) =>
      _AnimatedCategorySelect(
        child: child,
        isSelected: isSelected,
        duration: duration,
        scaleFactor: scaleFactor,
      );

  /// 交易确认动画
  static Widget animatedTransactionConfirm({
    required Widget child,
    required bool showConfirm,
    Duration duration = const Duration(milliseconds: 1000),
  }) =>
      _AnimatedTransactionConfirm(
            child: child,
        showConfirm: showConfirm,
        duration: duration,
      );

  /// 预算达成庆祝动画
  static Widget animatedBudgetCelebration({
    required Widget child,
    required bool showCelebration,
    Duration duration = const Duration(milliseconds: 2000),
  }) =>
      _AnimatedBudgetCelebration(
        child: child,
        showCelebration: showCelebration,
        duration: duration,
      );

  /// 保存成功确认动画
  static Widget animatedSaveConfirm({
    required Widget child,
    required bool showConfirm,
    Duration duration = const Duration(milliseconds: 1000),
  }) =>
      _AnimatedSaveConfirm(
        showConfirm: showConfirm,
        duration: duration,
        child: child,
      );
}
