# 领域实体层 (Domain Entities)

## 概述

领域实体层定义了业务领域的核心概念和规则，是整个应用的核心业务逻辑所在。

## 职责

- **业务实体定义**: 定义领域内的核心业务对象
- **业务规则**: 封装业务规则和约束
- **值对象**: 定义不可变的值对象
- **领域事件**: 定义领域事件和状态变更

## 架构原则

### 1. 实体设计原则
```dart
/// 领域实体基类
abstract class DomainEntity {
  const DomainEntity();

  /// 唯一标识符
  String get id;

  /// 创建时间
  DateTime get createdAt;

  /// 最后更新时间
  DateTime get updatedAt;

  /// 是否有效
  bool get isValid;

  /// 验证业务规则
  ValidationResult validate();
}
```

### 2. 值对象模式
```dart
/// 值对象 - 不可变对象，通过属性值判断相等性
@immutable
class Money {
  const Money(this.amount, this.currency);

  final double amount;
  final String currency;

  Money add(Money other) {
    if (currency != other.currency) {
      throw ArgumentError('货币类型不匹配');
    }
    return Money(amount + other.amount, currency);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money &&
          runtimeType == other.runtimeType &&
          amount == other.amount &&
          currency == other.currency;

  @override
  int get hashCode => Object.hash(amount, currency);
}
```

## 目录结构

```
lib/core/domain/entities/
├── README.md                          # 本文档
├── asset_entity.dart                  # 资产领域实体
├── account_entity.dart                # 账户领域实体
├── transaction_entity.dart            # 交易领域实体
├── budget_entity.dart                 # 预算领域实体
├── financial_report_entity.dart       # 财务报表实体
├── validation_result.dart             # 验证结果
└── domain_events.dart                 # 领域事件定义
```

## 核心实体

### 1. 资产实体 (AssetEntity)
- **职责**: 定义资产的核心属性和业务规则
- **业务规则**:
  - 资产名称不能为空且唯一
  - 资产价值必须大于等于0
  - 资产类型必须有效
  - 折旧规则必须符合资产类型

### 2. 账户实体 (AccountEntity)
- **职责**: 定义账户的核心属性和业务规则
- **业务规则**:
  - 账户名称不能为空且唯一
  - 账户类型必须有效
  - 默认账户只能有一个

### 3. 交易实体 (TransactionEntity)
- **职责**: 定义交易的核心属性和业务规则
- **业务规则**:
  - 交易金额不能为0
  - 交易类型和分类必须匹配
  - 交易日期不能为未来日期

### 4. 预算实体 (BudgetEntity)
- **职责**: 定义预算的核心属性和业务规则
- **业务规则**:
  - 预算周期必须有效
  - 预算金额必须大于0
  - 预算时间范围必须合理

## 值对象

### 货币值对象 (Money)
- 金额和货币类型
- 货币运算方法
- 格式化显示

### 日期范围值对象 (DateRange)
- 开始和结束日期
- 验证日期有效性
- 计算时间跨度

## 业务规则验证

### 验证结果 (ValidationResult)
```dart
class ValidationResult {
  const ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  factory ValidationResult.valid() => const ValidationResult(
        isValid: true,
        errors: [],
        warnings: [],
      );

  factory ValidationResult.invalid(List<String> errors) => ValidationResult(
        isValid: false,
        errors: errors,
        warnings: [],
      );
}
```

## 领域事件

### 事件定义
```dart
/// 资产变更事件
class AssetChangedEvent {
  const AssetChangedEvent({
    required this.assetId,
    required this.changeType,
    required this.oldValue,
    required this.newValue,
    required this.timestamp,
  });

  final String assetId;
  final AssetChangeType changeType;
  final AssetEntity? oldValue;
  final AssetEntity newValue;
  final DateTime timestamp;
}
```

## 使用示例

### 创建资产实体
```dart
final asset = AssetEntity(
  id: 'asset_001',
  name: '公司股票',
  type: AssetType.investment,
  amount: 10000.0,
  currency: 'CNY',
);

// 验证业务规则
final validation = asset.validate();
if (!validation.isValid) {
  // 处理验证错误
  for (final error in validation.errors) {
    print('验证错误: $error');
  }
}
```

### 值对象运算
```dart
final salary = Money(5000.0, 'CNY');
final bonus = Money(1000.0, 'CNY');
final totalIncome = salary.add(bonus);

print('总收入: ${totalIncome.format()}'); // 输出: 总收入: ¥6,000.00
```

## 设计原则

### 1. 单一职责
每个实体只负责一个明确的业务概念。

### 2. 封装性
业务规则封装在实体内部，不暴露实现细节。

### 3. 不变性
值对象不可变，保证线程安全和可预测性。

### 4. 业务导向
设计决策基于业务需求而非技术便利。

### 5. 验证优先
所有业务规则都有对应的验证逻辑。

## 测试策略

### 单元测试
- **实体创建**: 验证正确创建和属性赋值
- **业务规则**: 验证各种业务规则的正确性
- **值对象**: 验证不可变性和运算逻辑

### 集成测试
- **实体交互**: 验证实体间的业务交互
- **状态转换**: 验证状态变更的正确性
- **事件发布**: 验证领域事件的发布机制

## 相关文档

- [领域服务层](../services/README.md) - 业务逻辑编排
- [应用服务层](../../application/README.md) - 用例实现
- [基础设施层](../../infrastructure/README.md) - 外部依赖接口
