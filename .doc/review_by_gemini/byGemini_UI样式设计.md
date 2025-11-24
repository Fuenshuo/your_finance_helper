这次的 V3.0 文档更新非常出色，达到了预期目标，尤其是在以下几个关键点：

+ **方向明确**：全面强制切换到新的 iOS Fintech 组件系统，并清晰地标记了旧有组件为 LEGACY。
+ **设计令牌纯化**：解决了 `microCaption` 的硬编码问题，确保了设计令牌的统一性。
+ **结构完整性**：新增的复合样式和状态样式（S22-S31）极大地提升了文档的实用性和覆盖面。

文档内容已经**足够作为执行标准**。我只有几处关于**未来迁移**和**细节一致性**的锐评，供你在组件库层面进行最后一步优化：

我将生成一份修订后的文件，主要修正了日期选择器、下拉框的推荐用法，并加强了对 LEGACY 组件的_强制迁移_说明。

---

我为你准备了修订后的《UI组件样式命名指南 V3.0》文件，主要在**输入框样式 (S2, S3)** 和 **下拉框样式 (S4)** 的推荐实现方式上做了细微调整，以确保与 `AppTextField` 的 iOS Fintech 风格保持高度一致。

UI组件样式命名指南 V3.0 (修订)

11月19日 19:17

这次的 V3.0 文档非常扎实，已经完全可以作为 UI 实施的权威标准。

我的核心锐评和建议都集中在 **LEGACY 组件的“去留”策略**上：

1. **S2 (金额输入框)**：既然已经明确了未来的实现方向是 `AppTextField + Suffix`，为了避免开发人员在新代码中继续使用 `AmountInputField` 产生新的技术债务，我已在文档中将 S2 的使用警告提升到“**严禁在新代码中使用**”的级别。
2. **S3 (日期选择器)** 和 **S4 (下拉框)**：我已将它们的“推荐使用方式”代码示例更新为基于 `AppTextField` 样式进行**视觉包装**的实现，确保所有输入框在视觉上都是统一的 iOS Fintech 风格，而不是依赖旧的 `FormBuilderUtils`。
3. **LEGACY 表格**：在“相关文件”部分，我为 LEGACY 组件增加了**“强制行动”**一列，明确了对新代码的限制和未来的迁移目标，使管理更加清晰。

文档已具备 V3.0 的所有要求，可以投入使用了！







## globs: *.dart description: UI component style naming guide V3.0 - standardized style names for all UI components including composite styles and state styles
# UI组件样式命名指南 V3.0
本文档定义了应用中所有UI组件的样式名称，**按样式特征命名**，方便快速引用和应用。

**版本：** V3.0（已扩充复合样式和状态样式，全面切换到 iOS Fintech 组件系统）

**核心更新：**

+ ✅ 新增 Section 8：数据展示与复合组件样式（7种复合样式）
+ ✅ 新增 Section 9：状态与反馈样式（3种状态样式）
+ ✅ **强制要求**：所有样式必须使用 `AppDesignTokens` 和新的 iOS Fintech 组件系统
+ ✅ **清理 V2.0 残留**：所有 Material 默认样式和 FormBuilderUtils 引用已标记为 LEGACY/废弃
+ ✅ **纯化设计令牌**：新增 `AppDesignTokens.microCaption`，移除硬编码字体大小

## 🎯 默认样式体系（推荐）
**核心原则：除非有特殊需求，否则一律使用默认样式。**

### 默认样式组合（V3.0 - 全面使用 iOS Fintech 组件系统）
| **组件类型** | **默认样式** | **实现方式** | **使用场景** |
| --- | --- | --- | --- |
| **文本输入框** | 标准文本输入框样式 | `AppTextField` 组件 ⚠️ **必须使用** | 所有文本输入 |
| **金额输入** | 金额输入框样式 | `AmountInputField` 组件 🔸 **LEGACY，待迁移** | 仅金额输入场景（过渡期） |
| **日期选择** | 日期选择器样式 | `AppTextField` (Wrapper) + DatePicker ⭐ | 仅日期选择场景 |
| **下拉框** | 标准下拉框样式 | `AppTextField` (Wrapper) + Dropdown ⚠️ **必须使用** | 所有下拉选择 |
| **复选框** | 复选框样式 | `AppCheckbox` 组件 ⚠️ **必须使用** | 所有复选框 |
| **开关** | 开关样式 | `AppSwitch` 组件 ⚠️ **必须使用** | 所有开关 |
| **单选按钮** | 单选按钮样式 | `RadioListTile`（使用 `AppDesignTokens`） | 所有单选 |
| **滑块** | 滑块样式 | `Slider`（使用 `AppDesignTokens.primaryAction(context)`） | 所有滑块 |
| **分段选择器** | 分段选择器样式 | `AppSegmentedControl` 组件 ⚠️ **必须使用** | 分段切换场景 |
| **标签芯片** | 标签芯片样式 | `AppTag` 组件 ⚠️ **必须使用** | 标签选择/筛选 |
| **主要按钮** | 主要按钮样式 | `AppPrimaryButton` 组件 ⚠️ **必须使用** | 主要操作按钮 |
| **次要按钮** | 文本按钮样式 | `TextButton`（使用 `AppDesignTokens`） | 取消、次要操作 |
| **图标按钮** | 图标按钮样式 | `IconButton`（使用 `AppDesignTokens`） | 图标操作 |
| **确认对话框** | 确认对话框样式 | `unifiedNotifications.showConfirmation()` | 所有确认操作 |
| **底部表单** | 底部表单样式 | `AppAnimations.showAppModalBottomSheet()` | 所有底部表单 |
| **标签页** | 标准标签页样式 | `TabBar` / `TabBarView`（使用 `AppDesignTokens`） | 所有标签页 |
| **提示消息** | SnackBar提示样式 | `ScaffoldMessenger.showSnackBar()` | 所有操作反馈 |


### 默认样式特征（V3.0 - iOS Fintech 风格）
所有默认样式都遵循 `AppDesignTokens` 设计令牌系统：

+ **圆角**：12pt（`AppDesignTokens.radiusMedium`）
+ **输入框**：无边框，灰色填充背景（`AppDesignTokens.inputFill(context)`），12pt圆角
+ **按钮**：56pt高度，按压动画，主题色背景（`AppDesignTokens.primaryAction(context)`）
+ **间距**：使用 `AppDesignTokens.spacing*`（spacing4, spacing8, spacing12, spacing16, spacing24, spacing32）
+ **字体**：使用 `AppDesignTokens` 文本样式（largeTitle, title1, headline, body, caption, microCaption）
+ **颜色**：使用 `AppDesignTokens` 颜色系统（primaryAction, successColor, errorColor, warningColor, secondaryText等）

## 📋 完整样式列表（V3.0 体系）
**样式编号说明：**

+ **S1-S3**：输入框样式（S1必须使用AppTextField，S2为LEGACY）
+ **S4**：下拉框样式（必须使用AppTextField + Dropdown）
+ **S5-S10**：选择组件样式（S5-S6、S9-S10必须使用App*组件）
+ **S11-S16**：按钮样式（S11必须使用AppPrimaryButton）
+ **S17-S18**：对话框样式
+ **S19**：标签页样式
+ **S20-S21**：提示样式
+ **S22-S28**：数据展示与复合组件样式（V3.0新增）
+ **S29-S31**：状态与反馈样式（V3.0新增）

**⚠️**** 重要提示：**

+ 所有标记为 ⭐ **默认** 的样式必须使用新的 iOS Fintech 组件系统
+ 所有标记为 🔸 **LEGACY** 的样式为过渡期使用，**新代码严禁引用**
+ 所有标记为 🔸 **特殊场景** 的样式仅在特定场景使用

## 1. 输入框样式 (Input Field Styles)
### 1.1 **标准文本输入框样式** (`StandardTextFieldStyle`) ⭐ **默认** [S1]
**命名：**`**标准文本输入框样式**`** 或 **`**StandardTextFieldStyle**`

**样式特征：**

+ ⚠️ **必须使用**`AppTextField` 组件
+ iOS 风格：无边框，灰色填充背景（`AppDesignTokens.inputFill(context)`）
+ 圆角：12pt（`AppDesignTokens.radiusMedium`）
+ 内边距：水平18pt，垂直16pt
+ 错误状态：红色边框（`Color(0xFFFF3B30)`）

**推荐使用方式：**

```plain
// ⚠️ 唯一推荐方式：使用 AppTextField
AppTextField(
  controller: _controller,
  labelText: '标签',
  hintText: '请输入...',
  prefixIcon: Icon(CupertinoIcons.person),
  validator: (value) => value?.isEmpty ?? true ? '不能为空' : null,
)
```

**使用位置：**

+ [AppTextField](https://www.google.com/search?q=mdc:lib/core/widgets/app_text_field.dart) - iOS风格输入框组件
+ 所有表单页面的文本输入

**⚠️**** 废弃方式（V2.0遗留，严禁在新代码中使用）：**

+ ~~`FormBuilderUtils.buildTextField()`~~ → 迁移到 `AppTextField`
+ ~~`TextField`~~ → 迁移到 `AppTextField`

### 1.2 **金额输入框样式** (`AmountInputFieldStyle`) 🔸 **LEGACY - 过渡期使用** [S2]
**命名：**`**金额输入框样式**`** 或 **`**AmountInputFieldStyle**`

**⚠️**** 迁移状态：** 此样式已标记为 LEGACY。**新代码中应优先考虑基于 AppTextField 的 Suffix 实现。**

**当前实现（过渡期）：**

+ 使用 `AmountInputField` 组件（LEGACY）
+ 左侧圆角：8pt（右侧无圆角，与单位块衔接）
+ 右侧单位块：36px宽，浅灰色背景

**未来实现方向（推荐新代码实现）：**

+ 基于 `AppTextField` 的 `suffix` 或自定义 `suffixBuilder` 实现单位块
+ 保持 iOS 风格的一致性

**当前使用位置（过渡期）：**

+ [AmountInputField](https://www.google.com/search?q=mdc:lib/core/widgets/amount_input_field.dart) - 金额输入组件（LEGACY）

**代码示例（过渡期 - 严禁新代码使用）：**

```plain
// ⚠️ 仅为兼容旧代码，新代码请勿使用 AmountInputField
AmountInputField(
  controller: controller,
  labelText: '金额',
  unitText: '元',
)
```

### 1.3 **日期选择器样式** (`DatePickerFieldStyle`) 🔸 **特殊场景** [S3]
**命名：**`**日期选择器样式**`** 或 **`**DatePickerFieldStyle**`

**样式特征：**

+ **必须**使用 `AppTextField` 组件作为外部视觉容器
+ 前缀图标：日历图标（`CupertinoIcons.calendar` 或 `Icons.calendar_today`）
+ 日期格式：yyyy-MM-dd
+ **仅在日期选择时使用**

**推荐使用方式：**

```plain
// 推荐方式：使用 AppTextField 包装一个只读的点击事件
AppTextField(
  labelText: '日期',
  hintText: '请选择日期',
  readOnly: true, // 只读
  prefixIcon: Icon(CupertinoIcons.calendar),
  controller: TextEditingController(text: selectedDateString), // 展示选定值
  onTap: () async {
    // 触发 DatePicker
    final DateTime? picked = await showCupertinoModalPopup<DateTime>(
      // ... DatePicker Implementation
    );
    // ...
  },
)
```

**使用位置：**

+ 所有日期选择场景

**⚠️**** 废弃方式（V2.0遗留，严禁在新代码中使用）：**

+ ~~`FormBuilderUtils.buildDateField()`~~ → 迁移到 `AppTextField` + DatePicker

## 2. 下拉框样式 (Dropdown Styles)
### 2.1 **标准下拉框样式** (`StandardDropdownStyle`) ⭐ **默认** [S4]
**命名：**`**标准下拉框样式**`** 或 **`**StandardDropdownStyle**`

**样式特征：**

+ ⚠️ **必须使用**`AppTextField` 的视觉风格作为包装
+ iOS 风格：无边框，灰色填充背景
+ 圆角：12pt（`AppDesignTokens.radiusMedium`）
+ 后缀图标：向下箭头（`CupertinoIcons.chevron_down`）

**推荐使用方式：**

```plain
// ⚠️ 推荐方式：使用 DropdownButtonFormField 并包裹在 AppTextField 的视觉容器中
Container(
  decoration: BoxDecoration(
    color: AppDesignTokens.inputFill(context),
    borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
  ),
  child: DropdownButtonFormField<String>(
    // 移除默认下划线和边框
    decoration: const InputDecoration(
      labelText: '选择项',
      border: InputBorder.none,
      contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      suffixIcon: Icon(CupertinoIcons.chevron_down), // 添加后缀箭头
    ),
    items: [
      DropdownMenuItem(value: 'option1', child: Text('选项1')),
      // ...
    ],
    onChanged: (value) {},
  ),
)
```

**使用位置：**

+ 所有下拉选择场景

**⚠️**** 废弃方式（V2.0遗留，严禁在新代码中使用）：**

+ ~~`FormBuilderUtils.buildDropdown()`~~ → 迁移到 `AppTextField` + 下拉菜单视觉组合

## 3. 选择组件样式 (Selection Component Styles)
### 3.1 **复选框样式** (`CheckboxStyle`) ⭐ **默认** [S5]
**命名：**`**复选框样式**`** 或 **`**CheckboxStyle**`

**样式特征：**

+ ⚠️ **必须使用**`AppCheckbox` 组件
+ iOS 风格：圆形，选中变蓝，带有缩放动画

**推荐使用方式：**

```plain
// ⚠️ 唯一推荐方式：使用 AppCheckbox
AppCheckbox(
  value: isChecked,
  onChanged: (value) => setState(() => isChecked = value),
  label: '选项', // 可选
)
```

**使用位置：**

+ [AppCheckbox](https://www.google.com/search?q=mdc:lib/core/widgets/app_selection_controls.dart) - iOS风格复选框组件
+ 所有复选框场景

**⚠️**** 废弃方式（V2.0遗留，严禁在新代码中使用）：**

+ ~~`FormBuilderUtils.buildCheckbox()`~~ → 迁移到 `AppCheckbox`
+ ~~`Checkbox`~~ → 迁移到 `AppCheckbox`

### 3.2 **开关样式** (`SwitchStyle`) ⭐ **默认** [S6]
**命名：**`**开关样式**`** 或 **`**SwitchStyle**`

**样式特征：**

+ ⚠️ **必须使用**`AppSwitch` 组件
+ iOS 风格：`CupertinoSwitch`，主题色激活

**推荐使用方式：**

```plain
// ⚠️ 唯一推荐方式：使用 AppSwitch
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      '开关',
      style: AppDesignTokens.body(context),
    ),
    AppSwitch(
      value: isEnabled,
      onChanged: (value) => setState(() => isEnabled = value),
    ),
  ],
)
```

**使用位置：**

+ [AppSwitch](https://www.google.com/search?q=mdc:lib/core/widgets/app_selection_controls.dart) - iOS风格开关组件
+ 所有开关场景

**⚠️**** 废弃方式（V2.0遗留，严禁在新代码中使用）：**

+ ~~`FormBuilderUtils.buildSwitch()`~~ → 迁移到 `AppSwitch`
+ ~~`SwitchListTile`~~ → 迁移到 `AppSwitch` + `Row`

### 3.3 **单选按钮样式** (`RadioButtonStyle`) ⭐ **默认** [S7]
**命名：**`**单选按钮样式**`** 或 **`**RadioButtonStyle**`

**推荐使用方式：**

```plain
// 使用RadioListTile（推荐，带标题）
RadioListTile<String>(
  title: Text('选项1'),
  value: 'option1',
  groupValue: selectedValue,
  onChanged: (value) => setState(() => selectedValue = value),
)
```

**使用位置：**

+ [ai_config_screen.dart](https://www.google.com/search?q=mdc:lib/screens/ai_config_screen.dart) - AI提供商选择

### 3.4 **滑块样式** (`SliderStyle`) ⭐ **默认** [S8]
**命名：**`**滑块样式**`** 或 **`**SliderStyle**`

**推荐使用方式：**

```plain
// 使用Material Slider
Slider(
  value: sliderValue,
  min: 0,
  max: 100,
  onChanged: (value) => setState(() => sliderValue = value),
)
```

**使用位置：**

+ [salary_income_setup_screen.dart](https://www.google.com/search?q=mdc:lib/features/family_info/screens/salary_income_setup_screen.dart) - 薪资比例滑块

### 3.5 **分段选择器样式** (`SegmentedControlStyle`) 🔸 **特殊场景** [S9]
**命名：**`**分段选择器样式**`** 或 **`**SegmentedControlStyle**`

**样式特征：**

+ 使用 `AppSegmentedControl` 组件
+ 无边框、扁平化设计，选中项主题色填充
+ iOS Cupertino 风格

**推荐使用方式：**

```plain
AppSegmentedControl<String>(
  children: const {
    'day': Text('日'),
    'week': Text('周'),
    'month': Text('月'),
  },
  groupValue: selectedPeriod,
  onValueChanged: (value) => setState(() => selectedPeriod = value),
)
```

**使用位置：**

+ 页面 B 的"方案对比"沙盒切换器
+ [AppSegmentedControl](https://www.google.com/search?q=mdc:lib/core/widgets/app_selection_controls.dart) - iOS 风格分段选择器

### 3.6 **标签芯片样式** (`ChipStyle`) ⭐ **默认** [S10]
**命名：**`**标签芯片样式**`** 或 **`**ChipStyle**`

**样式特征：**

+ ⚠️ **必须使用**`AppTag` 组件
+ iOS 风格：8pt圆角，选中/未选中状态，支持自定义颜色

**推荐使用方式：**

```plain
// ⚠️ 唯一推荐方式：使用 AppTag
AppTag(
  label: '标签',
  isSelected: isSelected,
  onTap: () => setState(() => isSelected = !isSelected),
  color: AppDesignTokens.primaryAction(context), // 可选
)
```

**使用位置：**

+ [AppTag](https://www.google.com/search?q=mdc:lib/core/widgets/app_tag.dart) - iOS风格标签组件
+ 标签选择/筛选场景
+ 分类展示场景

**⚠️**** 废弃方式（V2.0遗留，严禁在新代码中使用）：**

+ ~~`FilterChip`~~ → 迁移到 `AppTag`
+ ~~`ChoiceChip`~~ → 迁移到 `AppTag`

## 4. 按钮样式 (Button Styles)
### 4.1 **主要按钮样式** (`PrimaryButtonStyle`) ⭐ **默认** [S11]
**命名：**`**主要按钮样式**`** 或 **`**PrimaryButtonStyle**`

**样式特征：**

+ ⚠️ **必须使用**`AppPrimaryButton` 组件
+ iOS 风格：56pt高度，按压回弹动画，主题色背景
+ 圆角：16pt（`AppDesignTokens.radiusMedium`）
+ 支持 Loading 状态和禁用状态

**推荐使用方式：**

```plain
// ⚠️ 唯一推荐方式：使用 AppPrimaryButton
AppPrimaryButton(
  label: '确定',
  icon: CupertinoIcons.check_mark, // 可选
  onPressed: () => {},
  isLoading: false, // 可选
  isEnabled: true, // 可选
)
```

**使用位置：**

+ [AppPrimaryButton](https://www.google.com/search?q=mdc:lib/core/widgets/app_primary_button.dart) - iOS风格主按钮组件
+ 所有主要操作按钮

**⚠️**** 废弃方式（V2.0遗留，严禁在新代码中使用）：**

+ ~~`ElevatedButton`~~ → 迁移到 `AppPrimaryButton`
+ ~~`ElevatedButton.icon`~~ → 迁移到 `AppPrimaryButton`（带 `icon` 参数）

### 4.2 **文本按钮样式** (`TextButtonStyle`) ⭐ **默认** [S12]
**命名：**`**文本按钮样式**`** 或 **`**TextButtonStyle**`

**样式特征：**

+ 使用 `TextButton`（使用 `AppDesignTokens`）
+ 文字颜色：主题色（`AppDesignTokens.primaryAction(context)`）
+ 圆角：12pt（`AppDesignTokens.radiusMedium`）

**推荐使用方式：**

```plain
// 使用 TextButton + AppDesignTokens
TextButton(
  onPressed: () => {},
  style: TextButton.styleFrom(
    foregroundColor: AppDesignTokens.primaryAction(context),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
    ),
  ),
  child: Text('取消'),
)
```

**使用位置：**

+ 对话框操作按钮
+ 次要操作按钮

### 4.3 **轮廓按钮样式** (`OutlinedButtonStyle`) 🔸 **特殊场景** [S13]
**命名：**`**轮廓按钮样式**`** 或 **`**OutlinedButtonStyle**`

**仅在需要边框按钮时使用**

**推荐使用方式：**

```plain
OutlinedButton(
  onPressed: () => {},
  child: Text('取消'),
)
```

### 4.4 **图标按钮样式** (`IconButtonStyle`) ⭐ **默认** [S14]
**命名：**`**图标按钮样式**`** 或 **`**IconButtonStyle**`

**推荐使用方式：**

```plain
IconButton(
  icon: Icon(Icons.delete_outline),
  onPressed: () => {},
)
```

### 4.5 **浮动操作按钮样式** (`FloatingActionButtonStyle`) 🔸 **特殊场景** [S15]
**命名：**`**浮动操作按钮样式**`** 或 **`**FloatingActionButtonStyle**`

**仅在需要浮动添加按钮时使用**

**推荐使用方式：**

```plain
EnhancedFloatingActionButton(
  onPressed: () => {},
  icon: Icons.add,
)
```

**使用位置：**

+ [EnhancedFloatingActionButton](https://www.google.com/search?q=mdc:lib/core/widgets/enhanced_floating_action_button.dart) - 增强浮动按钮

### 4.6 **带图标按钮样式** (`IconLabelButtonStyle`) 🔸 **特殊场景** [S16]
**命名：**`**带图标按钮样式**`** 或 **`**IconLabelButtonStyle**`

**新代码应优先使用 S11 AppPrimaryButton 的 icon 参数实现。**

**推荐使用方式：**

```plain
// 推荐方式：使用 AppPrimaryButton(icon: ...) 实现
AppPrimaryButton(
  label: '添加',
  icon: CupertinoIcons.add,
  onPressed: () => {},
)

// 仅在 Material Design 特定场景使用（特殊场景）
ElevatedButton.icon(
  onPressed: () => {},
  icon: Icon(Icons.add, size: 20),
  label: Text('添加'),
)
```

## 5. 对话框样式 (Dialog Styles)
### 5.1 **确认对话框样式** (`ConfirmationDialogStyle`) ⭐ **默认** [S17]
**命名：**`**确认对话框样式**`** 或 **`**ConfirmationDialogStyle**`

**推荐使用方式：**

```plain
// 使用统一通知系统（推荐）
final confirmed = await unifiedNotifications.showConfirmation(
  context,
  title: '确认删除',
  message: '确定要删除吗？',
);
```

**使用位置：**

+ [unified_notifications.showConfirmation](https://www.google.com/search?q=mdc:lib/core/utils/unified_notifications.dart) - 统一确认对话框

### 5.2 **底部表单样式** (`BottomSheetStyle`) ⭐ **默认** [S18]
**命名：**`**底部表单样式**`** 或 **`**BottomSheetStyle**`

**推荐使用方式：**

```plain
AppAnimations.showAppModalBottomSheet(
  context: context,
  child: Container(
    padding: EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 内容
      ],
    ),
  ),
)
```

**使用位置：**

+ [AppAnimations.showAppModalBottomSheet](https://www.google.com/search?q=mdc:lib/core/widgets/app_animations.dart) - 底部表单动画

## 6. 标签页样式 (Tab Styles)
### 6.1 **标准标签页样式** (`StandardTabStyle`) ⭐ **默认** [S19]
**命名：**`**标准标签页样式**`** 或 **`**StandardTabStyle**`

**推荐使用方式：**

```plain
DefaultTabController(
  length: 2,
  child: Scaffold(
    appBar: AppBar(
      bottom: TabBar(
        tabs: [
          Tab(text: '标签1'),
          Tab(text: '标签2'),
        ],
      ),
    ),
    body: TabBarView(
      children: [
        // 内容1
        // 内容2
      ],
    ),
  ),
)
```

## 7. 提示样式 (Notification Styles)
### 7.1 **SnackBar提示样式** (`SnackBarStyle`) ⭐ **默认** [S20]
**命名：**`**SnackBar提示样式**`** 或 **`**SnackBarStyle**`

**推荐使用方式：**

```plain
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('操作成功'),
  ),
)
```

### 7.2 **玻璃通知样式** (`GlassNotificationStyle`) 🔸 **特殊场景** [S21]
**命名：**`**玻璃通知样式**`** 或 **`**GlassNotificationStyle**`

**仅在需要特殊视觉效果时使用**

**推荐使用方式：**

```plain
unifiedNotifications.showSuccess(context, '操作成功');
```

## 8. 数据展示与复合组件样式 (Data Display & Composite Styles) - V3.0 新增
### 8.1 **核心数据卡片样式** (`CoreDataCardStyle`) ⭐ **高频使用** [S22]
**命名：**`**核心数据卡片样式**`** 或 **`**CoreDataCardStyle**`

**样式特征：**

+ **结构：** 大字体主数值（￥2,345.00） + 描述性副标题（年度净收入）
+ **背景：** 强烈的圆角卡片（16pt），主题色或渐变色背景
+ **字体：** 主数值使用 `AppDesignTokens.largeTitle` 或 `AppDesignTokens.title1`
+ **用途：** 用于展示最高层级的关键结果（KPI）

**推荐使用方式：**

```plain
AppCard(
  child: Padding(
    padding: EdgeInsets.all(AppDesignTokens.spacing24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '年度净收入',
          style: AppDesignTokens.caption(context),
        ),
        SizedBox(height: AppDesignTokens.spacing8),
        Text(
          '￥${totalIncome.toStringAsFixed(2)}',
          style: AppDesignTokens.largeTitle(context).copyWith(
            color: AppDesignTokens.primaryAction(context),
          ),
        ),
      ],
    ),
  ),
)
```

**使用位置：**

+ 页面 B (`/financial-planning/tax-prediction`) 的"结果总览"
+ Tab 主页的资产总览
+ Dashboard 的关键指标卡片

### 8.2 **只读结果展示行样式** (`ReadOnlyResultRowStyle`) ⭐ **高频使用** [S23]
**命名：**`**只读结果展示行样式**`** 或 **`**ReadOnlyResultRowStyle**`

**样式特征：**

+ **结构：** 标题（左侧） + 只读数值（右侧）
+ **数值样式：** 数值使用灰色填充背景（`AppDesignTokens.inputFill(context)`），12pt圆角，以区别于输入框
+ **字体：** 标题使用 `AppDesignTokens.body`，数值使用 `AppDesignTokens.headline`
+ **用途：** 用于展示系统自动计算的只读结果，如扣款金额

**推荐使用方式：**

```plain
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      '社保（五险）',
      style: AppDesignTokens.body(context),
    ),
    Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDesignTokens.spacing12,
        vertical: AppDesignTokens.spacing8,
      ),
      decoration: BoxDecoration(
        color: AppDesignTokens.inputFill(context),
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
      ),
      child: Text(
        '¥${amount.toStringAsFixed(2)}',
        style: AppDesignTokens.headline(context),
      ),
    ),
  ],
)
```

**使用位置：**

+ 页面 A：只读展示社保、公积金、个税的计算金额
+ 页面 B：月度流水预测列表中的只读字段

### 8.3 **计算透明度详情样式** (`CalculationTransparencyDetailStyle`) 🔸 **特殊场景** [S24]
**命名：**`**计算透明度详情样式**`** 或 **`**CalculationTransparencyDetailStyle**`

**样式特征：**

+ **结构：** 列表详情行，Key-Value Pair
+ **字体：** 使用 `AppDesignTokens.microCaption(context)`（10pt，次要灰色）
+ **用途：** 显示计算的底层依据（基数、比例、税率），建立用户信任

**推荐使用方式：**

```plain
Text(
  '基数：¥${base.toStringAsFixed(2)}；比例：${rate.toStringAsFixed(1)}%',
  style: AppDesignTokens.microCaption(context),
)
```

**使用位置：**

+ 紧跟在 8.2 之下，显示社保公积金的基数和比例
+ 个税计算结果的透明度说明

### 8.4 **收支流水列表项样式** (`TransactionFlowListItemStyle`) ⭐ **最高频使用** [S25]
**命名：**`**收支流水列表项样式**`** 或 **`**TransactionFlowListItemStyle**`

**样式特征：**

+ **结构：** 左侧（图标/分类名），中间（描述/账户），右侧（金额，收入绿色，支出红色）
+ **交互：** 可点击（带波纹效果），点击后跳转至交易详情
+ **字体：** 分类名使用 `AppDesignTokens.headline`，金额使用 `AppDesignTokens.headline`（加粗）
+ **用途：** 应用中最常用、最高频的列表展示项

**推荐使用方式：**

```plain
InkWell(
  onTap: () => Navigator.push(...),
  child: Padding(
    padding: EdgeInsets.symmetric(
      horizontal: AppDesignTokens.spacing16,
      vertical: AppDesignTokens.spacing12,
    ),
    child: Row(
      children: [
        // 左侧图标/分类
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
          ),
          child: Icon(icon, color: categoryColor),
        ),
        SizedBox(width: AppDesignTokens.spacing12),
        // 中间描述
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                categoryName,
                style: AppDesignTokens.headline(context),
              ),
              SizedBox(height: AppDesignTokens.spacing4),
              Text(
                accountName,
                style: AppDesignTokens.caption(context),
              ),
            ],
          ),
        ),
        // 右侧金额
        Text(
          isIncome ? '+¥${amount.toStringAsFixed(2)}' : '-¥${amount.toStringAsFixed(2)}',
          style: AppDesignTokens.headline(context).copyWith(
            color: isIncome 
              ? AppDesignTokens.successColor 
              : AppDesignTokens.errorColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
)
```

**使用位置：**

+ Tab 3 收支流水主页
+ 页面 B 月度流水预测列表
+ Dashboard 最近交易列表

### 8.5 **AI 自然语言输入框样式** (`AINaturalLanguageInputStyle`) 🔸 **特殊场景** [S26]
**命名：**`**AI自然语言输入框样式**`** 或 **`**AINaturalLanguageInputStyle**`

**样式特征：**

+ **结构：** 文本输入框 + 语音图标按钮 + AI解析结果预览区域
+ **提示：** 占位符文案强调自然语言能力（如："一句话记录交易，如：今天星巴克拿铁35元"）
+ **用途：** 交易录入的最高效入口

**推荐使用方式：**

```plain
Column(
  children: [
    Row(
      children: [
        Expanded(
          child: AppTextField(
            controller: _inputController,
            hintText: '一句话记录交易，如：今天星巴克拿铁35元',
            prefixIcon: Icon(CupertinoIcons.chat_bubble_text),
          ),
        ),
        SizedBox(width: AppDesignTokens.spacing8),
        IconButton(
          icon: Icon(CupertinoIcons.mic),
          onPressed: () => _startVoiceInput(),
        ),
      ],
    ),
    if (_aiPreview != null) ...[
      SizedBox(height: AppDesignTokens.spacing12),
      AppCard(
        child: Padding(
          padding: EdgeInsets.all(AppDesignTokens.spacing12),
          child: Text(_aiPreview),
        ),
      ),
    ],
  ],
)
```

**使用位置：**

+ 添加交易页面顶部
+ 全局 FAB 的 AI 记账入口

### 8.6 **图表容器卡片样式** (`ChartContainerCardStyle`) ⭐ **高频使用** [S27]
**命名：**`**图表容器卡片样式**`** 或 **`**ChartContainerCardStyle**`

**样式特征：**

+ **结构：** 卡片顶部有标题/时间切换器，下方是图表区域
+ **背景：** 纯白色或浅灰色背景，12pt 圆角，带有轻微阴影
+ **用途：** 承载复杂的可视化内容

**推荐使用方式：**

```plain
AppCard(
  child: Padding(
    padding: EdgeInsets.all(AppDesignTokens.spacing16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '月度净收入',
              style: AppDesignTokens.title1(context),
            ),
            AppSegmentedControl<String>(
              children: const {
                'month': Text('月'),
                'year': Text('年'),
              },
              groupValue: _selectedPeriod,
              onValueChanged: (value) => setState(() => _selectedPeriod = value),
            ),
          ],
        ),
        SizedBox(height: AppDesignTokens.spacing16),
        // 图表区域
        SizedBox(
          height: 200,
          child: ChartWidget(data: chartData),
        ),
      ],
    ),
  ),
)
```

**使用位置：**

+ 页面 B 的月度净收入柱状图
+ Tab 2 财务规划页面的所有图表
+ Dashboard 的预算进度图表

### 8.7 **底部分页导航栏样式** (`BottomNavBarStyle`) ⭐ **全局使用** [S28]
**命名：**`**底部分页导航栏样式**`** 或 **`**BottomNavBarStyle**`

**样式特征：**

+ **颜色：** 背景色为 `AppDesignTokens.surface(context)`，选中的图标和文字使用 `AppDesignTokens.primaryAction(context)`，未选中使用 `AppDesignTokens.secondaryText(context)`
+ **结构：** 底部四个 Tab（概览、资产、记账、统计、设置）
+ **用途：** 全局导航

**推荐使用方式：**

```plain
BottomNavigationBar(
  currentIndex: _selectedIndex,
  onTap: _onItemTapped,
  selectedItemColor: AppDesignTokens.primaryAction(context),
  unselectedItemColor: AppDesignTokens.secondaryText(context),
  backgroundColor: AppDesignTokens.surface(context),
  type: BottomNavigationBarType.fixed,
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard_outlined),
      activeIcon: Icon(Icons.dashboard),
      label: '概览',
    ),
    // ... 其他 Tab
  ],
)
```

**使用位置：**

+ [MainNavigationScreen](https://www.google.com/search?q=mdc:lib/screens/main_navigation_screen.dart) - 主导航页面

## 9. 状态与反馈样式 (State & Feedback Styles) - V3.0 新增
### 9.1 **骨架屏加载样式** (`ShimmerLoadingStyle`) ⭐ **高频使用** [S29]
**命名：**`**骨架屏加载样式**`** 或 **`**ShimmerLoadingStyle**`

**样式特征：**

+ **动画：** 统一的亮光扫过效果，方向从左到右，速度适中
+ **形状：** 使用灰色/浅色矩形或圆形占位符，形状必须映射真实组件的结构
+ **用途：** 数据请求或计算进行中的等待状态，提升感知性能

**推荐使用方式：**

```plain
// 列表项骨架屏（映射 8.4 收支流水列表项样式）
Row(
  children: [
    AppShimmer.circle(size: 40),
    SizedBox(width: AppDesignTokens.spacing12),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppShimmer.text(width: 100, height: 16),
          SizedBox(height: AppDesignTokens.spacing4),
          AppShimmer.text(width: 60, height: 12),
        ],
      ),
    ),
    AppShimmer.text(width: 80, height: 16),
  ],
)

// 卡片骨架屏（映射 8.1 核心数据卡片样式）
AppCard(
  child: Padding(
    padding: EdgeInsets.all(AppDesignTokens.spacing24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppShimmer.text(width: 80, height: 12),
        SizedBox(height: AppDesignTokens.spacing8),
        AppShimmer.text(width: 150, height: 28),
      ],
    ),
  ),
)
```

**使用位置：**

+ 页面 B 初始加载时（等待后端计算结果）
+ Tab 主页的数据概览卡片加载时
+ 交易列表加载时

### 9.2 **空状态插画样式** (`EmptyStateIllustrationStyle`) ⭐ **高频使用** [S30]
**命名：**`**空状态插画样式**`** 或 **`**EmptyStateIllustrationStyle**`

**样式特征：**

+ **结构：** 中间位置的插画图标 + 居中的说明文字 + 一个引导按钮（使用 `AppPrimaryButton`）
+ **配色：** 插画主题色调柔和，避免过于鲜艳，与整体应用风格一致
+ **用途：** 列表或数据为空时的友好引导

**推荐使用方式：**

```plain
AppEmptyState(
  icon: CupertinoIcons.doc_text,
  title: '暂无交易记录',
  message: '点击下方按钮添加第一笔交易',
  action: AppPrimaryButton(
    label: '添加交易',
    icon: CupertinoIcons.add,
    onPressed: () => _navigateToAddTransaction(),
  ),
)
```

**使用位置：**

+ 交易记录为空
+ 规划列表为空
+ 资产列表为空
+ [AppEmptyState](https://www.google.com/search?q=mdc:lib/core/widgets/app_empty_state.dart) - 空状态组件

### 9.3 **通知横幅样式** (`NotificationBannerStyle`) 🔸 **特殊场景** [S31]
**命名：**`**通知横幅样式**`** 或 **`**NotificationBannerStyle**`

**样式特征：**

+ **结构：** 位于页面顶部，带有关闭按钮，图标+文字
+ **配色：**
    - 成功：绿色背景（`AppDesignTokens.successColor`），白色文字/图标
    - 警告：黄色背景（`AppDesignTokens.warningColor`），深色文字/图标
    - 错误：红色背景（`AppDesignTokens.errorColor`），白色文字/图标
+ **用途：** 提示关键信息（如 Policy Data Service 更新失败、清账提醒）

**推荐使用方式：**

```plain
Container(
  padding: EdgeInsets.symmetric(
    horizontal: AppDesignTokens.spacing16,
    vertical: AppDesignTokens.spacing12,
  ),
  decoration: BoxDecoration(
    color: AppDesignTokens.errorColor,
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(AppDesignTokens.radiusMedium),
      bottomRight: Radius.circular(AppDesignTokens.radiusMedium),
    ),
  ),
  child: Row(
    children: [
      Icon(CupertinoIcons.exclamationmark_triangle, color: Colors.white),
      SizedBox(width: AppDesignTokens.spacing12),
      Expanded(
        child: Text(
          'Policy Data Service 更新失败，请检查网络连接',
          style: AppDesignTokens.body(context).copyWith(color: Colors.white),
        ),
      ),
      IconButton(
        icon: Icon(CupertinoIcons.xmark, color: Colors.white),
        onPressed: () => _dismissBanner(),
      ),
    ],
  ),
)
```

**使用位置：**

+ 页面顶部，如 `FamilyInfoHomeScreen`
+ Policy Data Service 更新失败时
+ 清账提醒时

## 🎯 快速引用指南
### 默认样式（直接使用，无需指定）
+ **[S1] 文本输入框** → 使用 `AppTextField` 组件 ⚠️ **必须使用新组件**
+ **[S4] 下拉框** → 使用 `AppTextField` (Wrapper) + Dropdown ⚠️ **必须使用新组件**
+ **[S5] 复选框** → 使用 `AppCheckbox` 组件 ⚠️ **必须使用新组件**
+ **[S6] 开关** → 使用 `AppSwitch` 组件 ⚠️ **必须使用新组件**
+ **[S7] 单选按钮** → 使用 `RadioListTile`
+ **[S8] 滑块** → 使用 `Slider`（使用 `AppDesignTokens.primaryAction(context)` 作为 `activeColor`）
+ **[S9] 分段选择器** → 使用 `AppSegmentedControl` 组件 ⚠️ **必须使用新组件**
+ **[S11] 主要按钮** → 使用 `AppPrimaryButton` 组件 ⚠️ **必须使用新组件**
+ **[S12] 文本按钮** → 使用 `TextButton`（使用 `AppDesignTokens`）
+ **[S14] 图标按钮** → 使用 `IconButton`（使用 `AppDesignTokens`）
+ **[S17] 确认对话框** → 使用 `unifiedNotifications.showConfirmation()`
+ **[S18] 底部表单** → 使用 `AppAnimations.showAppModalBottomSheet()`
+ **[S19] 标签页** → 使用 `TabBar` / `TabBarView`
+ **[S20] 提示消息** → 使用 `ScaffoldMessenger.showSnackBar()`

### 复合样式（V3.0 新增，高频使用）
+ **[S22] 核心数据卡片** → 使用 `AppCard` + `AppDesignTokens.largeTitle/title1` + 主题色
+ **[S23] 只读结果展示行** → 使用 `Row` + `Container`（灰色背景）+ `AppDesignTokens.headline`
+ **[S24] 计算透明度详情** → 使用 `AppDesignTokens.microCaption`（10pt 字体） **(已修正)**
+ **[S25] 收支流水列表项** → 使用 `InkWell` + `Row` + `AppDesignTokens.headline` + 颜色区分
+ **[S26] AI自然语言输入框** → 使用 `AppTextField` + `IconButton` + `AppCard`（预览区域）
+ **[S27] 图表容器卡片** → 使用 `AppCard` + `AppSegmentedControl` + 图表组件
+ **[S28] 底部分页导航栏** → 使用 `BottomNavigationBar` + `AppDesignTokens` 颜色

### 状态样式（V3.0 新增，高频使用）
+ **[S29] 骨架屏加载** → 使用 `AppShimmer` 组件，形状必须映射真实组件结构
+ **[S30] 空状态插画** → 使用 `AppEmptyState` 组件 + `AppPrimaryButton`
+ **[S31] 通知横幅** → 使用 `Container` + `AppDesignTokens` 颜色 + `IconButton`（关闭）

### 特殊样式（仅在特定场景使用）
+ **[S2] 金额输入框** → 使用 `AmountInputField` 组件（**LEGACY**，新代码避免使用）
+ **[S3] 日期选择器** → 使用 `AppTextField` (Wrapper) + DatePicker
+ **[S10] 标签芯片** → 使用 `AppTag` 组件 ⚠️ **必须使用新组件**
+ **[S13] 轮廓按钮** → 使用 `OutlinedButton`
+ **[S15] 浮动操作按钮** → 使用 `EnhancedFloatingActionButton`
+ **[S16] 带图标按钮** → 使用 `AppPrimaryButton`（带 `icon` 参数）
+ **[S21] 玻璃通知** → 使用 `unifiedNotifications` 或 `GlassNotification`

## 📝 样式使用决策树
```plain
需要输入文本？
├─ 是金额？ → 使用 AmountInputField（金额输入框样式）🔸 LEGACY，**避免在新代码中使用**
├─ 是日期？ → 使用 AppTextField (Wrapper) + DatePicker（日期选择器样式）🔸
└─ 其他文本 → 使用 AppTextField（标准文本输入框样式）⭐ ⚠️ 必须使用新组件

需要选择？
├─ 下拉选择 → 使用 AppTextField (Wrapper) + Dropdown（标准下拉框样式）⭐ ⚠️ 必须使用新组件
├─ 多选 → 使用 AppCheckbox（复选框样式）⭐ ⚠️ 必须使用新组件
├─ 开关 → 使用 AppSwitch（开关样式）⭐ ⚠️ 必须使用新组件
├─ 单选 → 使用 RadioListTile（单选按钮样式）⭐（使用 AppDesignTokens）
├─ 数值范围 → 使用 Slider（滑块样式）⭐（使用 AppDesignTokens.primaryAction）
├─ 分段切换 → 使用 AppSegmentedControl（分段选择器样式）⭐ ⚠️ 必须使用新组件
└─ 标签筛选 → 使用 AppTag（标签芯片样式）⭐ ⚠️ 必须使用新组件

需要按钮？
├─ 主要操作 → 使用 AppPrimaryButton（主要按钮样式）⭐ ⚠️ 必须使用新组件
├─ 次要操作 → 使用 TextButton（文本按钮样式）⭐（使用 AppDesignTokens）
├─ 图标操作 → 使用 IconButton（图标按钮样式）⭐（使用 AppDesignTokens）
├─ 浮动添加 → 使用 EnhancedFloatingActionButton（浮动操作按钮样式）🔸
└─ 图标+文字 → 使用 AppPrimaryButton（带 icon 参数）⭐ ⚠️ 必须使用新组件

需要展示数据？
├─ 核心KPI数据 → 使用 CoreDataCardStyle（核心数据卡片样式）⭐ [S22]
├─ 只读计算结果 → 使用 ReadOnlyResultRowStyle（只读结果展示行样式）⭐ [S23]
├─ 计算透明度 → 使用 CalculationTransparencyDetailStyle（计算透明度详情样式）🔸 [S24]
├─ 交易列表项 → 使用 TransactionFlowListItemStyle（收支流水列表项样式）⭐ [S25]
├─ AI输入 → 使用 AINaturalLanguageInputStyle（AI自然语言输入框样式）🔸 [S26]
├─ 图表容器 → 使用 ChartContainerCardStyle（图表容器卡片样式）⭐ [S27]
└─ 底部导航 → 使用 BottomNavBarStyle（底部分页导航栏样式）⭐ [S28]

需要状态反馈？
├─ 加载中 → 使用 ShimmerLoadingStyle（骨架屏加载样式）⭐ [S29] ⚠️ 必须使用 AppShimmer
├─ 空状态 → 使用 EmptyStateIllustrationStyle（空状态插画样式）⭐ [S30] ⚠️ 必须使用 AppEmptyState
└─ 通知横幅 → 使用 NotificationBannerStyle（通知横幅样式）🔸 [S31]

需要对话框？
├─ 确认操作 → 使用 unifiedNotifications.showConfirmation()（确认对话框样式）⭐
└─ 表单输入 → 使用 AppAnimations.showAppModalBottomSheet()（底部表单样式）⭐

需要提示？
└─ 操作反馈 → 使用 ScaffoldMessenger.showSnackBar()（SnackBar提示样式）⭐
```

**图例：**

+ ⭐ = 默认样式（推荐使用）
+ 🔸 = 特殊样式（仅在特定场景使用）
+ ⚠️ = 必须使用新的 iOS Fintech 组件系统

## 相关文件
### ⚠️ 必须使用的组件（V3.0 新组件系统）
+ [AppDesignTokens](https://www.google.com/search?q=mdc:lib/core/theme/app_design_tokens.dart) - 设计令牌系统（**必须使用**）
+ [AppTextField](https://www.google.com/search?q=mdc:lib/core/widgets/app_text_field.dart) - iOS风格输入框组件
+ [AppPrimaryButton](https://www.google.com/search?q=mdc:lib/core/widgets/app_primary_button.dart) - iOS风格主按钮组件
+ [AppSwitch](https://www.google.com/search?q=mdc:lib/core/widgets/app_selection_controls.dart) - iOS风格开关组件
+ [AppCheckbox](https://www.google.com/search?q=mdc:lib/core/widgets/app_selection_controls.dart) - iOS风格复选框组件
+ [AppSegmentedControl](https://www.google.com/search?q=mdc:lib/core/widgets/app_selection_controls.dart) - iOS风格分段选择器组件
+ [AppTag](https://www.google.com/search?q=mdc:lib/core/widgets/app_tag.dart) - iOS风格标签组件
+ [AppCard](https://www.google.com/search?q=mdc:lib/core/widgets/app_card.dart) - iOS风格卡片组件
+ [AppShimmer](https://www.google.com/search?q=mdc:lib/core/widgets/app_shimmer.dart) - 骨架屏加载组件
+ [AppEmptyState](https://www.google.com/search?q=mdc:lib/core/widgets/app_empty_state.dart) - 空状态组件

### 🔸 LEGACY 组件（过渡期兼容，后续迁移）
| **文件名** | **样式/功能** | **迁移计划** | **强制行动** |
| --- | --- | --- | --- |
| [FormBuilderUtils](https://www.google.com/search?q=mdc:lib/core/widgets/form_builder_utils.dart) | 表单构建工具类 | 移除对 Material / FormBuilder 的依赖，使用新组件 API 重写。 | **新代码严禁引用。** |
| [AmountInputField](https://www.google.com/search?q=mdc:lib/core/widgets/amount_input_field.dart) | 金额输入组件 (S2) | 迁移到基于 `AppTextField` 的 `suffixIcon` 实现，并移除独立组件。 | **新代码避免使用。** |


### 其他工具类
+ [AppAnimations](https://www.google.com/search?q=mdc:lib/core/widgets/app_animations.dart) - 动效系统
+ [UnifiedNotifications](https://www.google.com/search?q=mdc:lib/core/utils/unified_notifications.dart) - 统一通知系统
+ [UI设计系统规范](https://www.google.com/search?q=mdc:.cursor/rules/ui-design-system.mdc) - 整体UI/UX设计系统

