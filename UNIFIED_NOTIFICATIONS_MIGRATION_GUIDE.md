# 统一提示系统迁移指南

## 🎯 概述

我们已经建立了一个统一的提示系统，用于替代项目中分散的提示方式。该系统提供：

- **统一API接口** - 所有提示都使用相同的调用方式
- **智能路由** - 根据上下文自动选择最佳显示方式
- **类型安全** - 强类型枚举确保提示类型正确
- **一致体验** - 统一的视觉风格和交互行为

## 📊 迁移统计

### 当前使用情况
- **SnackBar**: 33处使用，分布在15+个文件中
- **AlertDialog**: 13处使用，主要用于确认操作
- **NotificationManager**: 4处使用，功能最完善但覆盖率低
- **showModalBottomSheet**: 14处使用
- **动画提示组件**: 4处使用（仅定义，未广泛使用）

### 迁移优先级
1. **高优先级**: SnackBar → UnifiedNotifications
2. **中优先级**: 直接AlertDialog调用 → UnifiedNotifications
3. **低优先级**: NotificationManager保持兼容

## 🔄 迁移步骤

### 步骤1: 导入新的统一提示系统

```dart
// 在需要使用提示的文件顶部添加导入
import 'package:your_finance_flutter/core/utils/unified_notifications.dart';
```

### 步骤2: 替换SnackBar调用

#### 旧代码：
```dart
// 简单的成功提示
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('保存成功'))
);

// 带操作的提示
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('数据已更新'),
    action: SnackBarAction(
      label: '撤销',
      onPressed: () => undoAction(),
    ),
  ),
);
```

#### 新代码：
```dart
// 简单的成功提示
unifiedNotifications.showSuccess(context, '保存成功');

// 带操作的提示
unifiedNotifications.showSuccess(
  context,
  '数据已更新',
  actionLabel: '撤销',
  actionCallback: () => undoAction(),
);
```

### 步骤3: 替换AlertDialog确认对话框

#### 旧代码：
```dart
final result = await showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('确认删除'),
    content: const Text('确定要删除这个项目吗？'),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: const Text('取消'),
      ),
      TextButton(
        onPressed: () => Navigator.of(context).pop(true),
        child: const Text('删除'),
      ),
    ],
  ),
);
```

#### 新代码：
```dart
// 通用确认对话框
final result = await unifiedNotifications.showConfirmation(
  context,
  title: '确认删除',
  message: '确定要删除这个项目吗？',
);

// 删除确认对话框（预设样式）
final result = await unifiedNotifications.showDeleteConfirmation(
  context,
  '这个项目',
);
```

### 步骤4: 更新NotificationManager调用

#### NotificationManager保持兼容，但建议迁移到统一接口：

```dart
// 旧代码（仍然可用）
NotificationManager().showSuccess(context, '操作成功');

// 新代码（推荐）
unifiedNotifications.showSuccess(context, '操作成功');
```

## 🎨 提示类型说明

### NotificationType枚举

| 类型 | 适用场景 | 默认时长 | 显示方式 |
|------|----------|----------|----------|
| `info` | 普通信息提示 | 2秒 | GlassNotification |
| `success` | 操作成功反馈 | 2秒 | GlassNotification |
| `warning` | 警告信息 | 3秒 | GlassNotification |
| `error` | 错误信息 | 4秒 | GlassNotification |
| `critical` | 严重错误（需要确认） | 不自动关闭 | AlertDialog |
| `development` | 开发中功能提示 | 2秒 | GlassNotification |

### 智能路由规则

系统会根据上下文自动选择最佳显示方式：

- **严重错误** → 总是使用AlertDialog
- **在模态框中** → 使用AlertDialog避免层级问题
- **键盘可见时** → 使用AlertDialog避免被遮挡
- **横屏模式** → 使用AlertDialog提供更好可读性
- **其他情况** → 使用GlassNotification

## 📝 具体文件迁移示例

### 1. ios_animation_showcase.dart
```dart
// 旧代码
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('操作已确认')),
);

// 新代码
unifiedNotifications.showSuccess(context, '操作已确认');
```

### 2. dashboard_screen.dart
```dart
// 旧代码
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('功能开发中')),
);

// 新代码
unifiedNotifications.showDevelopment(context, '该功能');
```

### 3. asset_management_screen.dart
```dart
// 旧代码
final confirmed = await showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('确认删除'),
    content: Text('确定要删除 $assetName 吗？'),
    actions: [...],
  ),
);

// 新代码
final confirmed = await unifiedNotifications.showDeleteConfirmation(
  context,
  assetName,
);
```

## 🔧 高级用法

### 自定义配置
```dart
unifiedNotifications.showWithConfig(
  context,
  NotificationConfig(
    type: NotificationType.warning,
    message: '自定义警告消息',
    duration: const Duration(seconds: 5),
    backgroundColor: Colors.orange.withOpacity(0.1),
    icon: Icons.warning,
  ),
);
```

### 强制指定显示方式
```dart
// 虽然不推荐，但如果需要强制使用特定方式
final config = NotificationConfig.fromType(
  NotificationType.error,
  '网络连接失败',
);

// 系统会自动选择最佳方式，但你可以通过扩展系统来自定义
```

## 🧪 测试建议

### 迁移验证
1. **功能测试**: 确保所有提示都能正常显示
2. **上下文测试**: 在不同场景下测试提示行为
   - 正常页面
   - 模态框中
   - 键盘弹出时
   - 横屏模式

3. **兼容性测试**: 确保在不同设备上表现一致

### 性能测试
- 提示显示/隐藏动画流畅度
- 多个提示的队列处理
- 内存使用情况

## 📋 检查清单

### 迁移完成检查
- [ ] 所有SnackBar调用已替换
- [ ] 所有AlertDialog确认框已替换
- [ ] NotificationManager调用已更新
- [ ] 导入语句已添加
- [ ] 功能测试通过
- [ ] 视觉效果一致

### 代码质量检查
- [ ] 无编译错误
- [ ] 遵循Dart代码规范
- [ ] 适当的错误处理
- [ ] 性能优化完成

## 🚀 后续优化

### 阶段二计划
1. **个性化配置** - 用户可自定义提示偏好
2. **可访问性优化** - 支持屏幕阅读器等
3. **动画增强** - 更丰富的动效
4. **统计分析** - 提示使用情况分析

### 长期规划
1. **智能学习** - 根据用户行为调整提示策略
2. **多语言支持** - 提示文本国际化
3. **主题适配** - 更好的主题集成

---

## 📞 支持

如果在迁移过程中遇到问题，请：

1. 查看本文档的对应章节
2. 检查代码示例是否正确
3. 运行测试验证功能
4. 如有疑问，请查看UnifiedNotifications类的实现

统一的提示系统将为您的应用提供更好的一致性和用户体验！ 🎉
