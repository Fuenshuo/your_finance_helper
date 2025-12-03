# 领域服务层 (Domain Services)

## 概述

领域服务层负责编排领域实体间的复杂业务逻辑，处理跨实体的业务操作。

## 职责

- **业务逻辑编排**: 协调多个实体间的复杂业务流程
- **领域规则执行**: 实现跨越多个实体的业务规则
- **状态转换**: 处理实体状态的复杂转换逻辑
- **业务计算**: 执行复杂的业务计算和分析

## 架构原则

### 1. 服务接口设计
```dart
/// 领域服务接口
abstract class DomainService {
  /// 服务标识
  String get serviceId;

  /// 执行领域操作
  Future<OperationResult<T>> execute<T>(DomainOperation operation);
}

/// 领域操作结果
class OperationResult<T> {
  const OperationResult({
    required this.success,
    required this.data,
    required this.errors,
    required this.events,
  });

  final bool success;
  final T? data;
  final List<String> errors;
  final List<DomainEvent> events;
}
```

### 2. 领域操作定义
```dart
/// 领域操作基类
abstract class DomainOperation {
  const DomainOperation();

  /// 操作类型标识
  String get operationType;

  /// 验证操作参数
  ValidationResult validate();
}
```

## 目录结构

```
lib/core/domain/services/
├── README.md                          # 本文档
├── asset_domain_service.dart          # 资产领域服务
├── account_domain_service.dart        # 账户领域服务
├── transaction_domain_service.dart    # 交易领域服务
├── budget_domain_service.dart         # 预算领域服务
├── financial_analysis_service.dart    # 财务分析服务
├── reporting_service.dart             # 报表生成服务
└── domain_operation.dart              # 领域操作定义
```

## 核心领域服务

### 1. 资产领域服务 (AssetDomainService)
- **职责**: 处理资产相关的复杂业务逻辑
- **核心功能**:
  - 资产折旧计算和应用
  - 资产价值评估和调整
  - 资产分类和分组管理
  - 资产生命周期管理

### 2. 交易领域服务 (TransactionDomainService)
- **职责**: 处理交易相关的复杂业务逻辑
- **核心功能**:
  - 交易匹配和配对
  - 交易分类和标签管理
  - 交易模式识别和学习
  - 交易异常检测

### 3. 预算领域服务 (BudgetDomainService)
- **职责**: 处理预算相关的复杂业务逻辑
- **核心功能**:
  - 预算执行监控和预警
  - 预算调整和重新分配
  - 预算绩效分析
  - 预算预测和建议

### 4. 财务分析服务 (FinancialAnalysisService)
- **职责**: 执行复杂的财务分析和计算
- **核心功能**:
  - 现金流分析
  - 资产负债分析
  - 盈利能力分析
  - 财务比率计算

## 领域操作示例

### 资产转移操作
```dart
class AssetTransferOperation extends DomainOperation {
  const AssetTransferOperation({
    required this.assetId,
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
  });

  final String assetId;
  final String fromAccountId;
  final String toAccountId;
  final double amount;

  @override
  String get operationType => 'asset_transfer';

  @override
  ValidationResult validate() {
    final errors = <String>[];

    if (assetId.isEmpty) errors.add('资产ID不能为空');
    if (fromAccountId.isEmpty) errors.add('源账户ID不能为空');
    if (toAccountId.isEmpty) errors.add('目标账户ID不能为空');
    if (amount <= 0) errors.add('转移金额必须大于0');

    return errors.isEmpty
        ? ValidationResult.valid()
        : ValidationResult.invalid(errors);
  }
}
```

### 服务执行示例
```dart
class AssetDomainServiceImpl implements AssetDomainService {
  @override
  Future<OperationResult<AssetTransferResult>> execute(
    AssetTransferOperation operation,
  ) async {
    // 验证操作
    final validation = operation.validate();
    if (!validation.isValid) {
      return OperationResult(
        success: false,
        data: null,
        errors: validation.errors,
        events: [],
      );
    }

    try {
      // 执行业务逻辑
      final result = await _performAssetTransfer(operation);

      // 生成领域事件
      final events = [
        AssetTransferredEvent(
          assetId: operation.assetId,
          fromAccountId: operation.fromAccountId,
          toAccountId: operation.toAccountId,
          amount: operation.amount,
          timestamp: DateTime.now(),
        ),
      ];

      return OperationResult(
        success: true,
        data: result,
        errors: [],
        events: events,
      );
    } catch (e) {
      return OperationResult(
        success: false,
        data: null,
        errors: [e.toString()],
        events: [],
      );
    }
  }
}
```

## 设计模式应用

### 1. 策略模式 - 计算策略
```dart
abstract class DepreciationStrategy {
  double calculateDepreciation(AssetEntity asset, int periods);
}

class StraightLineDepreciation implements DepreciationStrategy {
  @override
  double calculateDepreciation(AssetEntity asset, int periods) {
    return asset.amount / asset.usefulLife * periods;
  }
}
```

### 2. 模板方法模式 - 业务流程
```dart
abstract class BudgetExecutionTemplate {
  Future<void> executeBudgetCycle(BudgetEntity budget);

  // 模板方法
  Future<void> executeBudgetCycleTemplate(BudgetEntity budget) async {
    await validateBudget(budget);
    await allocateFunds(budget);
    await monitorExecution(budget);
    await generateReport(budget);
  }

  Future<void> validateBudget(BudgetEntity budget);
  Future<void> allocateFunds(BudgetEntity budget);
  Future<void> monitorExecution(BudgetEntity budget);
  Future<void> generateReport(BudgetEntity budget);
}
```

### 3. 观察者模式 - 领域事件
```dart
class DomainEventBus {
  final Map<Type, List<DomainEventHandler>> _handlers = {};

  void register<T extends DomainEvent>(DomainEventHandler<T> handler) {
    final type = T;
    _handlers[type] ??= [];
    _handlers[type]!.add(handler);
  }

  void publish<T extends DomainEvent>(T event) {
    final handlers = _handlers[T] ?? [];
    for (final handler in handlers) {
      handler.handle(event);
    }
  }
}
```

## 业务规则引擎

### 规则定义
```dart
abstract class BusinessRule {
  const BusinessRule();

  String get ruleId;
  String get description;

  ValidationResult evaluate(DomainContext context);
}

class MinimumBalanceRule extends BusinessRule {
  const MinimumBalanceRule(this.minimumBalance);

  final double minimumBalance;

  @override
  String get ruleId => 'minimum_balance';

  @override
  String get description => '账户余额不能低于最低限额';

  @override
  ValidationResult evaluate(DomainContext context) {
    final balance = context.accountBalance;
    if (balance < minimumBalance) {
      return ValidationResult.invalid([
        '账户余额 $balance 低于最低限额 $minimumBalance',
      ]);
    }
    return ValidationResult.valid();
  }
}
```

### 规则引擎
```dart
class BusinessRuleEngine {
  final List<BusinessRule> _rules = [];

  void addRule(BusinessRule rule) => _rules.add(rule);

  ValidationResult evaluateAll(DomainContext context) {
    final allErrors = <String>[];
    final allWarnings = <String>[];

    for (final rule in _rules) {
      final result = rule.evaluate(context);
      allErrors.addAll(result.errors);
      allWarnings.addAll(result.warnings);
    }

    if (allErrors.isNotEmpty) {
      return ValidationResult.invalid(allErrors);
    }

    return ValidationResult.valid();
  }
}
```

## 依赖注入

### 服务注册
```dart
class DomainServiceRegistry {
  static final DomainServiceRegistry _instance = DomainServiceRegistry._internal();
  factory DomainServiceRegistry() => _instance;

  DomainServiceRegistry._internal();

  final Map<Type, DomainService> _services = {};

  void register<T extends DomainService>(T service) {
    _services[T] = service;
  }

  T get<T extends DomainService>() {
    final service = _services[T];
    if (service == null) {
      throw StateError('Service $T not registered');
    }
    return service as T;
  }
}
```

## 测试策略

### 单元测试
- **服务方法**: 验证单个服务方法的正确性
- **业务规则**: 验证业务规则的执行逻辑
- **领域事件**: 验证事件发布和处理

### 集成测试
- **服务协作**: 验证多个服务间的协作
- **事务完整性**: 验证业务操作的原子性
- **事件流**: 验证事件驱动的业务流程

### 验收测试
- **业务场景**: 验证完整的业务用例
- **边界条件**: 验证异常情况的处理
- **性能测试**: 验证复杂计算的性能

## 性能优化

### 1. 缓存策略
- 复杂计算结果缓存
- 频繁查询的数据缓存
- 缓存失效策略

### 2. 异步处理
- 长时间运行的操作异步执行
- 事件异步处理
- 非阻塞业务逻辑

### 3. 批量操作
- 批量数据处理
- 批量事件发布
- 批量验证

## 监控和日志

### 业务指标监控
```dart
class DomainMetrics {
  static final DomainMetrics _instance = DomainMetrics._internal();
  factory DomainMetrics() => _instance;

  final Map<String, int> _operationCounts = {};
  final Map<String, Duration> _operationDurations = {};

  void recordOperation(String operation, Duration duration) {
    _operationCounts[operation] = (_operationCounts[operation] ?? 0) + 1;
    _operationDurations[operation] = duration;
  }

  Map<String, dynamic> getMetrics() => {
    'operationCounts': _operationCounts,
    'averageDurations': _operationDurations,
  };
}
```

## 相关文档

- [领域实体层](./entities/README.md) - 业务实体定义
- [应用服务层](../../application/README.md) - 用例实现
- [基础设施层](../../infrastructure/README.md) - 外部依赖接口
- [架构决策记录](../../adr/README.md) - 架构决策说明
