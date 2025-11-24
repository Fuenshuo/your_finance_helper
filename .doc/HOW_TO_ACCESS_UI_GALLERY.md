# 如何访问UI Gallery页面

**UI Gallery** 是一个组件测试页面，用于展示所有Design Token和原子化组件，支持深色模式切换。

---

## 🚀 访问方式

### 方式1：通过设置页面（推荐）

1. **打开应用** → 进入 **"设置"** 页面（Tab 5）
2. **开启开发者模式**：
   - 连续点击设置页面顶部标题 **"设置"** 5次
   - 看到橙色 "已开启" 标签表示成功
3. **进入开发者模式**：
   - 点击 "开发者选项" 卡片中的箭头按钮
   - 进入开发者模式页面
4. **打开UI Gallery**：
   - 在开发者模式页面找到 **"UI工具"** 卡片
   - 点击 **"UI Gallery / 组件测试"** 按钮（紫色按钮）

### 方式2：直接路由（开发时）

如果你在开发环境中，可以直接使用路由：

```dart
// 在代码中导航
context.go('/debug-ui-kit');

// 或使用扩展方法
context.goDebugUIKit();
```

---

## 📱 UI Gallery功能

### 1. 颜色系统展示
- 展示所有语义化颜色（Primary, Success, Error等）
- 实时预览浅色/深色模式效果

### 2. 文本样式展示
- Display Large/Medium
- Headline Medium
- Body Large/Medium/Small
- Button, Label样式

### 3. 间距系统展示
- 8pt网格系统
- spacing2 到 spacing32

### 4. 圆角系统展示
- borderRadius4 到 borderRadius24

### 5. 按钮组件测试
- AppPrimaryButton（主要按钮）
- AppSecondaryButton（次要按钮）
- Loading状态
- Disabled状态

### 6. 输入框组件测试
- 标准输入框
- 带前缀图标
- 错误状态
- 禁用状态

### 7. 卡片组件测试
- 基础卡片
- 可点击卡片

### 8. 空状态组件测试
- 空列表
- 加载错误
- 自定义空状态

### 9. Shimmer骨架屏测试
- 卡片骨架屏
- 列表项骨架屏
- 文本骨架屏
- 按钮骨架屏

### 10. 错误处理测试
- 网络错误
- AI错误
- 验证错误

---

## 🌓 深色模式测试

在UI Gallery页面右上角有一个 **🌙/☀️** 图标按钮，点击可以：
- 切换浅色/深色模式
- 实时预览所有组件在不同主题下的效果
- 验证颜色Token是否正确适配

---

## 💡 使用建议

1. **视觉验证**：在UI Gallery中调整Token值，直到所有组件看起来协调
2. **组件测试**：在业务页面使用组件前，先在UI Gallery中测试所有状态
3. **深色模式**：确保所有组件在深色模式下都正常显示
4. **间距检查**：确认spacing和borderRadius的搭配是否合理

---

## 🔧 开发提示

如果UI Gallery页面无法访问，请检查：

1. ✅ 是否已开启开发者模式（连续点击设置标题5次）
2. ✅ 路由是否正确配置（`/debug-ui-kit`）
3. ✅ `DebugUIKitScreen` 文件是否存在
4. ✅ 是否在正确的分支（`refactor/ui-design-system`）

---

## 📝 相关文件

- UI Gallery页面：`lib/screens/debug_ui_kit_screen.dart`
- 路由配置：`lib/core/router/app_router.dart`
- 开发者模式：`lib/screens/developer_mode_screen.dart`
- Design Token：`lib/core/theme/app_design_tokens.dart`

