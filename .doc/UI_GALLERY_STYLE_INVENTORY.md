# UI Gallery 样式编号清单

## 当前问题
- **S26 重复**：AI Natural Language Input 和 Switch Control List Item 都用了 S26
- **S27 重复**：Chart Container Card 和 List Item Styles 都用了 S27

## 正确的样式编号体系（根据设计文档）

### 输入框样式 (S1-S4)
- **S1**: 标准文本输入框样式 (`AppTextField`)
- **S2**: 金额输入框样式 (`AmountInputField`) - LEGACY
- **S3**: 日期选择器样式 (`AppTextField` + DatePicker)
- **S4**: 标准下拉框样式 (`AppTextField` + Dropdown)

### 选择组件样式 (S5-S10)
- **S5**: 复选框样式 (`AppCheckbox`)
- **S6**: 开关样式 (`AppSwitch`)
- **S7**: 单选按钮样式 (`RadioListTile`)
- **S8**: 滑块样式 (`Slider`)
- **S9**: 分段选择器样式 (`AppSegmentedControl`)
- **S10**: 标签芯片样式 (`AppTag`)

### 按钮样式 (S11-S16)
- **S11**: 主要按钮样式 (`AppPrimaryButton`)
- **S12**: 文本按钮样式 (`TextButton`)
- **S13**: 轮廓按钮样式 (`OutlinedButton`)
- **S14**: 图标按钮样式 (`IconButton`)
- **S15**: 浮动操作按钮样式 (`EnhancedFloatingActionButton`)
- **S16**: 带图标按钮样式 (`AppPrimaryButton` with icon)

### 对话框样式 (S17-S18)
- **S17**: 确认对话框样式 (`unifiedNotifications.showConfirmation()`)
- **S18**: 底部表单样式 (`AppAnimations.showAppModalBottomSheet()`)

### 标签页样式 (S19)
- **S19**: 标准标签页样式 (`TabBar` / `TabBarView`)

### 提示样式 (S20-S21)
- **S20**: SnackBar提示样式 (`ScaffoldMessenger.showSnackBar()`)
- **S21**: 玻璃通知样式 (`unifiedNotifications`)

### 数据展示与复合组件样式 (S22-S28)
- **S22**: 核心数据卡片样式 (`CoreDataCard`)
- **S23**: 只读结果展示行样式 (`ReadOnlyResultRow`)
- **S24**: 计算透明度详情样式 (`CalculationTransparencyDetail`)
- **S25**: 收支流水列表项样式 (`TransactionFlowListItem`)
- **S26**: AI自然语言输入框样式 (`AINaturalLanguageInput`)
- **S27**: 图表容器卡片样式 (`ChartContainerCard`)
- **S28**: 底部分页导航栏样式 (`BottomNavigationBar`)

### 状态与反馈样式 (S29-S31)
- **S29**: 骨架屏加载样式 (`AppShimmer`)
- **S30**: 空状态插画样式 (`AppEmptyState`)
- **S31**: 通知横幅样式 (`NotificationBanner`)

## 新增的列表行组件（需要新编号）

根据重构需求，新增了统一的列表行组件族，这些**不在原始 S1-S31 编号体系中**：

- **NavigableListItem** (导航/可编辑行) - 应该作为 S26 的一部分或独立编号
- **ReadOnlyDataListItem** (只读数据行) - 应该作为 S23 的变体或独立编号
- **SwitchControlListItem** (开关控制行) - 应该作为 S6 的变体或独立编号

## 建议的修复方案

### 方案1：将新组件作为现有样式的变体
- `SwitchControlListItem` → 作为 **S6 的变体**（开关样式）
- `NavigableListItem` → 作为 **S27 的变体**（图表容器卡片中的导航行）
- `ReadOnlyDataListItem` → 作为 **S23 的变体**（只读结果展示行）

### 方案2：扩展编号体系
- 新增 S32-S34 给列表行组件族

### 方案3：使用描述性标题（推荐）
- 不使用 S26/S27 重复编号
- 使用清晰的描述性标题，如：
  - "S26: AI Natural Language Input"
  - "List Item Styles: Switch Control" (不使用 S26)
  - "S27: Chart Container Card"
  - "List Item Styles: Navigable & Read-Only" (不使用 S27)

