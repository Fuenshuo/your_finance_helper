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

  // ===== 输入反馈动画 =====

  /// 输入框聚焦发光动画
  static Widget animatedInputFocus({
    required Widget child,
    required bool hasFocus,
    Color focusColor = Colors.blue,
    Duration duration = const Duration(milliseconds: 300),
  }) =>
      _AnimatedInputFocus(
        hasFocus: hasFocus,
        focusColor: focusColor,
        duration: duration,
        child: child,
      );

  /// 密码字符遮罩切换动画
  static Widget animatedPasswordMask({
    required String text,
    required bool obscureText,
    TextStyle? style,
    Duration duration = const Duration(milliseconds: 200),
  }) =>
      _AnimatedPasswordMask(
        text: text,
        obscureText: obscureText,
        style: style,
        duration: duration,
      );

  /// 搜索框提示文字动画
  static Widget animatedSearchHint({
    required String hintText,
    required String currentText,
    TextStyle? style,
    Duration duration = const Duration(milliseconds: 250),
  }) =>
      _AnimatedSearchHint(
        hintText: hintText,
        currentText: currentText,
        style: style,
        duration: duration,
      );

  /// 数字千分位格式化动画
  static Widget animatedNumberFormat({
    required double value,
    TextStyle? style,
    Duration duration = const Duration(milliseconds: 600),
  }) =>
      _AnimatedNumberFormat(
        value: value,
        style: style,
        duration: duration,
      );

  /// 输入错误抖动反馈
  static Widget animatedInputError({
    required Widget child,
    required bool hasError,
    Duration duration = const Duration(milliseconds: 500),
  }) =>
      _AnimatedInputError(
        hasError: hasError,
        duration: duration,
        child: child,
      );

  /// 日期选择高亮动画
  static Widget animatedDateHighlight({
    required Widget child,
    required bool isSelected,
    required bool isToday,
    Duration duration = const Duration(milliseconds: 300),
  }) =>
      _AnimatedDateHighlight(
        isSelected: isSelected,
        isToday: isToday,
        duration: duration,
        child: child,
      );

  /// 滑块数值跟随动画
  static Widget animatedSliderValue({
    required double value,
    required double min,
    required double max,
    TextStyle? style,
    Duration duration = const Duration(milliseconds: 200),
  }) =>
      _AnimatedSliderValue(
        value: value,
        min: min,
        max: max,
        style: style,
        duration: duration,
      );

  /// 标签输入出现动画
  static Widget animatedTagAppear({
    required List<String> tags,
    TextStyle? style,
    Duration duration = const Duration(milliseconds: 400),
  }) =>
      _AnimatedTagAppear(
        tags: tags,
        style: style,
        duration: duration,
      );

  /// 多选框勾选动画
  static Widget animatedCheckbox({
    required bool value,
    required ValueChanged<bool?>? onChanged,
    Color? activeColor,
    Duration duration = const Duration(milliseconds: 200),
  }) =>
      _AnimatedCheckbox(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
        duration: duration,
      );

  /// 单选按钮组切换动画
  static Widget animatedRadioGroup<T>({
    required T? value,
    required T groupValue,
    required ValueChanged<T?>? onChanged,
    Widget? title,
    Duration duration = const Duration(milliseconds: 250),
  }) =>
      _AnimatedRadioGroup<T>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        title: title,
        duration: duration,
      );

  // ===== 状态变化动画 =====

  /// 进度条填充动画
  static Widget animatedProgressFill({
    required double progress,
    double height = 4,
    Color fillColor = Colors.blue,
    Color backgroundColor = Colors.grey,
    Duration duration = const Duration(milliseconds: 1000),
  }) =>
      _AnimatedProgressFill(
        progress: progress,
        height: height,
        fillColor: fillColor,
        backgroundColor: backgroundColor,
        duration: duration,
      );

  /// 统计卡片数据更新动画
  static Widget animatedStatCard({
    required Widget child,
    required bool shouldAnimate,
    Duration duration = const Duration(milliseconds: 600),
  }) =>
      _AnimatedStatCard(
        shouldAnimate: shouldAnimate,
        duration: duration,
        child: child,
      );

  /// 图表数据点亮动画
  static Widget animatedChartHighlight({
    required Widget child,
    required bool isHighlighted,
    Duration duration = const Duration(milliseconds: 300),
  }) =>
      _AnimatedChartHighlight(
        isHighlighted: isHighlighted,
        duration: duration,
        child: child,
      );

  /// 余额数字滚动动画
  static Widget animatedBalanceRoll({
    required double value,
    TextStyle? style,
    Duration duration = const Duration(milliseconds: 800),
  }) =>
      _AnimatedBalanceRoll(
        value: value,
        style: style,
        duration: duration,
      );

  /// 环形进度条动画
  static Widget animatedCircularProgress({
    required double progress,
    double size = 100,
    double strokeWidth = 8,
    Color progressColor = Colors.blue,
    Color backgroundColor = Colors.grey,
    Duration duration = const Duration(milliseconds: 1200),
  }) =>
      _AnimatedCircularProgress(
        progress: progress,
        size: size,
        strokeWidth: strokeWidth,
        progressColor: progressColor,
        backgroundColor: backgroundColor,
        duration: duration,
      );

  /// 等级提升动画
  static Widget animatedLevelUp({
    required Widget child,
    required bool shouldAnimate,
    Duration duration = const Duration(milliseconds: 1000),
  }) =>
      _AnimatedLevelUp(
        shouldAnimate: shouldAnimate,
        duration: duration,
        child: child,
      );

  /// 状态指示器颜色动画
  static Widget animatedStatusIndicator({
    required StatusType status,
    double size = 12,
    Duration duration = const Duration(milliseconds: 400),
  }) =>
      _AnimatedStatusIndicator(
        status: status,
        size: size,
        duration: duration,
      );

  /// 通知徽章数字动画
  static Widget animatedBadge({
    required int count,
    Color badgeColor = Colors.red,
    Duration duration = const Duration(milliseconds: 300),
  }) =>
      _AnimatedBadge(
        count: count,
        badgeColor: badgeColor,
        duration: duration,
      );

  /// 时间线事件展开动画
  static Widget animatedTimelineEvent({
    required Widget child,
    required bool isExpanded,
    Duration duration = const Duration(milliseconds: 500),
  }) =>
      _AnimatedTimelineEvent(
        isExpanded: isExpanded,
        duration: duration,
        child: child,
      );

  // ===== 列表操作动画 =====

  /// 滑动删除预览动画
  static Widget animatedSwipeDelete({
    required Widget child,
    required bool isDeleting,
    VoidCallback? onDelete,
    Duration duration = const Duration(milliseconds: 300),
  }) =>
      _AnimatedSwipeDelete(
        isDeleting: isDeleting,
        onDelete: onDelete,
        duration: duration,
        child: child,
      );

  /// 拖拽排序动画
  static Widget animatedDragSort({
    required Widget child,
    required bool isDragging,
    required Offset dragOffset,
    Duration duration = const Duration(milliseconds: 200),
  }) =>
      _AnimatedDragSort(
        isDragging: isDragging,
        dragOffset: dragOffset,
        duration: duration,
        child: child,
      );

  /// 列表项展开动画
  static Widget animatedListExpand({
    required Widget child,
    required bool isExpanded,
    Duration duration = const Duration(milliseconds: 400),
  }) =>
      _AnimatedListExpand(
        isExpanded: isExpanded,
        duration: duration,
        child: child,
      );

  /// 置顶动画
  static Widget animatedPinToTop({
    required Widget child,
    required bool isPinned,
    Duration duration = const Duration(milliseconds: 600),
  }) =>
      _AnimatedPinToTop(
        isPinned: isPinned,
        duration: duration,
        child: child,
      );

  /// 批量选择模式动画
  static Widget animatedBulkSelect({
    required Widget child,
    required bool isSelecting,
    required bool isSelected,
    Duration duration = const Duration(milliseconds: 300),
  }) =>
      _AnimatedBulkSelect(
        isSelecting: isSelecting,
        isSelected: isSelected,
        duration: duration,
        child: child,
      );

  /// 收藏动画
  static Widget animatedFavorite({
    required Widget child,
    required bool isFavorited,
    Duration duration = const Duration(milliseconds: 500),
  }) =>
      _AnimatedFavorite(
        isFavorited: isFavorited,
        duration: duration,
        child: child,
      );

  /// 列表筛选动画
  static Widget animatedListFilter({
    required List<Widget> children,
    required bool isFiltering,
    Duration duration = const Duration(milliseconds: 400),
  }) =>
      _AnimatedListFilter(
        isFiltering: isFiltering,
        duration: duration,
        children: children,
      );

  /// 优先级标记动画
  static Widget animatedPriorityTag({
    required Widget child,
    required PriorityLevel priority,
    Duration duration = const Duration(milliseconds: 300),
  }) =>
      _AnimatedPriorityTag(
        priority: priority,
        duration: duration,
        child: child,
      );

  /// 搜索结果高亮动画
  static Widget animatedSearchHighlight({
    required Widget child,
    required bool isHighlighted,
    Color highlightColor = Colors.yellow,
    Duration duration = const Duration(milliseconds: 200),
  }) =>
      _AnimatedSearchHighlight(
        isHighlighted: isHighlighted,
        highlightColor: highlightColor,
        duration: duration,
        child: child,
      );

  // ===== 交互选择动画 =====

  /// 下拉菜单展开动画
  static Widget animatedDropdown({
    required Widget child,
    required bool isExpanded,
    Duration duration = const Duration(milliseconds: 300),
  }) =>
      _AnimatedDropdown(
        isExpanded: isExpanded,
        duration: duration,
        child: child,
      );

  /// 标签页指示器动画
  static Widget animatedTabIndicator({
    required int currentIndex,
    required int tabCount,
    required double tabWidth,
    Color indicatorColor = Colors.blue,
    Duration duration = const Duration(milliseconds: 300),
  }) =>
      _AnimatedTabIndicator(
        currentIndex: currentIndex,
        tabCount: tabCount,
        tabWidth: tabWidth,
        indicatorColor: indicatorColor,
        duration: duration,
      );

  /// 分段选择器动画
  static Widget animatedSegmentedControl({
    required List<String> segments,
    required int selectedIndex,
    required ValueChanged<int> onChanged,
    Duration duration = const Duration(milliseconds: 200),
  }) =>
      _AnimatedSegmentedControl(
        segments: segments,
        selectedIndex: selectedIndex,
        onChanged: onChanged,
        duration: duration,
      );

  /// 颜色选择器动画
  static Widget animatedColorPicker({
    required List<Color> colors,
    required int? selectedIndex,
    required ValueChanged<int> onColorSelected,
    Duration duration = const Duration(milliseconds: 300),
  }) =>
      _AnimatedColorPicker(
        colors: colors,
        selectedIndex: selectedIndex,
        onColorSelected: onColorSelected,
        duration: duration,
      );

  /// 星级评分动画
  static Widget animatedStarRating({
    required int rating,
    required int maxRating,
    required ValueChanged<int> onRatingChanged,
    Color activeColor = Colors.amber,
    Color inactiveColor = Colors.grey,
    Duration duration = const Duration(milliseconds: 200),
  }) =>
      _AnimatedStarRating(
        rating: rating,
        maxRating: maxRating,
        onRatingChanged: onRatingChanged,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
        duration: duration,
      );

  /// 步进器动画
  static Widget animatedStepper({
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
    Duration duration = const Duration(milliseconds: 150),
  }) =>
      _AnimatedStepper(
        value: value,
        min: min,
        max: max,
        onChanged: onChanged,
        duration: duration,
      );

  /// 开关切换动画
  static Widget animatedSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    Color activeColor = Colors.blue,
    Duration duration = const Duration(milliseconds: 200),
  }) =>
      _AnimatedSwitch(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
        duration: duration,
      );

  /// 范围滑块动画
  static Widget animatedRangeSlider({
    required RangeValues values,
    required RangeValues min,
    required RangeValues max,
    required ValueChanged<RangeValues> onChanged,
    Duration duration = const Duration(milliseconds: 200),
  }) =>
      _AnimatedRangeSlider(
        values: values,
        min: min,
        max: max,
        onChanged: onChanged,
        duration: duration,
      );

  /// 级联选择器动画
  static Widget animatedCascadingSelect({
    required List<String> options,
    required List<bool> expandedStates,
    required ValueChanged<int> onToggle,
    Duration duration = const Duration(milliseconds: 300),
  }) =>
      _AnimatedCascadingSelect(
        options: options,
        expandedStates: expandedStates,
        onToggle: onToggle,
        duration: duration,
      );

  /// 过滤面板动画
  static Widget animatedFilterPanel({
    required Widget child,
    required bool isOpen,
    Duration duration = const Duration(milliseconds: 400),
  }) =>
      _AnimatedFilterPanel(
        isOpen: isOpen,
        duration: duration,
        child: child,
      );

  /// 快速选择菜单动画
  static Widget animatedQuickSelect({
    required Widget child,
    required bool isVisible,
    required Offset position,
    Duration duration = const Duration(milliseconds: 250),
  }) =>
      _AnimatedQuickSelect(
        isVisible: isVisible,
        position: position,
        duration: duration,
        child: child,
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
    required this.progressColor,
    required this.backgroundColor,
    required this.duration,
  });
  final double progress;
  final double size;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;
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
                backgroundColor: widget.backgroundColor.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(widget.progressColor),
                strokeWidth: widget.strokeWidth,
              ),
              Text(
                '${(_progressAnimation.value * 100).round()}%',
                style: TextStyle(
                  fontSize: widget.size * 0.15,
                  fontWeight: FontWeight.bold,
                  color: widget.progressColor,
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

// ===== 输入反馈动画组件实现 =====

/// 输入框聚焦发光动画
class _AnimatedInputFocus extends StatefulWidget {
  const _AnimatedInputFocus({
    required this.child,
    required this.hasFocus,
    required this.focusColor,
    required this.duration,
  });

  final Widget child;
  final bool hasFocus;
  final Color focusColor;
  final Duration duration;

  @override
  State<_AnimatedInputFocus> createState() => _AnimatedInputFocusState();
}

class _AnimatedInputFocusState extends State<_AnimatedInputFocus>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.hasFocus) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_AnimatedInputFocus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasFocus != oldWidget.hasFocus) {
      if (widget.hasFocus) {
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
        animation: _glowAnimation,
        builder: (context, child) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: widget.hasFocus
                ? [
                    BoxShadow(
                      color: widget.focusColor
                          .withValues(alpha: 0.3 * _glowAnimation.value),
                      blurRadius: 8 * _glowAnimation.value,
                      spreadRadius: 2 * _glowAnimation.value,
                    ),
                  ]
                : null,
          ),
          child: widget.child,
        ),
      );
}

/// 密码字符遮罩切换动画
class _AnimatedPasswordMask extends StatefulWidget {
  const _AnimatedPasswordMask({
    required this.text,
    required this.obscureText,
    required this.style,
    required this.duration,
  });

  final String text;
  final bool obscureText;
  final TextStyle? style;
  final Duration duration;

  @override
  State<_AnimatedPasswordMask> createState() => _AnimatedPasswordMaskState();
}

class _AnimatedPasswordMaskState extends State<_AnimatedPasswordMask>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_controller);
  }

  @override
  void didUpdateWidget(_AnimatedPasswordMask oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.obscureText != oldWidget.obscureText) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getDisplayText() {
    if (!widget.obscureText) return widget.text;
    return '•' * widget.text.length;
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _opacityAnimation,
        builder: (context, child) => Opacity(
          opacity: widget.obscureText
              ? _opacityAnimation.value
              : 1.0 - _opacityAnimation.value,
          child: Text(
            _getDisplayText(),
            style: widget.style,
          ),
        ),
      );
}

/// 搜索框提示文字动画
class _AnimatedSearchHint extends StatefulWidget {
  const _AnimatedSearchHint({
    required this.hintText,
    required this.currentText,
    required this.style,
    required this.duration,
  });

  final String hintText;
  final String currentText;
  final TextStyle? style;
  final Duration duration;

  @override
  State<_AnimatedSearchHint> createState() => _AnimatedSearchHintState();
}

class _AnimatedSearchHintState extends State<_AnimatedSearchHint>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(_AnimatedSearchHint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentText.isEmpty != oldWidget.currentText.isEmpty) {
      if (widget.currentText.isEmpty) {
        _controller.reverse();
      } else {
        _controller.forward();
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
        animation: _opacityAnimation,
        builder: (context, child) => Opacity(
          opacity: widget.currentText.isEmpty ? 1.0 : _opacityAnimation.value,
          child: Text(
            widget.hintText,
            style: widget.style?.copyWith(
              color: widget.style?.color?.withValues(
                  alpha: widget.currentText.isEmpty
                      ? 1.0
                      : _opacityAnimation.value),
            ),
          ),
        ),
      );
}

/// 数字千分位格式化动画
class _AnimatedNumberFormat extends StatefulWidget {
  const _AnimatedNumberFormat({
    required this.value,
    required this.style,
    required this.duration,
  });

  final double value;
  final TextStyle? style;
  final Duration duration;

  @override
  State<_AnimatedNumberFormat> createState() => _AnimatedNumberFormatState();
}

class _AnimatedNumberFormatState extends State<_AnimatedNumberFormat>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  String _previousFormatted = '';
  String _currentFormatted = '';

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

    _updateFormattedValue();
  }

  @override
  void didUpdateWidget(_AnimatedNumberFormat oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _previousFormatted = _currentFormatted;
      _updateFormattedValue();
      _controller.forward(from: 0.0);
    }
  }

  void _updateFormattedValue() {
    _currentFormatted = _formatNumber(widget.value);
  }

  String _formatNumber(double value) {
    final intPart = value.toInt();
    final decimalPart = ((value - intPart) * 100).round();
    final intStr = intPart.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
    return decimalPart > 0 ? '$intStr.$decimalPart' : intStr;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Text(
            _currentFormatted,
            style: widget.style,
          ),
        ),
      );
}

/// 输入错误抖动反馈
class _AnimatedInputError extends StatefulWidget {
  const _AnimatedInputError({
    required this.child,
    required this.hasError,
    required this.duration,
  });

  final Widget child;
  final bool hasError;
  final Duration duration;

  @override
  State<_AnimatedInputError> createState() => _AnimatedInputErrorState();
}

class _AnimatedInputErrorState extends State<_AnimatedInputError>
    with TickerProviderStateMixin {
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
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -10.0),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -10.0, end: 10.0),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 10.0, end: -10.0),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -10.0, end: 0.0),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(_AnimatedInputError oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasError && !oldWidget.hasError) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) => Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: widget.child,
        ),
      );
}

/// 日期选择高亮动画
class _AnimatedDateHighlight extends StatefulWidget {
  const _AnimatedDateHighlight({
    required this.child,
    required this.isSelected,
    required this.isToday,
    required this.duration,
  });

  final Widget child;
  final bool isSelected;
  final bool isToday;
  final Duration duration;

  @override
  State<_AnimatedDateHighlight> createState() => _AnimatedDateHighlightState();
}

class _AnimatedDateHighlightState extends State<_AnimatedDateHighlight>
    with TickerProviderStateMixin {
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
      end: widget.isSelected ? 1.2 : (widget.isToday ? 1.1 : 1.0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: widget.isSelected
          ? Colors.blue
          : (widget.isToday ? Colors.orange : Colors.transparent),
    ).animate(_controller);
  }

  @override
  void didUpdateWidget(_AnimatedDateHighlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected ||
        widget.isToday != oldWidget.isToday) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _colorAnimation]),
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _colorAnimation.value?.withValues(alpha: 0.2),
            ),
            child: widget.child,
          ),
        ),
      );
}

/// 滑块数值跟随动画
class _AnimatedSliderValue extends StatefulWidget {
  const _AnimatedSliderValue({
    required this.value,
    required this.min,
    required this.max,
    required this.style,
    required this.duration,
  });

  final double value;
  final double min;
  final double max;
  final TextStyle? style;
  final Duration duration;

  @override
  State<_AnimatedSliderValue> createState() => _AnimatedSliderValueState();
}

class _AnimatedSliderValueState extends State<_AnimatedSliderValue>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(_calculatePosition(), -40),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedSliderValue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _positionAnimation = Tween<Offset>(
        begin: _positionAnimation.value,
        end: Offset(_calculatePosition(), -40),
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
        ),
      );
      _controller.forward(from: 0.0);
    }
  }

  double _calculatePosition() {
    final percentage = (widget.value - widget.min) / (widget.max - widget.min);
    return (percentage - 0.5) * 200; // 假设滑块宽度为200
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _positionAnimation,
        builder: (context, child) => Transform.translate(
          offset: _positionAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.value.toStringAsFixed(1),
              style: widget.style?.copyWith(color: Colors.white) ??
                  const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
}

/// 标签输入出现动画
class _AnimatedTagAppear extends StatefulWidget {
  const _AnimatedTagAppear({
    required this.tags,
    required this.style,
    required this.duration,
  });

  final List<String> tags;
  final TextStyle? style;
  final Duration duration;

  @override
  State<_AnimatedTagAppear> createState() => _AnimatedTagAppearState();
}

class _AnimatedTagAppearState extends State<_AnimatedTagAppear>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _scaleAnimations = [];
  final List<Animation<Offset>> _slideAnimations = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void didUpdateWidget(_AnimatedTagAppear oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tags.length != oldWidget.tags.length) {
      _disposeAnimations();
      _initializeAnimations();
    }
  }

  void _initializeAnimations() {
    for (var i = 0; i < widget.tags.length; i++) {
      final controller = AnimationController(
        duration: widget.duration,
        vsync: this,
      );

      final scaleAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.elasticOut,
        ),
      );

      final slideAnimation = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOut,
        ),
      );

      _controllers.add(controller);
      _scaleAnimations.add(scaleAnimation);
      _slideAnimations.add(slideAnimation);

      // 错开动画开始时间
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) controller.forward();
      });
    }
  }

  void _disposeAnimations() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
    _scaleAnimations.clear();
    _slideAnimations.clear();
  }

  @override
  void dispose() {
    _disposeAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(widget.tags.length, (index) {
          if (index >= _controllers.length) return const SizedBox.shrink();

          return AnimatedBuilder(
            animation: Listenable.merge(
                [_scaleAnimations[index], _slideAnimations[index]]),
            builder: (context, child) => Transform.translate(
              offset: _slideAnimations[index].value,
              child: Transform.scale(
                scale: _scaleAnimations[index].value,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    widget.tags[index],
                    style: widget.style,
                  ),
                ),
              ),
            ),
          );
        }),
      );
}

/// 多选框勾选动画
class _AnimatedCheckbox extends StatefulWidget {
  const _AnimatedCheckbox({
    required this.value,
    required this.onChanged,
    required this.activeColor,
    required this.duration,
  });

  final bool value;
  final ValueChanged<bool?>? onChanged;
  final Color? activeColor;
  final Duration duration;

  @override
  State<_AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<_AnimatedCheckbox>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_AnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
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
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => widget.onChanged?.call(!widget.value),
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _checkAnimation]),
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.value
                      ? (widget.activeColor ?? Colors.blue)
                      : Colors.grey,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
                color: widget.value
                    ? (widget.activeColor ?? Colors.blue).withValues(alpha: 0.1)
                    : Colors.transparent,
              ),
              child: widget.value
                  ? Icon(
                      Icons.check,
                      size: 16 * _checkAnimation.value,
                      color: widget.activeColor ?? Colors.blue,
                    )
                  : null,
            ),
          ),
        ),
      );
}

/// 单选按钮组切换动画
class _AnimatedRadioGroup<T> extends StatefulWidget {
  const _AnimatedRadioGroup({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.title,
    required this.duration,
  });

  final T? value;
  final T groupValue;
  final ValueChanged<T?>? onChanged;
  final Widget? title;
  final Duration duration;

  @override
  State<_AnimatedRadioGroup<T>> createState() => _AnimatedRadioGroupState<T>();
}

class _AnimatedRadioGroupState<T> extends State<_AnimatedRadioGroup<T>>
    with TickerProviderStateMixin {
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
      begin: Colors.grey,
      end: Colors.blue,
    ).animate(_controller);

    if (widget.value == widget.groupValue) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_AnimatedRadioGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value ||
        widget.groupValue != oldWidget.groupValue) {
      if (widget.value == widget.groupValue) {
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
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => widget.onChanged?.call(widget.value),
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _colorAnimation]),
          builder: (context, child) => Row(
            children: [
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _colorAnimation.value ?? Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: widget.value == widget.groupValue
                      ? Container(
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _colorAnimation.value,
                          ),
                        )
                      : null,
                ),
              ),
              if (widget.title != null) ...[
                const SizedBox(width: 8),
                DefaultTextStyle(
                  style: TextStyle(
                    color: _colorAnimation.value,
                    fontWeight: widget.value == widget.groupValue
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  child: widget.title!,
                ),
              ],
            ],
          ),
        ),
      );
}

// ===== 状态变化动画组件实现 =====

/// 进度条填充动画
class _AnimatedProgressFill extends StatefulWidget {
  const _AnimatedProgressFill({
    required this.progress,
    required this.height,
    required this.fillColor,
    required this.backgroundColor,
    required this.duration,
  });

  final double progress;
  final double height;
  final Color fillColor;
  final Color backgroundColor;
  final Duration duration;

  @override
  State<_AnimatedProgressFill> createState() => _AnimatedProgressFillState();
}

class _AnimatedProgressFillState extends State<_AnimatedProgressFill>
    with TickerProviderStateMixin {
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
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedProgressFill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress != oldWidget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      );
      _controller.forward(from: 0.0);
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
            color: widget.backgroundColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progressAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: widget.fillColor,
                borderRadius: BorderRadius.circular(widget.height / 2),
              ),
            ),
          ),
        ),
      );
}

/// 统计卡片数据更新动画
class _AnimatedStatCard extends StatefulWidget {
  const _AnimatedStatCard({
    required this.child,
    required this.shouldAnimate,
    required this.duration,
  });

  final Widget child;
  final bool shouldAnimate;
  final Duration duration;

  @override
  State<_AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<_AnimatedStatCard>
    with TickerProviderStateMixin {
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
      begin: 1.0,
      end: 1.05,
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
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(_AnimatedStatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldAnimate && !oldWidget.shouldAnimate) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _opacityAnimation]),
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: widget.child,
          ),
        ),
      );
}

/// 图表数据点亮动画
class _AnimatedChartHighlight extends StatefulWidget {
  const _AnimatedChartHighlight({
    required this.child,
    required this.isHighlighted,
    required this.duration,
  });

  final Widget child;
  final bool isHighlighted;
  final Duration duration;

  @override
  State<_AnimatedChartHighlight> createState() =>
      _AnimatedChartHighlightState();
}

class _AnimatedChartHighlightState extends State<_AnimatedChartHighlight>
    with TickerProviderStateMixin {
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
      begin: Colors.grey,
      end: Colors.blue,
    ).animate(_controller);

    if (widget.isHighlighted) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_AnimatedChartHighlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted != oldWidget.isHighlighted) {
      if (widget.isHighlighted) {
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
        animation: Listenable.merge([_scaleAnimation, _colorAnimation]),
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _colorAnimation.value?.withValues(alpha: 0.2),
            ),
            child: widget.child,
          ),
        ),
      );
}

/// 余额数字滚动动画
class _AnimatedBalanceRoll extends StatefulWidget {
  const _AnimatedBalanceRoll({
    required this.value,
    required this.style,
    required this.duration,
  });

  final double value;
  final TextStyle? style;
  final Duration duration;

  @override
  State<_AnimatedBalanceRoll> createState() => _AnimatedBalanceRollState();
}

class _AnimatedBalanceRollState extends State<_AnimatedBalanceRoll>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _valueAnimation;
  double _previousValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _valueAnimation = Tween<double>(
      begin: widget.value,
      end: widget.value,
    ).animate(_controller);

    _previousValue = widget.value;
  }

  @override
  void didUpdateWidget(_AnimatedBalanceRoll oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _valueAnimation = Tween<double>(
        begin: _previousValue,
        end: widget.value,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      );
      _controller.forward(from: 0.0);
      _previousValue = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _valueAnimation,
        builder: (context, child) => Text(
          '¥${_valueAnimation.value.toStringAsFixed(2)}',
          style: widget.style,
        ),
      );
}

class _AnimatedStatusIndicatorState extends State<_AnimatedStatusIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _colorAnimation =
        AlwaysStoppedAnimation<Color>(_getStatusColor(widget.status));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.status == StatusType.loading) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_AnimatedStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status != oldWidget.status) {
      _colorAnimation = ColorTween(
        begin: _getStatusColor(oldWidget.status),
        end: _getStatusColor(widget.status),
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      );

      if (widget.status == StatusType.loading) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.value = 1.0;
      }

      _controller.forward(from: 0.0);
    }
  }

  Color _getStatusColor(StatusType status) {
    switch (status) {
      case StatusType.loading:
        return Colors.blue;
      case StatusType.success:
        return Colors.green;
      case StatusType.error:
        return Colors.red;
      case StatusType.warning:
        return Colors.orange;
      case StatusType.info:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([_colorAnimation, _pulseAnimation]),
        builder: (context, child) => Transform.scale(
          scale:
              widget.status == StatusType.loading ? _pulseAnimation.value : 1.0,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
}

/// 通知徽章数字动画
class _AnimatedBadge extends StatefulWidget {
  const _AnimatedBadge({
    required this.count,
    required this.badgeColor,
    required this.duration,
  });

  final int count;
  final Color badgeColor;
  final Duration duration;

  @override
  State<_AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<_AnimatedBadge>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _previousCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _previousCount = widget.count;
  }

  @override
  void didUpdateWidget(_AnimatedBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count) {
      _controller.forward(from: 0.0);
      _previousCount = widget.count;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.count == 0
      ? const SizedBox.shrink()
      : AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: widget.badgeColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                widget.count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
}

/// 时间线事件展开动画
class _AnimatedTimelineEvent extends StatefulWidget {
  const _AnimatedTimelineEvent({
    required this.child,
    required this.isExpanded,
    required this.duration,
  });

  final Widget child;
  final bool isExpanded;
  final Duration duration;

  @override
  State<_AnimatedTimelineEvent> createState() => _AnimatedTimelineEventState();
}

class _AnimatedTimelineEventState extends State<_AnimatedTimelineEvent>
    with TickerProviderStateMixin {
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
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_AnimatedTimelineEvent oldWidget) {
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
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([_heightAnimation, _opacityAnimation]),
        builder: (context, child) => ClipRect(
          child: Align(
            heightFactor: _heightAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: widget.child,
            ),
          ),
        ),
      );
}

// ===== 列表操作动画组件实现 =====

/// 滑动删除预览动画
class _AnimatedSwipeDelete extends StatefulWidget {
  const _AnimatedSwipeDelete({
    required this.child,
    required this.isDeleting,
    required this.onDelete,
    required this.duration,
  });

  final Widget child;
  final bool isDeleting;
  final VoidCallback? onDelete;
  final Duration duration;

  @override
  State<_AnimatedSwipeDelete> createState() => _AnimatedSwipeDeleteState();
}

class _AnimatedSwipeDeleteState extends State<_AnimatedSwipeDelete>
    with TickerProviderStateMixin {
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
      begin: Offset.zero,
      end: const Offset(-1.0, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isDeleting) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_AnimatedSwipeDelete oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDeleting != oldWidget.isDeleting) {
      if (widget.isDeleting) {
        _controller.forward().then((_) => widget.onDelete?.call());
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
        animation: Listenable.merge([_slideAnimation, _opacityAnimation]),
        builder: (context, child) => Transform.translate(
          offset: _slideAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: widget.child,
          ),
        ),
      );
}

/// 拖拽排序动画
class _AnimatedDragSort extends StatefulWidget {
  const _AnimatedDragSort({
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
  State<_AnimatedDragSort> createState() => _AnimatedDragSortState();
}

class _AnimatedDragSortState extends State<_AnimatedDragSort>
    with TickerProviderStateMixin {
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
      begin: 1.0,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isDragging) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_AnimatedDragSort oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDragging != oldWidget.isDragging) {
      if (widget.isDragging) {
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
        animation: Listenable.merge([_scaleAnimation, _rotationAnimation]),
        builder: (context, child) => Transform.translate(
          offset: widget.dragOffset,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: widget.child,
            ),
          ),
        ),
      );
}

/// 列表项展开动画
class _AnimatedListExpand extends StatefulWidget {
  const _AnimatedListExpand({
    required this.child,
    required this.isExpanded,
    required this.duration,
  });

  final Widget child;
  final bool isExpanded;
  final Duration duration;

  @override
  State<_AnimatedListExpand> createState() => _AnimatedListExpandState();
}

class _AnimatedListExpandState extends State<_AnimatedListExpand>
    with TickerProviderStateMixin {
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
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_AnimatedListExpand oldWidget) {
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
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([_heightAnimation, _opacityAnimation]),
        builder: (context, child) => ClipRect(
          child: Align(
            heightFactor: _heightAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: widget.child,
            ),
          ),
        ),
      );
}

/// 置顶动画
class _AnimatedPinToTop extends StatefulWidget {
  const _AnimatedPinToTop({
    required this.child,
    required this.isPinned,
    required this.duration,
  });

  final Widget child;
  final bool isPinned;
  final Duration duration;

  @override
  State<_AnimatedPinToTop> createState() => _AnimatedPinToTopState();
}

class _AnimatedPinToTopState extends State<_AnimatedPinToTop>
    with TickerProviderStateMixin {
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

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
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

    if (widget.isPinned) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_AnimatedPinToTop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPinned != oldWidget.isPinned) {
      if (widget.isPinned) {
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
        animation: Listenable.merge([_slideAnimation, _scaleAnimation]),
        builder: (context, child) => Transform.translate(
          offset: _slideAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: widget.isPinned
                    ? [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: widget.child,
            ),
          ),
        ),
      );
}

/// 批量选择模式动画
class _AnimatedBulkSelect extends StatefulWidget {
  const _AnimatedBulkSelect({
    required this.child,
    required this.isSelecting,
    required this.isSelected,
    required this.duration,
  });

  final Widget child;
  final bool isSelecting;
  final bool isSelected;
  final Duration duration;

  @override
  State<_AnimatedBulkSelect> createState() => _AnimatedBulkSelectState();
}

class _AnimatedBulkSelectState extends State<_AnimatedBulkSelect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.isSelected ? 1.1 : 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _backgroundAnimation = ColorTween(
      begin: Colors.transparent,
      end: widget.isSelected
          ? Colors.blue.withValues(alpha: 0.1)
          : Colors.transparent,
    ).animate(_controller);

    _updateAnimation();
  }

  @override
  void didUpdateWidget(_AnimatedBulkSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelecting != oldWidget.isSelecting ||
        widget.isSelected != oldWidget.isSelected) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (widget.isSelecting) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _backgroundAnimation]),
        builder: (context, child) => Transform.scale(
          scale: widget.isSelecting ? _scaleAnimation.value : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: _backgroundAnimation.value,
              borderRadius: BorderRadius.circular(8),
            ),
            child: widget.child,
          ),
        ),
      );
}

/// 收藏动画
class _AnimatedFavorite extends StatefulWidget {
  const _AnimatedFavorite({
    required this.child,
    required this.isFavorited,
    required this.duration,
  });

  final Widget child;
  final bool isFavorited;
  final Duration duration;

  @override
  State<_AnimatedFavorite> createState() => _AnimatedFavoriteState();
}

class _AnimatedFavoriteState extends State<_AnimatedFavorite>
    with TickerProviderStateMixin {
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
        tween: Tween(begin: 1.0, end: 1.3),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 1.0),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.1),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _colorAnimation = ColorTween(
      begin: Colors.grey,
      end: Colors.red,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isFavorited) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_AnimatedFavorite oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorited != oldWidget.isFavorited) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _colorAnimation]),
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: IconTheme(
            data: IconThemeData(
              color: _colorAnimation.value,
            ),
            child: widget.child,
          ),
        ),
      );
}

/// 列表筛选动画
class _AnimatedListFilter extends StatefulWidget {
  const _AnimatedListFilter({
    required this.children,
    required this.isFiltering,
    required this.duration,
  });

  final List<Widget> children;
  final bool isFiltering;
  final Duration duration;

  @override
  State<_AnimatedListFilter> createState() => _AnimatedListFilterState();
}

class _AnimatedListFilterState extends State<_AnimatedListFilter>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _opacityAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _initializeAnimations();
  }

  @override
  void didUpdateWidget(_AnimatedListFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.children.length != oldWidget.children.length) {
      _disposeAnimations();
      _initializeAnimations();
    }

    if (widget.isFiltering != oldWidget.isFiltering) {
      if (widget.isFiltering) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  void _initializeAnimations() {
    _opacityAnimations = List.generate(
      widget.children.length,
      (index) => Tween<double>(
        begin: 1.0,
        end: 0.3,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      ),
    );
  }

  void _disposeAnimations() {
    // No need to dispose individual animations as they are recreated
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Column(
          children: List.generate(widget.children.length, (index) {
            final opacity =
                widget.isFiltering ? _opacityAnimations[index].value : 1.0;
            return Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: opacity,
                child: widget.children[index],
              ),
            );
          }),
        ),
      );
}

/// 优先级标记动画
class _AnimatedPriorityTag extends StatefulWidget {
  const _AnimatedPriorityTag({
    required this.child,
    required this.priority,
    required this.duration,
  });

  final Widget child;
  final PriorityLevel priority;
  final Duration duration;

  @override
  State<_AnimatedPriorityTag> createState() => _AnimatedPriorityTagState();
}

class _AnimatedPriorityTagState extends State<_AnimatedPriorityTag>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _colorAnimation =
        AlwaysStoppedAnimation<Color>(_getPriorityColor(widget.priority));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: widget.priority == PriorityLevel.urgent ? 1.2 : 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.priority == PriorityLevel.urgent) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_AnimatedPriorityTag oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.priority != oldWidget.priority) {
      _colorAnimation = ColorTween(
        begin: _getPriorityColor(oldWidget.priority),
        end: _getPriorityColor(widget.priority),
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      );

      if (widget.priority == PriorityLevel.urgent) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.value = 1.0;
      }

      _controller.forward(from: 0.0);
    }
  }

  Color _getPriorityColor(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.low:
        return Colors.grey;
      case PriorityLevel.medium:
        return Colors.blue;
      case PriorityLevel.high:
        return Colors.orange;
      case PriorityLevel.urgent:
        return Colors.red;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([_colorAnimation, _pulseAnimation]),
        builder: (context, child) => Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _colorAnimation.value?.withValues(alpha: 0.1),
              border: Border.all(color: _colorAnimation.value ?? Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: widget.child,
          ),
        ),
      );
}

/// 搜索结果高亮动画
class _AnimatedSearchHighlight extends StatefulWidget {
  const _AnimatedSearchHighlight({
    required this.child,
    required this.isHighlighted,
    required this.highlightColor,
    required this.duration,
  });

  final Widget child;
  final bool isHighlighted;
  final Color highlightColor;
  final Duration duration;

  @override
  State<_AnimatedSearchHighlight> createState() =>
      _AnimatedSearchHighlightState();
}

class _AnimatedSearchHighlightState extends State<_AnimatedSearchHighlight>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _backgroundAnimation = ColorTween(
      begin: Colors.transparent,
      end: widget.highlightColor,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isHighlighted) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_AnimatedSearchHighlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted != oldWidget.isHighlighted) {
      if (widget.isHighlighted) {
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
        animation: _backgroundAnimation,
        builder: (context, child) => Container(
          color: _backgroundAnimation.value?.withValues(alpha: 0.3),
          child: widget.child,
        ),
      );
}

// ===== 交互选择动画组件实现 =====

/// 下拉菜单展开动画
class _AnimatedDropdown extends StatefulWidget {
  const _AnimatedDropdown({
    required this.child,
    required this.isExpanded,
    required this.duration,
  });

  final Widget child;
  final bool isExpanded;
  final Duration duration;

  @override
  State<_AnimatedDropdown> createState() => _AnimatedDropdownState();
}

class _AnimatedDropdownState extends State<_AnimatedDropdown>
    with TickerProviderStateMixin {
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
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_AnimatedDropdown oldWidget) {
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
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([_heightAnimation, _opacityAnimation]),
        builder: (context, child) => ClipRect(
          child: Align(
            heightFactor: _heightAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: widget.child,
            ),
          ),
        ),
      );
}

/// 标签页指示器动画
class _AnimatedTabIndicator extends StatefulWidget {
  const _AnimatedTabIndicator({
    required this.currentIndex,
    required this.tabCount,
    required this.tabWidth,
    required this.indicatorColor,
    required this.duration,
  });

  final int currentIndex;
  final int tabCount;
  final double tabWidth;
  final Color indicatorColor;
  final Duration duration;

  @override
  State<_AnimatedTabIndicator> createState() => _AnimatedTabIndicatorState();
}

class _AnimatedTabIndicatorState extends State<_AnimatedTabIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _positionAnimation = Tween<double>(
      begin: widget.currentIndex * widget.tabWidth,
      end: widget.currentIndex * widget.tabWidth,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(_AnimatedTabIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex ||
        widget.tabWidth != oldWidget.tabWidth) {
      _positionAnimation = Tween<double>(
        begin: _positionAnimation.value,
        end: widget.currentIndex * widget.tabWidth,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      );
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _positionAnimation,
        builder: (context, child) => Transform.translate(
          offset: Offset(_positionAnimation.value, 0),
          child: Container(
            width: widget.tabWidth,
            height: 3,
            decoration: BoxDecoration(
              color: widget.indicatorColor,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ),
      );
}

/// 分段选择器动画
class _AnimatedSegmentedControl extends StatefulWidget {
  const _AnimatedSegmentedControl({
    required this.segments,
    required this.selectedIndex,
    required this.onChanged,
    required this.duration,
  });

  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Duration duration;

  @override
  State<_AnimatedSegmentedControl> createState() =>
      _AnimatedSegmentedControlState();
}

class _AnimatedSegmentedControlState extends State<_AnimatedSegmentedControl>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _positionAnimation = Tween<double>(
      begin: widget.selectedIndex.toDouble(),
      end: widget.selectedIndex.toDouble(),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(_AnimatedSegmentedControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _positionAnimation = Tween<double>(
        begin: _positionAnimation.value,
        end: widget.selectedIndex.toDouble(),
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      );
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _positionAnimation,
        builder: (context, child) => Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: List.generate(widget.segments.length, (index) {
              final isSelected = index == widget.selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => widget.onChanged(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      widget.segments[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.blue : Colors.grey[600],
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      );
}

/// 颜色选择器动画
class _AnimatedColorPicker extends StatefulWidget {
  const _AnimatedColorPicker({
    required this.colors,
    required this.selectedIndex,
    required this.onColorSelected,
    required this.duration,
  });

  final List<Color> colors;
  final int? selectedIndex;
  final ValueChanged<int> onColorSelected;
  final Duration duration;

  @override
  State<_AnimatedColorPicker> createState() => _AnimatedColorPickerState();
}

class _AnimatedColorPickerState extends State<_AnimatedColorPicker>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    if (widget.selectedIndex != null) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_AnimatedColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(widget.colors.length, (index) {
            final isSelected = index == widget.selectedIndex;
            return GestureDetector(
              onTap: () => widget.onColorSelected(index),
              child: Transform.scale(
                scale: isSelected ? _scaleAnimation.value : 1.0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.colors[index],
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            );
          }),
        ),
      );
}

/// 星级评分动画
class _AnimatedStarRating extends StatefulWidget {
  const _AnimatedStarRating({
    required this.rating,
    required this.maxRating,
    required this.onRatingChanged,
    required this.activeColor,
    required this.inactiveColor,
    required this.duration,
  });

  final int rating;
  final int maxRating;
  final ValueChanged<int> onRatingChanged;
  final Color activeColor;
  final Color inactiveColor;
  final Duration duration;

  @override
  State<_AnimatedStarRating> createState() => _AnimatedStarRatingState();
}

class _AnimatedStarRatingState extends State<_AnimatedStarRating>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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

    _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(_AnimatedStarRating oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rating != oldWidget.rating) {
      _controller.forward(from: 0.0);
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
        children: List.generate(widget.maxRating, (index) {
          final isActive = index < widget.rating;
          return GestureDetector(
            onTap: () => widget.onRatingChanged(index + 1),
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) => Transform.scale(
                scale: isActive ? _scaleAnimation.value : 1.0,
                child: Icon(
                  isActive ? Icons.star : Icons.star_border,
                  color: isActive ? widget.activeColor : widget.inactiveColor,
                  size: 32,
                ),
              ),
            ),
          );
        }),
      );
}

/// 步进器动画
class _AnimatedStepper extends StatefulWidget {
  const _AnimatedStepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.duration,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final Duration duration;

  @override
  State<_AnimatedStepper> createState() => _AnimatedStepperState();
}

class _AnimatedStepperState extends State<_AnimatedStepper>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.value = 1.0;
  }

  void _animateChange() {
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: widget.value > widget.min
                  ? () {
                      widget.onChanged(widget.value - 1);
                      _animateChange();
                    }
                  : null,
              icon: const Icon(Icons.remove),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Text(
                  widget.value.toString(),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            IconButton(
              onPressed: widget.value < widget.max
                  ? () {
                      widget.onChanged(widget.value + 1);
                      _animateChange();
                    }
                  : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      );
}

/// 开关切换动画
class _AnimatedSwitch extends StatefulWidget {
  const _AnimatedSwitch({
    required this.value,
    required this.onChanged,
    required this.activeColor,
    required this.duration,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Duration duration;

  @override
  State<_AnimatedSwitch> createState() => _AnimatedSwitchState();
}

class _AnimatedSwitchState extends State<_AnimatedSwitch>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<Color?> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _positionAnimation = Tween<double>(
      begin: widget.value ? 20 : 0,
      end: widget.value ? 20 : 0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _backgroundAnimation = ColorTween(
      begin: widget.value ? widget.activeColor : Colors.grey,
      end: widget.value ? widget.activeColor : Colors.grey,
    ).animate(_controller);

    _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(_AnimatedSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _positionAnimation = Tween<double>(
        begin: _positionAnimation.value,
        end: widget.value ? 20 : 0,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      );

      _backgroundAnimation = ColorTween(
        begin: _backgroundAnimation.value,
        end: widget.value ? widget.activeColor : Colors.grey,
      ).animate(_controller);

      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => widget.onChanged(!widget.value),
        child: AnimatedBuilder(
          animation:
              Listenable.merge([_positionAnimation, _backgroundAnimation]),
          builder: (context, child) => Container(
            width: 44,
            height: 24,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: _backgroundAnimation.value,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Transform.translate(
              offset: Offset(_positionAnimation.value, 0),
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      );
}

/// 范围滑块动画
class _AnimatedRangeSlider extends StatefulWidget {
  const _AnimatedRangeSlider({
    required this.values,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.duration,
  });

  final RangeValues values;
  final RangeValues min;
  final RangeValues max;
  final ValueChanged<RangeValues> onChanged;
  final Duration duration;

  @override
  State<_AnimatedRangeSlider> createState() => _AnimatedRangeSliderState();
}

class _AnimatedRangeSliderState extends State<_AnimatedRangeSlider>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<RangeValues> _valuesAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _valuesAnimation = Tween<RangeValues>(
      begin: widget.values,
      end: widget.values,
    ).animate(_controller);

    _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(_AnimatedRangeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.values != oldWidget.values) {
      _valuesAnimation = Tween<RangeValues>(
        begin: _valuesAnimation.value,
        end: widget.values,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      );
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _valuesAnimation,
        builder: (context, child) => RangeSlider(
          values: _valuesAnimation.value,
          min: widget.min.start,
          max: widget.max.end,
          onChanged: widget.onChanged,
        ),
      );
}

/// 级联选择器动画
class _AnimatedCascadingSelect extends StatefulWidget {
  const _AnimatedCascadingSelect({
    required this.options,
    required this.expandedStates,
    required this.onToggle,
    required this.duration,
  });

  final List<String> options;
  final List<bool> expandedStates;
  final ValueChanged<int> onToggle;
  final Duration duration;

  @override
  State<_AnimatedCascadingSelect> createState() =>
      _AnimatedCascadingSelectState();
}

class _AnimatedCascadingSelectState extends State<_AnimatedCascadingSelect>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _heightAnimations;
  late List<Animation<double>> _opacityAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void didUpdateWidget(_AnimatedCascadingSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options.length != oldWidget.options.length) {
      _disposeAnimations();
      _initializeAnimations();
    }
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.options.length,
      (index) => AnimationController(
        duration: widget.duration,
        vsync: this,
      ),
    );

    _heightAnimations = List.generate(
      widget.options.length,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _controllers[index],
          curve: Curves.easeInOut,
        ),
      ),
    );

    _opacityAnimations = List.generate(
      widget.options.length,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _controllers[index],
          curve: Curves.easeInOut,
        ),
      ),
    );

    for (var i = 0; i < widget.expandedStates.length; i++) {
      if (widget.expandedStates[i]) {
        _controllers[i].value = 1.0;
      }
    }
  }

  void _disposeAnimations() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
    _heightAnimations.clear();
    _opacityAnimations.clear();
  }

  @override
  void dispose() {
    _disposeAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        children: List.generate(widget.options.length, (index) {
          final isExpanded = widget.expandedStates[index];
          return Column(
            children: [
              ListTile(
                title: Text(widget.options[index]),
                trailing: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                ),
                onTap: () => widget.onToggle(index),
              ),
              if (index < _controllers.length)
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _heightAnimations[index],
                    _opacityAnimations[index],
                  ]),
                  builder: (context, child) => ClipRect(
                    child: Align(
                      heightFactor:
                          isExpanded ? _heightAnimations[index].value : 0.0,
                      child: Opacity(
                        opacity:
                            isExpanded ? _opacityAnimations[index].value : 0.0,
                        child: Container(
                          margin: const EdgeInsets.only(left: 16),
                          padding: const EdgeInsets.all(16),
                          color: Colors.grey[100],
                          child: const Text('子选项内容'),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      );
}

/// 过滤面板动画
class _AnimatedFilterPanel extends StatefulWidget {
  const _AnimatedFilterPanel({
    required this.child,
    required this.isOpen,
    required this.duration,
  });

  final Widget child;
  final bool isOpen;
  final Duration duration;

  @override
  State<_AnimatedFilterPanel> createState() => _AnimatedFilterPanelState();
}

class _AnimatedFilterPanelState extends State<_AnimatedFilterPanel>
    with TickerProviderStateMixin {
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
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    if (widget.isOpen) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_AnimatedFilterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
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
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([_slideAnimation, _opacityAnimation]),
        builder: (context, child) => Transform.translate(
          offset: _slideAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        ),
      );
}

/// 快速选择菜单动画
class _AnimatedQuickSelect extends StatefulWidget {
  const _AnimatedQuickSelect({
    required this.child,
    required this.isVisible,
    required this.position,
    required this.duration,
  });

  final Widget child;
  final bool isVisible;
  final Offset position;
  final Duration duration;

  @override
  State<_AnimatedQuickSelect> createState() => _AnimatedQuickSelectState();
}

class _AnimatedQuickSelectState extends State<_AnimatedQuickSelect>
    with TickerProviderStateMixin {
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
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_AnimatedQuickSelect oldWidget) {
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
  Widget build(BuildContext context) => widget.isVisible
      ? Positioned(
          left: widget.position.dx,
          top: widget.position.dy,
          child: AnimatedBuilder(
            animation: Listenable.merge([_scaleAnimation, _opacityAnimation]),
            builder: (context, child) => Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        )
      : const SizedBox.shrink();
}

/// 状态指示器颜色动画
class _AnimatedStatusIndicator extends StatefulWidget {
  const _AnimatedStatusIndicator({
    required this.status,
    required this.size,
    required this.duration,
  });

  final StatusType status;
  final double size;
  final Duration duration;

  @override
  State<_AnimatedStatusIndicator> createState() =>
      _AnimatedStatusIndicatorState();
}

/// 等级提升动画
class _AnimatedLevelUp extends StatefulWidget {
  const _AnimatedLevelUp({
    required this.child,
    required this.shouldAnimate,
    required this.duration,
  });

  final Widget child;
  final bool shouldAnimate;
  final Duration duration;

  @override
  State<_AnimatedLevelUp> createState() => _AnimatedLevelUpState();
}

class _AnimatedLevelUpState extends State<_AnimatedLevelUp>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.5),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.5, end: 1.2),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * 3.14159, // 360 degrees
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.bounceOut,
      ),
    );
  }

  @override
  void didUpdateWidget(_AnimatedLevelUp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldAnimate && !oldWidget.shouldAnimate) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge(
            [_scaleAnimation, _rotationAnimation, _slideAnimation]),
        builder: (context, child) => Transform.translate(
          offset: _slideAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: widget.child,
            ),
          ),
        ),
      );
}
