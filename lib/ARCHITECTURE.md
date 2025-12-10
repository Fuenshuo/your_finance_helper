# 家庭资产记账应用 - 整体架构设计文档

## 概述

本文档描述了家庭资产记账应用的整体架构设计，包括项目结构、模块划分、数据流、技术栈等核心内容。

## 架构概览

### 三层架构设计

应用采用清晰的三层架构，将功能按照用户思维重新组织：

```
┌─────────────────────────────────────────────────────────┐
│                    UI Layer (Screens)                    │
│  主导航、设置、开发者模式、引导页等通用页面              │
└─────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
┌───────▼────────┐  ┌───────▼────────┐  ┌───────▼────────┐
│  Family Info   │  │   Financial    │  │  Transaction   │
│  家庭信息维护   │  │   Planning     │  │     Flow       │
│                │  │   财务计划      │  │   交易流水      │
│ 静态数据管理    │  │  动态规则配置   │  │  实际执行      │
└───────┬────────┘  └───────┬────────┘  └───────┬────────┘
        │                   │                   │
        └───────────────────┼───────────────────┘
                            │
                ┌───────────▼───────────┐
                │     Core Layer       │
                │   核心功能层          │
                │                      │
                │  Models, Providers,  │
                │  Services, Widgets, │
                │  Utils, Theme, etc.  │
                └───────────┬───────────┘
                            │
                ┌───────────▼───────────┐
                │   Data Layer         │
                │   数据层              │
                │                      │
                │  Drift Database     │
                │  SharedPreferences   │
                └──────────────────────┘
```

## 项目结构

```
lib/
├── core/                          # 核心功能层 (142个文件)
│   ├── animations/                # 动画系统 (5个文件)
│   ├── constants/                 # 常量定义 (1个文件)
│   ├── database/                  # 数据库层 (2个文件)
│   ├── domain/                    # 领域逻辑 (1个文件)
│   ├── models/                    # 数据模型 (20个文件)
│   ├── providers/                 # 状态管理 (11个文件)
│   ├── router/                    # 路由配置 (1个文件)
│   ├── services/                  # 业务服务 (75个文件)
│   │   ├── ai/                    # AI服务 (22个文件)
│   │   ├── legacy_import/         # 遗留数据导入 (3个文件)
│   │   └── verifiers/             # 验证服务 (5个文件)
│   ├── theme/                     # 主题样式 (4个文件)
│   ├── utils/                     # 工具类 (10个文件)
│   └── widgets/                   # 通用组件 (39个文件)
│       ├── animations/            # 动画组件 (25个文件)
│       └── composite/             # 复合组件 (7个文件)
│
├── features/                      # 功能模块层 (109个文件)
│   ├── family_info/               # 🏠 家庭信息维护 (42个文件)
│   │   ├── screens/               # 页面文件 (23个文件)
│   │   ├── widgets/               # 专用组件 (17个文件)
│   │   └── services/              # 专用服务 (2个文件)
│   │
│   ├── insights/                  # 📊 财务洞察 (33个文件)
│   │   ├── models/                # 数据模型 (10个文件)
│   │   ├── providers/             # 状态管理 (2个文件)
│   │   ├── services/              # AI分析服务 (10个文件)
│   │   ├── utils/                 # 工具函数 (1个文件)
│   │   ├── widgets/               # 图表组件 (7个文件)
│   │   └── screens/               # 洞察页面 (3个文件)
│   │
│   └── transaction_entry/         # 💳 交易录入 (35个文件)
│       ├── models/                # 数据模型 (3个文件)
│       ├── providers/             # 状态管理 (3个文件)
│       ├── services/              # 业务服务 (8个文件)
│       ├── utils/                 # 工具函数 (1个文件)
│       ├── widgets/               # UI组件 (19个文件)
│       │   ├── input_dock/        # 输入dock (4个文件)
│       │   ├── draft_card/        # 草稿卡片 (7个文件)
│       │   ├── timeline/          # 时间线 (4个文件)
│       │   └── insights/          # 洞察组件
│       └── screens/               # 页面组件 (3个文件)
│
├── screens/                       # 通用页面 (10个文件)
│   ├── ai_config_screen.dart      # AI配置页面
│   ├── dashboard_home_screen.dart # 数据概览页
│   ├── flux_navigation_screen.dart # Flux导航容器
│   ├── flux_screens.dart          # Flux屏幕导出
│   ├── flux_streams_screen.dart   # Flux流视图
│   ├── main_navigation_screen.dart # 主导航页面
│   ├── settings_screen.dart       # 设置页面
│   ├── unified_transaction_entry_screen.dart # 统一交易录入
│   └── verification_dashboard_screen.dart # 验证仪表板
│
├── home_screen.dart               # 首页路由
├── ios_animation_showcase.dart    # iOS动画展示
├── main_flux.dart                 # Flux Ledger主入口
├── main.dart                      # 默认主入口
├── performance_analysis_screen.dart # 性能分析页面
├── responsive_test_screen.dart    # 响应式测试
├── screens.dart                   # 屏幕导出
└── widgets/                       # 根级组件 (4个文件)
    ├── amount_input_demo.dart     # 金额输入演示
    ├── app_card.dart              # 应用卡片
    └── ... (更多组件)
```

**总文件统计**: 275个Dart文件

> **导航更新**：`MainNavigationScreen` 现采用四 Tab 结构（Stream / Insights / Assets / Me），其中 Stream Tab 承载新的 Smart Timeline，通过 `Stack + IndexedStack` 让 Input Dock 悬浮在底部导航之上。

### 应用入口
- `main_flux.dart`：Flux Ledger 专用入口，负责初始化 `FluxServiceManager`、注册 `ProviderScope` + `MultiProvider` 栈，并使用 `FluxLogger` 输出业务/错误日志。为了保证 `flutter analyze` 通过，它引用的 `FluxLogger` 目前是 `core/utils/flux_logger.dart` 中的轻量桩实现（封装 `debugPrint`），后续可平滑替换为真正的结构化日志流水线。
- `FluxLedgerApp` 构建了完整的 `ThemeData`（含 M3 语义、CardThemeData、新的 Amount Theme 扩展），且不再访问私有 `_processor`，避免跨文件私有字段引用导致的构建失败。

## 模块划分

### 1. Core 核心功能层

**职责**: 提供基础设施和通用功能，被所有功能模块共享使用。

**子模块**:
- **models**: 数据模型定义
- **providers**: 状态管理（Provider + Riverpod）
- **services**: 业务服务（存储、计算、AI等）
- **widgets**: 通用UI组件
- **utils**: 工具类（日志、性能监控等）
- **theme**: 主题和样式系统
- **database**: 数据库层（Drift/SQLite）
- **router**: 路由配置（GoRouter）
- **animations**: 动画系统
- **constants**: 常量定义

**设计原则**:
- 单一职责：每个子包只负责一个明确的功能领域
- 可复用性：所有组件和服务都设计为可复用的
- 类型安全：使用强类型和枚举避免魔法字符串
- 依赖方向：core包不依赖features包

### 2. Features 功能模块层

#### 2.1 Family Info - 家庭信息维护

**职责**: 管理静态财务数据（工资、资产、钱包）

**核心功能**:
- 工资收入设置和奖金管理
- 资产分类管理和估值
- 钱包账户的统一管理
- 清账会话和周期对账

**页面**:
- 家庭信息主页
- 工资收入设置页面
- 资产管理页面
- 钱包管理页面
- 清账管理页面

#### 2.2 Financial Planning - 财务计划

**职责**: 管理动态规则配置（收入计划、支出计划）

**核心功能**:
- 收入计划（工资计划、投资收益计划）
- 支出计划（周期性支出、预算约束）
- 预算管理（信封预算、零基预算）
- 贷款计算（房贷、车贷）
- 智能预算建议

**页面**:
- 财务计划主页
- 创建收入计划页面
- 创建支出计划页面
- 预算管理页面
- 房贷计算器页面

#### 2.3 Transaction Flow - 交易流水

**职责**: 管理实际交易执行（交易记录、智能关联）

**核心功能**:
- 交易记录的完整展示
- 添加、编辑、删除交易
- 与财务计划的智能关联
- 重复交易的智能建议
- 交易搜索和筛选

**页面**:
- 交易流水主页
- 添加交易页面
- 交易记录页面
- 交易详情页面

### 3. Screens 通用页面层

**职责**: 提供应用级别的通用页面

**页面**:
- **main_navigation_screen.dart**: 主导航页面（底部导航栏）
- **home_screen.dart**: 首页路由（引导到主导航或引导页）
- **dashboard_screen.dart**: 数据概览页（总资产、收支统计等）
- **onboarding_screen.dart**: 引导页面（首次使用）
- **settings_screen.dart**: 设置页面（应用设置）
- **developer_mode_screen.dart**: 开发者模式（数据导出、导入、测试等）
- **ai_config_screen.dart**: AI配置页面（AI服务配置）

## 数据流架构

### 数据存储层次

```
┌─────────────────────────────────────────┐
│         UI Layer (Screens)             │
│  ┌──────────┐  ┌──────────┐          │
│  │ Provider │  │ Riverpod │          │
│  └────┬─────┘  └────┬─────┘          │
└───────┼──────────────┼─────────────────┘
        │              │
┌───────▼──────────────▼───────┐
│      Service Layer           │
│  ┌──────────────────────┐   │
│  │ StorageService        │   │
│  │ DriftDatabaseService  │   │
│  │ HybridStorageService  │   │
│  └──────────┬───────────┘   │
└──────────────┼───────────────┘
               │
┌──────────────▼───────────────┐
│      Data Layer              │
│  ┌──────────┐  ┌──────────┐ │
│  │  Drift   │  │SharedPref│ │
│  │ Database │  │  Storage │ │
│  └──────────┘  └──────────┘ │
└──────────────────────────────┘
```

### 数据流向

1. **UI → Provider**: UI层通过Provider访问数据
2. **Provider → Service**: Provider调用Service层处理业务逻辑
3. **Service → Storage**: Service层将数据持久化到存储层
4. **Storage → Database**: 数据最终存储在Drift数据库或SharedPreferences

### 状态管理架构

**混合架构**:
- **旧架构**: Provider + SharedPreferences（兼容性）
- **新架构**: Riverpod + Drift Database（新功能）

**迁移策略**:
- 新功能使用Riverpod + Drift
- 旧功能逐步迁移
- 两者可以共存

## 技术栈

### 核心框架
- **Flutter**: 3.x
- **Dart**: 3.x

### 状态管理
- **Provider**: 状态管理（旧架构）
- **Riverpod**: 状态管理（新架构）

### 数据持久化
- **Drift**: 类型安全的SQLite ORM
- **SharedPreferences**: 键值存储（兼容性）

### 路由管理
- **GoRouter**: 声明式路由

### UI设计
- **Material Design 3**: UI设计规范
- **响应式布局**: 适配不同屏幕尺寸

### 其他依赖
- **equatable**: 值比较
- **uuid**: ID生成
- **fl_chart**: 图表库
- **syncfusion_flutter_charts**: 图表库

## 设计原则

### 1. 三层架构分离

**清晰的分层**:
- **信息维护层**: 管理静态财务数据
- **财务计划层**: 配置动态收支规则
- **交易流水层**: 执行实际交易操作

**职责边界**:
- 每层只负责自己的职责
- 层间通过明确的接口通信
- 避免跨层直接访问

### 2. 核心功能下沉

**原则**: 可复用的功能放在core包

**实践**:
- 通用组件 → `core/widgets`
- 通用服务 → `core/services`
- 数据模型 → `core/models`
- 工具类 → `core/utils`

### 3. 模块化设计

**原则**: 功能模块独立，便于维护和扩展

**实践**:
- 每个feature模块包含screens、widgets、services
- 模块间通过core包通信
- 模块可以独立开发和测试

### 4. 类型安全

**原则**: 使用强类型和枚举避免错误

**实践**:
- 使用Drift进行类型安全的数据库操作
- 使用枚举类型替代魔法字符串
- 使用强类型模型

### 5. 用户无感知的复式记账

**原则**: 自动处理账户余额和预算关联

**实践**:
- 交易创建时自动更新账户余额
- 交易创建时自动关联预算
- 清账完成后自动生成交易记录

## 数据模型关系

### 核心实体关系

```
Account (账户)
  ├── Transaction (交易) [fromAccountId/toAccountId]
  └── ExpensePlan (支出计划) [walletId]

AssetItem (资产)
  └── AssetHistory (资产历史)

SalaryIncome (工资收入)
  ├── BonusItem (奖金项)
  └── IncomePlan (收入计划)

EnvelopeBudget (信封预算)
  └── Transaction (交易) [envelopeBudgetId]

ZeroBasedBudget (零基预算)
  └── EnvelopeBudget (信封预算)

ExpensePlan (支出计划)
  └── Transaction (交易) [expensePlanId]

IncomePlan (收入计划)
  └── Transaction (交易) [incomePlanId]

PeriodClearanceSession (清账会话)
  ├── WalletBalanceSnapshot (余额快照)
  ├── WalletDifference (钱包差额)
  └── ManualTransaction (手动交易)
```

## 关键流程

### 1. 交易创建流程

```
用户输入交易信息
    ↓
AddTransactionScreen
    ↓
TransactionProvider.addTransaction()
    ↓
StorageService.saveTransaction()
    ↓
AccountProvider.updateBalance()  // 更新账户余额
    ↓
BudgetProvider.updateUsage()       // 更新预算使用情况
    ↓
DriftDatabase.insertTransaction()  // 持久化
```

### 2. 清账流程

```
创建清账会话
    ↓
录入期初余额
    ↓
录入期末余额
    ↓
计算差额
    ↓
手动添加交易解释差额
    ↓
剩余差额自动归类
    ↓
生成周期总结
    ↓
完成清账，生成交易记录
```

### 3. 计划执行流程

```
计划配置完成
    ↓
AutoTransactionService检查计划
    ↓
到达执行时间
    ↓
生成交易记录
    ↓
更新账户余额
    ↓
更新预算使用情况
```

## 性能优化

### 1. 数据库优化
- 使用索引字段进行查询
- 批量操作使用事务
- 懒加载数据库连接

### 2. 状态管理优化
- 避免不必要的重建
- 使用select进行细粒度监听
- 及时释放资源

### 3. UI优化
- 使用ListView.builder进行列表渲染
- 图片缓存和懒加载
- 避免在build方法中进行复杂计算

## 扩展性设计

### 1. 新功能模块添加
1. 在`features/`目录下创建新模块
2. 实现screens、widgets、services
3. 在`core/router/app_router.dart`中添加路由
4. 在`main_navigation_screen.dart`中添加导航入口

### 2. 新数据模型添加
1. 在`core/models/`目录下创建模型文件
2. 在`core/database/app_database.dart`中添加表定义
3. 运行代码生成：`flutter pub run build_runner build`
4. 创建对应的Provider和Service

### 3. 新服务添加
1. 在`core/services/`目录下创建服务文件
2. 使用单例模式
3. 提供异步方法
4. 添加错误处理

## 测试策略

### 1. 单元测试
- 测试Service层的业务逻辑
- 测试工具类的功能
- 测试数据模型的序列化

### 2. Widget测试
- 测试通用组件
- 测试页面组件
- 测试交互逻辑

### 3. 集成测试
- 测试完整流程
- 测试数据持久化
- 测试状态管理

## 相关文档

- [Core包文档](core/README.md)
- [Family Info模块文档](features/family_info/README.md)
- [Financial Planning模块文档](features/financial_planning/README.md)
- [Transaction Flow模块文档](features/transaction_flow/README.md)
- [数据存储架构与格式说明](../DEV_DOCUMENT/数据存储架构与格式说明.md)
- [项目架构重构总结](../项目架构重构总结.md)

