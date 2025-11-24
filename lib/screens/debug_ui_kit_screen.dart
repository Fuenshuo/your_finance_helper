import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/providers/theme_provider.dart';
import 'package:your_finance_flutter/core/providers/theme_style_provider.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/core/widgets/app_empty_state.dart';
import 'package:your_finance_flutter/core/widgets/app_primary_button.dart';
import 'package:your_finance_flutter/core/widgets/app_selection_controls.dart';
import 'package:your_finance_flutter/core/widgets/app_shimmer.dart';
import 'package:your_finance_flutter/core/widgets/app_tag.dart';
import 'package:your_finance_flutter/core/widgets/app_text_field.dart';
import 'package:your_finance_flutter/core/widgets/composite/composite_styles.dart';

class DebugUIKitScreen extends StatefulWidget {
  const DebugUIKitScreen({super.key});

  @override
  State<DebugUIKitScreen> createState() => _DebugUIKitScreenState();
}

class _DebugUIKitScreenState extends State<DebugUIKitScreen> {
  bool _switchValue = false;
  bool _switchValue2 = false;
  bool _checkboxValue = false;
  String? _selectedPeriod;
  DateTime? _selectedDate;
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: '2024-01-15');
    _selectedDate = DateTime(2024, 1, 15);
    // 确保 ThemeStyleProvider 已初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeStyleProvider =
          Provider.of<ThemeStyleProvider>(context, listen: false);
      if (!themeStyleProvider.isInitialized) {
        themeStyleProvider.initialize();
      }
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 使用 Grouped Background (高级灰)
    return Scaffold(
      backgroundColor: AppDesignTokens.pageBackground(context),
      appBar: AppBar(
        title: const Text('Design System 2.0'),
        backgroundColor: AppDesignTokens.pageBackground(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppDesignTokens.headline(context),
        iconTheme: IconThemeData(color: AppDesignTokens.primaryAction(context)),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              // If there's nothing to pop, navigate to home or root
              context.go('/');
            }
          },
          tooltip: '返回',
        ),
        automaticallyImplyLeading: false, // 禁用自动返回按钮，使用自定义的
        actions: [
          // 主题选择器
          Consumer<ThemeStyleProvider>(
            builder: (context, themeStyleProvider, child) =>
                PopupMenuButton<AppTheme>(
              icon: Icon(
                CupertinoIcons.paintbrush,
                color: AppDesignTokens.primaryAction(context),
              ),
              tooltip: '选择主题',
              onSelected: (theme) {
                themeStyleProvider.setTheme(theme);
              },
              itemBuilder: (context) => AppTheme.values.map((theme) {
                final colors = AppDesignTokens.getThemeColors(theme);
                return PopupMenuItem<AppTheme>(
                  value: theme,
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: colors['primary'],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: theme == themeStyleProvider.currentTheme
                                ? AppDesignTokens.primaryAction(context)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        themeStyleProvider.getThemeDisplayName(theme),
                        style: AppDesignTokens.body(context).copyWith(
                          fontWeight: theme == themeStyleProvider.currentTheme
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          // 风格选择器
          Consumer<ThemeStyleProvider>(
            builder: (context, themeStyleProvider, child) =>
                PopupMenuButton<AppStyle>(
              icon: Icon(
                CupertinoIcons.square_grid_2x2,
                color: AppDesignTokens.primaryAction(context),
              ),
              tooltip: '选择风格',
              onSelected: (style) {
                themeStyleProvider.setStyle(style);
              },
              itemBuilder: (context) => AppStyle.values
                  .map(
                    (style) => PopupMenuItem<AppStyle>(
                      value: style,
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: style == AppStyle.iOSFintech
                                  ? AppDesignTokens.primaryAction(context)
                                  : AppDesignTokens.secondaryText(context),
                              borderRadius: BorderRadius.circular(
                                style == AppStyle.iOSFintech ? 16 : 8,
                              ),
                              border: Border.all(
                                color: style == themeStyleProvider.currentStyle
                                    ? AppDesignTokens.primaryAction(context)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            themeStyleProvider.getStyleDisplayName(style),
                            style: AppDesignTokens.body(context).copyWith(
                              fontWeight:
                                  style == themeStyleProvider.currentStyle
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          // 深色/浅色模式切换
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) => IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
              tooltip: themeProvider.isDarkMode ? '切换到浅色模式' : '切换到深色模式',
            ),
          ),
        ],
      ),
      body: Consumer<ThemeStyleProvider>(
        builder: (context, themeStyleProvider, child) {
          // 当主题或风格改变时，重建整个UI
          return ListView(
            padding: const EdgeInsets.all(AppDesignTokens.spacing24),
            children: [
              // ============================================
              // 第一部分：基础组件（Foundation Components）
              // ============================================
              _buildSectionHeader(
                context,
                'Part I: Foundation Components (基础组件)',
                isMainSection: true,
              ),

              // F1: Typography（排版系统）
              _buildComponentHeader(
                context,
                'F1: Typography (排版系统)',
                '实现类：AppDesignTokens (TextStyle 方法)',
                '说明：字体样式系统，不是组件，是设计令牌',
              ),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Large Title',
                      style: AppDesignTokens.largeTitle(context),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Title 1 Header',
                      style: AppDesignTokens.title1(context),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Card Title (18pt SemiBold)',
                      style: AppDesignTokens.cardTitle(context),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Headline Text',
                      style: AppDesignTokens.headline(context),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Body text should be breathable and easy to read. line-height is adjusted to 1.4 for better readability.',
                      style: AppDesignTokens.body(context),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Subtitle (14pt Regular)',
                      style: AppDesignTokens.subtitle(context),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Label (12pt Regular)',
                      style: AppDesignTokens.label(context),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Caption / Secondary text',
                      style: AppDesignTokens.caption(context),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Primary Value (26pt Bold)',
                      style: AppDesignTokens.primaryValue(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDesignTokens.spacingMajor),

              // F2: Text Field（文本输入框）
              _buildComponentHeader(
                context,
                'F2: Text Field (文本输入框)',
                '实现类：AppTextField (lib/core/widgets/app_text_field.dart)',
                '基础组件聚合：TextField + Container + GestureDetector',
              ),
              const AppCard(
                child: Column(
                  children: [
                    AppTextField(
                      labelText: 'Username',
                      hintText: 'Enter your username',
                      prefixIcon: Icon(CupertinoIcons.person),
                    ),
                    SizedBox(height: 16),
                    AppTextField(
                      labelText: 'Password',
                      hintText: 'Enter secure password',
                      obscureText: true,
                      prefixIcon: Icon(CupertinoIcons.lock),
                      suffixIcon: Icon(CupertinoIcons.eye),
                    ),
                    SizedBox(height: 16),
                    AppTextField(
                      labelText: 'Error State',
                      hintText: 'Wrong value',
                      errorText: 'This field is required',
                      prefixIcon: Icon(CupertinoIcons.exclamationmark_circle),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDesignTokens.spacingMajor),

              // F3: Primary Button（主按钮）
              _buildComponentHeader(
                context,
                'F3: Primary Button (主按钮)',
                '实现类：AppPrimaryButton (lib/core/widgets/app_primary_button.dart)',
                '基础组件聚合：AnimatedContainer + Text + Icon + CircularProgressIndicator',
              ),
              AppPrimaryButton(
                label: 'Primary Action',
                onPressed: () {},
              ),
              const SizedBox(height: AppDesignTokens.spacingMedium),
              AppPrimaryButton(
                label: 'Loading State',
                isLoading: true,
                onPressed: () {},
              ),
              const SizedBox(height: AppDesignTokens.spacingMedium),
              AppPrimaryButton(
                label: 'With Icon',
                icon: CupertinoIcons.add,
                onPressed: () {},
              ),
              const SizedBox(height: AppDesignTokens.spacingMedium),
              AppPrimaryButton(
                label: 'Disabled',
                isEnabled: false,
                onPressed: () {},
              ),

              const SizedBox(height: AppDesignTokens.spacingMajor),

              // F4: Switch（开关）
              _buildComponentHeader(
                context,
                'F4: Switch (开关)',
                '实现类：AppSwitch (lib/core/widgets/app_selection_controls.dart)',
                '基础组件聚合：CupertinoSwitch',
              ),
              AppCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Enable Notifications',
                      style: AppDesignTokens.body(context),
                    ),
                    AppSwitch(
                      value: _switchValue,
                      onChanged: (value) =>
                          setState(() => _switchValue = value),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDesignTokens.spacingMajor),

              // F5: Checkbox（复选框）
              _buildComponentHeader(
                context,
                'F5: Checkbox (复选框)',
                '实现类：AppCheckbox (lib/core/widgets/app_selection_controls.dart)',
                '基础组件聚合：GestureDetector + AnimatedContainer + Icon',
              ),
              AppCard(
                child: AppCheckbox(
                  value: _checkboxValue,
                  onChanged: (value) => setState(() => _checkboxValue = value),
                  label: 'Remember me',
                ),
              ),

              const SizedBox(height: AppDesignTokens.spacingMajor),

              // F6: Segmented Control（分段选择器）
              _buildComponentHeader(
                context,
                'F6: Segmented Control (分段选择器)',
                '实现类：AppSegmentedControl (lib/core/widgets/app_selection_controls.dart)',
                '基础组件聚合：CupertinoSlidingSegmentedControl',
              ),
              AppCard(
                child: AppSegmentedControl<String>(
                  children: const {
                    'day': Text('日'),
                    'week': Text('周'),
                    'month': Text('月'),
                  },
                  groupValue: _selectedPeriod,
                  onValueChanged: (value) =>
                      setState(() => _selectedPeriod = value),
                ),
              ),

              const SizedBox(height: AppDesignTokens.spacingMajor),

              // F7: Tag（标签）
              _buildComponentHeader(
                context,
                'F7: Tag (标签)',
                '实现类：AppTag (lib/core/widgets/app_tag.dart)',
                '基础组件聚合：GestureDetector + Container + Text',
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  const AppTag(label: '餐饮'),
                  const AppTag(label: '交通', isSelected: true),
                  AppTag(
                    label: '购物',
                    color: AppDesignTokens.successColor(context),
                  ),
                  const AppTag(
                    label: '娱乐',
                    color: AppDesignTokens.warningColor,
                  ),
                  AppTag(label: '医疗', color: AppDesignTokens.errorColor),
                ],
              ),

              const SizedBox(height: AppDesignTokens.spacingMajor),

              // F8: Card（卡片）
              _buildComponentHeader(
                context,
                'F8: Card (卡片)',
                '实现类：AppCard (lib/core/widgets/app_card.dart)',
                '基础组件聚合：Container + BoxDecoration + InkWell',
              ),
              AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppDesignTokens.primaryAction(context)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        CupertinoIcons.chart_pie_fill,
                        color: AppDesignTokens.primaryAction(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Asset Overview',
                          style: AppDesignTokens.headline(context),
                        ),
                        Text(
                          'Updated just now',
                          style: AppDesignTokens.caption(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDesignTokens.spacingMajor),

              // F9: Shimmer（骨架屏）
              _buildComponentHeader(
                context,
                'F9: Shimmer (骨架屏)',
                '实现类：AppShimmer (lib/core/widgets/app_shimmer.dart)',
                '基础组件聚合：Container + LinearGradient + AnimationController',
              ),
              AppCard(
                child: Column(
                  children: [
                    AppShimmer.text(),
                    const SizedBox(height: 12),
                    AppShimmer.text(width: 200),
                    const SizedBox(height: 12),
                    AppShimmer.text(width: 150),
                    const SizedBox(height: AppDesignTokens.spacingMedium),
                    Row(
                      children: [
                        AppShimmer.circle(size: 48),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppShimmer.text(),
                              const SizedBox(height: 8),
                              AppShimmer.text(width: 120, height: 12),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDesignTokens.spacingMedium),
                    AppShimmer(
                      width: double.infinity,
                      height: 100,
                      radius: AppDesignTokens.radiusMedium(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDesignTokens.spacingMajor),

              // F10: Empty State（空状态）
              _buildComponentHeader(
                context,
                'F10: Empty State (空状态)',
                '实现类：AppEmptyState (lib/core/widgets/app_empty_state.dart)',
                '基础组件聚合：Column + Icon + Text + AppPrimaryButton',
              ),
              ConstrainedBox(
                constraints:
                    const BoxConstraints(minHeight: 200, maxHeight: 300),
                child: AppEmptyState(
                  icon: CupertinoIcons.doc_text,
                  title: '暂无交易记录',
                  subtitle: '点击下方按钮添加第一笔交易',
                  actionLabel: '添加交易',
                  onAction: () {},
                ),
              ),

              const SizedBox(height: AppDesignTokens.spacingMajor),

              // F11: Date Picker（日期选择器）
              _buildComponentHeader(
                context,
                'F11: Date Picker (日期选择器)',
                '实现类：AppTextField + CupertinoDatePicker + showCupertinoModalPopup',
                '基础组件聚合：F2 (AppTextField) + CupertinoDatePicker + Modal',
              ),
              AppTextField(
                labelText: '选择日期',
                hintText: '请选择日期',
                readOnly: true,
                prefixIcon: const Icon(CupertinoIcons.calendar),
                controller: _dateController,
                onTap: () async {
                  // 显示 iOS 风格的日期选择器（带完成按钮）
                  DateTime? tempSelectedDate = _selectedDate ?? DateTime.now();

                  await showCupertinoModalPopup<void>(
                    context: context,
                    builder: (context) => Container(
                      height: 300,
                      padding: const EdgeInsets.only(top: 6.0),
                      margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      color:
                          CupertinoColors.systemBackground.resolveFrom(context),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          children: [
                            // 顶部工具栏（完成/取消按钮）
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: CupertinoColors.separator
                                        .resolveFrom(context),
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('取消'),
                                  ),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      final selectedDate = tempSelectedDate;
                                      if (selectedDate != null) {
                                        setState(() {
                                          _selectedDate = selectedDate;
                                          _dateController.text =
                                              '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
                                        });
                                      }
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      '完成',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 日期选择器
                            Expanded(
                              child: CupertinoDatePicker(
                                initialDateTime:
                                    _selectedDate ?? DateTime.now(),
                                mode: CupertinoDatePickerMode.date,
                                minimumDate: DateTime(2020),
                                maximumDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                                use24hFormat: true,
                                onDateTimeChanged: (newDate) {
                                  tempSelectedDate = newDate;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppDesignTokens.spacingMajor),

              // F12: Dropdown（下拉框）
              _buildComponentHeader(
                context,
                'F12: Dropdown (下拉框)',
                '实现类：AppTextField + DropdownButtonFormField',
                '基础组件聚合：F2 (AppTextField) + DropdownButtonFormField',
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppDesignTokens.inputFill(context),
                  borderRadius: BorderRadius.circular(
                    AppDesignTokens.radiusMedium(context),
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: '选择项',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    suffixIcon: Icon(CupertinoIcons.chevron_down),
                  ),
                  initialValue: 'option1',
                  items: const [
                    DropdownMenuItem(value: 'option1', child: Text('选项1')),
                    DropdownMenuItem(value: 'option2', child: Text('选项2')),
                    DropdownMenuItem(value: 'option3', child: Text('选项3')),
                  ],
                  onChanged: (value) {},
                ),
              ),

              const SizedBox(height: AppDesignTokens.spacingMajor * 2),

              // ============================================
              // 第二部分：组合组件（Composite Components）
              // ============================================
              _buildSectionHeader(
                context,
                'Part II: Composite Components (组合组件)',
                isMainSection: true,
              ),

              // C1: Core Data Card（核心数据卡片）
              _buildComponentHeader(
                context,
                'C1: Core Data Card (核心数据卡片)',
                '实现类：CoreDataCard (lib/core/widgets/composite/core_data_card.dart)',
                '基础组件聚合：F8 (AppCard) + F1 (Typography: Primary Value, Subtitle) + CustomPainter (趋势图)',
              ),
              const CoreDataCard(
                subtitle: '总净资产',
                value: 54655.80,
              ),
              const SizedBox(height: AppDesignTokens.spacingMedium),
              const CoreDataCard(
                subtitle: '月度净收入',
                value: 12345.67,
                trendData: [10000, 11000, 10500, 12000, 11500, 12345],
              ),

              const SizedBox(height: AppDesignTokens.spacingMajor),

              // C2: Read-Only Result Row（只读结果展示行）
              _buildComponentHeader(
                context,
                'C2: Read-Only Result Row (只读结果展示行)',
                '实现类：ReadOnlyResultRow (lib/core/widgets/composite/read_only_result_row.dart)',
                '基础组件聚合：Row + F1 (Typography: Body, Subtitle)',
              ),
              const AppCard(
                child: Column(
                  children: [
                    ReadOnlyResultRow(
                      label: '社保（五险）',
                      amount: 1234.56,
                    ),
                    SizedBox(height: AppDesignTokens.spacingMedium),
                    ReadOnlyResultRow(
                      label: '公积金',
                      amount: 567.89,
                    ),
                    SizedBox(height: AppDesignTokens.spacingMedium),
                    ReadOnlyResultRow(
                      label: '个人所得税',
                      amount: 890.12,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDesignTokens.spacingMajor),

              // C3: Calculation Transparency Detail（计算透明度详情）
              _buildComponentHeader(
                context,
                'C3: Calculation Transparency Detail (计算透明度详情)',
                '实现类：CalculationTransparencyDetail (lib/core/widgets/composite/calculation_transparency_detail.dart)',
                '基础组件聚合：Text + F1 (Typography: Micro Caption)',
              ),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ReadOnlyResultRow(
                      label: '社保（五险）',
                      amount: 1234.56,
                    ),
                    const SizedBox(height: AppDesignTokens.spacingMinor),
                    CalculationTransparencyDetail(
                      text: '基数：¥${12345.67.toStringAsFixed(2)}；比例：10.0%',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDesignTokens.spacingMajor),

              // C4: Transaction Flow List Item（收支流水列表项）
              _buildComponentHeader(
                context,
                'C4: Transaction Flow List Item (收支流水列表项)',
                '实现类：TransactionFlowListItem (lib/core/widgets/composite/transaction_flow_list_item.dart)',
                '基础组件聚合：InkWell + Row + Container (左侧颜色指示条) + Icon + F1 (Typography: Subtitle, Label, Primary Value)',
              ),
              AppCard(
                child: Column(
                  children: [
                    TransactionFlowListItem(
                      icon: CupertinoIcons.cart,
                      categoryName: '餐饮',
                      accountName: '支付宝',
                      amount: 128.50,
                      isIncome: false,
                      categoryColor: AppDesignTokens.errorColor,
                    ),
                    const SizedBox(height: AppDesignTokens.spacing12),
                    TransactionFlowListItem(
                      icon: CupertinoIcons.money_dollar_circle,
                      categoryName: '工资',
                      accountName: '招商银行',
                      amount: 15000.00,
                      isIncome: true,
                      categoryColor: AppDesignTokens.successColor(context),
                    ),
                    const SizedBox(height: AppDesignTokens.spacing12),
                    const TransactionFlowListItem(
                      icon: CupertinoIcons.car,
                      categoryName: '交通',
                      accountName: '微信支付',
                      amount: 45.20,
                      isIncome: false,
                      categoryColor: AppDesignTokens.warningColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDesignTokens.spacingMajor),

              // C5: AI Natural Language Input（AI自然语言输入框）
              _buildComponentHeader(
                context,
                'C5: AI Natural Language Input (AI自然语言输入框)',
                '实现类：AINaturalLanguageInput (lib/core/widgets/composite/ai_natural_language_input.dart)',
                '基础组件聚合：F2 (AppTextField) + IconButton + F8 (AppCard) + Text',
              ),
              AINaturalLanguageInput(
                labelText: 'AI 记账',
                onVoiceInput: () {},
                aiPreview: '金额：¥35.00 | 分类：餐饮 | 账户：支付宝',
              ),

              const SizedBox(height: AppDesignTokens.spacingMajor),

              // C6: Chart Container Card（图表容器卡片）
              _buildComponentHeader(
                context,
                'C6: Chart Container Card (图表容器卡片)',
                '实现类：ChartContainerCard (lib/core/widgets/composite/chart_container_card.dart)',
                '基础组件聚合：F8 (AppCard) + F6 (AppSegmentedControl) + F1 (Typography: Subtitle) + Chart Widget',
              ),
              ChartContainerCard<String>(
                title: '月度净收入',
                segmentedControlChildren: const {
                  'month': Text('月'),
                  'year': Text('年'),
                },
                segmentedControlValue: 'month',
                onSegmentedControlChanged: (_) {},
                chart: Container(
                  decoration: BoxDecoration(
                    color: AppDesignTokens.inputFill(context),
                    borderRadius: BorderRadius.circular(
                      AppDesignTokens.radiusMedium(context),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '图表区域（Chart Widget）',
                      style: AppDesignTokens.caption(context),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDesignTokens.spacingMajor),

              // C7: Asset Allocation Card（资产配置卡片）
              _buildComponentHeader(
                context,
                'C7: Asset Allocation Card (资产配置卡片)',
                '实现类：AssetAllocationCard (lib/core/widgets/composite/asset_allocation_card.dart)',
                '基础组件聚合：F8 (AppCard) + Row (堆叠条形图) + Wrap (图例) + F1 (Typography: Card Title, Label)',
              ),
              const AssetAllocationCard(
                title: '资产组成',
                allocationData: {
                  '流动资产': 20000.0,
                  '房产': 300000.0,
                  '投资': 150000.0,
                  '消费资产': 5000.0,
                },
                totalAssets: 475000.0,
              ),

              const SizedBox(height: AppDesignTokens.spacingMajor),

              // C8: Standard List Item（基础列表行）
              _buildComponentHeader(
                context,
                'C8: Standard List Item (基础列表行)',
                '实现类：StandardListItem (lib/core/widgets/composite/standard_list_item.dart) - 抽象基类',
                '基础组件聚合：Container + Row + F1 (Typography: Body)',
              ),
              AppCard(
                child: Column(
                  children: [
                    // 使用 NavigableListItem 展示基础列表行的特性
                    NavigableListItem(
                      title: '基础列表行示例（通过 NavigableListItem）',
                      leading: Icon(
                        CupertinoIcons.info,
                        color: AppDesignTokens.primaryAction(context),
                      ),
                      trailingContent: Text(
                        '右侧内容',
                        style: AppDesignTokens.body(context),
                      ),
                      showArrow: false, // 不显示箭头，展示基础形态
                    ),
                    Divider(
                      height: 1,
                      color: AppDesignTokens.dividerColor(context),
                    ),
                    // 使用 ReadOnlyDataListItem 展示另一种基础形态
                    const ReadOnlyDataListItem(
                      title: '基础列表行示例（通过 ReadOnlyDataListItem）',
                      amount: 1234.56,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDesignTokens.spacingMajor),

              // C9: Navigable List Item（导航列表行）
              _buildComponentHeader(
                context,
                'C9: Navigable List Item (导航列表行)',
                '实现类：NavigableListItem (lib/core/widgets/composite/navigable_list_item.dart)',
                '基础组件聚合：C8 (StandardListItem) + Icon (CupertinoIcons.chevron_right) + InkWell',
              ),
              AppCard(
                child: Column(
                  children: [
                    NavigableListItem(
                      title: '交易分类',
                      leading: Icon(
                        CupertinoIcons.tag,
                        color: AppDesignTokens.primaryAction(context),
                      ),
                      trailingContent: Text(
                        '餐饮',
                        style: AppDesignTokens.body(context).copyWith(
                          color: AppDesignTokens.secondaryText(context),
                        ),
                      ),
                      onTap: () {},
                    ),
                    Divider(
                      height: 1,
                      color: AppDesignTokens.dividerColor(context),
                    ),
                    NavigableListItem(
                      title: '账户选择',
                      leading: Icon(
                        CupertinoIcons.creditcard,
                        color: AppDesignTokens.primaryAction(context),
                      ),
                      trailingContent: Text(
                        '招商银行',
                        style: AppDesignTokens.body(context).copyWith(
                          color: AppDesignTokens.secondaryText(context),
                        ),
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDesignTokens.spacingMajor),

              // C10: Read-Only Data List Item（只读数据列表行）
              _buildComponentHeader(
                context,
                'C10: Read-Only Data List Item (只读数据列表行)',
                '实现类：ReadOnlyDataListItem (lib/core/widgets/composite/read_only_data_list_item.dart)',
                '基础组件聚合：C8 (StandardListItem) + F1 (Typography: Subtitle SemiBold)',
              ),
              AppCard(
                child: Column(
                  children: [
                    const ReadOnlyDataListItem(
                      title: '阅读净收入',
                      amount: 54655.80,
                    ),
                    Divider(
                      height: 1,
                      color: AppDesignTokens.dividerColor(context),
                    ),
                    const ReadOnlyDataListItem(
                      title: 'AI 解析结果',
                      customValueText: '¥35.00 | 餐饮 | 支付宝',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDesignTokens.spacingMajor),

              // C11: Switch Control List Item（开关控制列表行）
              _buildComponentHeader(
                context,
                'C11: Switch Control List Item (开关控制列表行)',
                '实现类：SwitchControlListItem (lib/core/widgets/composite/switch_control_list_item.dart)',
                '基础组件聚合：C8 (StandardListItem) + F4 (AppSwitch) + F1 (Typography: Card Title)',
              ),
              AppCard(
                child: Column(
                  children: [
                    SwitchControlListItem(
                      title: '开启计划关联',
                      value: _switchValue,
                      onChanged: (value) {
                        setState(() {
                          _switchValue = value;
                        });
                      },
                    ),
                    Divider(
                      height: 1,
                      color: AppDesignTokens.dividerColor(context),
                    ),
                    SwitchControlListItem(
                      title: '通知设置',
                      value: _switchValue2,
                      onChanged: (value) {
                        setState(() {
                          _switchValue2 = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDesignTokens.spacingMajor),

              // C12: Notification Banner（通知横幅）
              _buildComponentHeader(
                context,
                'C12: Notification Banner (通知横幅)',
                '实现类：NotificationBanner (lib/core/widgets/composite/notification_banner.dart)',
                '基础组件聚合：Container + Row + Icon + Text + IconButton + F1 (Typography: Body)',
              ),
              Column(
                children: [
                  NotificationBanner(
                    type: NotificationBannerType.success,
                    message: '操作成功',
                    onDismiss: () {},
                  ),
                  const SizedBox(height: AppDesignTokens.spacing12),
                  NotificationBanner(
                    type: NotificationBannerType.warning,
                    message: 'Policy Data Service 更新失败，请检查网络连接',
                    onDismiss: () {},
                  ),
                  const SizedBox(height: AppDesignTokens.spacing12),
                  NotificationBanner(
                    type: NotificationBannerType.error,
                    message: '数据加载失败，请重试',
                    onDismiss: () {},
                  ),
                ],
              ),

              const SizedBox(height: 50),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    bool isMainSection = false,
  }) =>
      Padding(
        padding: EdgeInsets.only(
          bottom: isMainSection ? 24 : 16,
          top: isMainSection ? 8 : 0,
        ),
        child: Text(
          title,
          style: AppDesignTokens.headline(context).copyWith(
            color: AppDesignTokens.body(context).color!.withOpacity(0.7),
            fontSize: isMainSection ? 20 : 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      );

  Widget _buildComponentHeader(
    BuildContext context,
    String title,
    String implementation,
    String description,
  ) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12, top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppDesignTokens.headline(context).copyWith(
                color: AppDesignTokens.body(context).color!.withOpacity(0.6),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              implementation,
              style: AppDesignTokens.caption(context).copyWith(
                color: AppDesignTokens.secondaryText(context),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: AppDesignTokens.caption(context).copyWith(
                color: AppDesignTokens.secondaryText(context).withOpacity(0.8),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
}
