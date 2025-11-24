# UI Gallery 组件结构设计（方案C）

## 📐 新的编号体系

### 第一部分：基础组件（Foundation Components）
**编号规则：F1-F20**

### 第二部分：组合组件（Composite Components）
**编号规则：C1-C20**

---

## 第一部分：基础组件（Foundation Components）

### F1: Typography（排版系统）
**实现类：** `AppDesignTokens` (TextStyle 方法)
**说明：** 字体样式系统，不是组件，是设计令牌
- Large Title
- Title 1
- Headline
- Body
- Caption
- Label
- Subtitle
- Primary Value
- Card Title

### F2: Text Field（文本输入框）
**实现类：** `AppTextField` (`lib/core/widgets/app_text_field.dart`)
**基础组件聚合：** `TextField` + `Container` + `GestureDetector`
**说明：** iOS风格输入框，无边框，灰色填充背景

### F3: Primary Button（主按钮）
**实现类：** `AppPrimaryButton` (`lib/core/widgets/app_primary_button.dart`)
**基础组件聚合：** `AnimatedContainer` + `Text` + `Icon` + `CircularProgressIndicator`
**说明：** 56pt高度，按压动画，主题色背景

### F4: Switch（开关）
**实现类：** `AppSwitch` (`lib/core/widgets/app_selection_controls.dart`)
**基础组件聚合：** `CupertinoSwitch`
**说明：** iOS风格开关

### F5: Checkbox（复选框）
**实现类：** `AppCheckbox` (`lib/core/widgets/app_selection_controls.dart`)
**基础组件聚合：** `GestureDetector` + `AnimatedContainer` + `Icon`
**说明：** iOS风格复选框，圆形，选中动画

### F6: Segmented Control（分段选择器）
**实现类：** `AppSegmentedControl` (`lib/core/widgets/app_selection_controls.dart`)
**基础组件聚合：** `CupertinoSlidingSegmentedControl`
**说明：** iOS风格分段选择器

### F7: Tag（标签）
**实现类：** `AppTag` (`lib/core/widgets/app_tag.dart`)
**基础组件聚合：** `GestureDetector` + `Container` + `Text`
**说明：** iOS风格标签芯片

### F8: Card（卡片）
**实现类：** `AppCard` (`lib/core/widgets/app_card.dart`)
**基础组件聚合：** `Container` + `BoxDecoration` + `InkWell`
**说明：** iOS风格卡片容器

### F9: Shimmer（骨架屏）
**实现类：** `AppShimmer` (`lib/core/widgets/app_shimmer.dart`)
**基础组件聚合：** `Container` + `LinearGradient` + `AnimationController`
**说明：** 加载状态的骨架屏动画

### F10: Empty State（空状态）
**实现类：** `AppEmptyState` (`lib/core/widgets/app_empty_state.dart`)
**基础组件聚合：** `Column` + `Icon` + `Text` + `AppPrimaryButton`
**说明：** 空状态插画组件

### F11: Date Picker（日期选择器）
**实现类：** `AppTextField` + `CupertinoDatePicker` + `showCupertinoModalPopup`
**基础组件聚合：** F2 (AppTextField) + `CupertinoDatePicker` + `Modal`
**说明：** 基于 AppTextField 的日期选择器

### F12: Dropdown（下拉框）
**实现类：** `AppTextField` + `DropdownButtonFormField`
**基础组件聚合：** F2 (AppTextField) + `DropdownButtonFormField`
**说明：** 基于 AppTextField 视觉风格的下拉框

### F13: Bottom Navigation Bar（底部导航栏）
**实现类：** `AppBottomNavigationBar` (`lib/core/widgets/app_bottom_navigation_bar.dart`)
**基础组件聚合：** `Container` + `Row` + `Icon` + `Text`
**说明：** 自定义底部导航栏，支持 SharpProfessional 风格的底部指示线

---

## 第二部分：组合组件（Composite Components）

### C1: Core Data Card（核心数据卡片）
**实现类：** `CoreDataCard` (`lib/core/widgets/composite/core_data_card.dart`)
**基础组件聚合：** F8 (AppCard) + F1 (Typography: Primary Value, Subtitle) + CustomPainter (趋势图)
**说明：** 大字体主数值 + 副标题 + 可选趋势图，顶部3px强调线

### C2: Read-Only Result Row（只读结果展示行）
**实现类：** `ReadOnlyResultRow` (`lib/core/widgets/composite/read_only_result_row.dart`)
**基础组件聚合：** `Row` + F1 (Typography: Body, Subtitle)
**说明：** 左侧标签 + 右侧结果，无背景色块

### C3: Calculation Transparency Detail（计算透明度详情）
**实现类：** `CalculationTransparencyDetail` (`lib/core/widgets/composite/calculation_transparency_detail.dart`)
**基础组件聚合：** `Text` + F1 (Typography: Micro Caption)
**说明：** 显示计算的底层依据（基数、比例、税率）

### C4: Transaction Flow List Item（收支流水列表项）
**实现类：** `TransactionFlowListItem` (`lib/core/widgets/composite/transaction_flow_list_item.dart`)
**基础组件聚合：** `InkWell` + `Row` + `Container` (左侧颜色指示条) + `Icon` + F1 (Typography: Subtitle, Label, Primary Value)
**说明：** 左侧图标/分类 + 中间描述/账户 + 右侧金额（收入绿色，支出红色）

### C5: AI Natural Language Input（AI自然语言输入框）
**实现类：** `AINaturalLanguageInput` (`lib/core/widgets/composite/ai_natural_language_input.dart`)
**基础组件聚合：** F2 (AppTextField) + `IconButton` + F8 (AppCard) + `Text`
**说明：** 文本输入框 + 语音图标按钮 + AI解析结果预览区域

### C6: Chart Container Card（图表容器卡片）
**实现类：** `ChartContainerCard` (`lib/core/widgets/composite/chart_container_card.dart`)
**基础组件聚合：** F8 (AppCard) + F6 (AppSegmentedControl) + F1 (Typography: Subtitle) + Chart Widget
**说明：** 卡片顶部有标题/时间切换器，下方是图表区域

### C7: Asset Allocation Card（资产配置卡片）
**实现类：** `AssetAllocationCard` (`lib/core/widgets/composite/asset_allocation_card.dart`)
**基础组件聚合：** F8 (AppCard) + `Row` (堆叠条形图) + `Wrap` (图例) + F1 (Typography: Card Title, Label)
**说明：** 紧凑型水平堆叠条形图，替代圆饼图

### C8: Standard List Item（基础列表行）
**实现类：** `StandardListItem` (`lib/core/widgets/composite/standard_list_item.dart`)
**基础组件聚合：** `Container` + `Row` + F1 (Typography: Body)
**说明：** 所有列表行的基类，定义左右对齐、固定高度和间距

### C9: Navigable List Item（导航列表行）
**实现类：** `NavigableListItem` (`lib/core/widgets/composite/navigable_list_item.dart`)
**基础组件聚合：** C8 (StandardListItem) + `Icon` (CupertinoIcons.chevron_right) + `InkWell`
**说明：** 右侧有箭头，点击有波纹效果，用于导航

### C10: Read-Only Data List Item（只读数据列表行）
**实现类：** `ReadOnlyDataListItem` (`lib/core/widgets/composite/read_only_data_list_item.dart`)
**基础组件聚合：** C8 (StandardListItem) + F1 (Typography: Subtitle SemiBold)
**说明：** 无箭头，右侧数据使用 SemiBold + SecondaryTextColor

### C11: Switch Control List Item（开关控制列表行）
**实现类：** `SwitchControlListItem` (`lib/core/widgets/composite/switch_control_list_item.dart`)
**基础组件聚合：** C8 (StandardListItem) + F4 (AppSwitch) + F1 (Typography: Card Title)
**说明：** 右侧是开关，标题使用18pt SemiBold

### C12: Notification Banner（通知横幅）
**实现类：** `NotificationBanner` (`lib/core/widgets/composite/notification_banner.dart`)
**基础组件聚合：** `Container` + `Row` + `Icon` + `Text` + `IconButton` + F1 (Typography: Body)
**说明：** 位于页面顶部，带有关闭按钮，图标+文字

---

## 组件依赖关系图

```
基础组件层（Foundation）
├── F1: Typography (设计令牌)
├── F2: Text Field
├── F3: Primary Button
├── F4: Switch
├── F5: Checkbox
├── F6: Segmented Control
├── F7: Tag
├── F8: Card
├── F9: Shimmer
├── F10: Empty State
├── F11: Date Picker (基于 F2)
├── F12: Dropdown (基于 F2)
└── F13: Bottom Navigation Bar

组合组件层（Composite）
├── C1: Core Data Card (F8 + F1 + CustomPainter)
├── C2: Read-Only Result Row (F1)
├── C3: Calculation Transparency Detail (F1)
├── C4: Transaction Flow List Item (F1 + F8)
├── C5: AI Natural Language Input (F2 + F8)
├── C6: Chart Container Card (F8 + F6 + F1)
├── C7: Asset Allocation Card (F8 + F1)
├── C8: Standard List Item (F1)
├── C9: Navigable List Item (C8)
├── C10: Read-Only Data List Item (C8)
├── C11: Switch Control List Item (C8 + F4)
└── C12: Notification Banner (F1)
```

