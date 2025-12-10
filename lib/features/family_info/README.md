# Family Info 功能模块文档

## 概述

`family_info` 模块是三层架构中的第一层：**家庭信息维护**。它负责管理静态财务数据，包括工资收入、资产配置、钱包账户等基础信息。

**文件统计**: 42个Dart文件（screens: 23个, widgets: 17个, services: 2个）

## 模块定位

**核心理念**: 静态数据管理（工资、资产、钱包）

**职责边界**:
- ✅ 管理工资结构和奖金设置
- ✅ 管理各类资产（房产、股票、理财等）
- ✅ 管理钱包账户（银行卡、电子钱包等）
- ✅ 管理清账会话和周期对账
- ❌ 不涉及动态规则配置（属于financial_planning）
- ❌ 不涉及实际交易执行（属于transaction_flow）

## 包结构

```
family_info/
├── screens/          # 页面界面 (23个文件)
├── widgets/          # 专用组件 (17个文件)
└── services/         # 专用服务 (2个文件)
```

## Screens 页面说明

### 1. family_info_home_screen.dart - 家庭信息主页

**职责**: 提供家庭信息维护的统一入口

**功能**:
- 展示模块介绍
- 功能卡片网格（工资管理、资产管理、钱包管理、清账管理）
- 快速操作入口

**导航**:
- 工资管理 → `salary_income_setup_screen.dart`
- 资产管理 → `asset_management_screen.dart`
- 钱包管理 → `wallet_management_screen.dart`
- 清账管理 → `clearance_home_screen.dart`

### 2. salary_income_setup_screen.dart - 工资收入设置页面

**职责**: 配置工资收入结构和奖金设置

**功能**:
- 基本工资设置
- 津贴设置（住房、餐补、交通、其他）
- 奖金管理（年终奖、季度奖、项目奖等）
- 个税计算（专项扣除、其他扣除）
- 社保和公积金设置
- 工资预览和计算

**关键组件**:
- `SalaryBasicInfoWidget` - 基本工资信息与补录模式开关
- `BonusManagementWidget` - 奖金管理
- `TaxDeductionsWidget` - 税务扣除
- `SalarySummaryWidget` - 工资汇总

### 3. asset_management_screen.dart - 资产管理页面

**职责**: 管理家庭各类资产

**功能**:
- 资产总览卡片（总资产、净资产、负债率）
- 资产分布可视化（饼图、柱状图）
- 资产列表管理（按分类显示）
- 添加/编辑/删除资产
- 资产详情查看

**资产分类**:
- 流动资产（银行活期、支付宝、微信、货币基金）
- 不动产（房产自住/投资、车位）
- 投资理财（银行理财、定期存款、基金、股票、黄金）
- 消费资产（电脑、家具等）
- 应收款（借出款项、押金、报销款）
- 债务（信用卡、个人借款、房屋贷款、车辆贷款）

### 4. add_asset_flow_screen.dart - 添加资产流程页面

**职责**: 引导式添加资产流程

**功能**:
- 分步式资产录入
- 五大资产分类的逐步录入
- 每个分类的预设子分类
- 自定义选项支持

### 5. asset_detail_screen.dart - 资产详情页面

**职责**: 展示资产详细信息

**功能**:
- 资产基本信息展示
- 资产历史记录
- 资产估值信息
- 编辑和删除操作

### 6. asset_history_screen.dart - 资产历史页面

**职责**: 展示资产的变更历史

**功能**:
- 资产变更记录列表
- 变更类型筛选（创建、更新、删除、估值变更）
- 变更详情查看
- 历史数据导出

### 7. wallet_management_screen.dart - 钱包管理页面

**职责**: 管理钱包账户

**功能**:
- 账户列表展示
- 账户类型管理（现金、银行、信用卡、投资、贷款等）
- 账户余额显示
- 添加/编辑/删除账户
- 账户详情查看

### 8. account_detail_screen.dart - 账户详情页面

**职责**: 展示账户详细信息

**功能**:
- 账户基本信息
- 账户余额和交易记录
- 账户操作（转账、充值、提现）
- 账户设置

### 9. clearance_home_screen.dart - 清账管理主页

**职责**: 管理周期清账会话

**功能**:
- 清账会话列表
- 创建新的清账会话
- 查看清账历史
- 删除未完成的清账

### 10. period_difference_analysis_screen.dart - 周期差额分析页面

**职责**: 分析周期内的余额差额

**功能**:
- 期初余额展示
- 期末余额展示
- 差额计算和展示
- 手动添加交易来解释差额
- 剩余差额自动归类

### 11. period_summary_screen.dart - 周期总结页面

**职责**: 生成周期性的财务报告

**功能**:
- 周期收支分析
- 分类统计
- 交易记录汇总
- 财务总结报告

### 12. 其他页面

- `add_wallet_screen.dart` - 添加钱包页面
- `asset_edit_screen.dart` - 编辑资产页面
- `asset_valuation_setup_screen.dart` - 资产估值设置页面
- `asset_calendar_view.dart` - 资产日历视图
- `fixed_asset_detail_screen.dart` - 固定资产详情页面
- `property_detail_screen.dart` - 房产详情页面
- `loan_detail_screen.dart` - 贷款详情页面
- `salary_preview_screen.dart` - 工资预览页面

## Widgets 组件说明

### 1. bonus_management_widget.dart - 奖金管理组件

**职责**: 管理工资收入中的奖金项

**功能**:
- 奖金列表展示
- 添加/编辑/删除奖金
- 奖金类型选择（年终奖、季度奖、项目奖等）
- 奖金频率配置

### 2. bonus_dialog_manager.dart - 奖金对话框管理

**职责**: 管理奖金相关的对话框

**功能**:
- 添加奖金对话框
- 编辑奖金对话框
- 奖金类型选择对话框

### 3. asset_overview_card.dart - 资产概览卡片

**职责**: 展示资产总览信息

**功能**:
- 总资产显示
- 净资产显示
- 负债率显示
- 隐私保护（金额隐藏/显示）

### 4. asset_distribution_card.dart - 资产分布卡片

**职责**: 展示资产分布情况

**功能**:
- 资产分类占比
- 饼图可视化
- 柱状图展示

### 5. asset_list_item.dart - 资产列表项

**职责**: 展示单个资产项

**功能**:
- 资产基本信息展示
- 资产金额显示
- 资产分类图标
- 点击跳转到详情

### 6. 其他组件

- `asset_category_tab_bar.dart` - 资产分类标签栏
- `asset_chart_card.dart` - 资产图表卡片
- `asset_list_overview_card.dart` - 资产列表概览卡片
- `bonus_item_widget.dart` - 奖金项组件
- `expandable_calculation_item.dart` - 可展开计算项
- `monthly_allowance_adjustment_widget.dart` - 月度津贴调整组件
- `quarterly_bonus_calculator.dart` - 季度奖金计算器
- `salary_basic_info_widget.dart` - 工资基本信息组件，内置年中补录/自动估算开关与滑块
- `salary_history_widget.dart` - 工资历史组件
- `salary_summary_widget.dart` - 工资汇总组件
- `tax_deductions_widget.dart` - 税务扣除组件，暴露 `onCalculateTax` 回调与即时「重新计算」按钮

## Services 服务说明

### 1. asset_history_service.dart - 资产历史服务

**职责**: 管理资产历史记录

**功能**:
- 记录资产变更
- 查询资产历史
- 导出历史数据

### 2. depreciation_service.dart - 资产折旧服务

**职责**: 计算资产折旧

**功能**:
- 直线法折旧计算
- 加速折旧计算
- 折旧历史记录

## 数据流

### 数据来源
- `core/providers/asset_provider.dart` - 资产状态管理
- `core/providers/account_provider.dart` - 账户状态管理
- `core/services/storage_service.dart` - 存储服务
- `core/services/drift_database_service.dart` - 数据库服务

### 数据流向
1. UI层（Screens） → Provider层（状态管理）
2. Provider层 → Service层（业务逻辑）
3. Service层 → Storage/Database层（数据持久化）

## 与其他模块的关系

### 与 Financial Planning 模块
- **输入**: 工资收入数据用于收入计划
- **输入**: 资产数据用于预算建议

### 与 Transaction Flow 模块
- **输入**: 账户数据用于交易记录
- **输出**: 清账完成后生成交易记录

## 设计原则

### 1. 静态数据管理
专注于管理不会频繁变化的财务基础信息。

### 2. 引导式录入
使用分步式流程降低用户使用门槛。

### 3. 可视化展示
提供丰富的图表和统计信息帮助用户理解财务状况。

### 4. 历史追溯
完整记录所有变更历史，支持数据追溯。

## 使用指南

### 添加新的资产类型

1. 在 `core/models/asset_item.dart` 中添加新的资产分类
2. 在 `add_asset_flow_screen.dart` 中添加对应的录入流程
3. 在 `asset_management_screen.dart` 中添加展示逻辑

### 添加新的账户类型

1. 在 `core/models/account.dart` 中添加新的账户类型枚举
2. 在 `wallet_management_screen.dart` 中添加对应的管理逻辑
3. 在 `account_detail_screen.dart` 中添加详情展示

## 相关文档

- [Core包文档](../../core/README.md)
- [项目架构重构总结](../../../项目架构重构总结.md)
- [数据存储架构与格式说明](../../../DEV_DOCUMENT/数据存储架构与格式说明.md)

