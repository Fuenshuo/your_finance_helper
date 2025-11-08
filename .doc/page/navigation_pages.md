# 🚀 导航层页面详解

本层包含应用的核心导航和入口页面，负责用户流程的引导和主要功能模块的访问。

## 📱 核心导航页面

### HomeScreen (应用入口)
**文件位置**: `lib/screens/home_screen.dart`
**功能**: 应用的根页面，负责状态路由和初始化检查

#### 主要职责
- **数据库初始化**: 等待Riverpod数据库服务初始化完成
- **状态路由**: 根据资产数据状态决定显示引导页或主导航页
- **依赖管理**: 集成Riverpod状态管理和数据库服务

#### 数据依赖
```dart
// Riverpod依赖
final assets = ref.watch(assetsProvider);          // 资产数据状态
final dbAsync = ref.watch(databaseServiceProvider); // 数据库连接状态
```

#### 状态流程
```
应用启动 → 数据库初始化 → 检查资产数据
    ↓
资产为空 → 显示OnboardingScreen (引导页面)
资产存在 → 显示MainNavigationScreen (主导航)
```

---

### MainNavigationScreen (主导航栏)
**文件位置**: `lib/screens/main_navigation_screen.dart`
**功能**: 底部导航栏，实现三层架构的核心导航

#### 导航结构
```dart
// 四个主要标签页
const List<Widget> _screens = [
  FamilyInfoHomeScreen(),        // 🏠 家庭信息
  FinancialPlanningHomeScreen(), // 📊 财务规划
  TransactionFlowHomeScreen(),   // 💳 交易流水
  DebugScreen(),                 // 🐛 调试工具
];
```

#### 导航特性
- **IndexedStack**: 保持页面状态，避免重复构建
- **底部导航**: 固定式导航栏，支持4个主要功能模块
- **状态保持**: 页面切换时保持各模块的内部状态

#### 依赖关系
```
MainNavigationScreen
├── FamilyInfoHomeScreen (家庭信息模块首页)
├── FinancialPlanningHomeScreen (财务规划模块首页)
├── TransactionFlowHomeScreen (交易流水模块首页)
└── DebugScreen (调试工具页)
```

---

### OnboardingScreen (新用户引导)
**文件位置**: `lib/screens/onboarding_screen.dart`
**功能**: 新用户首次使用时的引导流程

#### 引导流程
1. **资产创建**: 引导用户添加第一个资产
2. **功能介绍**: 展示应用核心功能
3. **数据初始化**: 创建示例数据和配置

#### 交互特性
- **资产添加**: 集成`AddAssetFlowScreen`进行资产创建
- **调试模式**: 支持开发者模式的隐藏入口
- **状态管理**: 通过AssetProvider管理资产创建状态

#### 依赖服务
```dart
// 核心依赖
final AssetProvider assetProvider;      // 资产状态管理
final BudgetProvider budgetProvider;    // 预算状态管理
final StorageService storageService;    // 数据持久化
```

---

### DebugScreen (开发者工具)
**文件位置**: `lib/screens/debug_screen.dart`
**功能**: 开发者调试和测试工具页面

#### 调试功能
- **数据导出**: 导出所有应用数据用于分析
- **动效测试**: 展示各种动画效果的演示
- **性能监控**: 显示应用性能指标
- **数据重置**: 清除所有数据（开发用）

#### 开发者特性
- **条件编译**: 只在开发模式下显示
- **数据可视化**: JSON格式的数据展示
- **快捷操作**: 快速创建测试数据

---

## 🔄 页面间数据流

### 导航数据流
```
HomeScreen → 检查数据状态
    ↓
无数据: OnboardingScreen → 创建初始数据 → MainNavigationScreen
有数据: MainNavigationScreen → 各功能模块首页
```

### 状态同步
- **全局状态**: 通过Riverpod在页面间共享
- **模块状态**: 各模块通过Provider管理内部状态
- **数据持久化**: 所有状态变更自动保存到本地存储

## 🎨 UI/UX特性

### 响应式设计
- **统一背景**: `context.primaryBackground`主题背景色
- **标准间距**: `context.responsiveSpacing16`响应式间距
- **文字样式**: `context.textTheme.headlineMedium`统一标题样式

### 动效集成
- **页面转场**: `AppAnimations.createRoute()`统一页面过渡
- **组件动效**: `AppAnimations.animatedListItem()`列表项动画
- **按钮反馈**: `AppAnimations.animatedButton()`按钮交互反馈

### 无障碍支持
- **语义标签**: 为所有交互元素提供accessibility labels
- **键盘导航**: 支持键盘操作和屏幕阅读器
- **高对比度**: 支持系统高对比度模式

## 📊 性能优化

### 懒加载策略
- **按需加载**: 页面组件延迟初始化
- **资源管理**: 自动清理不需要的资源
- **缓存机制**: Provider状态缓存避免重复计算

### 内存管理
- **状态清理**: dispose时释放所有控制器和监听器
- **避免泄漏**: 正确移除事件监听器和Provider监听
- **资源复用**: 共享昂贵的资源实例

## 🔧 开发注意事项

### 状态管理
```dart
// 正确的方式：使用Consumer包装需要状态的组件
Consumer<AssetProvider>(
  builder: (context, assetProvider, child) {
    return Text('资产数量: ${assetProvider.assets.length}');
  },
);
```

### 导航最佳实践
```dart
// 使用统一动效的页面跳转
Navigator.of(context).push(
  AppAnimations.createRoute(TargetScreen()),
);
```

### 错误处理
```dart
// 异步操作必须包含错误处理
try {
  await someAsyncOperation();
} catch (e) {
  // 显示用户友好的错误提示
  unifiedNotifications.showError(context, '操作失败: $e');
}
```
