# 🔄 页面依赖关系与数据流图

本项目采用**三层架构**设计，页面间的依赖关系清晰分层，确保数据流的一致性和可维护性。

## 🏗️ 架构层次依赖关系

### 表现层依赖 (Presentation Layer)
```
页面 (Screens)
├── 状态管理 (Providers)
├── 业务服务 (Services)
├── UI组件 (Widgets)
├── 动效系统 (Animations)
└── 主题系统 (Theme)
```

### 业务逻辑层依赖 (Business Logic Layer)
```
功能模块 (Features)
├── 数据模型 (Models)
├── 状态管理 (Providers)
├── 业务服务 (Services)
└── 工具类 (Utils)
```

### 数据层依赖 (Data Layer)
```
数据持久化 (Persistence)
├── 本地存储 (SharedPreferences)
├── 结构化存储 (SQLite)
├── 文件存储 (JSON)
└── 缓存机制 (Memory Cache)
```

---

## 📊 核心Provider依赖网络

### AssetProvider (资产状态管理)
**位置**: `lib/core/providers/asset_provider.dart`
**职责**: 管理所有资产数据的CRUD操作

#### 依赖页面
```
AssetManagementScreen (资产管理)
├── AssetDetailScreen (资产详情)
├── AssetEditScreen (资产编辑)
├── AddAssetFlowScreen (资产添加流程)
├── AssetCalendarView (资产日历视图)
└── FamilyInfoHomeScreen (家庭信息首页 - 资产概览)
```

#### 数据流向
```
外部输入 → AssetProvider.addAsset() → 存储到SQLite
    ↓
AssetProvider.getAssets() → 提供给各个页面
    ↓
页面操作 → AssetProvider.updateAsset() → 更新存储
    ↓
AssetHistoryService.recordChange() → 记录历史
```

### AccountProvider (账户状态管理)
**位置**: `lib/core/providers/account_provider.dart`
**职责**: 管理账户余额和账户信息

#### 依赖页面
```
WalletManagementScreen (钱包管理)
├── AccountDetailScreen (账户详情)
├── AccountEditScreen (账户编辑)
├── AddWalletScreen (添加钱包)
└── Transaction相关页面 (余额显示)
```

#### 数据流向
```
交易创建 → AccountProvider.updateBalance() → 余额计算
    ↓
Transfer操作 → 双向余额更新 (转出-转入)
    ↓
AccountProvider.getAccounts() → 页面显示
    ↓
余额变更 → 通知所有监听页面更新
```

### TransactionProvider (交易状态管理)
**位置**: `lib/core/providers/transaction_provider.dart`
**职责**: 管理交易记录的增删改查

#### 依赖页面
```
TransactionFlowHomeScreen (交易首页)
├── AddTransactionScreen (添加交易)
├── TransactionDetailScreen (交易详情)
├── TransactionListScreen (交易列表)
├── TransactionManagementScreen (交易管理)
└── TransactionRecordsScreen (交易统计)
```

#### 数据流向
```
用户输入 → 表单验证 → TransactionProvider.createTransaction()
    ↓
关联处理 → 账户余额更新 + 预算使用更新
    ↓
TransactionProvider.getTransactions() → 列表显示
    ↓
筛选条件 → TransactionProvider.queryTransactions() → 过滤结果
```

### BudgetProvider (预算状态管理)
**位置**: `lib/core/providers/budget_provider.dart`
**职责**: 管理预算设置和使用跟踪

#### 依赖页面
```
BudgetManagementScreen (预算管理)
├── EnvelopeBudgetDetailScreen (信封预算详情)
├── CreateBudgetScreen (创建预算)
├── SalaryIncomeSetupScreen (薪资设置 - 预算关联)
└── Transaction相关页面 (预算扣除)
```

#### 数据流向
```
预算创建 → BudgetProvider.createEnvelopeBudget()
    ↓
交易关联 → BudgetProvider.updateUsage() → 使用金额更新
    ↓
BudgetProvider.getBudgets() → 预算列表显示
    ↓
预算检查 → BudgetProvider.checkBudgetLimits() → 超支提醒
```

---

## 🔄 页面间数据流图

### 应用启动数据流
```
应用启动
    ↓
HomeScreen检查Riverpod状态
    ├── assetsProvider.isEmpty → 显示OnboardingScreen
    │   ↓
    │   OnboardingScreen → 创建示例资产 → AssetProvider
    │   ↓
    │   引导完成 → 跳转MainNavigationScreen
    │
    └── assets存在 → 直接显示MainNavigationScreen
        ↓
        MainNavigationScreen → 加载三个功能模块首页
        ├── FamilyInfoHomeScreen
        ├── FinancialPlanningHomeScreen
        └── TransactionFlowHomeScreen
```

### 资产管理数据流
```
FamilyInfoHomeScreen (资产概览)
    ↓
用户点击"资产管理" → AssetManagementScreen
    ↓
AssetManagementScreen加载数据
    ├── AssetProvider.getAssets() → 资产列表
    ├── AccountProvider.getAccounts() → 账户列表
    └── TransactionProvider.getTransactions() → 交易统计
    ↓
用户操作
    ├── 添加资产 → AddAssetFlowScreen → AssetProvider.addAsset()
    ├── 查看详情 → AssetDetailScreen → 资产详细信息
    ├── 编辑资产 → AssetEditScreen → AssetProvider.updateAsset()
    └── 删除资产 → 确认对话框 → AssetProvider.deleteAsset()
    ↓
操作完成 → 返回AssetManagementScreen → 刷新数据
```

### 交易创建数据流
```
TransactionFlowHomeScreen (交易概览)
    ↓
用户点击"添加交易" → AddTransactionScreen
    ↓
AddTransactionScreen初始化
    ├── AccountProvider.getAccounts() → 账户选择列表
    ├── BudgetProvider.getBudgets() → 预算选择列表
    └── 分类数据加载
    ↓
用户填写表单
    ├── 类型选择 → 动态显示对应字段
    ├── 账户选择 → 验证账户有效性
    ├── 金额输入 → 实时格式化显示
    └── 预算关联 → 可选的信封预算关联
    ↓
表单验证通过 → TransactionProvider.createTransaction()
    ↓
级联更新
    ├── AccountProvider.updateBalance() → 账户余额更新
    ├── BudgetProvider.updateUsage() → 预算使用更新
    └── AssetHistoryService.recordChange() → 历史记录
    ↓
创建成功 → 返回列表页面 → 刷新显示
```

### 预算管理数据流
```
FinancialPlanningHomeScreen (规划概览)
    ↓
用户点击"预算管理" → BudgetManagementScreen
    ↓
BudgetManagementScreen加载数据
    ├── BudgetProvider.getBudgets() → 预算列表
    ├── TransactionProvider.getTransactions() → 交易数据
    └── 计算预算使用率和统计信息
    ↓
用户操作
    ├── 创建预算 → CreateBudgetScreen → BudgetProvider.createBudget()
    ├── 查看详情 → EnvelopeBudgetDetailScreen → 预算详细信息
    ├── 编辑预算 → 预算编辑表单 → BudgetProvider.updateBudget()
    └── 删除预算 → 确认对话框 → BudgetProvider.deleteBudget()
    ↓
预算关联交易
    ├── 交易创建时 → 可选择关联预算
    ├── TransactionProvider.createTransaction()
    └── BudgetProvider.updateUsage() → 预算使用更新
```

---

## 🔗 服务层依赖关系

### StorageService (数据持久化)
**位置**: `lib/core/services/storage_service.dart`
**职责**: 统一的数据存储接口

#### 依赖关系
```
所有Provider
├── AssetProvider → 资产数据存储
├── AccountProvider → 账户数据存储
├── TransactionProvider → 交易数据存储
├── BudgetProvider → 预算数据存储
└── SalaryIncome存储
```

#### 数据流
```
Provider操作 → StorageService接口
    ↓
数据序列化 → JSON格式转换
    ↓
存储到SharedPreferences/SQLite
    ↓
读取时反序列化 → 返回给Provider
```

### AssetHistoryService (历史记录)
**位置**: `lib/features/family_info/services/asset_history_service.dart`
**职责**: 资产变更历史追踪

#### 依赖关系
```
资产相关操作
├── AssetProvider所有CRUD操作
├── AccountProvider余额变更
├── TransactionProvider交易记录
└── 定期清理任务
```

#### 数据流
```
资产变更触发 → AssetHistoryService.recordChange()
    ↓
创建历史记录 → 包含变更前后的完整数据
    ↓
存储到历史数据库 → 限制1000条记录
    ↓
历史查询 → AssetHistoryScreen展示
```

### DepreciationService (折旧服务)
**位置**: `lib/features/family_info/services/depreciation_service.dart`
**职责**: 固定资产折旧计算

#### 依赖关系
```
FixedAssetDetailScreen (固定资产详情页)
├── 资产数据 → 折旧计算
├── 时间参数 → 折旧周期
└── 计算结果 → 显示给用户
```

#### 数据流
```
资产信息 + 时间参数 → DepreciationService.calculate()
    ↓
折旧算法计算 → 直线折旧/加速折旧等
    ↓
返回折旧表 → 页面显示
    ↓
定期更新 → 资产价值调整
```

---

## 📱 UI组件依赖关系

### AppCard (基础卡片组件)
**位置**: `lib/core/widgets/app_card.dart`
**职责**: 统一的设计风格卡片

#### 依赖页面
```
几乎所有页面
├── 统计信息展示
├── 列表项容器
├── 功能模块入口
└── 数据概览卡片
```

### AppAnimations (动效系统)
**位置**: `lib/core/widgets/app_animations.dart`
**职责**: 统一的动效处理

#### 依赖关系
```
页面导航
├── AppAnimations.createRoute() → 页面间转场
├── AppAnimations.animatedListItem() → 列表项动画
└── AppAnimations.showAppModalBottomSheet() → 弹窗动效

组件动效
├── 按钮点击反馈
├── 数字滚动动画
├── 输入框聚焦效果
└── 加载状态动画
```

### IOSAnimationSystem (企业级动效)
**位置**: `lib/core/animations/ios_animation_system.dart`
**职责**: 高级动效系统

#### 依赖页面
```
AccountDetailScreen (账户详情页)
├── 余额变化动画
├── 交易记录滑入
├── 自定义缓动曲线
└── iOS风格交互反馈
```

---

## 🔧 工具类依赖关系

### Logger (日志工具)
**位置**: `lib/core/utils/logger.dart`
**职责**: 统一日志记录

#### 依赖范围
```
所有页面和服务
├── 调试信息记录
├── 错误异常捕获
├── 性能监控数据
└── 用户操作追踪
```

### UnifiedNotifications (通知系统)
**位置**: `lib/core/utils/unified_notifications.dart`
**职责**: 统一的通知展示

#### 依赖页面
```
所有用户交互页面
├── 操作成功提示
├── 错误信息展示
├── 警告提醒
└── 加载状态提示
```

### PerformanceMonitor (性能监控)
**位置**: `lib/core/utils/performance_monitor.dart`
**职责**: 运行时性能监控

#### 依赖页面
```
关键性能页面
├── 构建时间监控
├── 绘制时间监控
├── 内存使用统计
└── 帧率监控报告
```

---

## 📊 数据流向图例

### 标准CRUD数据流
```
用户操作触发
    ↓
页面收集数据 → 表单验证
    ↓
调用Provider方法 → 业务逻辑处理
    ↓
数据持久化 → StorageService
    ↓
状态更新通知 → 相关页面刷新
    ↓
用户界面更新 → 操作完成反馈
```

### 关联数据更新流
```
主数据变更 (如交易创建)
    ↓
主Provider更新 (TransactionProvider)
    ↓
级联更新触发
    ├── AccountProvider (账户余额)
    ├── BudgetProvider (预算使用)
    └── AssetHistoryService (历史记录)
    ↓
所有相关页面状态同步更新
```

### 异步操作数据流
```
用户发起异步操作
    ↓
显示加载状态
    ↓
调用async方法 → 错误处理try-catch
    ↓
操作成功 → 状态更新 + 成功提示
    ↓
操作失败 → 错误提示 + 状态回滚
```

---

## 🚨 依赖关系维护原则

### 依赖注入原则
- **Provider优先**: 使用Provider进行依赖注入，避免直接实例化
- **接口抽象**: 通过抽象接口定义依赖，便于测试和替换
- **生命周期管理**: 正确管理Provider的生命周期，避免内存泄漏

### 数据一致性保证
- **单向数据流**: 严格遵循数据从上到下的单向流动
- **状态同步**: Provider状态变更时自动通知所有依赖页面
- **事务处理**: 复杂操作使用数据库事务保证数据一致性

### 性能优化策略
- **懒加载**: 页面和数据按需加载
- **缓存机制**: 常用数据的内存缓存
- **批量操作**: 减少频繁的数据库调用
- **异步处理**: 耗时操作异步执行，避免阻塞UI

这个依赖关系和数据流图提供了完整的架构视图，帮助开发者理解系统的数据流向、依赖关系和最佳实践。
