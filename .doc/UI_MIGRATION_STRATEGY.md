# UI 迁移战略指南

**更新时间**: 2025-01-13  
**策略**: 侵入式重构（在做业务的同时顺手改 UI）

---

## 🎯 核心原则

### ✅ 采用策略：侵入式重构
- **拒绝"休克疗法"**：不停下所有业务开发去全量改 UI
- **在做业务的同时顺手改 UI**：写逻辑时顺便迁移 UI
- **严禁混搭**：一个页面要么全用新组件，要么全用旧组件

### ❌ 禁止策略：休克疗法
- 停下所有业务开发
- 专门花时间全量迁移 UI
- 在还没有产出实际业务价值前就产生厌倦感

---

## 📋 必须立即迁移的"门面"（The Must-Haves）

这些页面决定了 App 的"质感"，必须在 Phase 3 逻辑开发之前完成迁移。

### ✅ 1. Dashboard (首页)
**状态**: ✅ **已完成**
- 使用了 `AppDesignTokens`
- 使用了 `AppCard`
- 使用了 `AppEmptyState`
- 完全符合新 Design System

### ⚠️ 2. Transaction List (流水列表)
**状态**: ⚠️ **部分迁移**
- ✅ 已使用 `AppCard`（部分）
- ❌ 可能还有旧样式混搭
- **行动**: 在开发 Phase 3 的"清账逻辑"时，完整迁移此页面

### ⚠️ 3. Add Transaction (记账页)
**状态**: ⚠️ **部分迁移**
- ✅ 已使用 `AppCard`（部分）
- ❌ 还有 `Container`、`ElevatedButton`、`TextButton`、`TextField` 等旧组件
- **行动**: 在开发 Phase 3 的"AI 记账"功能时，完整迁移此页面

---

## 🔄 随逻辑重构而迁移（Refactor as You Go）

Phase 3 的任务是"逻辑解耦与状态重塑"，这是迁移 UI 的绝佳时机。

### 迁移原则
- **不要专门为了改 UI 而改 UI**
- **而是为了改逻辑而顺便改 UI**
- **一次修改，两个收益**

### 迁移场景示例

#### 场景 1: 重写 SalaryNotifier（工资逻辑）
- **动作**:
  1. 把旧的逻辑代码删掉，换成 notifier
  2. **顺手**把 `Container(color: blue)` 换成 `AppCard`
  3. **顺手**把 `TextField` 换成 `AppTextField`
  4. **顺手**把 `ElevatedButton` 换成 `AppPrimaryButton`
- **好处**: 测试逻辑时，顺便测试了 UI

#### 场景 2: 开发"清账逻辑"
- **动作**: 重写清账页面时，使用新的 Design Tokens 和组件
- **好处**: 新功能直接使用新 UI，避免技术债务

#### 场景 3: 开发"AI 记账"
- **动作**: 写 AI 记账的半屏弹窗时，直接使用新 UI 组件
- **好处**: 新功能从一开始就是新 UI

---

## 🚫 暂时不动的"边角料"（The Long Tail）

以下页面不要动，留着旧样式也没关系：

- 关于页面 / 法律条款
- 极其低频的设置项
- 很少用到的资产详情页（除非正在做资产重构）

**策略**: 等 App 1.0 上线前再统一扫尾，或者等以后有空了像"做家务"一样慢慢改。

---

## 🔴 红线：严禁混搭

### ❌ 错误示例
```dart
// 一个页面里，上面是新版的 AppCard，下面是旧版的 ElevatedButton
Column(
  children: [
    AppCard(...), // ✅ 新组件
    ElevatedButton(...), // ❌ 旧组件 - 禁止！
  ],
)
```

### ✅ 正确做法
```dart
// 只要你决定动一个页面，就必须把这个页面内的所有组件全部替换成新的原子组件
Column(
  children: [
    AppCard(...), // ✅ 新组件
    AppPrimaryButton(...), // ✅ 新组件
  ],
)
```

**原则**: 要改就改一整页，不要半途而废。

---

## 🚀 下一步行动路径

### 1. ✅ 锁定 Design System
- UI Gallery 代码（Token + Widgets）已经 8.5 分
- **封板，不要再微调颜色**
- Design System 已锁定

### 2. 🎯 Phase 3 启动：Domain 层开发
开始写 Domain 层的计算器（纯 Dart）：

- [ ] **个税计算器** (`lib/core/domain/tax_calculator.dart`)
  - 计算个人所得税
  - 支持年度累计扣除
  - 纯 Dart，无 UI 依赖

- [ ] **贷款利息计算器** (`lib/core/domain/loan_calculator.dart`)
  - 等额本息计算
  - 等额本金计算
  - 提前还款计算

- [ ] **AI 记账意图识别** (`lib/core/domain/transaction_intent_parser.dart`)
  - 解析自然语言
  - 提取交易信息
  - 结构化数据验证

- [ ] **清账差额分析算法** (`lib/core/domain/reconciliation_analyzer.dart`)
  - 账户余额对比
  - 差额分析
  - 异常检测

### 3. 📝 按需翻新 UI
在开发业务逻辑时，按需迁移 UI：

- **当你要写"清账逻辑"时** → 重写"清账页面"的 UI
- **当你要写"AI 记账"时** → 直接用新 UI 写那个半屏弹窗
- **当你要写"工资计算"时** → 重写"工资设置页面"的 UI

---

## 📊 当前状态总结

### ✅ 已完成
- [x] Design System 建立（8.5/10 分）
- [x] Dashboard 首页迁移完成
- [x] 所有原子组件封装完成
- [x] 深色模式支持完成

### ⚠️ 部分完成
- [ ] Transaction List（流水列表）- 部分迁移
- [ ] Add Transaction（记账页）- 部分迁移

### 🎯 下一步
- [ ] 开始 Phase 3 Domain 层开发
- [ ] 在开发业务逻辑时，按需迁移 UI
- [ ] 禁止专门为了改 UI 而改 UI

---

## 💡 架构师的警告

**虽然是"渐进式迁移"，但有一条红线不能踩：严禁在同一个页面内"混搭"！**

一个页面要么全用新组件，要么全用旧组件。半新半旧比全是旧版更丑，显得不专业。

---

## 🎯 总结

**现在，忘掉 UI，去写那些复杂的财务逻辑吧。那才是这个 App 的灵魂。**

UI 系统已经锁定，Design System 已经建立。接下来专注于：
1. Domain 层的纯 Dart 计算器
2. 状态管理的拆分和优化
3. 业务逻辑的解耦和重构

在写业务逻辑的过程中，顺手迁移 UI。一次修改，两个收益。

