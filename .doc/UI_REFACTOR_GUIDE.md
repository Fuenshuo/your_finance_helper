# UI重构指南 - 从后端思维到前端工程化

**更新时间**: 2025-01-13  
**目标**: 建立完整的设计系统，实现UI工程化

---

## 📋 已完成的工作

### 1. Design Token层建立 ✅

**文件**: `lib/core/theme/app_design_tokens.dart`

- ✅ **色彩系统**: 语义化颜色（primaryBackground, successColor等）
- ✅ **间距系统**: 8pt网格系统（spacing2到spacing48）
- ✅ **圆角系统**: 统一的圆角值（borderRadius4到borderRadius24）
- ✅ **字体系统**: 字体大小和字重Token
- ✅ **阴影系统**: 小/中/大三种阴影
- ✅ **动画时长**: Fast/Medium/Slow
- ✅ **组件尺寸**: 按钮高度、输入框高度等

**使用方式**:
```dart
// ❌ 错误：硬编码
Container(
  padding: EdgeInsets.all(16.0),
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(12.0),
  ),
)

// ✅ 正确：使用Token
Container(
  padding: EdgeInsets.all(AppDesignTokens.spacing16),
  decoration: BoxDecoration(
    color: AppDesignTokens.primaryAction,
    borderRadius: BorderRadius.circular(AppDesignTokens.borderRadius12),
  ),
)
```

### 2. 原子化组件封装 ✅

#### AppPrimaryButton
**文件**: `lib/core/widgets/app_primary_button.dart`

- ✅ 封装所有按钮状态：Normal, Loading, Disabled
- ✅ 点击反馈动画（Scale）
- ✅ 支持图标+文字组合
- ✅ 统一的样式和尺寸

**使用方式**:
```dart
AppPrimaryButton(
  onPressed: () => handleSubmit(),
  label: '提交',
  icon: Icons.check,
  isLoading: isSubmitting,
  isEnabled: formIsValid,
)
```

#### AppTextField
**文件**: `lib/core/widgets/app_text_field.dart`

- ✅ 封装所有输入框状态：Normal, Focus, Error, Disabled
- ✅ 统一的样式和验证反馈
- ✅ 支持前缀/后缀图标

**使用方式**:
```dart
AppTextField(
  labelText: '金额',
  hintText: '请输入金额',
  errorText: validationError,
  prefixIcon: Icon(Icons.attach_money),
  keyboardType: TextInputType.number,
  validator: (value) => value?.isEmpty ?? true ? '不能为空' : null,
)
```

#### AppEmptyState
**文件**: `lib/core/widgets/app_empty_state.dart`

- ✅ 统一的空状态展示
- ✅ 预定义的常用空状态（空列表、加载失败、搜索无结果等）
- ✅ 支持自定义操作按钮

**使用方式**:
```dart
// 空列表
AppEmptyStates.emptyList(
  actionLabel: '添加资产',
  onAction: () => navigateToAdd(),
)

// 加载失败
AppEmptyStates.loadError(
  onRetry: () => retryLoad(),
)
```

### 3. 错误处理系统 ✅

**文件**: `lib/core/widgets/app_error_handler.dart`

- ✅ 统一的错误处理入口
- ✅ 友好的错误提示（SnackBar）
- ✅ 错误页面（全屏）
- ✅ 分类错误处理（网络、AI、验证、存储）

**使用方式**:
```dart
try {
  await someOperation();
} catch (e) {
  AppErrorHandler.handleError(
    context,
    e,
    onRetry: () => retryOperation(),
  );
}
```

### 4. Shimmer骨架屏 ✅

**文件**: `lib/core/widgets/app_shimmer.dart`

- ✅ 统一的加载占位效果
- ✅ 预定义的组件骨架屏（卡片、列表项、文本、按钮）

**使用方式**:
```dart
// 列表加载中
isLoading
  ? Column(
      children: List.generate(
        3,
        (index) => AppShimmerWidgets.listItem(),
      ),
    )
  : actualList
```

### 5. AI功能工程化 ✅

**文件**: `lib/core/services/ai/ai_service_isolate.dart`

- ✅ Isolate隔离线程解析JSON
- ✅ 避免阻塞UI线程
- ✅ 结构化数据验证

**使用方式**:
```dart
final parsed = await AIServiceIsolate.parseAIResponseInIsolate(
  response: aiResponse,
  contextData: contextData,
);
```

---

## 🚧 待完成的工作

### 1. 状态管理优化（优先级：高）

**问题**: Provider粒度过大，导致不必要的重绘

**解决方案**:
- 拆分Provider：SalaryNotifier, AssetNotifier, WalletNotifier
- 使用Selector/Consumer局部刷新
- 将Consumer下沉到具体Widget节点

**示例**:
```dart
// ❌ 错误：整个页面重绘
Consumer<FamilyInfoProvider>(
  builder: (context, provider, child) => Scaffold(
    body: Column(
      children: [
        Text(provider.salary.toString()), // 只改这个
        Text(provider.asset.toString()),   // 但整个Column都重绘
      ],
    ),
  ),
)

// ✅ 正确：局部刷新
Scaffold(
  body: Column(
    children: [
      Selector<FamilyInfoProvider, double>(
        selector: (_, provider) => provider.salary,
        builder: (context, salary, child) => Text(salary.toString()),
      ),
      Selector<FamilyInfoProvider, double>(
        selector: (_, provider) => provider.asset,
        builder: (context, asset, child) => Text(asset.toString()),
      ),
    ],
  ),
)
```

### 2. 业务逻辑抽离（优先级：高）

**问题**: UI层包含计算逻辑

**解决方案**:
- 创建Domain层（纯Dart类）
- 抽离计算逻辑（个税计算、贷款利息等）
- UI层只负责展示和触发

**示例**:
```dart
// ❌ 错误：UI层包含计算逻辑
onPressed: () {
  final tax = (salary - 5000) * 0.1; // 计算逻辑在UI层
  setState(() => netSalary = salary - tax);
}

// ✅ 正确：Domain层处理
onPressed: () {
  final calculator = PersonalIncomeTaxCalculator();
  final result = calculator.calculate(salary: salary);
  setState(() => netSalary = result.netIncome);
}
```

### 3. 安装依赖包（优先级：中）

需要运行：
```bash
flutter pub get
```

安装shimmer包后，更新`app_shimmer.dart`使用真正的Shimmer效果。

### 4. 重构现有页面（优先级：中）

逐步将现有页面中的硬编码样式替换为Design Token和原子化组件：

- [ ] Dashboard首页
- [ ] 资产列表页面
- [ ] 交易记录页面
- [ ] 表单页面

### 5. 添加Hero动画（优先级：低）

为卡片跳转添加Hero动画：
```dart
Hero(
  tag: 'asset_${asset.id}',
  child: AssetCard(asset: asset),
)
```

---

## 📝 代码规范

### 1. 严禁硬编码

```dart
// ❌ 错误
Container(
  padding: EdgeInsets.all(16.0),
  color: Colors.blue,
)

// ✅ 正确
Container(
  padding: EdgeInsets.all(AppDesignTokens.spacing16),
  color: AppDesignTokens.primaryAction,
)
```

### 2. 使用原子化组件

```dart
// ❌ 错误：直接使用Material组件
ElevatedButton(
  onPressed: () => {},
  child: Text('提交'),
)

// ✅ 正确：使用封装组件
AppPrimaryButton(
  onPressed: () => {},
  label: '提交',
)
```

### 3. 统一错误处理

```dart
// ❌ 错误：直接显示错误
catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.toString())),
  );
}

// ✅ 正确：使用错误处理器
catch (e) {
  AppErrorHandler.handleError(context, e);
}
```

### 4. 空状态处理

```dart
// ❌ 错误：空白页面
if (items.isEmpty) {
  return Center(child: Text('暂无数据'));
}

// ✅ 正确：使用空状态组件
if (items.isEmpty) {
  return AppEmptyStates.emptyList(
    actionLabel: '添加',
    onAction: () => navigateToAdd(),
  );
}
```

---

## 🎯 下一步行动

1. **立即执行**:
   - 运行 `flutter pub get` 安装shimmer包
   - 更新shimmer组件使用真正的Shimmer效果

2. **本周完成**:
   - 重构Dashboard首页使用新组件
   - 拆分Provider，优化状态管理
   - 抽离业务逻辑到Domain层

3. **持续优化**:
   - 逐步重构所有页面
   - 添加Hero动画
   - 性能优化和测试

---

## 📚 相关文档

- [Design Token文档](lib/core/theme/app_design_tokens.dart)
- [UI组件样式指南](.cursor/rules/ui-component-styles.mdc)
- [UI设计系统规范](.cursor/rules/ui-design-system.mdc)

