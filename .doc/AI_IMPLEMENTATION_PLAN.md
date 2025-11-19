# AI功能技术落地策略

## 概述

本文档详细拆解AI功能的技术实现方案，包括任务分解、技术架构、实现步骤和验收标准。

## 第一阶段（MVP）任务拆解

### 任务1：自然语言记账（LLM）

#### 1.1 核心服务层
- [ ] 创建 `NaturalLanguageTransactionService`
  - 解析自然语言输入
  - 提取交易信息（描述、金额、分类、账户等）
  - 结合用户历史数据智能推荐
  - 返回结构化的交易数据

#### 1.2 数据模型
- [ ] 创建 `ParsedTransaction` 模型
  - 包含解析后的交易字段
  - 包含置信度信息
  - 支持用户确认和修改

#### 1.3 UI层集成
- [ ] 在 `AddTransactionScreen` 添加自然语言输入入口
  - 顶部添加输入框
  - 实时显示解析结果预览
  - 一键填充表单
  - 支持修改确认

#### 1.4 智能推荐逻辑
- [ ] 账户推荐服务
  - 基于历史交易记录
  - 基于分类偏好
- [ ] 分类推荐服务
  - 基于描述语义理解
  - 基于历史分类习惯
- [ ] 预算关联推荐
  - 自动匹配信封预算

---

### 任务2：发票/收据识别（VL）

#### 2.1 图片处理服务
- [ ] 创建 `ImageProcessingService`
  - 图片上传/转换
  - 图片压缩和优化
  - Base64编码（用于Vision API）

#### 2.2 发票识别服务
- [ ] 创建 `InvoiceRecognitionService`
  - 调用Vision模型识别发票
  - 解析识别结果（商家、金额、日期、商品）
  - 返回结构化的交易数据

#### 2.3 UI层集成
- [ ] 在 `AddTransactionScreen` 添加拍照入口
  - 相机图标按钮
  - 图片选择器集成
  - 识别进度显示
  - 识别结果展示和确认

#### 2.4 图片存储
- [ ] 图片本地存储
  - 保存到应用目录
  - 关联到交易记录
  - 支持图片查看和删除

---

## 技术架构设计

### 服务层架构

```
lib/core/services/ai/
├── ai_service.dart                    # 基础AI服务接口（已存在）
├── natural_language_transaction_service.dart  # 自然语言记账服务（新增）
├── invoice_recognition_service.dart   # 发票识别服务（新增）
└── image_processing_service.dart     # 图片处理服务（新增）
```

### 数据模型

```
lib/core/models/
├── parsed_transaction.dart            # 解析后的交易数据（新增）
└── transaction.dart                   # 交易模型（已存在，需支持imagePath）
```

### UI组件

```
lib/features/transaction_flow/
├── screens/
│   └── add_transaction_screen.dart    # 添加交易页面（需集成AI功能）
└── widgets/
    ├── natural_language_input_widget.dart  # 自然语言输入组件（新增）
    └── invoice_recognition_widget.dart     # 发票识别组件（新增）
```

---

## 实现步骤

### Step 1: 创建核心服务（自然语言记账）

1. **创建 `ParsedTransaction` 模型**
   - 定义解析结果的数据结构
   - 包含所有交易字段
   - 包含置信度和建议信息

2. **创建 `NaturalLanguageTransactionService`**
   - 实现自然语言解析逻辑
   - 调用LLM模型
   - 结合用户历史数据推荐

3. **创建账户和分类推荐服务**
   - 基于历史数据的推荐算法
   - 缓存推荐结果

### Step 2: 创建图片处理服务（发票识别）

1. **创建 `ImageProcessingService`**
   - 图片选择和上传
   - 图片格式转换
   - Base64编码

2. **创建 `InvoiceRecognitionService`**
   - 调用Vision模型
   - 解析识别结果
   - 错误处理和重试

### Step 3: UI集成

1. **自然语言输入组件**
   - 输入框UI
   - 解析结果预览
   - 一键填充功能

2. **发票识别组件**
   - 拍照按钮
   - 图片预览
   - 识别结果展示

3. **集成到 `AddTransactionScreen`**
   - 添加AI功能入口
   - 保持原有功能不变
   - 优雅降级处理

---

## 技术细节

### 自然语言解析Prompt设计

```dart
final systemPrompt = '''
你是一个财务记账助手，从用户描述中提取交易信息。
请返回JSON格式：
{
  "description": "交易描述",
  "amount": 金额（数字）,
  "type": "income|expense|transfer",
  "category": "分类名称",
  "subCategory": "子分类（可选）",
  "accountName": "账户名称（可选）",
  "date": "日期（可选，格式：YYYY-MM-DD）",
  "confidence": 置信度（0-1）
}
''';
```

### 发票识别Prompt设计

```dart
final visionPrompt = '''
识别这张发票/收据，提取以下信息：
1. 商家名称
2. 总金额
3. 交易日期
4. 商品明细（可选）

返回JSON格式：
{
  "merchant": "商家名称",
  "amount": 金额,
  "date": "日期（YYYY-MM-DD）",
  "items": ["商品1", "商品2"]
}
''';
```

### 错误处理策略

1. **AI服务不可用**
   - 显示友好提示
   - 提供手动输入选项
   - 不阻塞用户操作

2. **解析失败**
   - 显示解析结果（即使不完整）
   - 允许用户手动修改
   - 提供重试选项

3. **网络错误**
   - 自动重试（最多3次）
   - 显示错误信息
   - 保存草稿供后续处理

---

## 验收标准

### 自然语言记账

- [ ] 能够正确解析常见交易描述
- [ ] 准确率 > 85%
- [ ] 支持修改和确认
- [ ] 响应时间 < 3秒
- [ ] 优雅降级处理

### 发票识别

- [ ] 能够识别常见发票格式
- [ ] 识别准确率 > 80%
- [ ] 支持多种发票类型
- [ ] 响应时间 < 5秒
- [ ] 图片保存和关联正确

---

## 后续优化

### 性能优化
- 缓存解析结果
- 批量处理优化
- 异步处理优化

### 用户体验优化
- 语音输入支持
- 历史记录学习
- 个性化推荐

### 功能扩展
- 批量识别
- 离线模式
- 多语言支持

---

**文档版本**：v1.0  
**创建时间**：2025-01-13  
**维护者**：开发团队

