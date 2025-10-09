import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

// 导入动画组件
part 'animations/components/animation_components.dart';
part 'animations/financial/animation_financial.dart';
part 'animations/navigation/animation_navigation.dart';

// 动画相关枚举定义
enum StatusType { loading, success, error, warning, info }

enum PriorityLevel { low, medium, high, urgent }

enum DrawerPosition { left, right, top, bottom }

enum ValidationState { none, valid, invalid, validating }

/// 金融记账应用动画库
/// 提供专门为金融、记账、金额变动、列表操作等场景设计的特效动画
///
/// 按功能分类：
/// 1. 📝 输入反馈动画 - 用户输入时的即时视觉反馈
/// 2. 💰 状态变化动画 - 金额、余额、进度等数据变化的可视化
/// 3. 📋 列表操作动画 - 列表项增删改查操作的流畅体验
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
///   isCelebrating: true,
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
        onPressed: onPressed,
        duration: duration,
        child: child,
      );

  /// 数字滚动动画
  static Widget animatedNumber({
    required double value,
    TextStyle? style,
    Duration duration = const Duration(milliseconds: 800),
  }) =>
      _AnimatedNumber(
        value: value,
        style: style,
        duration: duration,
      );

  /// 整数计数动画
  static Widget animatedIntegerCounter({
    required int value,
    Key? key,
    TextStyle? style,
    Duration duration = const Duration(milliseconds: 1000),
    bool animateFromZero = true,
  }) =>
      _AnimatedIntegerCounter(
        key: key,
        value: value,
        style: style,
        duration: duration,
        animateFromZero: animateFromZero,
      );

  /// 百分比进度动画
  static Widget animatedPercentage({
    required double percentage,
    TextStyle? style,
    Color? color,
    Duration duration = const Duration(milliseconds: 1200),
  }) =>
      _AnimatedPercentage(
        percentage: percentage,
        style: style,
        color: color,
        duration: duration,
      );

  /// 货币金额动画
  static Widget animatedCurrencyAmount({
    required double amount,
    String currencySymbol = '¥',
    TextStyle? style,
    Duration duration = const Duration(milliseconds: 800),
  }) =>
      _AnimatedCurrencyAmount(
        amount: amount,
        currencySymbol: currencySymbol,
        style: style,
        duration: duration,
      );

  /// 数字跳动计数器
  static Widget animatedBouncingCounter({
    required int value,
    TextStyle? style,
    Duration duration = const Duration(milliseconds: 600),
  }) =>
      _AnimatedBouncingCounter(
        value: value,
        style: style,
        duration: duration,
      );

  /// 渐变数字显示
  static Widget animatedGradientNumber({
    required double value,
    List<Color>? gradientColors,
    TextStyle? style,
    Duration duration = const Duration(milliseconds: 1000),
  }) =>
      _AnimatedGradientNumber(
        value: value,
        gradientColors: gradientColors,
        style: style,
        duration: duration,
      );

  // ===== 状态转换动画 =====

  /// 加载状态指示器
  static Widget animatedLoadingIndicator({
    String? message,
    Color? color,
    double size = 60.0,
    Duration duration = const Duration(milliseconds: 1000),
  }) =>
      _AnimatedLoadingIndicator(
        message: message,
        color: color,
        size: size,
        duration: duration,
      );

  /// 成功状态反馈
  static Widget animatedSuccessFeedback({
    required Widget child,
    required bool showSuccess,
    Duration duration = const Duration(milliseconds: 800),
  }) =>
      _AnimatedSuccessFeedback(
        showSuccess: showSuccess,
        duration: duration,
        child: child,
      );

  /// 失败状态反馈
  static Widget animatedErrorFeedback({
    required Widget child,
    required bool showError,
    Duration duration = const Duration(milliseconds: 600),
  }) =>
      _AnimatedErrorFeedback(
        showError: showError,
        duration: duration,
        child: child,
      );

  /// 等待状态动画
  static Widget animatedWaitingState({
    required Widget child,
    required bool isWaiting,
    Duration duration = const Duration(milliseconds: 1000),
  }) =>
      _AnimatedWaitingState(
        isWaiting: isWaiting,
        duration: duration,
        child: child,
      );

  /// 状态切换过渡
  static Widget animatedStateTransition({
    required Widget child,
    required StatusType status,
    Duration duration = const Duration(milliseconds: 500),
  }) =>
      _AnimatedStateTransition(
        status: status,
        duration: duration,
        child: child,
      );

  /// 进度状态指示器
  static Widget animatedProgressIndicator({
    required double progress,
    Color? color,
    double size = 60.0,
    Duration duration = const Duration(milliseconds: 800),
  }) =>
      _AnimatedProgressIndicator(
        progress: progress,
        color: color,
        size: size,
        duration: duration,
      );

  /// 步骤完成动画
  static Widget animatedStepCompletion({
    required Widget child,
    required bool isCompleted,
    Duration duration = const Duration(milliseconds: 600),
  }) =>
      _AnimatedStepCompletion(
        isCompleted: isCompleted,
        duration: duration,
        child: child,
      );

  /// 验证状态动画
  static Widget animatedValidationState({
    required Widget child,
    required ValidationState state,
    Duration duration = const Duration(milliseconds: 400),
  }) =>
      _AnimatedValidationState(
        state: state,
        duration: duration,
        child: child,
      );

  // ===== 进度和指标器动画 =====

  /// 圆环进度条动画
  static Widget animatedCircularProgress({
    required double progress,
    Color? color,
    double size = 100.0,
    double strokeWidth = 8.0,
    Duration duration = const Duration(milliseconds: 800),
  }) =>
      _AnimatedCircularProgress(
        progress: progress,
        color: color,
        size: size,
        strokeWidth: strokeWidth,
        duration: duration,
      );

  /// 条形进度条动画
  static Widget animatedLinearProgress({
    required double progress,
    Color? color,
    double height = 8.0,
    Duration duration = const Duration(milliseconds: 600),
  }) =>
      _AnimatedLinearProgress(
        progress: progress,
        color: color,
        height: height,
        duration: duration,
      );

  /// 步数器动画
  static Widget animatedStepCounter({
    required int currentStep,
    required int totalSteps,
    Color? activeColor,
    Color? inactiveColor,
    double size = 12.0,
    Duration duration = const Duration(milliseconds: 500),
  }) =>
      _AnimatedStepCounter(
        currentStep: currentStep,
        totalSteps: totalSteps,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
        size: size,
        duration: duration,
      );

  /// 百分比环形指示器
  static Widget animatedPercentageRing({
    required double percentage,
    Color? color,
    double size = 120.0,
    double strokeWidth = 12.0,
    Duration duration = const Duration(milliseconds: 1000),
  }) =>
      _AnimatedPercentageRing(
        percentage: percentage,
        color: color,
        size: size,
        strokeWidth: strokeWidth,
        duration: duration,
      );

  /// 加载进度指示器
  static Widget animatedLoadingProgress({
    required double progress,
    String? loadingText,
    Color? color,
    double size = 60.0,
    Duration duration = const Duration(milliseconds: 800),
  }) =>
      _AnimatedLoadingProgress(
        progress: progress,
        loadingText: loadingText,
        color: color,
        size: size,
        duration: duration,
      );

  /// 完成度指示器
  static Widget animatedCompletionIndicator({
    required bool isCompleted,
    Color? color,
    double size = 80.0,
    Duration duration = const Duration(milliseconds: 1200),
  }) =>
      _AnimatedCompletionIndicator(
        isCompleted: isCompleted,
        color: color,
        size: size,
        duration: duration,
      );

  /// 计时器进度条
  static Widget animatedTimerProgress({
    required Duration remainingTime,
    required Duration totalTime,
    Color? color,
    double height = 6.0,
    Duration updateInterval = const Duration(milliseconds: 100),
  }) =>
      _AnimatedTimerProgress(
        remainingTime: remainingTime,
        totalTime: totalTime,
        color: color,
        height: height,
        updateInterval: updateInterval,
      );

  /// 下载进度动画
  static Widget animatedDownloadProgress({
    required double progress,
    String? fileName,
    Color? color,
    double height = 8.0,
    Duration duration = const Duration(milliseconds: 300),
  }) =>
      _AnimatedDownloadProgress(
        progress: progress,
        fileName: fileName,
        color: color,
        height: height,
        duration: duration,
      );

  // ===== 列表和表格动画 =====

  /// 列表项滑动插入动画
  static Widget animatedListSlideInsert({
    required Widget child,
    int index = 0,
    Duration duration = const Duration(milliseconds: 600),
  }) =>
      _AnimatedListSlideInsert(
        index: index,
        duration: duration,
        child: child,
      );

  /// 列表项组合动画（缩放+滑动）
  static Widget animatedListCombined({
    required Widget child,
    int index = 0,
    Duration duration = const Duration(milliseconds: 800),
  }) =>
      _AnimatedListCombined(
        index: index,
        duration: duration,
        child: child,
      );

  /// 列表排序动画
  static Widget animatedListSort({
    required Widget child,
    required int oldIndex,
    required int newIndex,
    Duration duration = const Duration(milliseconds: 500),
  }) =>
      _AnimatedListSort(
        oldIndex: oldIndex,
        newIndex: newIndex,
        duration: duration,
        child: child,
      );

  /// 表格行展开动画
  static Widget animatedTableRowExpand({
    required Widget child,
    required bool isExpanded,
    Duration duration = const Duration(milliseconds: 400),
  }) =>
      _AnimatedTableRowExpand(
        isExpanded: isExpanded,
        duration: duration,
        child: child,
      );

  /// 表格列排序动画
  static Widget animatedTableColumnSort({
    required Widget child,
    required bool isSorting,
    Duration duration = const Duration(milliseconds: 300),
  }) =>
      _AnimatedTableColumnSort(
        isSorting: isSorting,
        duration: duration,
        child: child,
      );

  /// 列表项拖拽动画
  static Widget animatedListDrag({
    required Widget child,
    required bool isDragging,
    required Offset dragOffset,
    Duration duration = const Duration(milliseconds: 200),
  }) =>
      _AnimatedListDrag(
        isDragging: isDragging,
        dragOffset: dragOffset,
        duration: duration,
        child: child,
      );

  // ===== 图表和数据可视化动画 =====

  /// 柱状图动画
  static Widget animatedBarChart({
    required List<double> values,
    required double maxValue,
    List<Color>? colors,
    Duration duration = const Duration(milliseconds: 1500),
  }) =>
      _AnimatedBarChart(
        values: values,
        colors: colors,
        maxValue: maxValue,
        duration: duration,
      );

  /// 线图动画
  static Widget animatedLineChart({
    required List<double> values,
    Color? lineColor,
    double strokeWidth = 3.0,
    Duration duration = const Duration(milliseconds: 2000),
  }) =>
      _AnimatedLineChart(
        values: values,
        lineColor: lineColor,
        strokeWidth: strokeWidth,
        duration: duration,
      );

  /// 饼图动画
  static Widget animatedPieChart({
    required List<double> values,
    List<Color>? colors,
    double size = 200.0,
    Duration duration = const Duration(milliseconds: 1500),
  }) =>
      _AnimatedPieChart(
        values: values,
        colors: colors,
        size: size,
        duration: duration,
      );

  /// 数据点闪烁动画
  static Widget animatedDataPoint({
    required Widget child,
    required bool isHighlighted,
    Color? highlightColor,
    Duration duration = const Duration(milliseconds: 800),
  }) =>
      _AnimatedDataPoint(
        isHighlighted: isHighlighted,
        highlightColor: highlightColor,
        duration: duration,
        child: child,
      );

  /// 图表网格线动画
  static Widget animatedChartGrid({
    int horizontalLines = 5,
    int verticalLines = 5,
    Color? gridColor,
    Duration duration = const Duration(milliseconds: 1000),
  }) =>
      _AnimatedChartGrid(
        horizontalLines: horizontalLines,
        verticalLines: verticalLines,
        gridColor: gridColor,
        duration: duration,
      );

  // ===== 导航和页面转场动画 =====

  /// 创建滑动页面转场路由
  static PageRouteBuilder createSlideRoute(Widget page) =>
      _AnimatedSlideTransition(page: page);

  /// 创建渐变页面转场路由
  static PageRouteBuilder createFadeRoute(Widget page) =>
      _AnimatedFadeTransition(page: page);

  /// 创建展开页面转场路由
  static PageRouteBuilder createScaleRoute(Widget page) =>
      _AnimatedScaleTransition(page: page);

  /// 创建旋转页面转场路由
  static PageRouteBuilder createRotationRoute(Widget page) =>
      _AnimatedRotationTransition(page: page);

  /// 创建底部滑入页面转场路由
  static PageRouteBuilder createBottomSlideRoute(Widget page) =>
      _AnimatedBottomSlideTransition(page: page);

  /// 标签页切换动画
  static Widget animatedTabSwitcher({
    required List<Widget> tabs,
    required int currentIndex,
    Duration duration = const Duration(milliseconds: 300),
  }) =>
      _AnimatedTabSwitcher(
        tabs: tabs,
        currentIndex: currentIndex,
        duration: duration,
      );

  /// 抽屉切换动画
  static Widget animatedDrawerTransition({
    required Widget child,
    required bool isOpen,
    DrawerPosition position = DrawerPosition.left,
    Duration duration = const Duration(milliseconds: 300),
  }) =>
      _AnimatedDrawerTransition(
        isOpen: isOpen,
        position: position,
        duration: duration,
        child: child,
      );

  /// 底部导航栏切换动画
  static Widget animatedBottomNavigation({
    required List<Widget> items,
    required int currentIndex,
    Duration duration = const Duration(milliseconds: 200),
  }) =>
      _AnimatedBottomNavigation(
        items: items,
        currentIndex: currentIndex,
        duration: duration,
      );

  // ===== 按钮和交互动画 =====

  /// 触摸反馈按钮动画
  static Widget animatedTouchFeedback({
    required Widget child,
    VoidCallback? onPressed,
    Color? feedbackColor,
    double scaleFactor = 0.95,
    Duration duration = const Duration(milliseconds: 150),
  }) =>
      _AnimatedTouchFeedback(
        onPressed: onPressed,
        feedbackColor: feedbackColor,
        scaleFactor: scaleFactor,
        duration: duration,
        child: child,
      );

  /// 长按按钮动画
  static Widget animatedLongPress({
    required Widget child,
    VoidCallback? onLongPress,
    Color? highlightColor,
    Duration duration = const Duration(milliseconds: 200),
  }) =>
      _AnimatedLongPress(
        onLongPress: onLongPress,
        highlightColor: highlightColor,
        duration: duration,
        child: child,
      );

  /// 滚动列表动画
  static Widget animatedScrollList({
    required List<Widget> children,
    ScrollController? controller,
    Duration staggerDuration = const Duration(milliseconds: 300),
  }) =>
      _AnimatedScrollList(
        controller: controller,
        staggerDuration: staggerDuration,
        children: children,
      );

  /// 拖拽反馈动画
  static Widget animatedDragFeedback({
    required Widget child,
    required Offset dragOffset,
    required bool isDragging,
    Duration duration = const Duration(milliseconds: 200),
  }) =>
      _AnimatedDragFeedback(
        dragOffset: dragOffset,
        isDragging: isDragging,
        duration: duration,
        child: child,
      );

  /// 悬停动画
  static Widget animatedHover({
    required Widget child,
    Color? hoverColor,
    double hoverScale = 1.05,
    Duration duration = const Duration(milliseconds: 200),
  }) =>
      _AnimatedHover(
        hoverColor: hoverColor,
        hoverScale: hoverScale,
        duration: duration,
        child: child,
      );

  /// 摇晃动画
  static Widget animatedShake({
    required Widget child,
    required bool shouldShake,
    Duration duration = const Duration(milliseconds: 500),
  }) =>
      _AnimatedShake(
        shouldShake: shouldShake,
        duration: duration,
        child: child,
      );

  // ===== 特效动画 =====

  /// 粒子效果动画
  static Widget animatedParticles({
    required Widget child,
    int particleCount = 12,
    Color? particleColor,
    double particleSize = 4.0,
    Duration duration = const Duration(milliseconds: 1000),
  }) =>
      _AnimatedParticles(
        particleCount: particleCount,
        particleColor: particleColor,
        particleSize: particleSize,
        duration: duration,
        child: child,
      );

  /// 波纹扩散动画
  static Widget animatedRipple({
    required Widget child,
    Color? rippleColor,
    double maxRadius = 100.0,
    Duration duration = const Duration(milliseconds: 2000),
  }) =>
      _AnimatedRipple(
        rippleColor: rippleColor,
        maxRadius: maxRadius,
        duration: duration,
        child: child,
      );

  /// 扭曲变形动画
  static Widget animatedDistortion({
    required Widget child,
    double distortionFactor = 5.0,
    Duration duration = const Duration(milliseconds: 1000),
  }) =>
      _AnimatedDistortion(
        distortionFactor: distortionFactor,
        duration: duration,
        child: child,
      );

  /// 发光效果动画
  static Widget animatedGlow({
    required Widget child,
    Color? glowColor,
    double glowRadius = 20.0,
    Duration duration = const Duration(milliseconds: 1500),
  }) =>
      _AnimatedGlow(
        glowColor: glowColor,
        glowRadius: glowRadius,
        duration: duration,
        child: child,
      );

  /// 爆炸效果动画
  static Widget animatedExplosion({
    required Widget child,
    required bool shouldExplode,
    int fragmentCount = 8,
    Color? fragmentColor,
    Duration duration = const Duration(milliseconds: 800),
  }) =>
      _AnimatedExplosion(
        shouldExplode: shouldExplode,
        fragmentCount: fragmentCount,
        fragmentColor: fragmentColor,
        duration: duration,
        child: child,
      );

  /// 脉冲波动画
  static Widget animatedPulseWave({
    required Widget child,
    Color? waveColor,
    double maxRadius = 150.0,
    Duration duration = const Duration(milliseconds: 3000),
  }) =>
      _AnimatedPulseWave(
        waveColor: waveColor,
        maxRadius: maxRadius,
        duration: duration,
        child: child,
      );

  // ===== 通用工具动画 =====

  /// 动画弹出对话框
  static Widget animatedDialog({
    required Widget child,
    required bool isVisible,
    Duration duration = const Duration(milliseconds: 300),
  }) =>
      _AnimatedDialog(
        isVisible: isVisible,
        duration: duration,
        child: child,
      );

  /// 提示消息动画
  static Widget animatedToast({
    required String message,
    required bool isVisible,
    Color? backgroundColor,
    Duration duration = const Duration(milliseconds: 400),
  }) =>
      _AnimatedToast(
        message: message,
        isVisible: isVisible,
        backgroundColor: backgroundColor,
        duration: duration,
      );

  /// 成功提示动画
  static Widget animatedSuccessPrompt({
    required bool isVisible,
    String? message,
    Color? color,
    Duration duration = const Duration(milliseconds: 500),
  }) =>
      _AnimatedSuccessPrompt(
        message: message,
        isVisible: isVisible,
        color: color,
        duration: duration,
      );

  /// 错误提示动画
  static Widget animatedErrorPrompt({
    required bool isVisible,
    String? message,
    Color? color,
    Duration duration = const Duration(milliseconds: 600),
  }) =>
      _AnimatedErrorPrompt(
        message: message,
        isVisible: isVisible,
        color: color,
        duration: duration,
      );

  /// 警告提示动画
  static Widget animatedWarningPrompt({
    required bool isVisible,
    String? message,
    Color? color,
    Duration duration = const Duration(milliseconds: 500),
  }) =>
      _AnimatedWarningPrompt(
        message: message,
        isVisible: isVisible,
        color: color,
        duration: duration,
      );

  // ===== 金融动画 =====

  /// 金额弹跳动画
  static Widget animatedAmountBounce({
    required Widget child,
    required bool isPositive,
    Duration duration = const Duration(milliseconds: 1000),
  }) =>
      _AnimatedAmountBounce(
        isPositive: isPositive,
        duration: duration,
        child: child,
      );

  /// 键盘按钮动画
  static Widget animatedKeypadButton({
    required Widget child,
    required VoidCallback onPressed,
    Duration duration = const Duration(milliseconds: 100),
  }) =>
      _AnimatedKeypadButton(
        onPressed: onPressed,
        duration: duration,
        child: child,
      );

  /// 金额脉冲动画
  static Widget animatedAmountPulse({
    required Widget child,
    required bool isPositive,
    Duration duration = const Duration(milliseconds: 600),
  }) =>
      _AnimatedAmountPulse(
        isPositive: isPositive,
        duration: duration,
        child: child,
      );

  /// 金额颜色过渡动画
  static Widget animatedAmountColor({
    required double amount,
    required String Function(double) formatter,
    Duration duration = const Duration(milliseconds: 800),
  }) =>
      _AnimatedAmountColor(
        amount: amount,
        formatter: formatter,
        duration: duration,
      );

  /// 资产余额涟漪效果
  static Widget animatedBalanceRipple({
    required Widget child,
    required bool isChanged,
    Duration duration = const Duration(milliseconds: 1500),
  }) =>
      _AnimatedBalanceRipple(
        isChanged: isChanged,
        duration: duration,
        child: child,
      );

  // ===== 列表动画 =====

  /// 列表项插入动画
  static Widget animatedListInsert({
    required Widget child,
    required int index,
    Duration duration = const Duration(milliseconds: 500),
  }) =>
      _AnimatedListInsert(
        index: index,
        duration: duration,
        child: child,
      );

  /// 列表项删除动画
  static Widget animatedListDelete({
    required Widget child,
    required VoidCallback onDelete,
    Duration duration = const Duration(milliseconds: 300),
  }) =>
      _AnimatedListDelete(
        onDelete: onDelete,
        duration: duration,
        child: child,
      );

  /// 列表项基础动画
  static Widget animatedListItem({
    required Widget child,
    required int index,
    Duration duration = const Duration(milliseconds: 400),
  }) =>
      _AnimatedListItem(
        index: index,
        duration: duration,
        child: child,
      );

  // ===== 交互动画 =====

  /// 分类选择动画
  static Widget animatedCategorySelect({
    required Widget child,
    required bool isSelected,
    Duration duration = const Duration(milliseconds: 300),
  }) =>
      _AnimatedCategorySelect(
        isSelected: isSelected,
        duration: duration,
        child: child,
      );

  /// 交易确认动画
  static Widget animatedTransactionConfirm({
    required Widget child,
    required bool showConfirm,
    Duration duration = const Duration(milliseconds: 500),
  }) =>
      _AnimatedTransactionConfirm(
        showConfirm: showConfirm,
        duration: duration,
        child: child,
      );

  /// 预算达成庆祝动画
  static Widget animatedBudgetCelebration({
    required Widget child,
    required bool isCelebrating,
    Duration duration = const Duration(milliseconds: 2000),
  }) =>
      _AnimatedBudgetCelebration(
        isCelebrating: isCelebrating,
        duration: duration,
        child: child,
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

  // ===== 导航动画 =====

  /// 创建页面过渡动画
  static Route<T> createRoute<T>(Widget page, {RouteSettings? settings}) =>
      PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      );

  /// 显示底部弹窗动画
  static Future<T?> showAppModalBottomSheet<T>({
    required BuildContext context,
    WidgetBuilder? builder,
    Widget? child,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    bool? showDragHandle,
    bool isScrollControlled = true,
  }) {
    assert(
      builder != null || child != null,
      'Either builder or child must be provided',
    );
    final effectiveBuilder = builder ?? (context) => child!;
    return showModalBottomSheet<T>(
      context: context,
      builder: effectiveBuilder,
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: elevation ?? 8,
      shape: shape ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
      showDragHandle: showDragHandle ?? true,
      isScrollControlled: isScrollControlled,
    );
  }

  // ===== 经济特定动画 =====

  /// 钱包抖动动画
  static Widget animatedWalletShake({
    required Widget child,
    required bool shouldShake,
    double shakeIntensity = 8.0,
    Duration duration = const Duration(milliseconds: 600),
  }) =>
      _AnimatedWalletShake(
        shouldShake: shouldShake,
        shakeIntensity: shakeIntensity,
        duration: duration,
        child: child,
      );

  /// 收入飘然动画
  static Widget animatedIncomeFloat({
    required String amount,
    required bool shouldFloat,
    Color? textColor,
    Duration duration = const Duration(milliseconds: 2000),
  }) =>
      _AnimatedIncomeFloat(
        amount: amount,
        shouldFloat: shouldFloat,
        textColor: textColor,
        duration: duration,
      );

  /// 支出波纹动画
  static Widget animatedExpenseRipple({
    required String amount,
    required bool shouldRipple,
    Color? rippleColor,
    Duration duration = const Duration(milliseconds: 1500),
  }) =>
      _AnimatedExpenseRipple(
        amount: amount,
        shouldRipple: shouldRipple,
        rippleColor: rippleColor,
        duration: duration,
      );

  /// 预算警戒动画
  static Widget animatedBudgetAlert({
    required Widget child,
    required bool isAlerting,
    double alertThreshold = 0.8,
    Color? alertColor,
    Duration duration = const Duration(milliseconds: 1000),
  }) =>
      _AnimatedBudgetAlert(
        isAlerting: isAlerting,
        alertThreshold: alertThreshold,
        alertColor: alertColor,
        duration: duration,
        child: child,
      );

  /// 投资收益波动动画
  static Widget animatedInvestmentWave({
    required List<double> values,
    Color? profitColor,
    Color? lossColor,
    Duration duration = const Duration(milliseconds: 2000),
  }) =>
      _AnimatedInvestmentWave(
        values: values,
        profitColor: profitColor,
        lossColor: lossColor,
        duration: duration,
      );

  /// 信用卡消费动画
  static Widget animatedCreditCardSpend({
    required Widget child,
    bool isSpending = false,
    double spendAmount = 0.0,
    Duration duration = const Duration(milliseconds: 400),
  }) =>
      _AnimatedCreditCardSpend(
        isSpending: isSpending,
        spendAmount: spendAmount,
        duration: duration,
        child: child,
      );
}

// ===== 数据显示动画 =====

/// 整数计数动画
class _AnimatedIntegerCounter extends StatefulWidget {
  const _AnimatedIntegerCounter({
    required this.value,
    required this.duration,
    super.key,
    this.style,
    this.animateFromZero = true,
  });
  final int value;
  final TextStyle? style;
  final Duration duration;
  final bool animateFromZero;

  @override
  State<_AnimatedIntegerCounter> createState() =>
      _AnimatedIntegerCounterState();
}

class _AnimatedIntegerCounterState extends State<_AnimatedIntegerCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  int _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _previousValue = widget.animateFromZero ? 0 : widget.value;
    _animation = IntTween(
      begin: _previousValue,
      end: widget.value,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedIntegerCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _animation = IntTween(
        begin: _previousValue,
        end: widget.value,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Text(
          '${_animation.value}',
          style: widget.style ?? Theme.of(context).textTheme.displayLarge,
        ),
      );
}

/// 百分比进度动画
class _AnimatedPercentage extends StatefulWidget {
  const _AnimatedPercentage({
    required this.percentage,
    required this.duration,
    this.style,
    this.color,
  });
  final double percentage;
  final TextStyle? style;
  final Color? color;
  final Duration duration;

  @override
  State<_AnimatedPercentage> createState() => _AnimatedPercentageState();
}

class _AnimatedPercentageState extends State<_AnimatedPercentage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: _previousValue,
      end: widget.percentage,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedPercentage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _previousValue = oldWidget.percentage;
      _animation = Tween<double>(
        begin: _previousValue,
        end: widget.percentage,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Text(
          '${_animation.value.toStringAsFixed(1)}%',
          style: widget.style?.copyWith(color: widget.color) ??
              Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(color: widget.color),
        ),
      );
}

/// 货币金额动画
class _AnimatedCurrencyAmount extends StatefulWidget {
  const _AnimatedCurrencyAmount({
    required this.amount,
    required this.duration,
    this.currencySymbol = '¥',
    this.style,
  });
  final double amount;
  final String currencySymbol;
  final TextStyle? style;
  final Duration duration;

  @override
  State<_AnimatedCurrencyAmount> createState() =>
      _AnimatedCurrencyAmountState();
}

class _AnimatedCurrencyAmountState extends State<_AnimatedCurrencyAmount>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: _previousValue,
      end: widget.amount,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedCurrencyAmount oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _previousValue = oldWidget.amount;
      _animation = Tween<double>(
        begin: _previousValue,
        end: widget.amount,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatCurrency(double value) {
    final integerPart = value.truncate();
    final decimalPart = ((value - integerPart) * 100).round();

    return '${widget.currencySymbol}${integerPart.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        )}.${decimalPart.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Text(
          _formatCurrency(_animation.value),
          style: widget.style ?? Theme.of(context).textTheme.displayLarge,
        ),
      );
}

/// 数字跳动计数器
class _AnimatedBouncingCounter extends StatefulWidget {
  const _AnimatedBouncingCounter({
    required this.value,
    required this.duration,
    this.style,
  });
  final int value;
  final TextStyle? style;
  final Duration duration;

  @override
  State<_AnimatedBouncingCounter> createState() =>
      _AnimatedBouncingCounterState();
}

class _AnimatedBouncingCounterState extends State<_AnimatedBouncingCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _numberAnimation;
  late Animation<double> _scaleAnimation;
  int _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _numberAnimation = IntTween(
      begin: _previousValue,
      end: widget.value,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 0.9),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.0),
        weight: 30,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedBouncingCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _numberAnimation = IntTween(
        begin: _previousValue,
        end: widget.value,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
      );

      // Recreate scale animation for bouncing effect
      _scaleAnimation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.3),
          weight: 30,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.3, end: 0.9),
          weight: 40,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.9, end: 1.0),
          weight: 30,
        ),
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.elasticOut,
        ),
      );

      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Text(
            '${_numberAnimation.value}',
            style: widget.style ?? Theme.of(context).textTheme.displayLarge,
          ),
        ),
      );
}

/// 渐变数字显示
class _AnimatedGradientNumber extends StatefulWidget {
  const _AnimatedGradientNumber({
    required this.value,
    required this.duration,
    this.gradientColors,
    this.style,
  });
  final double value;
  final List<Color>? gradientColors;
  final TextStyle? style;
  final Duration duration;

  @override
  State<_AnimatedGradientNumber> createState() =>
      _AnimatedGradientNumberState();
}

class _AnimatedGradientNumberState extends State<_AnimatedGradientNumber>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _numberAnimation;
  late Animation<double> _opacityAnimation;
  double _previousValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _numberAnimation = Tween<double>(
      begin: _previousValue,
      end: widget.value,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedGradientNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _numberAnimation = Tween<double>(
        begin: _previousValue,
        end: widget.value,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        widget.gradientColors ?? [Colors.blue, Colors.purple, Colors.pink];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        child: Opacity(
          opacity: _opacityAnimation.value,
          child: Text(
            widget.value.toStringAsFixed(
              widget.value.truncateToDouble() == widget.value ? 0 : 2,
            ),
            style: (widget.style ?? Theme.of(context).textTheme.displayLarge)
                ?.copyWith(
              color: Colors.white, // ShaderMask will override this
            ),
          ),
        ),
      ),
    );
  }
}

// ===== 状态转换动画 =====

/// 加载状态指示器
class _AnimatedLoadingIndicator extends StatefulWidget {
  const _AnimatedLoadingIndicator({
    required this.size,
    required this.duration,
    this.message,
    this.color,
  });
  final String? message;
  final Color? color;
  final double size;
  final Duration duration;

  @override
  State<_AnimatedLoadingIndicator> createState() =>
      _AnimatedLoadingIndicatorState();
}

class _AnimatedLoadingIndicatorState extends State<_AnimatedLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * 3.14159,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnimation.value,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.color ?? Theme.of(context).primaryColor,
                  ),
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.message!,
              style: TextStyle(
                color: widget.color ?? Theme.of(context).primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      );
}

/// 成功状态反馈
class _AnimatedSuccessFeedback extends StatefulWidget {
  const _AnimatedSuccessFeedback({
    required this.child,
    required this.showSuccess,
    required this.duration,
  });
  final Widget child;
  final bool showSuccess;
  final Duration duration;

  @override
  State<_AnimatedSuccessFeedback> createState() =>
      _AnimatedSuccessFeedbackState();
}

class _AnimatedSuccessFeedbackState extends State<_AnimatedSuccessFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0),
        weight: 70,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.green.withValues(alpha: 0.1),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(_AnimatedSuccessFeedback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showSuccess && !oldWidget.showSuccess) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Container(
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Transform.scale(
            scale: widget.showSuccess ? _scaleAnimation.value : 1.0,
            child: widget.child,
          ),
        ),
      );
}

/// 失败状态反馈
class _AnimatedErrorFeedback extends StatefulWidget {
  const _AnimatedErrorFeedback({
    required this.child,
    required this.showError,
    required this.duration,
  });
  final Widget child;
  final bool showError;
  final Duration duration;

  @override
  State<_AnimatedErrorFeedback> createState() => _AnimatedErrorFeedbackState();
}

class _AnimatedErrorFeedbackState extends State<_AnimatedErrorFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: -10), weight: 15),
      TweenSequenceItem(tween: Tween<double>(begin: -10, end: 10), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 10, end: -10), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: -10, end: 0), weight: 15),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.red.withValues(alpha: 0.1),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(_AnimatedErrorFeedback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showError && !oldWidget.showError) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Container(
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Transform.translate(
            offset: Offset(widget.showError ? _shakeAnimation.value : 0, 0),
            child: widget.child,
          ),
        ),
      );
}

/// 等待状态动画
class _AnimatedWaitingState extends StatefulWidget {
  const _AnimatedWaitingState({
    required this.child,
    required this.isWaiting,
    required this.duration,
  });
  final Widget child;
  final bool isWaiting;
  final Duration duration;

  @override
  State<_AnimatedWaitingState> createState() => _AnimatedWaitingStateState();
}

class _AnimatedWaitingStateState extends State<_AnimatedWaitingState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.5,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Opacity(
          opacity: widget.isWaiting ? _opacityAnimation.value : 1.0,
          child: Transform.scale(
            scale: widget.isWaiting ? _scaleAnimation.value : 1.0,
            child: widget.child,
          ),
        ),
      );
}

/// 状态切换过渡
class _AnimatedStateTransition extends StatefulWidget {
  const _AnimatedStateTransition({
    required this.child,
    required this.status,
    required this.duration,
  });
  final Widget child;
  final StatusType status;
  final Duration duration;

  @override
  State<_AnimatedStateTransition> createState() =>
      _AnimatedStateTransitionState();
}

class _AnimatedStateTransitionState extends State<_AnimatedStateTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _backgroundAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _backgroundAnimation = _getBackgroundColor().animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = _getScaleAnimation().animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedStateTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      _backgroundAnimation = _getBackgroundColor().animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      );

      _scaleAnimation = _getScaleAnimation().animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.elasticOut,
        ),
      );

      _controller.reset();
      _controller.forward();
    }
  }

  ColorTween _getBackgroundColor() {
    switch (widget.status) {
      case StatusType.loading:
        return ColorTween(
          begin: Colors.transparent,
          end: Colors.blue.withValues(alpha: 0.1),
        );
      case StatusType.success:
        return ColorTween(
          begin: Colors.transparent,
          end: Colors.green.withValues(alpha: 0.1),
        );
      case StatusType.error:
        return ColorTween(
          begin: Colors.transparent,
          end: Colors.red.withValues(alpha: 0.1),
        );
      case StatusType.warning:
        return ColorTween(
          begin: Colors.transparent,
          end: Colors.orange.withValues(alpha: 0.1),
        );
      case StatusType.info:
        return ColorTween(
          begin: Colors.transparent,
          end: Colors.grey.withValues(alpha: 0.1),
        );
    }
  }

  Tween<double> _getScaleAnimation() {
    switch (widget.status) {
      case StatusType.loading:
        return Tween<double>(begin: 1.0, end: 1.05);
      case StatusType.success:
        return Tween<double>(begin: 1.0, end: 1.1);
      case StatusType.error:
        return Tween<double>(begin: 1.0, end: 0.95);
      case StatusType.warning:
        return Tween<double>(begin: 1.0, end: 1.02);
      case StatusType.info:
        return Tween<double>(begin: 1.0, end: 1.01);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Container(
          decoration: BoxDecoration(
            color: _backgroundAnimation.value,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          ),
        ),
      );
}

/// 进度状态指示器
class _AnimatedProgressIndicator extends StatefulWidget {
  const _AnimatedProgressIndicator({
    required this.progress,
    required this.size,
    required this.duration,
    this.color,
  });
  final double progress;
  final Color? color;
  final double size;
  final Duration duration;

  @override
  State<_AnimatedProgressIndicator> createState() =>
      _AnimatedProgressIndicatorState();
}

class _AnimatedProgressIndicatorState extends State<_AnimatedProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) => CircularProgressIndicator(
            value: _progressAnimation.value,
            backgroundColor: Colors.grey.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.color ?? Theme.of(context).primaryColor,
            ),
            strokeWidth: 6,
          ),
        ),
      );
}

/// 步骤完成动画
class _AnimatedStepCompletion extends StatefulWidget {
  const _AnimatedStepCompletion({
    required this.child,
    required this.isCompleted,
    required this.duration,
  });
  final Widget child;
  final bool isCompleted;
  final Duration duration;

  @override
  State<_AnimatedStepCompletion> createState() =>
      _AnimatedStepCompletionState();
}

class _AnimatedStepCompletionState extends State<_AnimatedStepCompletion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 0.9),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.0),
        weight: 30,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _colorAnimation = ColorTween(
      begin: Colors.grey,
      end: Colors.green,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(_AnimatedStepCompletion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCompleted && !oldWidget.isCompleted) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: widget.isCompleted ? _scaleAnimation.value : 1.0,
          child: IconTheme(
            data: IconThemeData(
              color: widget.isCompleted ? _colorAnimation.value : Colors.grey,
            ),
            child: widget.child,
          ),
        ),
      );
}

/// 验证状态动画
class _AnimatedValidationState extends StatefulWidget {
  const _AnimatedValidationState({
    required this.child,
    required this.state,
    required this.duration,
  });
  final Widget child;
  final ValidationState state;
  final Duration duration;

  @override
  State<_AnimatedValidationState> createState() =>
      _AnimatedValidationStateState();
}

class _AnimatedValidationStateState extends State<_AnimatedValidationState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _borderColorAnimation;
  late Animation<double> _borderWidthAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _borderColorAnimation = _getBorderColor().animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _borderWidthAnimation = _getBorderWidth().animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedValidationState oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _borderColorAnimation = _getBorderColor().animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      );

      _borderWidthAnimation = _getBorderWidth().animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      );

      _controller.reset();
      _controller.forward();
    }
  }

  ColorTween _getBorderColor() {
    switch (widget.state) {
      case ValidationState.none:
        return ColorTween(begin: Colors.grey, end: Colors.grey);
      case ValidationState.valid:
        return ColorTween(begin: Colors.grey, end: Colors.green);
      case ValidationState.invalid:
        return ColorTween(begin: Colors.grey, end: Colors.red);
      case ValidationState.validating:
        return ColorTween(begin: Colors.grey, end: Colors.blue);
    }
  }

  Tween<double> _getBorderWidth() {
    switch (widget.state) {
      case ValidationState.none:
        return Tween<double>(begin: 1.0, end: 1.0);
      case ValidationState.valid:
        return Tween<double>(begin: 1.0, end: 2.0);
      case ValidationState.invalid:
        return Tween<double>(begin: 1.0, end: 2.0);
      case ValidationState.validating:
        return Tween<double>(begin: 1.0, end: 1.5);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _borderColorAnimation.value ?? Colors.grey,
              width: _borderWidthAnimation.value,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: widget.child,
        ),
      );
}

// ===== 进度和指标器动画 =====

/// 圆环进度条动画
class _AnimatedCircularProgress extends StatefulWidget {
  const _AnimatedCircularProgress({
    required this.progress,
    required this.size,
    required this.strokeWidth,
    required this.duration,
    this.color,
  });
  final double progress;
  final Color? color;
  final double size;
  final double strokeWidth;
  final Duration duration;

  @override
  State<_AnimatedCircularProgress> createState() =>
      _AnimatedCircularProgressState();
}

class _AnimatedCircularProgressState extends State<_AnimatedCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) => Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.color ?? Theme.of(context).primaryColor,
                ),
                strokeWidth: widget.strokeWidth,
              ),
              Text(
                '${(_progressAnimation.value * 100).round()}%',
                style: TextStyle(
                  fontSize: widget.size * 0.15,
                  fontWeight: FontWeight.bold,
                  color: widget.color ?? Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      );
}

/// 条形进度条动画
class _AnimatedLinearProgress extends StatefulWidget {
  const _AnimatedLinearProgress({
    required this.progress,
    required this.height,
    required this.duration,
    this.color,
  });
  final double progress;
  final Color? color;
  final double height;
  final Duration duration;

  @override
  State<_AnimatedLinearProgress> createState() =>
      _AnimatedLinearProgressState();
}

class _AnimatedLinearProgressState extends State<_AnimatedLinearProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedLinearProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) => Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progressAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: widget.color ?? Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(widget.height / 2),
              ),
            ),
          ),
        ),
      );
}

/// 步数器动画
class _AnimatedStepCounter extends StatefulWidget {
  const _AnimatedStepCounter({
    required this.currentStep,
    required this.totalSteps,
    required this.size,
    required this.duration,
    this.activeColor,
    this.inactiveColor,
  });
  final int currentStep;
  final int totalSteps;
  final Color? activeColor;
  final Color? inactiveColor;
  final double size;
  final Duration duration;

  @override
  State<_AnimatedStepCounter> createState() => _AnimatedStepCounterState();
}

class _AnimatedStepCounterState extends State<_AnimatedStepCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimations = List.generate(
      widget.totalSteps,
      (index) => Tween<double>(
        begin: index < widget.currentStep ? 1.0 : 0.5,
        end: index < widget.currentStep ? 1.2 : 1.0,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.elasticOut,
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedStepCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      _scaleAnimations = List.generate(
        widget.totalSteps,
        (index) => Tween<double>(
          begin: index < oldWidget.currentStep ? 1.0 : 0.5,
          end: index < widget.currentStep ? 1.2 : 1.0,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.elasticOut,
          ),
        ),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          widget.totalSteps,
          (index) => AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Container(
              margin: EdgeInsets.symmetric(horizontal: widget.size * 0.5),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index < widget.currentStep
                    ? (widget.activeColor ?? Theme.of(context).primaryColor)
                    : (widget.inactiveColor ??
                        Colors.grey.withValues(alpha: 0.3)),
              ),
              child: Transform.scale(
                scale: _scaleAnimations[index].value,
                child: index < widget.currentStep
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                        size: widget.size * 0.6,
                      )
                    : null,
              ),
            ),
          ),
        ),
      );
}

/// 百分比环形指示器
class _AnimatedPercentageRing extends StatefulWidget {
  const _AnimatedPercentageRing({
    required this.percentage,
    required this.size,
    required this.strokeWidth,
    required this.duration,
    this.color,
  });
  final double percentage;
  final Color? color;
  final double size;
  final double strokeWidth;
  final Duration duration;

  @override
  State<_AnimatedPercentageRing> createState() =>
      _AnimatedPercentageRingState();
}

class _AnimatedPercentageRingState extends State<_AnimatedPercentageRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _textScaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.percentage,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _textScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedPercentageRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.percentage,
        end: widget.percentage,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => CustomPaint(
            painter: _PercentageRingPainter(
              progress: _progressAnimation.value,
              color: widget.color ?? Theme.of(context).primaryColor,
              strokeWidth: widget.strokeWidth,
            ),
            child: Center(
              child: Transform.scale(
                scale: _textScaleAnimation.value,
                child: Text(
                  '${(_progressAnimation.value * 100).round()}%',
                  style: TextStyle(
                    fontSize: widget.size * 0.15,
                    fontWeight: FontWeight.bold,
                    color: widget.color ?? Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class _PercentageRingPainter extends CustomPainter {
  _PercentageRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });
  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top
      progress * 2 * 3.14159, // Sweep angle
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_PercentageRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}

/// 加载进度指示器
class _AnimatedLoadingProgress extends StatefulWidget {
  const _AnimatedLoadingProgress({
    required this.progress,
    required this.size,
    required this.duration,
    this.loadingText,
    this.color,
  });
  final double progress;
  final String? loadingText;
  final Color? color;
  final double size;
  final Duration duration;

  @override
  State<_AnimatedLoadingProgress> createState() =>
      _AnimatedLoadingProgressState();
}

class _AnimatedLoadingProgressState extends State<_AnimatedLoadingProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedLoadingProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Transform.scale(
                scale: widget.progress < 1.0 ? _pulseAnimation.value : 1.0,
                child: CircularProgressIndicator(
                  value: _progressAnimation.value,
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.color ?? Theme.of(context).primaryColor,
                  ),
                  strokeWidth: 6,
                ),
              ),
            ),
          ),
          if (widget.loadingText != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.loadingText!,
              style: TextStyle(
                fontSize: 14,
                color: widget.color ?? Theme.of(context).primaryColor,
              ),
            ),
          ],
        ],
      );
}

/// 完成指示器
class _AnimatedCompletionIndicator extends StatefulWidget {
  const _AnimatedCompletionIndicator({
    required this.isCompleted,
    required this.size,
    required this.duration,
    this.color,
  });
  final bool isCompleted;
  final Color? color;
  final double size;
  final Duration duration;

  @override
  State<_AnimatedCompletionIndicator> createState() =>
      _AnimatedCompletionIndicatorState();
}

class _AnimatedCompletionIndicatorState
    extends State<_AnimatedCompletionIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * 3.14159,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    if (widget.isCompleted) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_AnimatedCompletionIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCompleted && !oldWidget.isCompleted) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: widget.isCompleted ? _scaleAnimation.value : 0.0,
          child: Transform.rotate(
            angle: widget.isCompleted ? _rotationAnimation.value : 0.0,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color ?? Colors.green,
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: widget.size * 0.6,
              ),
            ),
          ),
        ),
      );
}

/// 计时器进度条
class _AnimatedTimerProgress extends StatefulWidget {
  const _AnimatedTimerProgress({
    required this.totalTime,
    required this.remainingTime,
    required this.height,
    required this.updateInterval,
    this.color,
  });
  final Duration totalTime;
  final Duration remainingTime;
  final Color? color;
  final double height;
  final Duration updateInterval;

  @override
  State<_AnimatedTimerProgress> createState() => _AnimatedTimerProgressState();
}

class _AnimatedTimerProgressState extends State<_AnimatedTimerProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.updateInterval,
      vsync: this,
    );

    final progress =
        widget.remainingTime.inMilliseconds / widget.totalTime.inMilliseconds;
    _progressAnimation = Tween<double>(
      begin: progress,
      end: progress,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.updateInterval, (_) {
      if (mounted) {
        final progress = widget.remainingTime.inMilliseconds /
            widget.totalTime.inMilliseconds;
        _progressAnimation = Tween<double>(
          begin: _progressAnimation.value,
          end: math.max(0.0, progress),
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.linear,
          ),
        );
        _controller.reset();
        _controller.forward();
      }
    });
  }

  @override
  void didUpdateWidget(_AnimatedTimerProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.remainingTime != widget.remainingTime ||
        oldWidget.totalTime != widget.totalTime) {
      final progress =
          widget.remainingTime.inMilliseconds / widget.totalTime.inMilliseconds;
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: math.max(0.0, progress),
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.linear,
        ),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) => Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progressAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: _getColor(),
                borderRadius: BorderRadius.circular(widget.height / 2),
              ),
            ),
          ),
        ),
      );

  Color _getColor() {
    final progress = _progressAnimation.value;
    if (progress > 0.5) {
      return widget.color ?? Colors.green;
    } else if (progress > 0.25) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

/// 下载进度指示器
class _AnimatedDownloadProgress extends StatefulWidget {
  const _AnimatedDownloadProgress({
    required this.progress,
    required this.height,
    required this.duration,
    this.fileName,
    this.color,
  });
  final double progress;
  final String? fileName;
  final Color? color;
  final double height;
  final Duration duration;

  @override
  State<_AnimatedDownloadProgress> createState() =>
      _AnimatedDownloadProgressState();
}

class _AnimatedDownloadProgressState extends State<_AnimatedDownloadProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.bounceOut,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedDownloadProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.fileName != null) ...[
            Text(
              widget.fileName!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(widget.height / 2),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => ClipRRect(
                borderRadius: BorderRadius.circular(widget.height / 2),
                child: Row(
                  children: [
                    Expanded(
                      flex: (_progressAnimation.value * 100).round(),
                      child: Container(
                        height: widget.height,
                        color: widget.color ?? Theme.of(context).primaryColor,
                      ),
                    ),
                    Expanded(
                      flex: 100 - (_progressAnimation.value * 100).round(),
                      child: Container(
                        height: widget.height,
                        color: Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(_progressAnimation.value * 100).round()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.color ?? Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.progress >= 1.0)
                AnimatedBuilder(
                  animation: _bounceAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _bounceAnimation.value,
                    child: const Icon(
                      Icons.download_done,
                      color: Colors.green,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
}

// ===== 列表和表格动画 =====

/// 列表项滑动插入动画
class _AnimatedListSlideInsert extends StatefulWidget {
  const _AnimatedListSlideInsert({
    required this.child,
    required this.index,
    required this.duration,
  });
  final Widget child;
  final int index;
  final Duration duration;

  @override
  State<_AnimatedListSlideInsert> createState() =>
      _AnimatedListSlideInsertState();
}

class _AnimatedListSlideInsertState extends State<_AnimatedListSlideInsert>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: widget.child,
        ),
      );
}

/// 列表项组合动画（缩放+滑动）
class _AnimatedListCombined extends StatefulWidget {
  const _AnimatedListCombined({
    required this.child,
    required this.index,
    required this.duration,
  });
  final Widget child;
  final int index;
  final Duration duration;

  @override
  State<_AnimatedListCombined> createState() => _AnimatedListCombinedState();
}

class _AnimatedListCombinedState extends State<_AnimatedListCombined>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: widget.child,
          ),
        ),
      );
}

/// 列表排序动画
class _AnimatedListSort extends StatefulWidget {
  const _AnimatedListSort({
    required this.child,
    required this.oldIndex,
    required this.newIndex,
    required this.duration,
  });
  final Widget child;
  final int oldIndex;
  final int newIndex;
  final Duration duration;

  @override
  State<_AnimatedListSort> createState() => _AnimatedListSortState();
}

class _AnimatedListSortState extends State<_AnimatedListSort>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    final direction = widget.newIndex > widget.oldIndex ? -1.0 : 1.0;
    _slideAnimation = Tween<Offset>(
      begin: Offset(direction * 0.5, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.1,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      );
}

/// 表格行展开动画
class _AnimatedTableRowExpand extends StatefulWidget {
  const _AnimatedTableRowExpand({
    required this.child,
    required this.isExpanded,
    required this.duration,
  });
  final Widget child;
  final bool isExpanded;
  final Duration duration;

  @override
  State<_AnimatedTableRowExpand> createState() =>
      _AnimatedTableRowExpandState();
}

class _AnimatedTableRowExpandState extends State<_AnimatedTableRowExpand>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _heightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    if (widget.isExpanded) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_AnimatedTableRowExpand oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizeTransition(
        sizeFactor: _heightAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: widget.child,
        ),
      );
}

/// 表格列排序动画
class _AnimatedTableColumnSort extends StatefulWidget {
  const _AnimatedTableColumnSort({
    required this.child,
    required this.isSorting,
    required this.duration,
  });
  final Widget child;
  final bool isSorting;
  final Duration duration;

  @override
  State<_AnimatedTableColumnSort> createState() =>
      _AnimatedTableColumnSortState();
}

class _AnimatedTableColumnSortState extends State<_AnimatedTableColumnSort>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: widget.isSorting);

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(_AnimatedTableColumnSort oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSorting != oldWidget.isSorting) {
      if (widget.isSorting) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: widget.isSorting ? _rotationAnimation.value : 0.0,
        child: Transform.scale(
          scale: widget.isSorting ? _scaleAnimation.value : 1.0,
          child: widget.child,
        ),
      );
}

/// 列表项拖拽动画
class _AnimatedListDrag extends StatefulWidget {
  const _AnimatedListDrag({
    required this.child,
    required this.isDragging,
    required this.dragOffset,
    required this.duration,
  });
  final Widget child;
  final bool isDragging;
  final Offset dragOffset;
  final Duration duration;

  @override
  State<_AnimatedListDrag> createState() => _AnimatedListDragState();
}

class _AnimatedListDragState extends State<_AnimatedListDrag>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: widget.dragOffset,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    if (widget.isDragging) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_AnimatedListDrag oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDragging != oldWidget.isDragging ||
        widget.dragOffset != oldWidget.dragOffset) {
      _positionAnimation = Tween<Offset>(
        begin: oldWidget.dragOffset,
        end: widget.dragOffset,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
      );

      if (widget.isDragging) {
        _controller.reset();
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Transform.translate(
        offset: widget.isDragging ? _positionAnimation.value : Offset.zero,
        child: Transform.scale(
          scale: widget.isDragging ? _scaleAnimation.value : 1.0,
          child: Opacity(
            opacity: widget.isDragging ? _opacityAnimation.value : 1.0,
            child: widget.child,
          ),
        ),
      );
}

// ===== 图表和数据可视化动画 =====

/// 柱状图动画
class _AnimatedBarChart extends StatefulWidget {
  const _AnimatedBarChart({
    required this.values,
    required this.maxValue,
    required this.duration,
    this.colors,
  });
  final List<double> values;
  final List<Color>? colors;
  final double maxValue;
  final Duration duration;

  @override
  State<_AnimatedBarChart> createState() => _AnimatedBarChartState();
}

class _AnimatedBarChartState extends State<_AnimatedBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _heightAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _heightAnimations = List.generate(
      widget.values.length,
      (index) => Tween<double>(
        begin: 0.0,
        end: widget.values[index] / widget.maxValue,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.1,
            (index + 1) * 0.1 + 0.5,
            curve: Curves.elasticOut,
          ),
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.values != widget.values) {
      _heightAnimations = List.generate(
        widget.values.length,
        (index) => Tween<double>(
          begin: oldWidget.values.length > index
              ? oldWidget.values[index] / widget.maxValue
              : 0.0,
          end: widget.values[index] / widget.maxValue,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.elasticOut,
          ),
        ),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          widget.values.length,
          (index) => AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Container(
              width: 20, // Reduced from 40 to 20 to fit in 120px container
              height: 200 * _heightAnimations[index].value,
              decoration: BoxDecoration(
                color: widget.colors != null && widget.colors!.length > index
                    ? widget.colors![index]
                    : Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      );
}

/// 线图动画
class _AnimatedLineChart extends StatefulWidget {
  const _AnimatedLineChart({
    required this.values,
    required this.strokeWidth,
    required this.duration,
    this.lineColor,
  });
  final List<double> values;
  final Color? lineColor;
  final double strokeWidth;
  final Duration duration;

  @override
  State<_AnimatedLineChart> createState() => _AnimatedLineChartState();
}

class _AnimatedLineChartState extends State<_AnimatedLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _LineChartPainter(
          values: widget.values,
          progress: _progressAnimation.value,
          color: widget.lineColor ?? Theme.of(context).primaryColor,
          strokeWidth: widget.strokeWidth,
        ),
        child: Container(),
      );
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.values,
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });
  final List<double> values;
  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    final points = <Offset>[];
    for (var i = 0; i < values.length && i < progress * values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final y = size.height - ((values[i] - minValue) / range) * size.height;
      points.add(Offset(x, y));
    }

    if (points.length > 1) {
      final path = Path();
      path.moveTo(points[0].dx, points[0].dy);
      for (var i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.values != values ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}

/// 饼图动画
class _AnimatedPieChart extends StatefulWidget {
  const _AnimatedPieChart({
    required this.values,
    required this.size,
    required this.duration,
    this.colors,
  });
  final List<double> values;
  final List<Color>? colors;
  final double size;
  final Duration duration;

  @override
  State<_AnimatedPieChart> createState() => _AnimatedPieChartState();
}

class _AnimatedPieChartState extends State<_AnimatedPieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _PieChartPainter(
          values: widget.values,
          progress: _progressAnimation.value,
          colors: widget.colors ?? [Theme.of(context).primaryColor],
          size: widget.size,
        ),
        child: SizedBox(width: widget.size, height: widget.size),
      );
}

class _PieChartPainter extends CustomPainter {
  _PieChartPainter({
    required this.values,
    required this.progress,
    required this.colors,
    required this.size,
  });
  final List<double> values;
  final double progress;
  final List<Color> colors;
  final double size;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final total = values.fold(0.0, (sum, value) => sum + value);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    var startAngle = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * 2 * math.pi * progress;

      if (sweepAngle > 0) {
        final paint = Paint()
          ..color = colors[i % colors.length]
          ..style = PaintingStyle.fill;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          true,
          paint,
        );
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(_PieChartPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.values != values ||
      oldDelegate.colors != colors ||
      oldDelegate.size != size;
}

/// 数据点闪烁动画
class _AnimatedDataPoint extends StatefulWidget {
  const _AnimatedDataPoint({
    required this.child,
    required this.isHighlighted,
    required this.duration,
    this.highlightColor,
  });
  final Widget child;
  final bool isHighlighted;
  final Color? highlightColor;
  final Duration duration;

  @override
  State<_AnimatedDataPoint> createState() => _AnimatedDataPointState();
}

class _AnimatedDataPointState extends State<_AnimatedDataPoint>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: widget.highlightColor ?? Colors.blue,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isHighlighted) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_AnimatedDataPoint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted != oldWidget.isHighlighted) {
      if (widget.isHighlighted) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isHighlighted
                ? _colorAnimation.value?.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
          child: Transform.scale(
            scale: widget.isHighlighted ? _scaleAnimation.value : 1.0,
            child: widget.child,
          ),
        ),
      );
}

/// 图表网格线动画
class _AnimatedChartGrid extends StatefulWidget {
  const _AnimatedChartGrid({
    required this.horizontalLines,
    required this.verticalLines,
    required this.duration,
    this.gridColor,
  });
  final int horizontalLines;
  final int verticalLines;
  final Color? gridColor;
  final Duration duration;

  @override
  State<_AnimatedChartGrid> createState() => _AnimatedChartGridState();
}

class _AnimatedChartGridState extends State<_AnimatedChartGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _horizontalAnimations;
  late List<Animation<double>> _verticalAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _horizontalAnimations = List.generate(
      widget.horizontalLines,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.1,
            (index + 1) * 0.1 + 0.3,
            curve: Curves.easeOut,
          ),
        ),
      ),
    );

    _verticalAnimations = List.generate(
      widget.verticalLines,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.1,
            (index + 1) * 0.1 + 0.3,
            curve: Curves.easeOut,
          ),
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _GridPainter(
          horizontalLines: widget.horizontalLines,
          verticalLines: widget.verticalLines,
          horizontalProgress: _horizontalAnimations,
          verticalProgress: _verticalAnimations,
          color: widget.gridColor ?? Colors.grey.withValues(alpha: 0.3),
        ),
        child: Container(),
      );
}

class _GridPainter extends CustomPainter {
  _GridPainter({
    required this.horizontalLines,
    required this.verticalLines,
    required this.horizontalProgress,
    required this.verticalProgress,
    required this.color,
  });
  final int horizontalLines;
  final int verticalLines;
  final List<Animation<double>> horizontalProgress;
  final List<Animation<double>> verticalProgress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw horizontal lines
    for (var i = 0; i < horizontalLines; i++) {
      final progress =
          horizontalProgress.length > i ? horizontalProgress[i].value : 1.0;
      final y = (i + 1) * size.height / (horizontalLines + 1);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width * progress, y),
        paint,
      );
    }

    // Draw vertical lines
    for (var i = 0; i < verticalLines; i++) {
      final progress =
          verticalProgress.length > i ? verticalProgress[i].value : 1.0;
      final x = (i + 1) * size.width / (verticalLines + 1);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height * progress),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => true;
}

// ===== 导航和页面转场动画 =====

/// 滑动页面转场
class _AnimatedSlideTransition extends PageRouteBuilder {
  _AnimatedSlideTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            final offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
  final Widget page;
}

/// 渐变页面转场
class _AnimatedFadeTransition extends PageRouteBuilder {
  _AnimatedFadeTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 300),
        );
  final Widget page;
}

/// 展开页面转场
class _AnimatedScaleTransition extends PageRouteBuilder {
  _AnimatedScaleTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              ScaleTransition(
            scale: Tween<double>(
              begin: 0.8,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.elasticOut,
              ),
            ),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
          transitionDuration: const Duration(milliseconds: 500),
        );
  final Widget page;
}

/// 旋转页面转场
class _AnimatedRotationTransition extends PageRouteBuilder {
  _AnimatedRotationTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              RotationTransition(
            turns: Tween<double>(
              begin: 0.1,
              end: 0.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.elasticOut,
              ),
            ),
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.8,
                end: 1.0,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            ),
          ),
          transitionDuration: const Duration(milliseconds: 600),
        );
  final Widget page;
}

/// 底部滑入页面转场
class _AnimatedBottomSlideTransition extends PageRouteBuilder {
  _AnimatedBottomSlideTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            final offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
  final Widget page;
}

/// 标签页切换动画
class _AnimatedTabSwitcher extends StatefulWidget {
  const _AnimatedTabSwitcher({
    required this.tabs,
    required this.currentIndex,
    required this.duration,
  });
  final List<Widget> tabs;
  final int currentIndex;
  final Duration duration;

  @override
  State<_AnimatedTabSwitcher> createState() => _AnimatedTabSwitcherState();
}

class _AnimatedTabSwitcherState extends State<_AnimatedTabSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.2, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedTabSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;

      _slideAnimation = Tween<Offset>(
        begin: widget.currentIndex > oldWidget.currentIndex
            ? const Offset(0.2, 0.0)
            : const Offset(-0.2, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
      );

      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          // Previous tab fading out
          if (_previousIndex != widget.currentIndex)
            FadeTransition(
              opacity: Tween<double>(
                begin: 1.0,
                end: 0.0,
              ).animate(_controller),
              child: widget.tabs[_previousIndex],
            ),

          // Current tab sliding in
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: widget.tabs[widget.currentIndex],
            ),
          ),
        ],
      );
}

/// 抽屉切换动画
class _AnimatedDrawerTransition extends StatefulWidget {
  const _AnimatedDrawerTransition({
    required this.child,
    required this.isOpen,
    required this.position,
    required this.duration,
  });
  final Widget child;
  final bool isOpen;
  final DrawerPosition position;
  final Duration duration;

  @override
  State<_AnimatedDrawerTransition> createState() =>
      _AnimatedDrawerTransitionState();
}

class _AnimatedDrawerTransitionState extends State<_AnimatedDrawerTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _updateAnimations();
    if (widget.isOpen) {
      _controller.value = 1.0;
    }
  }

  void _updateAnimations() {
    Offset begin;
    Offset end;
    switch (widget.position) {
      case DrawerPosition.left:
        begin = const Offset(-1.0, 0.0);
        end = Offset.zero;
      case DrawerPosition.right:
        begin = const Offset(1.0, 0.0);
        end = Offset.zero;
      case DrawerPosition.top:
        begin = const Offset(0.0, -1.0);
        end = Offset.zero;
      case DrawerPosition.bottom:
        begin = const Offset(0.0, 1.0);
        end = Offset.zero;
    }

    _slideAnimation = Tween<Offset>(
      begin: begin,
      end: end,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void didUpdateWidget(_AnimatedDrawerTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.position != widget.position) {
      _updateAnimations();
    }

    if (oldWidget.isOpen != widget.isOpen) {
      if (widget.isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          // Background dimming
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Container(
              color: Colors.black.withValues(alpha: _controller.value * 0.5),
            ),
          ),

          // Drawer content
          SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        ],
      );
}

/// 底部导航栏切换动画
class _AnimatedBottomNavigation extends StatefulWidget {
  const _AnimatedBottomNavigation({
    required this.items,
    required this.currentIndex,
    required this.duration,
  });
  final List<Widget> items;
  final int currentIndex;
  final Duration duration;

  @override
  State<_AnimatedBottomNavigation> createState() =>
      _AnimatedBottomNavigationState();
}

class _AnimatedBottomNavigationState extends State<_AnimatedBottomNavigation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 0.9),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.0),
        weight: 30,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在这里创建color animation，因为Theme.of()需要context
    _colorAnimation = ColorTween(
      begin: Colors.grey,
      end: Theme.of(context).primaryColor,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(_AnimatedBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          widget.items.length,
          (index) => AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Transform.scale(
              scale: index == widget.currentIndex ? _scaleAnimation.value : 1.0,
              child: IconTheme(
                data: IconThemeData(
                  color: index == widget.currentIndex
                      ? _colorAnimation.value
                      : Colors.grey,
                ),
                child: widget.items[index],
              ),
            ),
          ),
        ),
      );
}

// ===== 按钮和交互动画 =====

/// 触摸反馈按钮动画
class _AnimatedTouchFeedback extends StatefulWidget {
  const _AnimatedTouchFeedback({
    required this.child,
    required this.scaleFactor,
    required this.duration,
    this.onPressed,
    this.feedbackColor,
  });
  final Widget child;
  final VoidCallback? onPressed;
  final Color? feedbackColor;
  final double scaleFactor;
  final Duration duration;

  @override
  State<_AnimatedTouchFeedback> createState() => _AnimatedTouchFeedbackState();
}

class _AnimatedTouchFeedbackState extends State<_AnimatedTouchFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: widget.feedbackColor ?? Colors.white.withValues(alpha: 0.2),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Container(
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: widget.child,
            ),
          ),
        ),
      );
}

/// 长按按钮动画
class _AnimatedLongPress extends StatefulWidget {
  const _AnimatedLongPress({
    required this.child,
    required this.duration,
    this.onLongPress,
    this.highlightColor,
  });
  final Widget child;
  final VoidCallback? onLongPress;
  final Color? highlightColor;
  final Duration duration;

  @override
  State<_AnimatedLongPress> createState() => _AnimatedLongPressState();
}

class _AnimatedLongPressState extends State<_AnimatedLongPress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: widget.highlightColor ?? Colors.blue.withValues(alpha: 0.3),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _onLongPressStart(LongPressStartDetails details) {
    _controller.forward();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    _controller.reverse();
    widget.onLongPress?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onLongPressStart: _onLongPressStart,
        onLongPressEnd: _onLongPressEnd,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Container(
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: widget.child,
            ),
          ),
        ),
      );
}

/// 滚动列表动画
class _AnimatedScrollList extends StatefulWidget {
  const _AnimatedScrollList({
    required this.children,
    required this.staggerDuration,
    this.controller,
  });
  final List<Widget> children;
  final ScrollController? controller;
  final Duration staggerDuration;

  @override
  State<_AnimatedScrollList> createState() => _AnimatedScrollListState();
}

class _AnimatedScrollListState extends State<_AnimatedScrollList>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<Animation<Offset>> _animations = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    for (var i = 0; i < widget.children.length; i++) {
      final controller = AnimationController(
        duration: widget.staggerDuration,
        vsync: this,
      );

      final animation = Tween<Offset>(
        begin: const Offset(0.0, 0.2),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic,
        ),
      );

      _controllers.add(controller);
      _animations.add(animation);

      // Stagger the animations
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          controller.forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(_AnimatedScrollList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length) {
      _disposeControllers();
      _initAnimations();
    }
  }

  void _disposeControllers() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
    _animations.clear();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView.builder(
        controller: widget.controller,
        itemCount: widget.children.length,
        itemBuilder: (context, index) => SlideTransition(
          position: _animations[index],
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(_controllers[index]),
            child: widget.children[index],
          ),
        ),
      );
}

/// 拖拽反馈动画
class _AnimatedDragFeedback extends StatefulWidget {
  const _AnimatedDragFeedback({
    required this.child,
    required this.dragOffset,
    required this.isDragging,
    required this.duration,
  });
  final Widget child;
  final Offset dragOffset;
  final bool isDragging;
  final Duration duration;

  @override
  State<_AnimatedDragFeedback> createState() => _AnimatedDragFeedbackState();
}

class _AnimatedDragFeedbackState extends State<_AnimatedDragFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: widget.dragOffset,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 0.9),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.0),
        weight: 30,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isDragging) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_AnimatedDragFeedback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDragging != widget.isDragging ||
        oldWidget.dragOffset != widget.dragOffset) {
      _positionAnimation = Tween<Offset>(
        begin: oldWidget.dragOffset,
        end: widget.dragOffset,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
      );

      if (widget.isDragging) {
        _controller.reset();
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.translate(
          offset: _positionAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Opacity(
                opacity: widget.isDragging ? 0.8 : 1.0,
                child: widget.child,
              ),
            ),
          ),
        ),
      );
}

/// 悬停动画
class _AnimatedHover extends StatefulWidget {
  const _AnimatedHover({
    required this.child,
    required this.hoverScale,
    required this.duration,
    this.hoverColor,
  });
  final Widget child;
  final Color? hoverColor;
  final double hoverScale;
  final Duration duration;

  @override
  State<_AnimatedHover> createState() => _AnimatedHoverState();
}

class _AnimatedHoverState extends State<_AnimatedHover>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.hoverScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: widget.hoverColor ?? Colors.grey.withValues(alpha: 0.1),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _onEnter(PointerEvent event) {
    _controller.forward();
  }

  void _onExit(PointerEvent event) {
    _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: _onEnter,
        onExit: _onExit,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Container(
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: widget.child,
            ),
          ),
        ),
      );
}

/// 摇晃动画
class _AnimatedShake extends StatefulWidget {
  const _AnimatedShake({
    required this.child,
    required this.shouldShake,
    required this.duration,
  });
  final Widget child;
  final bool shouldShake;
  final Duration duration;

  @override
  State<_AnimatedShake> createState() => _AnimatedShakeState();
}

class _AnimatedShakeState extends State<_AnimatedShake>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: -10), weight: 15),
      TweenSequenceItem(tween: Tween<double>(begin: -10, end: 10), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 10, end: -10), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: -10, end: 0), weight: 15),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(_AnimatedShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldShake && !oldWidget.shouldShake) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.translate(
          offset: Offset(widget.shouldShake ? _shakeAnimation.value : 0, 0),
          child: widget.child,
        ),
      );
}

// ===== 特效动画 =====

/// 粒子效果动画
class _AnimatedParticles extends StatefulWidget {
  const _AnimatedParticles({
    required this.child,
    required this.particleCount,
    required this.particleSize,
    required this.duration,
    this.particleColor,
  });
  final Widget child;
  final int particleCount;
  final Color? particleColor;
  final double particleSize;
  final Duration duration;

  @override
  State<_AnimatedParticles> createState() => _AnimatedParticlesState();
}

class _AnimatedParticlesState extends State<_AnimatedParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<Offset>> _positionAnimations;
  late List<Animation<double>> _opacityAnimations;
  final List<Offset> _initialPositions = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Generate random initial positions
    _initialPositions.clear();
    for (var i = 0; i < widget.particleCount; i++) {
      _initialPositions.add(
        Offset(
          math.Random().nextDouble() * 200 - 100,
          math.Random().nextDouble() * 200 - 100,
        ),
      );
    }

    _positionAnimations = List.generate(
      widget.particleCount,
      (index) => Tween<Offset>(
        begin: Offset.zero,
        end: _initialPositions[index],
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _opacityAnimations = List.generate(
      widget.particleCount,
      (index) => Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(
            0.0,
            0.8,
            curve: Curves.easeOut,
          ),
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          ...List.generate(
            widget.particleCount,
            (index) => AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Transform.translate(
                offset: _positionAnimations[index].value,
                child: Opacity(
                  opacity: _opacityAnimations[index].value,
                  child: Container(
                    width: widget.particleSize,
                    height: widget.particleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.particleColor ??
                          Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}

/// 波纹扩散动画
class _AnimatedRipple extends StatefulWidget {
  const _AnimatedRipple({
    required this.child,
    required this.maxRadius,
    required this.duration,
    this.rippleColor,
  });
  final Widget child;
  final Color? rippleColor;
  final double maxRadius;
  final Duration duration;

  @override
  State<_AnimatedRipple> createState() => _AnimatedRippleState();
}

class _AnimatedRippleState extends State<_AnimatedRipple>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _radiusAnimation = Tween<double>(
      begin: 0.0,
      end: widget.maxRadius,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _RipplePainter(
          radius: _radiusAnimation.value,
          opacity: _opacityAnimation.value,
          color: widget.rippleColor ?? Colors.blue.withValues(alpha: 0.3),
        ),
        child: widget.child,
      );
}

class _RipplePainter extends CustomPainter {
  _RipplePainter({
    required this.radius,
    required this.opacity,
    required this.color,
  });
  final double radius;
  final double opacity;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      radius,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) =>
      oldDelegate.radius != radius ||
      oldDelegate.opacity != opacity ||
      oldDelegate.color != color;
}

/// 扭曲变形动画
class _AnimatedDistortion extends StatefulWidget {
  const _AnimatedDistortion({
    required this.child,
    required this.distortionFactor,
    required this.duration,
  });
  final Widget child;
  final double distortionFactor;
  final Duration duration;

  @override
  State<_AnimatedDistortion> createState() => _AnimatedDistortionState();
}

class _AnimatedDistortionState extends State<_AnimatedDistortion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _distortionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _distortionAnimation = Tween<double>(
      begin: 0.0,
      end: widget.distortionFactor,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform(
          transform: Matrix4.identity()
            ..setEntry(2, 1, _distortionAnimation.value * 0.01)
            ..rotateZ(_distortionAnimation.value * 0.02),
          child: widget.child,
        ),
      );
}

/// 发光效果动画
class _AnimatedGlow extends StatefulWidget {
  const _AnimatedGlow({
    required this.child,
    required this.glowRadius,
    required this.duration,
    this.glowColor,
  });
  final Widget child;
  final Color? glowColor;
  final double glowRadius;
  final Duration duration;

  @override
  State<_AnimatedGlow> createState() => _AnimatedGlowState();
}

class _AnimatedGlowState extends State<_AnimatedGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: widget.glowRadius,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: (widget.glowColor ?? Colors.blue).withValues(alpha: 0.6),
                blurRadius: _glowAnimation.value,
                spreadRadius: _glowAnimation.value * 0.3,
              ),
            ],
          ),
          child: widget.child,
        ),
      );
}

/// 爆炸效果动画
class _AnimatedExplosion extends StatefulWidget {
  const _AnimatedExplosion({
    required this.child,
    required this.shouldExplode,
    required this.fragmentCount,
    required this.duration,
    this.fragmentColor,
  });
  final Widget child;
  final bool shouldExplode;
  final int fragmentCount;
  final Color? fragmentColor;
  final Duration duration;

  @override
  State<_AnimatedExplosion> createState() => _AnimatedExplosionState();
}

class _AnimatedExplosionState extends State<_AnimatedExplosion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<Offset>> _fragmentAnimations;
  late List<Animation<double>> _opacityAnimations;
  final List<Offset> _fragmentDirections = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Generate random directions for fragments
    _fragmentDirections.clear();
    for (var i = 0; i < widget.fragmentCount; i++) {
      final angle = (i / widget.fragmentCount) * 2 * math.pi;
      _fragmentDirections.add(Offset(math.cos(angle), math.sin(angle)));
    }

    _fragmentAnimations = List.generate(
      widget.fragmentCount,
      (index) => Tween<Offset>(
        begin: Offset.zero,
        end: _fragmentDirections[index] * 100,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _opacityAnimations = List.generate(
      widget.fragmentCount,
      (index) => Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(_AnimatedExplosion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldExplode && !oldWidget.shouldExplode) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          // Original widget (fades out)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Opacity(
              opacity: widget.shouldExplode ? (1.0 - _controller.value) : 1.0,
              child: widget.child,
            ),
          ),

          // Explosion fragments
          if (widget.shouldExplode)
            ...List.generate(
              widget.fragmentCount,
              (index) => AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Transform.translate(
                  offset: _fragmentAnimations[index].value,
                  child: Opacity(
                    opacity: _opacityAnimations[index].value,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.fragmentColor ?? Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
}

/// 脉冲波动画
class _AnimatedPulseWave extends StatefulWidget {
  const _AnimatedPulseWave({
    required this.child,
    required this.maxRadius,
    required this.duration,
    this.waveColor,
  });
  final Widget child;
  final Color? waveColor;
  final double maxRadius;
  final Duration duration;

  @override
  State<_AnimatedPulseWave> createState() => _AnimatedPulseWaveState();
}

class _AnimatedPulseWaveState extends State<_AnimatedPulseWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _radiusAnimation = Tween<double>(
      begin: 20.0,
      end: widget.maxRadius,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.8,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _PulseWavePainter(
          radius: _radiusAnimation.value,
          opacity: _opacityAnimation.value,
          color: widget.waveColor ?? Colors.blue.withValues(alpha: 0.3),
        ),
        child: widget.child,
      );
}

class _PulseWavePainter extends CustomPainter {
  _PulseWavePainter({
    required this.radius,
    required this.opacity,
    required this.color,
  });
  final double radius;
  final double opacity;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      radius,
      paint,
    );

    // Draw inner circle for layered effect
    final innerPaint = Paint()
      ..color = color.withValues(alpha: opacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      radius * 0.7,
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(_PulseWavePainter oldDelegate) =>
      oldDelegate.radius != radius ||
      oldDelegate.opacity != opacity ||
      oldDelegate.color != color;
}

// ===== 通用工具动画 =====

/// 动画弹出对话框
class _AnimatedDialog extends StatefulWidget {
  const _AnimatedDialog({
    required this.child,
    required this.isVisible,
    required this.duration,
  });
  final Widget child;
  final bool isVisible;
  final Duration duration;

  @override
  State<_AnimatedDialog> createState() => _AnimatedDialogState();
}

class _AnimatedDialogState extends State<_AnimatedDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_AnimatedDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          ),
        ),
      );
}

/// 提示消息动画
class _AnimatedToast extends StatefulWidget {
  const _AnimatedToast({
    required this.message,
    required this.isVisible,
    required this.duration,
    this.backgroundColor,
  });
  final String message;
  final bool isVisible;
  final Color? backgroundColor;
  final Duration duration;

  @override
  State<_AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<_AnimatedToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_AnimatedToast oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                widget.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
}

/// 成功提示动画
class _AnimatedSuccessPrompt extends StatefulWidget {
  const _AnimatedSuccessPrompt({
    required this.isVisible,
    required this.duration,
    this.message,
    this.color,
  });
  final String? message;
  final bool isVisible;
  final Color? color;
  final Duration duration;

  @override
  State<_AnimatedSuccessPrompt> createState() => _AnimatedSuccessPromptState();
}

class _AnimatedSuccessPromptState extends State<_AnimatedSuccessPrompt>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_AnimatedSuccessPrompt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (widget.color ?? Colors.green).withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 48,
                  ),
                  if (widget.message != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.message!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
}

/// 错误提示动画
class _AnimatedErrorPrompt extends StatefulWidget {
  const _AnimatedErrorPrompt({
    required this.isVisible,
    required this.duration,
    this.message,
    this.color,
  });
  final String? message;
  final bool isVisible;
  final Color? color;
  final Duration duration;

  @override
  State<_AnimatedErrorPrompt> createState() => _AnimatedErrorPromptState();
}

class _AnimatedErrorPromptState extends State<_AnimatedErrorPrompt>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: -15), weight: 15),
      TweenSequenceItem(tween: Tween<double>(begin: -15, end: 15), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 15, end: -15), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: -15, end: 0), weight: 15),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_AnimatedErrorPrompt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: (widget.color ?? Colors.red).withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error,
                      color: Colors.white,
                      size: 48,
                    ),
                    if (widget.message != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.message!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

/// 警告提示动画
class _AnimatedWarningPrompt extends StatefulWidget {
  const _AnimatedWarningPrompt({
    required this.isVisible,
    required this.duration,
    this.message,
    this.color,
  });
  final String? message;
  final bool isVisible;
  final Color? color;
  final Duration duration;

  @override
  State<_AnimatedWarningPrompt> createState() => _AnimatedWarningPromptState();
}

class _AnimatedWarningPromptState extends State<_AnimatedWarningPrompt>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.bounceOut,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_AnimatedWarningPrompt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _bounceAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (widget.color ?? Colors.orange).withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning,
                    color: Colors.white,
                    size: 48,
                  ),
                  if (widget.message != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.message!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
}

// ===== 经济特定动画 =====

/// 钱包抖动动画
class _AnimatedWalletShake extends StatefulWidget {
  const _AnimatedWalletShake({
    required this.child,
    required this.shouldShake,
    required this.shakeIntensity,
    required this.duration,
  });
  final Widget child;
  final bool shouldShake;
  final double shakeIntensity;
  final Duration duration;

  @override
  State<_AnimatedWalletShake> createState() => _AnimatedWalletShakeState();
}

class _AnimatedWalletShakeState extends State<_AnimatedWalletShake>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -widget.shakeIntensity),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -widget.shakeIntensity,
          end: widget.shakeIntensity,
        ),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: widget.shakeIntensity,
          end: -widget.shakeIntensity,
        ),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -widget.shakeIntensity,
          end: widget.shakeIntensity,
        ),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: widget.shakeIntensity, end: 0),
        weight: 13,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void didUpdateWidget(_AnimatedWalletShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldShake && !oldWidget.shouldShake) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Transform.scale(
            scale: widget.shouldShake ? _scaleAnimation.value : 1.0,
            child: widget.child,
          ),
        ),
      );
}
