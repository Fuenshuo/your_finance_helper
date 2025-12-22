# AI服务系统文档

## 概述

`core/services/ai/` 是Flux Ledger的AI能力核心，集成了多种AI服务提供商和智能功能，为应用提供自然语言处理、图像识别、文档分析等AI增强功能。

**文件统计**: 22个Dart文件 + 7个Prompt模板文件，构建完整的AI服务生态

## 架构定位

### 层级关系
```
UI Layer (交易录入/洞察分析)       # 调用AI功能
    ↓ (自然语言解析/智能分析)
core/services/ai/                  # 🔵 当前层级 - AI服务核心
    ↓ (API调用/模型推理)
第三方AI平台 (DashScope/SiliconFlow) # 外部AI服务
    ↓ (返回结果)
UI Layer (展示解析结果)            # 显示AI结果
```

### 职责边界
- ✅ **AI服务集成**: 统一管理多种AI服务提供商
- ✅ **智能功能**: 自然语言解析、图像识别、文档分析
- ✅ **Prompt管理**: 专业Prompt模板的设计和维护
- ✅ **服务抽象**: 统一的AI服务接口和工厂模式
- ❌ **UI展示**: 不负责AI结果的界面展示
- ❌ **业务逻辑**: 不包含具体的财务业务规则

## AI服务架构

### 核心组件

#### 1. 服务抽象层 (3个文件)

##### AiService (`ai_service.dart`)
**职责**: 定义统一的AI服务接口契约

**核心接口**:
```dart
abstract class AiService {
  Future<AiResponse> processText(String text, {AiConfig? config});
  Future<AiResponse> processImage(Uint8List imageBytes, {AiConfig? config});
  Future<AiResponse> analyzeDocument(String content, {AiConfig? config});
}
```

**关联关系**:
- **实现**: 被所有具体AI服务类实现
- **使用**: 通过`AiServiceFactory`创建实例
- **依赖**: `AiConfig` (配置模型)

##### AiServiceFactory (`ai_service_factory.dart`)
**职责**: AI服务工厂，负责创建和管理AI服务实例

**核心功能**:
- 根据配置创建对应的AI服务实例
- 服务实例缓存和复用
- 配置验证和错误处理

**关联关系**:
- **依赖**: `AiConfigService` (获取配置)
- **被依赖**: 所有需要AI功能的服务类
- **关联**: `AiService` 接口的所有实现类

##### AiConfigService (`ai_config_service.dart`)
**职责**: AI配置管理服务

**核心功能**:
- AI服务提供商配置管理
- API密钥安全存储
- 模型参数动态调整

**关联关系**:
- **依赖**: `StorageService` (配置持久化)
- **被依赖**: `AiServiceFactory` (获取配置)
- **级联影响**: 所有AI服务的配置变更

#### 2. 具体服务实现 (3个文件)

##### DashScopeAiService (`dashscope_ai_service.dart`)
**职责**: 阿里云DashScope AI服务集成

**核心功能**:
- 通义千问模型集成
- 文本生成和对话
- 图像理解和分析

**关联关系**:
- **实现**: `AiService` 接口
- **依赖**: DashScope API
- **使用场景**: 通用AI功能

##### SiliconFlowAiService (`siliconflow_ai_service.dart`)
**职责**: SiliconFlow AI服务集成

**核心功能**:
- 开源大模型集成
- 高性价比AI服务
- 多种模型支持

**关联关系**:
- **实现**: `AiService` 接口
- **依赖**: SiliconFlow API
- **使用场景**: 成本敏感场景

##### AiServiceIsolate (`ai_service_isolate.dart`)
**职责**: AI服务隔离执行环境

**核心功能**:
- 将AI调用隔离到独立线程
- 防止UI阻塞
- 提高应用响应性

**关联关系**:
- **依赖**: `AiService` 接口
- **被依赖**: 长时间AI操作的调用方
- **优势**: 提升用户体验

#### 3. 专用AI服务 (6个文件)

##### NaturalLanguageTransactionService (`natural_language_transaction_service.dart`)
**职责**: 自然语言交易解析服务

**核心功能**:
- 中英文自然语言解析
- 智能提取交易要素（金额、类型、账户等）
- 实时解析和验证

**关联关系**:
- **依赖**: `AiService` (AI能力), `prompts/natural_language_prompt.txt`
- **被依赖**: `screens/unified_transaction_entry_screen.dart` (交易录入)
- **级联影响**: 交易录入的用户体验

##### ImageProcessingService (`image_processing_service.dart`)
**职责**: 图像处理和识别服务

**核心功能**:
- 发票图片识别
- 收据自动录入
- 票据信息提取

**关联关系**:
- **依赖**: `AiService` (图像理解), `invoice_recognition_service.dart`
- **被依赖**: 交易录入中的图片上传功能
- **级联影响**: 自动化数据录入效率

##### InvoiceRecognitionService (`invoice_recognition_service.dart`)
**职责**: 发票专用识别服务

**核心功能**:
- 增值税发票识别
- 发票真伪验证
- 发票信息结构化

**关联关系**:
- **依赖**: `AiService`, `prompts/invoice_recognition_prompt.txt`
- **被依赖**: `ImageProcessingService`
- **使用场景**: 企业报销和财务管理

##### BankStatementRecognitionService (`bank_statement_recognition_service.dart`)
**职责**: 银行流水识别服务

**核心功能**:
- 银行对账单解析
- 交易记录批量导入
- 数据去重和合并

**关联关系**:
- **依赖**: `AiService`, `prompts/bank_statement_recognition_prompt.txt`
- **被依赖**: 数据导入功能
- **级联影响**: 批量数据录入效率

##### CategoryRecommendationService (`category_recommendation_service.dart`)
**职责**: 交易分类智能推荐服务

**核心功能**:
- 基于历史数据的分类建议
- 机器学习优化分类
- 用户习惯学习

**关联关系**:
- **依赖**: `AiService`, 历史交易数据
- **被依赖**: 交易录入时的分类建议
- **级联影响**: 交易分类的准确性和便捷性

##### AssetValuationService (`asset_valuation_service.dart`)
**职责**: 资产估值AI服务

**核心功能**:
- 房地产估值分析
- 投资组合建议
- 市场趋势预测

**关联关系**:
- **依赖**: `AiService`, `prompts/asset_valuation_prompt.txt`
- **被依赖**: 资产管理功能
- **级联影响**: 资产配置决策支持

#### 4. 配置和调优 (2个文件)

##### AiTuningConfigService (`ai_tuning_config_service.dart`)
**职责**: AI调参配置服务

**核心功能**:
- 运行时模型参数调整
- Prompt模板动态切换
- 性能监控和优化

**关联关系**:
- **依赖**: `AiNlpTuningConfig` 模型
- **被依赖**: 所有AI服务 (参数调优)
- **级联影响**: AI服务性能和准确性

##### PayrollRecognitionService (`payroll_recognition_service.dart`)
**职责**: 工资单识别服务

**核心功能**:
- 工资条OCR识别
- 薪资结构解析
- 税务信息提取

**关联关系**:
- **依赖**: `AiService`, `prompts/payroll_recognition_prompt.txt`
- **被依赖**: 工资设置功能
- **级联影响**: 工资数据录入自动化

#### 5. Prompt管理系统 (7个文件)

##### prompts/ 目录
**职责**: AI Prompt模板集中管理

**文件结构**:
```
prompts/
├── natural_language_prompt.txt      # 自然语言解析模板
├── invoice_recognition_prompt.txt   # 发票识别模板
├── bank_statement_recognition_prompt.txt  # 银行流水模板
├── category_recommendation_prompt.txt    # 分类推荐模板
├── asset_valuation_prompt.txt       # 资产估值模板
├── payroll_recognition_prompt.txt   # 工资单识别模板
├── transaction_analysis_prompt.txt  # 交易分析模板
└── prompt_loader.dart               # Prompt加载器
```

**PromptLoader (`prompt_loader.dart`)**
**职责**: Prompt模板加载和缓存管理

**核心功能**:
- 模板文件加载
- 变量替换处理
- 缓存优化

**关联关系**:
- **依赖**: `prompts/` 目录下的模板文件
- **被依赖**: 所有需要Prompt的AI服务
- **级联影响**: AI输出的稳定性和一致性

## AI服务调用流程

### 标准调用流程
```
用户输入 → 服务选择 → Prompt加载 → 参数配置 → AI调用 → 结果解析 → 数据返回
```

### 错误处理机制
- 服务不可用时的降级策略
- API限流和重试机制
- 结果验证和格式化

## 性能优化

### 1. 服务缓存
AI服务实例的智能缓存和复用。

### 2. 请求合并
相似请求的合并处理，减少API调用。

### 3. 异步处理
长时间AI操作的后台异步执行。

### 4. 结果缓存
AI结果的智能缓存，避免重复计算。

## 安全考虑

### 1. API密钥管理
- 安全的密钥存储和访问
- 密钥轮换机制
- 权限控制

### 2. 数据隐私
- 用户数据加密传输
- 本地数据不上传
- 隐私保护机制

### 3. 服务监控
- API调用监控
- 异常检测和告警
- 性能指标收集

## 测试策略

### 单元测试
- AI服务接口测试
- Prompt模板测试
- 配置管理测试

### 集成测试
- 端到端AI功能测试
- 第三方API集成测试
- 错误场景测试

### Mock 支持
- `mock_ai_service.dart` 基于 Mockito，用于 Insights 等模块的集成测试。
  - 为兼容 Mockito 在 sound null-safety 下的参数 matcher（本质上以 `null` 作为占位），`analyzeDailyCap / analyzeWeeklyPatterns / analyzeMonthlyHealth` 的入参允许为 nullable，并在实现内部做空值兜底。

### 性能测试
- AI响应时间测试
- 并发处理能力测试
- 内存使用监控

## 扩展开发

### 添加新AI服务提供商
```dart
class NewAiService extends AiService {
  @override
  Future<AiResponse> processText(String text, {AiConfig? config}) async {
    // 实现新的AI服务集成
  }
}
```

### 添加新的Prompt模板
1. 在`prompts/`目录下创建新的`.txt`文件
2. 在`PromptLoader`中添加对应的加载方法
3. 在相关AI服务中集成使用

## 相关文档

- [Core Services总文档](../README.md)
- [自然语言交易解析服务](natural_language_transaction_service.dart)
- [AI配置管理服务](ai_config_service.dart)



