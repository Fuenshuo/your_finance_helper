# 设计系统迁移计划

**目标**: 从兼容模式迁移到纯iOS风格设计系统

---

## 📊 当前状态

### 使用旧Token的文件
- `lib/screens/dashboard_home_screen.dart` - Dashboard首页
- `lib/core/widgets/app_empty_state.dart` - 空状态组件
- `lib/core/widgets/app_shimmer.dart` - Shimmer组件
- `lib/core/widgets/app_error_handler.dart` - 错误处理
- `lib/screens/developer_mode_screen.dart` - 开发者模式（使用context扩展）

### 已使用新Token的文件
- `lib/core/widgets/app_primary_button.dart` - ✅ 新iOS风格
- `lib/core/widgets/app_text_field.dart` - ✅ 新iOS风格
- `lib/core/widgets/app_card.dart` - ✅ 新iOS风格（部分兼容）
- `lib/screens/debug_ui_kit_screen.dart` - ✅ 新UI Gallery

---

## 🎯 迁移策略

### 方案A：验证后一次性全量迁移（推荐）

**优点**:
- 代码风格统一
- 移除兼容层，代码更简洁
- 一次性完成，不留技术债

**步骤**:
1. ✅ 验证新设计系统（UI Gallery测试）
2. ⏳ 全量替换旧Token → 新Token
3. ⏳ 删除兼容性方法
4. ⏳ 测试所有页面

### 方案B：逐步迁移

**优点**:
- 风险分散
- 可以逐个页面验证

**步骤**:
1. Dashboard首页 → 新Token
2. 组件库 → 新Token
3. 其他页面 → 新Token
4. 删除兼容层

---

## 📝 Token映射表

### 颜色Token
```dart
// 旧 → 新
AppDesignTokens.primaryBackground(context) → AppDesignTokens.pageBackground(context)
AppDesignTokens.accentBackground(context) → AppDesignTokens.surface(context)
AppDesignTokens.surfaceColor(context) → AppDesignTokens.surface(context)
AppDesignTokens.primaryText(context) → AppDesignTokens._textColor(context)
AppDesignTokens.secondaryText(context) → AppDesignTokens._textColor(context).withOpacity(0.6)
AppDesignTokens.tertiaryText(context) → AppDesignTokens._textColor(context).withOpacity(0.4)
AppDesignTokens.dividerColor(context) → AppDesignTokens._textColor(context).withOpacity(0.1)
AppDesignTokens.borderColor(context) → AppDesignTokens._textColor(context).withOpacity(0.1)
```

### 文本样式Token
```dart
// 旧 → 新
AppTextStyles.displayLarge(context) → AppDesignTokens.largeTitle(context)
AppTextStyles.displayMedium(context) → AppDesignTokens.title1(context)
AppTextStyles.headlineMedium(context) → AppDesignTokens.headline(context)
AppTextStyles.bodyLarge(context) → AppDesignTokens.body(context)
AppTextStyles.bodyMedium(context) → AppDesignTokens.body(context).copyWith(fontSize: 15)
AppTextStyles.bodySmall(context) → AppDesignTokens.caption(context)
AppTextStyles.button(context) → AppDesignTokens.headline(context).copyWith(color: Colors.white)
AppTextStyles.label(context) → AppDesignTokens.caption(context)
```

### 阴影Token
```dart
// 旧 → 新
AppDesignTokens.shadowSmall(context) → AppDesignTokens.primaryShadow(context)
AppDesignTokens.shadowMedium(context) → AppDesignTokens.primaryShadow(context)
AppDesignTokens.shadowLarge(context) → AppDesignTokens.primaryShadow(context)
```

---

## ✅ 验证清单

在删除兼容层之前，确保：

- [ ] UI Gallery页面显示正常
- [ ] 深色模式切换正常
- [ ] Dashboard首页显示正常
- [ ] 所有组件在不同状态下显示正常
- [ ] 按钮点击动画流畅
- [ ] 输入框聚焦效果正常
- [ ] 卡片阴影效果符合预期
- [ ] 文本排版呼吸感良好

---

## 🚀 执行建议

**建议采用方案A（一次性全量迁移）**：

1. **现在**: 保留兼容层，验证新设计系统
2. **验证完成后**: 
   - 使用全局搜索替换所有旧Token
   - 删除兼容性方法
   - 运行测试确保无遗漏
3. **好处**: 代码更干净，没有历史包袱

---

## 📋 迁移脚本（待执行）

验证完成后，可以运行以下全局替换：

```bash
# 颜色Token替换
find lib -name "*.dart" -exec sed -i '' 's/AppDesignTokens\.primaryBackground(context)/AppDesignTokens.pageBackground(context)/g' {} \;
find lib -name "*.dart" -exec sed -i '' 's/AppDesignTokens\.surfaceColor(context)/AppDesignTokens.surface(context)/g' {} \;

# 文本样式替换
find lib -name "*.dart" -exec sed -i '' 's/AppTextStyles\.headlineMedium(context)/AppDesignTokens.headline(context)/g' {} \;
find lib -name "*.dart" -exec sed -i '' 's/AppTextStyles\.bodyLarge(context)/AppDesignTokens.body(context)/g' {} \;
# ... 等等
```

**或者** 使用IDE的全局搜索替换功能更安全。

---

## ⚠️ 注意事项

1. **不要同时保留两套系统** - 验证完立即迁移，避免混乱
2. **测试覆盖** - 迁移后测试所有页面
3. **深色模式** - 确保深色模式下所有组件正常
4. **性能** - 新Token都是方法调用，性能影响可忽略

---

## 🎯 下一步

1. ✅ 验证新UI Gallery
2. ⏳ 验证Dashboard首页
3. ⏳ 验证所有组件状态
4. ⏳ **全量迁移 + 删除兼容层**
5. ⏳ 最终测试

