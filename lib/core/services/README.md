# Core Services 包文档

## 概述

`core/services` 包是Flux Ledger应用的核心业务逻辑层，提供所有业务服务、数据处理和外部系统集成。它是连接数据层与表现层的桥梁，实现了应用的业务规则和数据操作。

**文件统计**: 75个Dart文件，涵盖AI服务、数据迁移、验证框架等核心业务功能

## 架构定位

### 层级关系
```
UI Layer (Screens/Widgets)          # 调用服务
    ↓ (业务逻辑调用)
core/services/                      # 🔵 当前层级 - 业务逻辑
    ↓ (数据操作)
core/database/ + SharedPreferences  # 数据存储
    ↓ (外部接口)
Third-party APIs                    # 外部服务
```

### 职责边界
- ✅ **业务逻辑**: 实现复杂的业务规则和数据处理
- ✅ **数据访问**: 封装数据存储和检索操作
- ✅ **外部集成**: 处理第三方API和服务调用
- ✅ **异步操作**: 管理所有异步业务流程
- ❌ **UI渲染**: 不负责界面展示逻辑
- ❌ **状态管理**: 不直接管理应用状态（通过Provider）

## 服务分类

### 1. 数据存储服务 (8个文件)

#### StorageService (`storage_service.dart`)
**职责**: 统一的SharedPreferences数据存储服务

**核心功能**:
- 键值对数据存储和检索
- 类型安全的数据序列化
- 数据迁移和版本管理

**关联关系**:
- **依赖**: `SharedPreferences` (系统存储)
- **被依赖**: 所有Provider (数据持久化)
- **级联影响**: 应用重启后的数据恢复

#### DriftDatabaseService (`drift_database_service.dart`)
**职责**: Drift数据库操作服务

**核心功能**:
- 类型安全的SQL查询执行
- 数据库事务管理
- 数据迁移处理

**关联关系**:
- **依赖**: `core/database/app_database.dart` (数据库定义)
- **被依赖**: 所有数据密集型Provider
- **级联影响**: 复杂查询的性能优化

#### HybridStorageService (`hybrid_storage_service.dart`)
**职责**: 混合存储策略服务

**核心功能**:
- 智能选择存储方式（内存/本地/云端）
- 数据同步策略
- 缓存管理

**关联关系**:
- **依赖**: `StorageService`, `DriftDatabaseService`
- **被依赖**: 大数据量场景的Provider
- **级联影响**: 存储性能和用户体验

### 2. 财务计算服务 (6个文件)

#### PersonalIncomeTaxService (`personal_income_tax_service.dart`)
**职责**: 个人所得税计算服务

**核心功能**:
- 最新个税政策计算
- 专项附加扣除处理
- 税款预扣预缴计算

**关联关系**:
- **依赖**: 工资收入数据 (通过Provider)
- **被依赖**: `features/family_info/` (工资设置页面)
- **级联影响**: 工资计算准确性

#### LoanCalculationService (`loan_calculation_service.dart`)
**职责**: 贷款计算服务

**核心功能**:
- 等额本息/等额本金计算
- 提前还款计算
- 利率调整模拟

**关联关系**:
- **依赖**: 贷款参数 (通过UI输入)
- **被依赖**: `features/financial_planning/` (贷款计算器)
- **级联影响**: 财务规划准确性

#### ChineseMortgageService (`chinese_mortgage_service.dart`)
**职责**: 中国房贷专项计算服务

**核心功能**:
- 公积金贷款计算
- 商业贷款计算
- 组合贷款处理

**关联关系**:
- **依赖**: 房产贷款参数
- **被依赖**: 资产管理中的房贷计算
- **级联影响**: 资产估值准确性

#### SalaryCalculationService (`salary_calculation_service.dart`)
**职责**: 工资计算服务

**核心功能**:
- 复杂工资结构计算
- 年终奖分月处理
- 社保公积金计算

**关联关系**:
- **依赖**: 工资配置数据
- **被依赖**: 工资设置和预算规划
- **级联影响**: 收入计划准确性

### 3. 数据处理服务 (4个文件)

#### DataMigrationService (`data_migration_service.dart`)
**职责**: 数据迁移和升级服务

**核心功能**:
- 应用版本升级时的数据迁移
- 数据结构变更处理
- 向后兼容性保证

**关联关系**:
- **依赖**: 旧版本数据格式
- **被依赖**: 应用启动时的初始化流程
- **级联影响**: 版本升级的平滑过渡

#### ClearanceService (`clearance_service.dart`)
**职责**: 账目清算服务

**核心功能**:
- 周期性账目核对
- 余额差异分析
- 交易补录建议

**关联关系**:
- **依赖**: 交易记录和账户余额
- **被依赖**: 清账会话管理页面
- **级联影响**: 账目准确性和完整性

#### AssetHistoryService (`asset_history_service.dart`)
**职责**: 资产历史记录服务

**核心功能**:
- 资产变更历史追踪
- 资产估值历史记录
- 历史数据分析

**关联关系**:
- **依赖**: 资产数据变更事件
- **被依赖**: 资产详情和历史页面
- **级联影响**: 资产变化的可追溯性

### 4. AI服务系统 (22个文件)

#### 核心AI服务
- **NaturalLanguageTransactionService**: 自然语言交易解析
- **AiConfigService**: AI配置管理
- **AiServiceFactory**: AI服务工厂

**关联关系**:
- **依赖**: 第三方AI API (DashScope, SiliconFlow)
- **被依赖**: 交易录入和AI分析功能
- **级联影响**: 智能功能的可用性和准确性

### 5. 验证框架 (5个文件)

#### VerificationRunner (`verification_runner.dart`)
**职责**: 组件验证框架的核心运行器

**核心功能**:
- 统一验证接口定义
- 验证结果收集和汇总
- 验证流程编排

**关联关系**:
- **依赖**: `ComponentVerifier` 接口实现
- **被依赖**: 迁移验证和自动化测试
- **级联影响**: 系统完整性保证

## 设计原则

### 1. 单例模式
所有服务类都使用单例模式，确保全局唯一实例。

### 2. 依赖注入
通过构造函数注入依赖，便于测试和解耦。

### 3. 异步优先
所有服务方法都是异步的，保证UI响应性。

### 4. 错误处理
完善的错误处理和异常传播机制。

### 5. 类型安全
使用强类型接口，确保数据传递的安全性。

## 服务间通信

### 事件驱动模式
```dart
class TransactionService {
  final _transactionController = StreamController<Transaction>.broadcast();

  Stream<Transaction> get transactionStream => _transactionController.stream;

  Future<void> createTransaction(Transaction transaction) async {
    await _databaseService.saveTransaction(transaction);
    _transactionController.add(transaction); // 广播事件
  }
}
```

### 服务协作
```
TransactionService
├── AccountService (余额更新)
├── BudgetService (预算扣减)
├── NotificationService (提醒通知)
└── LoggingService (操作日志)
```

## 性能优化

### 1. 连接池管理
数据库连接的智能复用和生命周期管理。

### 2. 缓存策略
热点数据的内存缓存，减少数据库访问。

### 3. 批量操作
支持批量数据处理，优化I/O性能。

### 4. 异步处理
长时间操作的后台异步执行。

## 测试策略

### 单元测试
- 测试业务逻辑的正确性
- 测试错误处理场景
- 测试边界条件

### 集成测试
- 测试服务间的协作
- 测试与数据库的交互
- 测试外部API调用

### 性能测试
- 测试服务响应时间
- 测试并发处理能力
- 测试内存使用情况

## 扩展开发

### 添加新服务
```dart
class NewFinancialService {
  static NewFinancialService? _instance;
  static NewFinancialService get instance => _instance ??= NewFinancialService._();

  NewFinancialService._();

  Future<Result> performCalculation(InputData data) async {
    // 实现业务逻辑
  }
}
```

### 服务依赖注入
```dart
class ComplexService {
  final StorageService _storage;
  final ApiService _api;

  ComplexService(this._storage, this._api);

  Future<void> complexOperation() async {
    final data = await _storage.loadData();
    await _api.sendData(data);
  }
}
```

## 相关文档

- [Core包总文档](../README.md)
- [AI服务系统](ai/README.md)
- [验证框架](verifiers/README.md)
- [数据迁移服务](legacy_import/README.md)



