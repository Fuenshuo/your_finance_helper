# 💰 工资收入复用功能使用指南

## 🎯 功能概述

工资收入复用功能允许用户直接从已设置的工资收入中创建收入计划，避免重复录入和计算，大大提升用户体验。

## ✨ 核心特性

### 1. 智能工资识别
- 自动识别已设置的工资收入
- 显示工资名称和月薪金额
- 标记已创建收入计划的工资

### 2. 自动收入计算
- 自动计算每月固定收入（扣除五险一金和个税）
- 智能处理奖金项目，按发放频率创建独立计划
- 自动关联到指定钱包

### 3. 双向关联管理
- 工资与收入计划建立关联关系
- 避免重复创建相同的收入计划
- 支持查看和管理关联的收入计划

## 📋 使用流程

### 步骤1：进入创建收入计划页面
```
财务计划页面 → 点击右上角"+"按钮 → 选择"创建收入计划"
```

### 步骤2：选择"从工资创建"模板
在计划模板选择区域，选择第三个选项：
- 🏦 **从工资创建** - 使用已设置的工资
- 系统会自动检测是否有已设置的工资

### 步骤3：选择工资收入
如果有多个工资设置，选择要使用的工资：
- 显示工资名称
- 显示月薪净收入
- 绿色对勾表示已创建收入计划
- 点击选择对应工资

### 步骤4：选择关联钱包
选择收入计划关联的钱包账户：
- 工资卡
- 储蓄卡
- 投资账户

### 步骤5：确认创建
点击"创建计划"按钮，系统将：
- 创建每月固定工资收入计划
- 为每个奖金项目创建独立收入计划
- 自动设置合适的发放频率

## 🔧 技术实现

### 数据结构
```dart
// 工资收入模型
class SalaryIncome {
  final String id;
  final String name;
  final double basicSalary;           // 基本工资
  final double netIncome;             // 税后收入
  final List<BonusItem> bonuses;      // 奖金列表
  final double socialInsurance;       // 五险
  final double housingFund;           // 公积金
  final double personalIncomeTax;     // 个税
}

// 收入计划模型
class IncomePlan {
  final String id;
  final String name;
  final double amount;
  final IncomeFrequency frequency;
  final String walletId;
  final String? salaryIncomeId;       // 关联工资ID
}
```

### 自动计算逻辑
```dart
// 计算每月固定收入
double _calculateMonthlyFixedIncome(SalaryIncome salaryIncome) {
  final fixedIncome = salaryIncome.basicSalary +
      salaryIncome.housingAllowance +
      salaryIncome.mealAllowance +
      salaryIncome.transportationAllowance +
      salaryIncome.otherAllowance;

  final deductions = salaryIncome.socialInsurance +
      salaryIncome.housingFund +
      salaryIncome.personalIncomeTax;

  return fixedIncome - deductions;
}
```

### 奖金处理逻辑
```dart
// 为每个奖金创建独立计划
for (final bonus in salaryIncome.bonuses) {
  final bonusPlan = IncomePlan.create(
    name: '${salaryIncome.name} - ${bonus.name}',
    amount: bonus.amount / bonus.paymentCount,
    frequency: _convertBonusFrequency(bonus.frequency),
    walletId: walletId,
    salaryIncomeId: salaryIncome.id,
  );
}
```

## 📊 用户体验亮点

### 1. 一键创建
- 无需手动录入工资数据
- 自动计算扣除项
- 智能奖金分摊

### 2. 避免重复
- 系统检测已创建的计划
- 避免重复创建相同工资的计划
- 清晰的关联关系显示

### 3. 智能分摊
- 奖金按实际发放频率分摊
- 支持多种奖金类型
- 自动计算分摊金额

## 🎨 界面设计

### 模板选择界面
```
┌─────────────────────────────────────┐
│ 🎯 计划模板                           │
│                                     │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐ │
│ │💰普通收入│ │🛠️详细工资│ │🏦从工资创建│ │
│ │一次性或  │ │包含五险一│ │使用已设置│ │
│ │定期收入  │ │金等      │ │的工资    │ │
│ └─────────┘ └─────────┘ └─────────┘ │
└─────────────────────────────────────┘
```

### 工资选择对话框
```
┌─────────────────────────────────────┐
│ 选择工资收入                          │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 主职工资                          │ │
│ │ 月薪: ¥15,000                   │ │
│ │ ✅ 已创建收入计划                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 副职工资                          │ │
│ │ 月薪: ¥8,000                    │ │
│ │ ⚪ 未创建收入计划                 │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

## 🔗 关联功能

### 查看关联计划
在工资管理页面可以：
- 查看已关联的收入计划
- 跳转到对应的收入计划详情
- 管理关联关系

### 计划追溯
在收入计划详情页面可以：
- 查看来源工资信息
- 返回到工资设置页面
- 查看奖金分摊详情

## 📈 扩展功能

### 未来计划
1. **工资变更同步** - 当工资调整时自动更新收入计划
2. **智能提醒** - 到账提醒和异常检测
3. **税务优化** - 奖金发放优化建议
4. **多账户分配** - 支持不同奖金分配到不同账户

### 集成场景
1. **薪资调整** - 自动更新所有相关收入计划
2. **奖金发放** - 按计划自动记录奖金收入
3. **年度结算** - 年终奖自动分摊到全年

## 🐛 常见问题

### Q: 为什么没有显示工资选项？
A: 请先在"家庭信息维护 → 工资管理"中设置工资信息。

### Q: 奖金金额为什么被分摊了？
A: 系统会根据奖金发放频率自动分摊到每次发放。例如年终奖一次性发放，系统会将其作为年度收入处理。

### Q: 如何修改已创建的收入计划？
A: 在财务计划主页点击对应计划进行编辑，或通过工资管理页面的关联入口进入。

## 🎯 总结

工资收入复用功能实现了：
- ✅ **用户体验优化** - 一键创建，避免重复录入
- ✅ **数据准确性** - 自动计算，减少人工错误
- ✅ **系统集成** - 与现有工资系统深度整合
- ✅ **智能处理** - 奖金分摊，频率转换等
- ✅ **关联管理** - 双向关联，便于追溯和管理

这个功能大大提升了用户的操作效率，让复杂的工资收入管理变得简单直观！🚀
