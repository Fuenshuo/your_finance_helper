# UI Gallery 开发进度分析与开发计划

## 📊 当前开发进度总结

### ✅ 已完成功能

1. **基础组件展示**
   - ✅ Typography（排版系统）- 6种文本样式
   - ✅ Buttons（按钮）- AppPrimaryButton 的4种状态
   - ✅ Inputs（输入框）- AppTextField 的3种状态
   - ✅ Selection Controls（选择控件）- AppSwitch, AppCheckbox, AppSegmentedControl
   - ✅ Tags（标签）- AppTag 的5种颜色变体
   - ✅ Shimmer（骨架屏）- AppShimmer 的多种形状
   - ✅ Cards & Shadows（卡片和阴影）- AppCard 展示

2. **基础功能**
   - ✅ 深色/浅色模式切换（ThemeProvider）
   - ✅ 返回按钮
   - ✅ iOS Fintech 风格实现

### ❌ 缺失功能（对比 Design Token 系统要求）

#### 1. 主题系统缺失
- ❌ **4套主题切换**：当前只有深色/浅色模式，缺少 ModernForestGreen, EleganceDeepBlue, PremiumGraphite, ClassicBurgundy 主题
- ❌ **主题选择器 UI**：UI Gallery 中没有主题切换控件
- ❌ **AppDesignTokens 多主题支持**：当前只支持 iOS 蓝色（#007AFF），不支持4套主题配置

#### 2. 风格系统缺失
- ❌ **风格切换功能**：当前只有 iOS Fintech 风格，缺少 SharpProfessional 风格
- ❌ **风格选择器 UI**：UI Gallery 中没有风格切换控件
- ❌ **AppDesignTokens 风格切换**：缺少风格切换逻辑

#### 3. 复合样式展示缺失
- ❌ **S22 核心数据卡片样式**：缺少大字体主数值 + 描述性副标题的展示
- ❌ **S23 只读结果展示行样式**：缺少标题（左）+ 只读数值（右，灰色背景）的展示
- ❌ **S24 计算透明度详情样式**：缺少 microCaption 的展示
- ❌ **S25 收支流水列表项样式**：缺少左图标、中间描述、右侧金额（红/绿）的展示
- ❌ **S26 AI 自然语言输入框样式**：缺少文本输入框 + 语音图标 + AI预览区域的展示
- ❌ **S27 图表容器卡片样式**：缺少卡片 + 标题/切换器 + 图表区域的展示
- ❌ **S28 底部分页导航栏样式**：缺少 BottomNavigationBar 的展示

#### 4. 状态样式展示缺失
- ❌ **S29 骨架屏加载样式**：当前只有基础 Shimmer，缺少映射真实组件结构的骨架屏
- ❌ **S30 空状态插画样式**：缺少 AppEmptyState 的展示
- ❌ **S31 通知横幅样式**：缺少成功/警告/错误三种状态的横幅展示

#### 5. 输入组件展示缺失
- ❌ **S3 日期选择器样式**：缺少基于 AppTextField 包装的日期选择器示例
- ❌ **S4 下拉框样式**：缺少基于 AppTextField 包装的下拉框示例

#### 6. 对比展示缺失
- ❌ **iOS Fintech vs SharpProfessional 对比**：缺少两种风格的并排对比展示

---

## 🎯 开发计划（按优先级排序）

### Phase 1: 核心基础设施（必须优先完成）

#### Task 1.1: 扩展 AppDesignTokens 支持多主题系统
**优先级：** 🔴 最高  
**工作量：** 中等（2-3小时）

**实现内容：**
1. 在 `AppDesignTokens` 中定义4套主题的颜色配置
2. 创建 `AppTheme` 枚举（ModernForestGreen, EleganceDeepBlue, PremiumGraphite, ClassicBurgundy）
3. 修改 `primaryAction()` 等方法支持主题切换
4. 添加 `getCurrentTheme()` 和 `setTheme()` 方法

**代码结构：**
```dart
enum AppTheme {
  modernForestGreen,  // #004D40 / #8BC34A
  eleganceDeepBlue,   // #1A237E / #2E7D32
  premiumGraphite,    // #424242 / #4CAF50
  classicBurgundy,    // #4A148C / #66BB6A
}

class AppDesignTokens {
  static AppTheme _currentTheme = AppTheme.modernForestGreen;
  
  static Color primaryColor(BuildContext context, {AppTheme? theme}) {
    final t = theme ?? _currentTheme;
    // 根据主题返回对应颜色
  }
  
  // ... 其他颜色方法
}
```

**验收标准：**
- [ ] 4套主题的颜色配置完整定义
- [ ] 所有颜色方法支持主题参数
- [ ] 向后兼容（不传主题参数时使用当前主题）

---

#### Task 1.2: 扩展 AppDesignTokens 支持风格切换
**优先级：** 🔴 最高  
**工作量：** 中等（2-3小时）

**实现内容：**
1. 创建 `AppStyle` 枚举（iOSFintech, SharpProfessional）
2. 修改圆角、阴影等方法支持风格切换
3. 添加 `getCurrentStyle()` 和 `setStyle()` 方法

**代码结构：**
```dart
enum AppStyle {
  iOSFintech,          // 12pt/16pt圆角，弥散阴影
  SharpProfessional,   // 8pt圆角，清晰阴影
}

class AppDesignTokens {
  static AppStyle _currentStyle = AppStyle.iOSFintech;
  
  static double borderRadius(BuildContext context, {AppStyle? style}) {
    final s = style ?? _currentStyle;
    return s == AppStyle.iOSFintech ? 16.0 : 8.0;
  }
  
  // ... 其他样式方法
}
```

**验收标准：**
- [ ] 两种风格的圆角、阴影配置完整
- [ ] 所有样式方法支持风格参数
- [ ] 向后兼容

---

#### Task 1.3: 创建 ThemeStyleProvider 管理主题和风格状态
**优先级：** 🔴 最高  
**工作量：** 小（1小时）

**实现内容：**
1. 创建 `ThemeStyleProvider` 继承 `ChangeNotifier`
2. 管理当前主题和风格状态
3. 提供切换方法
4. 持久化存储（SharedPreferences）

**代码结构：**
```dart
class ThemeStyleProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.modernForestGreen;
  AppStyle _currentStyle = AppStyle.iOSFintech;
  
  AppTheme get currentTheme => _currentTheme;
  AppStyle get currentStyle => _currentStyle;
  
  Future<void> setTheme(AppTheme theme) async {
    // 更新状态 + 持久化
  }
  
  Future<void> setStyle(AppStyle style) async {
    // 更新状态 + 持久化
  }
}
```

**验收标准：**
- [ ] 主题和风格状态管理正常
- [ ] 切换后状态持久化
- [ ] 应用重启后恢复上次选择

---

### Phase 2: UI Gallery 功能扩展

#### Task 2.1: 在 UI Gallery 中添加主题选择器
**优先级：** 🟡 高  
**工作量：** 小（1小时）

**实现内容：**
1. 在 AppBar actions 中添加主题选择器（下拉菜单或 SegmentedControl）
2. 展示4套主题的预览色块
3. 切换主题时更新整个 Gallery

**UI 设计：**
- 使用 `AppSegmentedControl` 或下拉菜单
- 每个主题显示主色和成功色的预览

**验收标准：**
- [ ] 4套主题可以切换
- [ ] 切换后所有组件颜色立即更新
- [ ] UI 展示清晰直观

---

#### Task 2.2: 在 UI Gallery 中添加风格选择器
**优先级：** 🟡 高  
**工作量：** 小（1小时）

**实现内容：**
1. 在 AppBar actions 中添加风格切换开关
2. 切换风格时更新圆角、阴影等样式
3. 提供并排对比展示

**UI 设计：**
- 使用 `AppSwitch` 或 `AppSegmentedControl`
- 切换时显示风格名称和关键特征

**验收标准：**
- [ ] 两种风格可以切换
- [ ] 切换后所有组件样式立即更新
- [ ] 圆角和阴影变化明显可见

---

#### Task 2.3: 添加复合样式展示（S22-S28）
**优先级：** 🟡 高  
**工作量：** 中等（3-4小时）

**实现内容：**
1. **S22 核心数据卡片**：大字体主数值 + 描述性副标题
2. **S23 只读结果展示行**：标题（左）+ 只读数值（右，灰色背景）
3. **S24 计算透明度详情**：microCaption 展示
4. **S25 收支流水列表项**：左图标、中间描述、右侧金额（红/绿）
5. **S26 AI 自然语言输入框**：文本输入框 + 语音图标 + AI预览区域
6. **S27 图表容器卡片**：卡片 + 标题/切换器 + 图表占位符
7. **S28 底部分页导航栏**：BottomNavigationBar 展示

**验收标准：**
- [ ] 所有7种复合样式都有完整展示
- [ ] 样式符合 Design Token 规范
- [ ] 交互效果正常（如点击、切换）

---

#### Task 2.4: 添加状态样式展示（S29-S31）
**优先级：** 🟡 高  
**工作量：** 中等（2-3小时）

**实现内容：**
1. **S29 骨架屏加载**：映射真实组件结构的骨架屏（列表项、卡片）
2. **S30 空状态插画**：AppEmptyState 的完整展示
3. **S31 通知横幅**：成功/警告/错误三种状态的横幅

**验收标准：**
- [ ] 骨架屏形状映射真实组件
- [ ] 空状态展示完整（图标+文字+按钮）
- [ ] 通知横幅三种状态都展示

---

#### Task 2.5: 添加输入组件展示（S3, S4）
**优先级：** 🟢 中  
**工作量：** 小（1小时）

**实现内容：**
1. **S3 日期选择器**：基于 AppTextField 包装的日期选择器
2. **S4 下拉框**：基于 AppTextField 包装的下拉框（带 suffixIcon）

**验收标准：**
- [ ] 日期选择器可以正常选择日期
- [ ] 下拉框可以正常选择选项
- [ ] 视觉风格符合 iOS Fintech

---

#### Task 2.6: 添加风格对比展示
**优先级：** 🟢 中  
**工作量：** 小（1小时）

**实现内容：**
1. 创建并排对比展示区域
2. 左侧 iOS Fintech，右侧 SharpProfessional
3. 展示关键组件的差异（圆角、阴影、边框）

**验收标准：**
- [ ] 两种风格差异清晰可见
- [ ] 对比展示直观易懂

---

## 📋 开发节奏建议

### Week 1: 基础设施（Phase 1）
- **Day 1-2**: Task 1.1 + Task 1.2（多主题和风格系统）
- **Day 3**: Task 1.3（ThemeStyleProvider）
- **Day 4-5**: 测试和修复

### Week 2: UI Gallery 扩展（Phase 2）
- **Day 1**: Task 2.1 + Task 2.2（主题和风格选择器）
- **Day 2-3**: Task 2.3（复合样式展示）
- **Day 4**: Task 2.4（状态样式展示）
- **Day 5**: Task 2.5 + Task 2.6（输入组件和对比展示）

---

## 🔍 关键差异总结（Diff）

### 当前实现 vs 目标实现

| 功能模块 | 当前状态 | 目标状态 | 差异 |
|---------|---------|---------|------|
| **主题系统** | 只有深色/浅色模式 | 4套主题 + 深色/浅色模式 | 缺少4套主题配置和切换功能 |
| **风格系统** | 只有 iOS Fintech | iOS Fintech + SharpProfessional | 缺少风格切换功能 |
| **复合样式** | 无 | 7种复合样式（S22-S28） | 完全缺失 |
| **状态样式** | 基础 Shimmer | 3种状态样式（S29-S31） | 部分缺失（缺少空状态和通知横幅） |
| **输入组件** | 基础 AppTextField | AppTextField + 日期选择器 + 下拉框 | 缺少包装示例 |
| **对比展示** | 无 | iOS Fintech vs SharpProfessional | 完全缺失 |

---

## ⚠️ 注意事项

1. **向后兼容**：所有新功能必须保持向后兼容，不影响现有代码
2. **性能考虑**：主题和风格切换应该流畅，避免重建整个 Widget 树
3. **持久化**：用户选择的主题和风格应该持久化存储
4. **测试覆盖**：每个新功能都应该有对应的 UI Gallery 展示

---

## 📝 下一步行动

1. **立即开始**：Task 1.1（扩展 AppDesignTokens 支持多主题系统）
2. **并行开发**：可以同时进行 Task 1.2（风格切换）和 Task 1.3（Provider）
3. **验证方式**：每个 Task 完成后在 UI Gallery 中验证效果

