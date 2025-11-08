# 📱 家庭资产记账应用 - 页面架构总览

## 🏗️ 整体架构

本项目采用**三层架构设计**，清晰分离关注点，提升代码可维护性和可扩展性。

### 架构层次

#### 🖥️ 表现层 (Presentation Layer)
**位置**: `lib/screens/` 和 `lib/features/*/screens/`
- **职责**: 用户界面展示、用户交互处理、页面导航
- **技术**: Flutter Widgets + Provider状态管理
- **特点**: 响应式设计、统一动效、适配Web/iOS/Android

#### 🧠 业务逻辑层 (Business Logic Layer)
**位置**: `lib/features/` 模块目录
- **职责**: 业务规则处理、数据转换、领域逻辑
- **技术**: Provider状态管理 + Service层
- **特点**: 模块化设计、依赖注入、单元测试友好

#### 💾 数据层 (Data Layer)
**位置**: `lib/core/models/`、`lib/core/providers/`、`lib/core/services/`
- **职责**: 数据持久化、状态管理、外部服务集成
- **技术**: Provider + SharedPreferences/SQLite
- **特点**: 数据一致性、错误处理、性能优化

## 📊 页面统计

### 总览
- **总页面数**: 45+ 个页面
- **主要模块**: 3个核心功能模块 + 7个基础页面
- **技术栈**: Flutter + Provider + Riverpod混合使用

### 按层级分布

#### 🚀 导航层 (4个)
| 页面 | 位置 | 功能 |
|------|------|------|
| `HomeScreen` | `lib/screens/` | 应用入口，状态路由 |
| `MainNavigationScreen` | `lib/screens/` | 底部导航栏，主架构导航 |
| `OnboardingScreen` | `lib/screens/` | 新用户引导 |
| `DebugScreen` | `lib/screens/` | 开发者调试工具 |

#### 🏠 功能模块层 (3个主模块首页)
| 模块 | 首页位置 | 包含页面数 |
|------|----------|------------|
| **家庭信息** | `features/family_info/screens/family_info_home_screen.dart` | 18个 |
| **财务规划** | `features/financial_planning/screens/financial_planning_home_screen.dart` | 10个 |
| **交易流水** | `features/transaction_flow/screens/transaction_flow_home_screen.dart` | 7个 |

#### 📋 业务功能层 (38个业务页面)
- **资产管理**: 账户详情、资产编辑、估值设置等
- **预算管理**: 信封预算、零基预算、预算指导等
- **交易管理**: 添加交易、交易详情、交易记录等

## 🔄 数据流向

### 单向数据流
```
用户操作 → 表现层 → 业务逻辑层 → 数据层 → 持久化存储
    ↑                                            ↓
    ←——————— 状态更新 ←————————————— 响应式UI ←————
```

### 状态管理策略
- **全局状态**: Riverpod (应用级配置、数据库连接)
- **页面状态**: Provider (模块级状态、业务逻辑)
- **组件状态**: StatefulWidget (UI交互状态)

### 数据持久化
- **本地存储**: SharedPreferences (配置、轻量数据)
- **结构化存储**: SQLite (资产、交易、预算数据)
- **历史记录**: 自动版本控制，支持导出

## 📱 页面生命周期

### 标准页面生命周期
1. **初始化**: Provider初始化、数据加载
2. **渲染**: 响应式UI构建、动效加载
3. **交互**: 用户操作处理、状态更新
4. **清理**: 资源释放、状态保存

### 性能优化策略
- **懒加载**: 页面按需加载，减少启动时间
- **缓存策略**: Provider缓存、图片缓存
- **内存管理**: 自动资源清理、防内存泄漏

## 🎯 设计原则

### 用户体验优先
- **无感知记账**: 复杂逻辑对用户透明
- **响应式设计**: 适配多种屏幕尺寸
- **流畅动效**: 60fps体验，动效增强交互

### 开发效率
- **组件复用**: AppCard、AppAnimations等通用组件
- **类型安全**: Equatable模型、强类型Provider
- **测试友好**: 依赖注入、模块化设计

### 可维护性
- **清晰分层**: 每层职责单一
- **模块化**: 功能模块独立部署
- **文档完善**: 代码注释、README同步
