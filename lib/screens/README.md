# Screens 通用页面文档

## 概述

`screens` 包包含应用级别的通用页面，这些页面不属于特定的功能模块，而是为整个应用提供导航、设置、开发者工具等功能。

## 页面列表

### 1. main_navigation_screen.dart - 主导航页面

**职责**: 提供应用的主导航界面

**功能**:
- 底部导航栏（三个主要模块）
  - 家庭信息维护
  - 财务计划
  - 交易流水
- 顶部AppBar（每月工资钱包、开发者模式）
- 页面切换动画
- 状态保持

**导航结构**:
```
MainNavigationScreen
├── FamilyInfoHomeScreen
├── FinancialPlanningHomeScreen
└── TransactionFlowHomeScreen
```

### 2. home_screen.dart - 首页路由

**职责**: 应用入口页面，决定跳转到主导航还是引导页

**功能**:
- 检查首次使用状态
- 首次使用 → 跳转到引导页
- 非首次使用 → 跳转到主导航

**逻辑**:
```dart
if (isFirstLaunch) {
  → OnboardingScreen
} else {
  → MainNavigationScreen
}
```

### 3. dashboard_screen.dart - 数据概览页

**职责**: 展示应用的总体数据概览

**功能**:
- 总资产展示
- 净资产展示
- 收支统计
- 资产分布图表
- 交易趋势图表

**数据来源**:
- AssetProvider - 资产数据
- TransactionProvider - 交易数据
- AccountProvider - 账户数据

### 4. onboarding_screen.dart - 引导页面

**职责**: 首次使用时的引导流程

**功能**:
- 应用介绍
- 功能说明
- 引导用户完成初始设置
- 标记首次使用完成

**流程**:
1. 欢迎页面
2. 功能介绍
3. 初始设置引导
4. 完成引导，跳转到主导航

### 5. settings_screen.dart - 设置页面

**职责**: 应用设置和配置

**功能**:
- 主题设置（浅色/深色模式）
- 语言设置
- 数据管理（导出、导入、清空）
- 关于应用
- 隐私设置

**设置项**:
- 外观设置
- 数据管理
- 通知设置
- 关于信息

### 6. developer_mode_screen.dart - 开发者模式

**职责**: 开发者工具和数据管理

**功能**:
- 数据导出（JSON格式）
- 数据导入（从剪贴板）
- 测试数据生成
- 数据清空
- 历史清账数据处理
- 强制数据迁移
- 数据库检查工具
- 性能监控

**使用场景**:
- 开发调试
- 数据备份和恢复
- 测试数据生成
- 数据迁移

### 7. ai_config_screen.dart - AI配置页面

**职责**: AI服务配置和管理

**功能**:
- AI服务提供商选择（DashScope、SiliconFlow等）
- API密钥配置
- 模型选择
- 参数配置（温度、最大Token等）
- API密钥验证
- 使用统计

**AI服务**:
- DashScope（阿里云）
- SiliconFlow
- 其他AI服务提供商

### 8. 其他页面

- **debug_screen.dart**: 调试页面（开发用）
- **responsive_test_screen.dart**: 响应式测试页面
- **personal_screen.dart**: 个人中心页面

## 页面关系

```
HomeScreen (入口)
    ↓
    ├── OnboardingScreen (首次使用)
    │       ↓
    │   MainNavigationScreen
    │
    └── MainNavigationScreen (非首次使用)
            ├── FamilyInfoHomeScreen
            ├── FinancialPlanningHomeScreen
            └── TransactionFlowHomeScreen

SettingsScreen (设置)
    ├── 数据管理
    ├── 主题设置
    └── 关于应用

DeveloperModeScreen (开发者模式)
    ├── 数据导出/导入
    ├── 测试数据生成
    └── 数据迁移

AIConfigScreen (AI配置)
    ├── 服务提供商选择
    ├── API密钥配置
    └── 模型配置
```

## 设计原则

### 1. 通用性
这些页面不包含特定业务逻辑，而是提供通用的应用功能。

### 2. 导航中心
`main_navigation_screen.dart` 作为应用的导航中心，管理主要功能模块的切换。

### 3. 状态管理
使用Provider管理页面状态，确保数据一致性。

### 4. 用户体验
- 流畅的页面转场动画
- 清晰的信息层次
- 友好的错误提示

## 使用指南

### 添加新的通用页面

1. 在 `screens/` 目录下创建新页面文件
2. 在 `core/router/app_router.dart` 中添加路由配置
3. 在相应的入口页面添加导航逻辑

### 修改主导航结构

1. 编辑 `main_navigation_screen.dart`
2. 修改底部导航栏的标签和图标
3. 更新路由配置

### 添加新的设置项

1. 编辑 `settings_screen.dart`
2. 添加新的设置项UI
3. 实现设置逻辑
4. 持久化设置数据

## 相关文档

- [Core包文档](../core/README.md)
- [Router文档](../core/router/README.md)
- [项目架构文档](../ARCHITECTURE.md)

