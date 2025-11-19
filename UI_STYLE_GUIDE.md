# UI样式命名指南

本文档定义了应用中所有UI组件的样式名称，**按样式特征命名**，方便快速引用和应用。

## 📋 样式列表

---

## 1. 输入框样式 (Input Field Styles)

### 1.1 **标准文本输入框样式** (`StandardTextFieldStyle`)
**命名：`标准文本输入框样式` 或 `StandardTextFieldStyle`**

**样式特征：**
- 使用 `FormBuilderTextField`
- 圆角：12pt
- 填充背景：白色（cardColor）
- 边框：默认灰色（dividerColor），聚焦时主题色（primaryColor）2px宽
- 内边距：水平16pt，垂直16pt
- 支持前缀/后缀图标
- 支持多行输入

**使用位置：**
- `form_builder_utils.dart` - `buildTextField()` - 通用文本输入框构建器
- 所有使用 `FormBuilderUtils.buildTextField()` 的表单页面

**代码示例：**
```dart
FormBuilderTextField(
  name: name,
  decoration: InputDecoration(
    labelText: label,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Theme.of(context).primaryColor,
        width: 2,
      ),
    ),
    filled: true,
    fillColor: Theme.of(context).cardColor,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),
)
```

---

### 1.2 **金额输入框样式** (`AmountInputFieldStyle`)
**命名：`金额输入框样式` 或 `AmountInputFieldStyle`**

**样式特征：**
- 使用 `AmountInputField` 组件
- 左侧圆角：8pt（右侧无圆角，与单位块衔接）
- 填充背景：浅灰色（grey.withOpacity(0.03)）
- 右侧单位块：36px宽，浅灰色背景，右侧圆角8pt
- 边框：默认浅灰色，聚焦时主题色2px宽
- 内边距：左侧16pt，右侧40pt（为单位块预留空间）

**使用位置：**
- `amount_input_field.dart` - `AmountInputField` - 金额输入组件
- `amount_input_demo.dart` - 金额输入演示
- `widgets/amount_input_demo.dart` - 金额输入演示

**代码示例：**
```dart
AmountInputField(
  controller: controller,
  labelText: '金额',
  unitText: '元',
  borderRadius: 8.0,
  showBorder: true,
)
```

---

### 1.3 **日期选择器样式** (`DatePickerFieldStyle`)
**命名：`日期选择器样式` 或 `DatePickerFieldStyle`**

**样式特征：**
- 使用 `FormBuilderDateTimePicker`
- 圆角：12pt
- 填充背景：白色（cardColor）
- 前缀图标：日历图标（Icons.calendar_today）
- 日期格式：yyyy-MM-dd
- 边框样式与标准文本输入框相同

**使用位置：**
- `form_builder_utils.dart` - `buildDateField()` - 日期选择器构建器
- `add_transaction_screen.dart` - 交易日期选择
- `clearance_home_screen.dart` - 清账日期选择

**代码示例：**
```dart
FormBuilderDateTimePicker(
  name: name,
  inputType: InputType.date,
  format: DateFormat('yyyy-MM-dd'),
  decoration: InputDecoration(
    labelText: label,
    prefixIcon: Icon(Icons.calendar_today),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)
```

---

## 2. 下拉框样式 (Dropdown Styles)

### 2.1 **标准下拉框样式** (`StandardDropdownStyle`)
**命名：`标准下拉框样式` 或 `StandardDropdownStyle`**

**样式特征：**
- 使用 `FormBuilderDropdown`
- 圆角：12pt
- 填充背景：白色（cardColor）
- 边框：默认灰色，聚焦时主题色2px宽
- 内边距：水平16pt，垂直16pt
- 支持禁用状态（灰色背景）

**使用位置：**
- `form_builder_utils.dart` - `buildDropdown()` - 下拉框构建器
- 所有使用 `FormBuilderUtils.buildDropdown()` 的表单页面

**代码示例：**
```dart
FormBuilderDropdown<T>(
  name: name,
  items: items,
  decoration: InputDecoration(
    labelText: label,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Theme.of(context).primaryColor,
        width: 2,
      ),
    ),
    filled: true,
    fillColor: Theme.of(context).cardColor,
  ),
)
```

---

## 3. 选择组件样式 (Selection Component Styles)

### 3.1 **复选框样式** (`CheckboxStyle`)
**命名：`复选框样式` 或 `CheckboxStyle`**

**样式特征：**
- 使用 `FormBuilderCheckbox`
- 支持标题和副标题
- 默认未选中状态
- 支持禁用状态

**使用位置：**
- `form_builder_utils.dart` - `buildCheckbox()` - 复选框构建器
- `add_transaction_screen.dart` - 交易选项复选框

**代码示例：**
```dart
FormBuilderCheckbox(
  name: name,
  title: Text(title),
  subtitle: subtitle != null ? Text(subtitle) : null,
  initialValue: false,
)
```

---

### 3.2 **开关样式** (`SwitchStyle`)
**命名：`开关样式` 或 `SwitchStyle`**

**样式特征：**
- 使用 `FormBuilderSwitch` 或 `SwitchListTile`
- 支持标题和副标题
- 默认关闭状态
- 支持禁用状态

**使用位置：**
- `form_builder_utils.dart` - `buildSwitch()` - 开关构建器
- `add_transaction_screen.dart` - `SwitchListTile` - 交易选项开关
- `ai_config_screen.dart` - `SwitchListTile` - AI配置开关
- `developer_mode_screen.dart` - `Switch` - 开发者模式开关

**代码示例：**
```dart
FormBuilderSwitch(
  name: name,
  title: Text(title),
  subtitle: subtitle != null ? Text(subtitle) : null,
  initialValue: false,
)
```

---

### 3.3 **单选按钮样式** (`RadioButtonStyle`)
**命名：`单选按钮样式` 或 `RadioButtonStyle`**

**样式特征：**
- 使用 `Radio` 或 `RadioListTile`
- 支持分组选择
- 选中时显示主题色
- 支持禁用状态

**使用位置：**
- `ai_config_screen.dart` - `RadioListTile<AiProvider>` - AI提供商选择
- `asset_valuation_setup_screen.dart` - `Radio<DepreciationMethod>` - 折旧方法选择

**代码示例：**
```dart
Radio<T>(
  value: value,
  groupValue: groupValue,
  onChanged: onChanged,
  activeColor: Theme.of(context).primaryColor,
)
```

---

### 3.4 **滑块样式** (`SliderStyle`)
**命名：`滑块样式` 或 `SliderStyle`**

**样式特征：**
- 使用 `FormBuilderSlider` 或 `Slider`
- 支持最小值、最大值、分段数
- 支持数值格式化显示
- 支持禁用状态

**使用位置：**
- `form_builder_utils.dart` - `buildSlider()` - 滑块构建器
- `salary_income_setup_screen.dart` - `Slider` - 薪资比例滑块

**代码示例：**
```dart
FormBuilderSlider(
  name: name,
  min: min,
  max: max,
  divisions: divisions,
  numberFormat: NumberFormat('#.##'),
)
```

---

### 3.5 **分段选择器样式** (`SegmentedControlStyle`)
**命名：`分段选择器样式` 或 `SegmentedControlStyle`**

**样式特征：**
- 使用 `AppAnimations.animatedSegmentedControl()` 或自定义实现
- 灰色背景容器
- 选中项：白色背景 + 阴影 + 蓝色文字 + 粗体
- 未选中项：透明背景 + 灰色文字
- 支持动画过渡

**使用位置：**
- `app_animations.dart` - `animatedSegmentedControl()` - 分段选择器动画组件
- 时间周期选择（日/周/月/年）

**代码示例：**
```dart
AppAnimations.animatedSegmentedControl(
  segments: ['日', '周', '月', '年'],
  selectedIndex: selectedIndex,
  onChanged: (index) => setState(() => selectedIndex = index),
)
```

---

### 3.6 **标签芯片样式** (`ChipStyle`)
**命名：`标签芯片样式` 或 `ChipStyle`**

**样式特征：**
- 使用 `FilterChip` 或 `ChoiceChip`
- 圆角：8pt
- 选中时：主题色背景 + 白色文字
- 未选中时：灰色背景 + 深色文字
- 支持多选（FilterChip）或单选（ChoiceChip）

**使用位置：**
- `add_asset_sheet.dart` - `FilterChip` - 资产子分类选择
- `transaction_list_screen.dart` - `FilterChip` - 交易筛选标签
- `bonus_dialog_manager_simple.dart` - `FilterChip` / `ChoiceChip` - 奖金类型选择

**代码示例：**
```dart
FilterChip(
  label: Text(label),
  selected: isSelected,
  onSelected: (selected) => setState(() => isSelected = selected),
)
```

---

## 4. 按钮样式 (Button Styles)

### 4.1 **主要按钮样式** (`PrimaryButtonStyle`)
**命名：`主要按钮样式` 或 `PrimaryButtonStyle`**

**样式特征：**
- 使用 `ElevatedButton`
- 背景色：主题色（primaryAction - #007AFF）
- 文字颜色：白色
- 圆角：12pt
- 内边距：水平24pt，垂直16pt
- 无阴影（elevation: 0）
- 字体：15pt，中等粗细（FontWeight.w500）

**使用位置：**
- `app_theme.dart` - `elevatedButtonTheme` - 全局主题配置
- `form_builder_utils.dart` - `buildFormActions()` - 表单操作按钮
- 所有使用 `ElevatedButton` 的页面

**代码示例：**
```dart
ElevatedButton(
  onPressed: onPressed,
  style: ElevatedButton.styleFrom(
    backgroundColor: primaryAction,
    foregroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  ),
  child: Text('确定'),
)
```

---

### 4.2 **文本按钮样式** (`TextButtonStyle`)
**命名：`文本按钮样式` 或 `TextButtonStyle`**

**样式特征：**
- 使用 `TextButton`
- 文字颜色：主题色（primaryAction）
- 圆角：12pt
- 字体：15pt，中等粗细（FontWeight.w500）
- 无背景色

**使用位置：**
- `app_theme.dart` - `textButtonTheme` - 全局主题配置
- `form_builder_utils.dart` - `buildFormActions()` - 表单取消按钮
- 对话框操作按钮

**代码示例：**
```dart
TextButton(
  onPressed: onPressed,
  style: TextButton.styleFrom(
    foregroundColor: primaryAction,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  child: Text('取消'),
)
```

---

### 4.3 **轮廓按钮样式** (`OutlinedButtonStyle`)
**命名：`轮廓按钮样式` 或 `OutlinedButtonStyle`**

**样式特征：**
- 使用 `OutlinedButton`
- 边框：主题色边框
- 文字颜色：主题色
- 圆角：12pt
- 内边距：水平24pt，垂直16pt
- 无背景色

**使用位置：**
- `form_builder_utils.dart` - `buildFormActions()` - 表单取消按钮
- `family_info_home_screen.dart` - `ElevatedButton.icon` - 带边框的图标按钮

**代码示例：**
```dart
OutlinedButton(
  onPressed: onPressed,
  style: OutlinedButton.styleFrom(
    side: BorderSide(color: primaryAction),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  ),
  child: Text('取消'),
)
```

---

### 4.4 **图标按钮样式** (`IconButtonStyle`)
**命名：`图标按钮样式` 或 `IconButtonStyle`**

**样式特征：**
- 使用 `IconButton`
- 默认无背景
- 点击时显示水波纹效果
- 支持自定义图标大小和颜色

**使用位置：**
- 所有使用 `IconButton` 的页面（删除、编辑、设置等操作）

**代码示例：**
```dart
IconButton(
  icon: Icon(Icons.delete_outline),
  onPressed: onPressed,
  color: Colors.red,
)
```

---

### 4.5 **浮动操作按钮样式** (`FloatingActionButtonStyle`)
**命名：`浮动操作按钮样式` 或 `FloatingActionButtonStyle`**

**样式特征：**
- 使用 `FloatingActionButton` 或 `EnhancedFloatingActionButton`
- 圆形按钮
- 默认大小：56x56pt
- 背景色：主题色（primaryAction）
- 图标颜色：白色
- 支持脉冲动画和缩放动画（EnhancedFloatingActionButton）

**使用位置：**
- `enhanced_floating_action_button.dart` - `EnhancedFloatingActionButton` - 增强浮动按钮
- `transaction_flow_home_screen.dart` - 添加交易浮动按钮

**代码示例：**
```dart
EnhancedFloatingActionButton(
  onPressed: onPressed,
  icon: Icons.add,
  backgroundColor: primaryAction,
  foregroundColor: Colors.white,
  size: 56.0,
)
```

---

### 4.6 **带图标按钮样式** (`IconLabelButtonStyle`)
**命名：`带图标按钮样式` 或 `IconLabelButtonStyle`**

**样式特征：**
- 使用 `ElevatedButton.icon`
- 左侧图标：20pt大小
- 右侧文字标签
- 背景色：主背景色（primaryBackground）
- 文字颜色：主文字色（primaryText）
- 边框：分割线颜色（dividerColor）
- 圆角：8pt
- 内边距：水平16pt，垂直12pt

**使用位置：**
- `family_info_home_screen.dart` - `_buildActionButton()` - 操作按钮构建器

**代码示例：**
```dart
ElevatedButton.icon(
  onPressed: onPressed,
  icon: Icon(icon, size: 20),
  label: Text(label),
  style: ElevatedButton.styleFrom(
    backgroundColor: primaryBackground,
    foregroundColor: primaryText,
    elevation: 0,
    side: BorderSide(color: dividerColor),
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
)
```

---

## 5. 对话框样式 (Dialog Styles)

### 5.1 **确认对话框样式** (`ConfirmationDialogStyle`)
**命名：`确认对话框样式` 或 `ConfirmationDialogStyle`**

**样式特征：**
- 使用 `AlertDialog`
- 标题：粗体文字
- 内容：普通文字
- 操作按钮：取消（TextButton）+ 确定（TextButton，主题色）
- 圆角：默认Material圆角

**使用位置：**
- `unified_notifications.dart` - `showConfirmation()` - 统一确认对话框
- `period_difference_analysis_screen.dart` - 删除确认对话框
- `clearance_home_screen.dart` - 删除确认对话框
- `financial_planning_home_screen.dart` - 删除确认对话框

**代码示例：**
```dart
AlertDialog(
  title: Text(title),
  content: Text(message),
  actions: [
    TextButton(
      onPressed: () => Navigator.of(context).pop(false),
      child: Text('取消'),
    ),
    TextButton(
      onPressed: () => Navigator.of(context).pop(true),
      style: TextButton.styleFrom(
        foregroundColor: primaryAction,
      ),
      child: Text('确定'),
    ),
  ],
)
```

---

### 5.2 **底部表单样式** (`BottomSheetStyle`)
**命名：`底部表单样式` 或 `BottomSheetStyle`**

**样式特征：**
- 使用 `showModalBottomSheet` 或 `AppAnimations.showAppModalBottomSheet()`
- 白色背景
- 顶部圆角：16pt
- 显示拖拽手柄（showDragHandle: true）
- 支持滚动（isScrollControlled: true）
- 阴影：elevation: 8

**使用位置：**
- `app_animations.dart` - `showAppModalBottomSheet()` - 底部表单动画
- `add_asset_sheet.dart` - 添加资产底部表单
- `financial_planning_home_screen.dart` - 创建计划底部表单
- `account_detail_screen.dart` - 账户操作底部表单

**代码示例：**
```dart
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

---

## 6. 标签页样式 (Tab Styles)

### 6.1 **标准标签页样式** (`StandardTabStyle`)
**命名：`标准标签页样式` 或 `StandardTabStyle`**

**样式特征：**
- 使用 `TabBar` 和 `TabBarView`
- 标签栏：底部显示（bottom: TabBar）
- 选中标签：主题色下划线 + 主题色文字
- 未选中标签：灰色文字
- 标签视图：支持滑动切换

**使用位置：**
- `account_detail_screen.dart` - `TabBar` / `TabBarView` - 账户详情标签页
- `envelope_budget_detail_screen.dart` - 信封预算标签页
- `transaction_management_screen.dart` - 交易管理标签页
- `budget_management_screen.dart` - 预算管理标签页

**代码示例：**
```dart
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

---

## 7. 提示样式 (Notification Styles)

### 7.1 **SnackBar提示样式** (`SnackBarStyle`)
**命名：`SnackBar提示样式` 或 `SnackBarStyle`**

**样式特征：**
- 使用 `SnackBar`
- 底部显示
- 默认背景色：深灰色
- 文字颜色：白色
- 支持操作按钮（SnackBarAction）

**使用位置：**
- 所有使用 `ScaffoldMessenger.of(context).showSnackBar()` 的页面
- 33处使用，分布在15+个文件中

**代码示例：**
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('操作成功'),
    action: SnackBarAction(
      label: '撤销',
      onPressed: () => undoAction(),
    ),
  ),
)
```

---

### 7.2 **玻璃通知样式** (`GlassNotificationStyle`)
**命名：`玻璃通知样式` 或 `GlassNotificationStyle`**

**样式特征：**
- 使用 `GlassNotification` 组件
- 毛玻璃效果背景
- 顶部显示
- 支持成功、错误、警告、信息等类型
- 自动消失（可配置时长）

**使用位置：**
- `glass_notification.dart` - `GlassNotification` - 玻璃通知组件
- `unified_notifications.dart` - 统一通知系统（使用GlassNotification）

**代码示例：**
```dart
GlassNotification(
  type: NotificationType.success,
  message: '操作成功',
  duration: Duration(seconds: 2),
)
```

---

## 🎯 快速引用

以后只需要说：
- **"用标准文本输入框样式"** → 应用 `StandardTextFieldStyle`
- **"用金额输入框样式"** → 应用 `AmountInputFieldStyle`
- **"用标准下拉框样式"** → 应用 `StandardDropdownStyle`
- **"用复选框样式"** → 应用 `CheckboxStyle`
- **"用开关样式"** → 应用 `SwitchStyle`
- **"用单选按钮样式"** → 应用 `RadioButtonStyle`
- **"用滑块样式"** → 应用 `SliderStyle`
- **"用分段选择器样式"** → 应用 `SegmentedControlStyle`
- **"用标签芯片样式"** → 应用 `ChipStyle`
- **"用主要按钮样式"** → 应用 `PrimaryButtonStyle`
- **"用文本按钮样式"** → 应用 `TextButtonStyle`
- **"用轮廓按钮样式"** → 应用 `OutlinedButtonStyle`
- **"用图标按钮样式"** → 应用 `IconButtonStyle`
- **"用浮动操作按钮样式"** → 应用 `FloatingActionButtonStyle`
- **"用带图标按钮样式"** → 应用 `IconLabelButtonStyle`
- **"用确认对话框样式"** → 应用 `ConfirmationDialogStyle`
- **"用底部表单样式"** → 应用 `BottomSheetStyle`
- **"用标准标签页样式"** → 应用 `StandardTabStyle`
- **"用SnackBar提示样式"** → 应用 `SnackBarStyle`
- **"用玻璃通知样式"** → 应用 `GlassNotificationStyle`

---

## 📝 样式对比表

| 样式类型 | 组件 | 主要特征 | 使用场景 |
|---------|------|---------|---------|
| 标准文本输入框 | FormBuilderTextField | 12pt圆角，白色背景 | 通用文本输入 |
| 金额输入框 | AmountInputField | 右侧单位块，左侧圆角 | 金额输入 |
| 日期选择器 | FormBuilderDateTimePicker | 日历图标，日期格式 | 日期选择 |
| 标准下拉框 | FormBuilderDropdown | 12pt圆角，白色背景 | 选项选择 |
| 复选框 | FormBuilderCheckbox | 支持标题副标题 | 多选选项 |
| 开关 | FormBuilderSwitch | 开关切换 | 开关设置 |
| 单选按钮 | Radio | 分组选择 | 单选选项 |
| 滑块 | FormBuilderSlider | 数值范围选择 | 数值调节 |
| 分段选择器 | SegmentedControl | 分段切换 | 周期选择 |
| 标签芯片 | FilterChip | 标签选择 | 分类筛选 |
| 主要按钮 | ElevatedButton | 主题色背景 | 主要操作 |
| 文本按钮 | TextButton | 主题色文字 | 次要操作 |
| 轮廓按钮 | OutlinedButton | 主题色边框 | 取消操作 |
| 图标按钮 | IconButton | 图标操作 | 快捷操作 |
| 浮动操作按钮 | FloatingActionButton | 圆形浮动 | 添加操作 |
| 带图标按钮 | ElevatedButton.icon | 图标+文字 | 操作按钮 |
| 确认对话框 | AlertDialog | 标题+内容+按钮 | 确认操作 |
| 底部表单 | showModalBottomSheet | 底部弹出 | 表单输入 |
| 标准标签页 | TabBar | 标签切换 | 内容分类 |
| SnackBar提示 | SnackBar | 底部提示 | 操作反馈 |
| 玻璃通知 | GlassNotification | 顶部毛玻璃 | 统一通知 |

---

## 🔍 样式特征速查

### 按组件类型分类：
- **输入组件**：标准文本输入框、金额输入框、日期选择器
- **选择组件**：下拉框、复选框、开关、单选按钮、滑块、分段选择器、标签芯片
- **按钮组件**：主要按钮、文本按钮、轮廓按钮、图标按钮、浮动操作按钮、带图标按钮
- **对话框组件**：确认对话框、底部表单
- **导航组件**：标准标签页
- **提示组件**：SnackBar提示、玻璃通知

### 按圆角分类：
- **12pt圆角**：标准文本输入框、日期选择器、标准下拉框、主要按钮、文本按钮、轮廓按钮
- **8pt圆角**：金额输入框、带图标按钮、标签芯片
- **圆形**：浮动操作按钮、图标按钮

### 按颜色分类：
- **主题色背景**：主要按钮、浮动操作按钮
- **主题色文字**：文本按钮、轮廓按钮
- **主题色边框**：轮廓按钮、聚焦时的输入框

---

**最后更新：** 2024-12-19
**维护者：** AI Assistant

