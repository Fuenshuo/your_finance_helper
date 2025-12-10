# Transaction Entry Feature - 交易录入功能

## 概述

交易录入功能是家庭资产记账应用的核心模块，提供了直观的自然语言交易录入体验。通过AI驱动的解析引擎，用户可以使用日常语言快速记录各类交易，支持实时验证、草稿管理和多层次的安全保护。

**文件统计**: 35个Dart文件（models: 3个, providers: 3个, services: 8个, widgets: 19个, screens: 3个, utils: 1个）

## 架构设计

### 分层架构

```
┌─────────────────┐
│   UI Layer      │  Widgets & Screens (22个文件)
├─────────────────┤
│ Business Logic  │  Providers & Services (11个文件)
├─────────────────┤
│   Data Layer    │  Models & Persistence (3个文件)
└─────────────────┘
```

### 核心组件

#### UI 层
- **TransactionEntryScreen**: 主页面组件，整合所有UI元素
- **InputDock**: 输入面板，包含文本输入、语音输入和发送按钮
- **DraftCard**: 草稿显示卡片，展示解析结果
- **TimelineView**: 时间线视图，显示交易历史

#### 业务逻辑层
- **TransactionEntryProvider**: 主状态管理器
- **DraftManagerProvider**: 草稿管理
- **InputValidationProvider**: 输入验证
- **TransactionParserService**: 自然语言解析服务
- **ValidationService**: 业务规则验证
- **DraftPersistenceService**: 草稿持久化

#### 数据层
- **TransactionEntryState**: 主状态模型
- **DraftTransaction**: 草稿交易模型
- **InputValidation**: 验证结果模型

## 功能特性

### 🌟 核心功能

1. **自然语言解析**
   - 支持中英文混合输入
   - 智能识别金额、类型、分类
   - 实时解析和验证

2. **实时验证**
   - 金额范围检查
   - 业务规则验证
   - 错误提示和建议

3. **草稿管理**
   - 自动保存草稿
   - 多草稿管理
   - 草稿恢复功能

4. **性能监控**
   - 响应时间 < 50ms
   - 内存使用监控
   - UI渲染性能跟踪

### 🔒 安全特性

- **数据加密**: 敏感数据使用AES加密存储
- **iOS Keychain兼容**: 支持安全密钥存储
- **权限控制**: 细粒度权限管理

### 📱 用户体验

- **响应式设计**: 适配手机、平板、Web
- **无障碍支持**: 完整的无障碍功能
- **多主题支持**: 明暗主题切换

## 文件结构

```
lib/features/transaction_entry/
├── models/                    # 数据模型 (3个文件)
│   ├── transaction_entry_state.dart
│   ├── draft_transaction.dart
│   └── input_validation.dart
├── providers/                 # 状态管理 (3个文件)
│   ├── transaction_entry_provider.dart
│   ├── draft_manager_provider.dart
│   └── input_validation_provider.dart
├── services/                  # 业务服务 (8个文件)
│   ├── transaction_parser_service.dart
│   ├── validation_service.dart
│   ├── draft_persistence_service.dart
│   ├── secure_storage_service.dart
│   ├── performance_monitor_service.dart
│   ├── cross_layer_communication_service.dart
│   ├── error_handling_service.dart
│   └── ... (更多服务)
├── utils/                     # 工具函数 (1个文件)
│   └── performance_monitor.dart
├── widgets/                   # UI组件 (19个文件)
│   ├── transaction_entry_screen.dart
│   ├── input_dock/            # 输入dock组件 (4个文件)
│   ├── draft_card/            # 草稿卡片组件 (7个文件)
│   ├── timeline/              # 时间线组件 (4个文件)
│   └── insights/              # 洞察组件
├── screens/                   # 页面组件 (3个文件)
│   ├── transaction_entry_screen.dart
│   ├── unified_transaction_entry_screen.dart
│   └── transaction_detail_screen.dart
├── index.dart                 # 模块导出
├── migration_guide.md         # 迁移指南
├── migration_manager.dart     # 迁移管理
└── security_audit.md          # 安全审计
```

## 使用指南

### 基本使用

```dart
import 'package:your_finance_flutter/features/transaction_entry/screens/transaction_entry_screen.dart';

// 在路由中添加页面
'/transaction-entry': (context) => const TransactionEntryScreenPage(),
```

### 高级配置

```dart
// 配置解析服务
final parserService = TransactionParserService();

// 配置验证规则
final validationService = ValidationService();

// 使用Provider
ProviderScope(
  overrides: [
    transactionParserServiceProvider.overrideWithValue(parserService),
    validationServiceProvider.overrideWithValue(validationService),
  ],
  child: const TransactionEntryScreenPage(),
)
```

## 性能指标

- **解析响应时间**: < 50ms
- **UI渲染帧率**: 60fps
- **内存使用**: < 100MB
- **测试覆盖率**: > 85%

## 测试覆盖

### 单元测试
- 服务层测试: `test/features/transaction_entry/services/`
- 模型测试: `test/features/transaction_entry/models/`

### 集成测试
- Provider集成测试
- 端到端用户流程测试

### 性能测试
- 响应时间基准测试
- 内存泄漏检测

## 依赖项

### 核心依赖
- `flutter_riverpod`: 状态管理
- `shared_preferences`: 本地存储
- `flutter_secure_storage`: 安全存储

### 可选依赖
- `speech_to_text`: 语音输入
- `permission_handler`: 权限管理

## 扩展开发

### 添加新的解析规则

```dart
class CustomTransactionParser extends TransactionParserService {
  @override
  Future<DraftTransaction> parseTransaction(String input) async {
    // 自定义解析逻辑
    return super.parseTransaction(input);
  }
}
```

### 自定义验证规则

```dart
class CustomValidationService extends ValidationService {
  @override
  Future<InputValidation> validateDraft(DraftTransaction draft) async {
    // 自定义验证逻辑
    return super.validateDraft(draft);
  }
}
```

## 故障排除

### 常见问题

1. **解析失败**
   - 检查输入格式
   - 确认权限设置

2. **性能问题**
   - 检查内存使用
   - 优化UI渲染

3. **存储问题**
   - 检查存储权限
   - 验证数据完整性

## 贡献指南

1. 遵循现有的代码规范
2. 添加相应的测试用例
3. 更新文档
4. 提交PR进行代码审查

## 版本历史

- **v1.0.0**: 初始版本，支持基础交易录入
- **v1.1.0**: 添加语音输入支持
- **v1.2.0**: 优化性能和用户体验

## 许可证

本项目采用 MIT 许可证。
