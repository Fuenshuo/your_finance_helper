# AI-Native 收入记录系统 - 技术方案设计

## 🎯 核心理念

**从"配置工资"到"记录收入"的范式转换**

- ❌ **旧模式**: 用户配置复杂的工资结构 → 系统计算预测
- ✅ **新模式**: 用户记录实际收入 → AI理解模式 → 自动预测

## 📊 架构设计

### 1. 数据模型简化

#### 当前问题
- `SalaryIncome` 模型过于复杂（基本工资、津贴、扣除项等20+字段）
- 用户需要手动配置所有细节
- 与实际记账流程脱节

#### 新设计：统一到 Transaction 模型

```
Transaction {
  type: income | expense | transfer  // ⚠️ 必须明确区分转账
  category: salary | bonus | ... | food | transport | ...
  amount: 实际金额
  date: 实际日期
  description: 原始输入（用于AI学习）
  metadata: {
    source: "natural_language" | "image" | "voice"
    confidence: 0.0-1.0
    rawInput: "工资12350"
    aiExtracted: AiExtractedSchema  // ⚠️ 预定义结构，见下方
  }
}

// ⚠️ 预定义 metadata.aiExtracted 结构（避免后期混乱）
interface AiExtracted {
  grossAmount?: number;      // 税前工资
  socialInsurance?: number;  // 社保
  housingFund?: number;      // 公积金
  incomeTax?: number;        // 个税
  netAmount?: number;        // 实发（应等于 amount）
  employer?: string;         // 公司名称（从工资条提取）
  // ... 其他可选字段
}
```

**关键决策**：
- 不再维护复杂的 `SalaryIncome` 配置表
- 所有收入都通过 `Transaction` 记录
- **转账类型单独处理**：transfer 不计入预算统计，避免污染收支数据
- **metadata.aiExtracted 预定义结构**：便于前端展示和专业用户查看详情

### 2. AI 解析流程

#### 输入处理（伪代码）

```
function processIncomeInput(input) {
  // 输入类型判断
  if (input is Image) {
    text = multimodalOCR(input)  // 多模态提取文本
    return parseIncomeFromText(text, source="image")
  }
  else if (input is Voice) {
    text = speechToText(input)
    return parseIncomeFromText(text, source="voice")
  }
  else {
    return parseIncomeFromText(input, source="text")
  }
}

function parseIncomeFromText(text, source) {
  // 构建上下文
  context = {
    today: DateTime.now(),
    userHistory: getRecentIncomeTransactions(limit=20),
    userProfile: getUserIncomeProfile()  // 学习到的模式
  }
  
  // LLM解析
  result = llm.parse({
    prompt: buildIncomePrompt(text, context),
    temperature: 0.3,
    format: "json"
  })
  
  // ⚠️ 动态置信度阈值（冷启动策略）
  thresholds = getConfidenceThresholds(userProfile)
  
  // 置信度路由
  if (result.confidence >= thresholds.autoSave) {
    return {action: "auto_save", data: result}
  }
  else if (result.confidence >= thresholds.quickConfirm) {
    return {action: "quick_confirm", data: result}
  }
  else {
    return {action: "clarify", data: result}
  }

function getConfidenceThresholds(userProfile) {
  // 冷启动：前5笔记录使用更严格阈值
  if (userProfile.isColdStart()) {
    return {
      autoSave: 0.95,
      quickConfirm: 0.85
    }
  }
  else {
    return {
      autoSave: 0.90,
      quickConfirm: 0.70
    }
  }
}
}
```

#### LLM Prompt 设计（关键）⚠️ 需强化转账和模糊输入处理

```
系统角色：
你是一个个人财务助理，擅长从用户输入中提取交易信息（收入/支出/转账）。

⚠️ 关键：必须明确区分转账（transfer）和收支（income/expense）
- transfer: 银行卡间转账、账户间转移（不计入预算统计）
- income: 外部资金流入（工资、奖金、红包等）
- expense: 资金流出（消费、缴费等）

输出格式（严格JSON）：
{
  "amount": number,           // 金额（元，整数，必须）
  "type": string,             // "income" | "expense" | "transfer"（必须）
  "category": string,         // 分类（见下方规则）
  "date": "YYYY-MM-DD",       // 日期（优先使用输入中的，否则用今天）
  "confidence": 0.0-1.0,      // 置信度（必须，基于信息完整性）
  "sourceSnippet": string,     // 提取的原始片段
  "uncertainty": string        // 不确定性说明（可选，如"用户说'发钱了'但未提金额"）
}

类型判断规则：
- transfer: 包含"转账"、"转出"、"转入"且无明确收支方向
- income: 包含"工资"、"奖金"、"收入"、"到账"、"收到"等
- expense: 包含"消费"、"支出"、"买了"、"花了"等
- 模糊情况（如"转账5000"）→ 优先判断为 transfer，置信度降低

分类规则（type=income）：
- salary: 包含"工资"、"薪水"、"月薪"或金额≈用户平均月收入
- bonus: 包含"奖金"、"年终"、"十三薪"、"绩效"
- freelance: 包含"兼职"、"稿费"、"外包"
- gift: 包含"红包"、"礼金"、"礼物"
- otherIncome: 其他收入

分类规则（type=expense）：
- food: 餐饮相关
- transport: 交通相关
- shopping: 购物相关
- ...（见现有分类列表）

置信度评估：
- 信息完整（金额+类型+日期明确）→ 0.9+
- 信息部分缺失（如"发钱了"但无金额）→ 0.4-0.6
- 信息模糊（如"到账了"）→ 0.3-0.5

用户上下文：
- 今日日期: {{TODAY}}
- 用户平均月收入: {{AVG_MONTHLY_SALARY}}
- 常见收入类型: {{COMMON_TYPES}}
- 发薪日模式: {{SALARY_DAY_PATTERN}}

用户输入：「{{USER_INPUT}}」

⚠️ 如果输入模糊（如"到账了"、"发钱了"），请在uncertainty字段说明缺失信息。
```

### 3. 用户画像学习

#### 学习机制（伪代码）

```
class UserIncomeProfile {
  avgMonthlySalary: number
  bonusMonths: number[]      // 通常发奖金的月份
  commonIncomeTypes: string[]
  salaryDayPattern: number   // 通常几号发工资（±3天）
  
  function updateFromTransaction(transaction) {
    if (transaction.category == "salary") {
      this.avgMonthlySalary = calculateMovingAverage(
        this.avgMonthlySalary, 
        transaction.amount
      )
      this.salaryDayPattern = extractDayPattern(transaction.date)
    }
    else if (transaction.category == "bonus") {
      this.bonusMonths.add(transaction.date.month)
    }
  }
  
  function enhanceConfidence(parsedResult) {
    // 基于用户画像提升置信度
    if (parsedResult.category == "salary" 
        && isNearSalaryDay(parsedResult.date)
        && isNearAverageAmount(parsedResult.amount)) {
      parsedResult.confidence += 0.1
    }
    return parsedResult
  }
}
```

### 4. 交互流程设计

#### 高置信度（≥90%）→ 自动保存

```
用户输入 → AI解析 → 置信度0.95 → 自动保存
  ↓
显示Toast: "✅ 已记录：工资收入 ¥12,350（今天）"
  ↓
可选：显示预测提示 "下次发工资时，我会自动提醒你确认 👍"
```

#### 中置信度（70-89%）→ 快速确认

```
用户输入 → AI解析 → 置信度0.85 → 显示确认条
  ↓
底部弹出（3秒自动消失）：
"🤔 看起来像工资 ¥12,350？"
[✓ 是] [💰 是奖金] [✏️ 其他]
  ↓
用户点击 → 保存
```

#### 低置信度（<70%）→ 降级补全

```
用户输入 → AI解析 → 置信度0.6 → 显示极简选择
  ↓
"📝 请告诉我这是什么收入？"
[工资] [奖金] [兼职] [其他]
  ↓
用户选择 → 保存（金额和日期使用AI提取的）
```

## 🔄 与现有系统集成

### 1. 数据迁移策略

```
旧数据迁移：
1. 读取所有 SalaryIncome 记录
2. 如果有 salaryHistory，转换为 Transaction 记录
3. 如果有 bonuses，转换为 Transaction 记录
4. 保留原始数据作为备份（标记为 deprecated）
5. 新功能不再使用 SalaryIncome 表
```

### 2. 预算系统集成

```
收入预测：
- 不再基于 SalaryIncome 配置计算
- 改为基于 Transaction 历史数据 + AI学习模式预测
- 使用 UserIncomeProfile 中的模式进行预测

预算计算：
- 总收入 = 账户余额 + 信封可用余额（保持不变）
- 收入来源从 Transaction 中统计，而非 SalaryIncome
```

### 3. 删除的功能模块

```
需要删除/废弃：
- SalaryIncomeSetupScreen（工资设置页面）
- SalaryIncome 模型（保留表结构用于迁移，但不再使用）
- 所有工资配置相关的 Widgets
- 工资预览和计算相关的服务

保留但重构：
- PersonalIncomeTaxService（个税计算）
  → 改为从 Transaction 中提取信息后计算
- BudgetProvider
  → 改为从 Transaction 统计收入
```

## 📱 UI/UX 设计

### 主入口：统一记账入口（AI自动识别收支）

```
[顶部状态栏]
💰 总资产：¥XXX,XXX  |  📊 本月收入：¥XX,XXX

[统一输入框]
➕ 记一笔...
placeholder: "说'工资12000'或'奶茶28'、拍照或粘贴"

[操作按钮]
📷 [拍照] 🎤 [语音] 📋 [粘贴]

[快速入口]（可选）
[💰 记收入] [💸 记支出] [🔄 转账]
```

**关键设计**：
- **统一入口**：用户只需一个"记一笔"动作
- **AI自动识别**：输入后AI判断是收入/支出/转账
- **智能反馈**：根据识别类型展示不同的确认界面

### 反馈机制

#### 高置信度（≥90%）→ 自动保存
```
用户输入 → AI解析 → 置信度0.95 → 自动保存
  ↓
显示Toast: "✅ 已记录：工资收入 ¥12,350（今天）"
  ↓
可选：显示预测提示 "下次发工资时，我会自动提醒你确认 👍"
  ↓
[错误恢复]：点击Toast → 快速编辑页面
```

#### 中置信度（70-89%）→ 快速确认
```
用户输入 → AI解析 → 置信度0.85 → 显示确认条
  ↓
底部弹出（3秒自动消失）：
"🤔 看起来像工资 ¥12,350？"
[✓ 是] [💰 是奖金] [✏️ 其他]
  ↓
用户点击 → 保存
```

#### 低置信度（<70%）→ 降级补全
```
用户输入 → AI解析 → 置信度0.6 → 显示极简选择
  ↓
"📝 请告诉我这是什么收入？"
[工资] [奖金] [兼职] [其他]
  ↓
用户选择 → 保存（金额和日期使用AI提取的）
```

### 错误恢复机制（MVP必须包含）

#### 1. Toast点击快速编辑
```
用户点击Toast → 弹出极简编辑页
  ↓
显示：金额、类型、日期（可修改）
  ↓
[保存] [删除] [取消]
```

#### 2. 最近记录快速编辑
```
首页下滑或长按 → 显示最近3笔记录
  ↓
点击任意记录 → 快速编辑页
  ↓
仅显示关键字段（金额、类型、日期）
```

#### 3. "识别错了？"一键修正
```
在确认界面显示：
"识别错了？" [修正]
  ↓
点击 → 跳转到极简编辑页
```

**设计原则**：
- **可逆性 > 准确性**：用户对"可修正"的信任 > 对"准确性"的期待
- **极简编辑**：只显示关键字段，不展示复杂配置
- **快速访问**：最近记录始终可快速编辑

## 🧠 AI 服务层设计

### 服务层设计（统一记账入口）

#### 方案：扩展 NaturalLanguageTransactionService

**不新建 IncomeParsingService，而是扩展现有服务**

```
NaturalLanguageTransactionService {
  // 扩展现有方法，支持收支自动识别
  parseTransaction({
    input: string | File | AudioFile,
    userHistory?: Transaction[],
    userProfile?: UserIncomeProfile
  }): Promise<{
    type: "income" | "expense" | "transfer",
    amount: number,
    category: string,
    date: DateTime,
    confidence: number,
    action: "auto_save" | "quick_confirm" | "clarify"
  }>
  
  // 新增：专门处理收入场景的增强方法
  parseIncomeEnhanced({
    input: string | File | AudioFile,
    userHistory?: Transaction[],
    userProfile?: UserIncomeProfile
  }): Promise<IncomeParseResult>
}
```

**优势**：
- 复用现有架构和Prompt设计
- 统一的数据流和错误处理
- 避免服务碎片化

### 复用现有服务

```
- AiService（已有）：LLM调用
- ImageProcessingService（已有）：图片处理
- NaturalLanguageTransactionService（已有）：可参考其prompt设计
- InvoiceRecognitionService（已有）：OCR逻辑可复用
```

## 📊 数据流图

```
用户输入（文本/语音/图片）
    ↓
IncomeParsingService
    ↓
[多模态处理] → OCR/STT → 文本
    ↓
[LLM解析] → 结构化数据 + 置信度
    ↓
[用户画像增强] → 提升置信度
    ↓
[置信度路由]
    ├─ ≥0.9 → 自动保存 → Transaction
    ├─ 0.7-0.9 → 快速确认 → 用户选择 → Transaction
    └─ <0.7 → 降级补全 → 用户选择 → Transaction
    ↓
[更新用户画像] → UserIncomeProfile
    ↓
[更新预算预测] → BudgetProvider
```

## ✅ 关键决策（已确认）

### 1. 是否保留 SalaryIncome 表？

**✅ 决策**：保留表结构，但标记为 deprecated
- 原因：已有数据需要迁移
- 方案：新功能不再写入，只读用于迁移

### 2. 如何处理复杂的工资条信息？

**✅ 决策**：AI提取关键信息，其余存储在 metadata
- **必须**：金额、类型、日期
- **可选**：税前金额、扣除项等（存储在 `metadata.aiExtracted`）
- **不强制**用户填写所有字段
- **专业用户**：点击记录详情页 → 查看/编辑 metadata（渐进式披露）

### 3. 收入预测如何实现？

**✅ 决策**：基于 Transaction 历史 + 用户画像，按月统计即可
- 不再基于 SalaryIncome 配置
- 使用时间序列分析 + AI模式识别
- 预测逻辑独立成服务：IncomePredictionService
- **初期不必实时预测**，按月统计即可

### 4. 与现有记账流程的关系？

**✅ 决策：统一记账入口，AI自动识别收支类型**

- **单一入口**："记一笔"（而非独立的"记收入"入口）
- **AI自动识别**：用户输入 → AI判断是收入还是支出
  - "工资 12000" → income, salary
  - "奶茶 28" → expense, food
- **收入专属反馈**：识别为收入时，自动展开收入专属提示（如周期性预测）
- **优势**：用户心智统一、AI能力复用、避免功能碎片化

### 5. 是否保留工资配置功能？

**✅ 决策：完全删除，高级能力移至记录详情页**

- **普通用户**：只看到"工资 ¥12,350"
- **专业用户**：点击该记录 → 查看/编辑 metadata（税前、扣除项等）
- **设计原则**：渐进式披露优于平行路径

### 6. 错误恢复机制？

**✅ 决策：MVP必须包含**

- **Toast点击快速编辑**：点击Toast → 极简编辑页
- **最近记录快速编辑**：首页下滑/长按 → 最近3笔记录 → 快速编辑
- **"识别错了？"一键修正**：确认界面显示修正入口
- **设计原则**：可逆性 > 准确性

## 🚀 实施步骤

### Phase 1: 核心功能（MVP）⭐ 优先级最高

**目标**：统一记账入口 + 文本输入 + 自动识别 + 错误恢复

1. **扩展 NaturalLanguageTransactionService**
   - 增强收支类型自动识别
   - 实现收入专属解析逻辑
   - 置信度路由机制

2. **统一记账入口UI**
   - 单一"记一笔"输入框
   - AI自动识别收支类型
   - 高置信度自动保存（≥90%）

3. **错误恢复机制**（MVP必须）
   - Toast点击快速编辑
   - 最近3笔记录快速编辑入口
   - 极简编辑页面（仅关键字段）

4. **数据保存**
   - 统一保存到 Transaction 表
   - metadata 存储AI提取详情

**验收标准**：
- ✅ 用户输入"工资12000" → 自动识别为收入并保存
- ✅ 用户输入"奶茶28" → 自动识别为支出并保存
- ✅ 识别错误可快速修正

### Phase 2: 多模态支持（优先级调整：文本粘贴 ≈ 工资条图片 > 通用图片 > 语音）

**2.1 文本粘贴**（最高优先级，与工资条并行）
- 支持银行短信、微信、邮件粘贴
- 开发成本最低，ROI最高

**2.2 工资条图片OCR**（最高优先级，与文本并行）
- 工资条场景是刚需（用户天然有图）
- 格式相对固定，比银行通知简单
- 先支持主流模板，逐步扩展

**2.3 通用图片OCR**（次优先级）
- 银行通知、微信截图等
- 格式多样，延后开发

**2.4 语音输入**（最低优先级）
- 可降级为"语音转文本后走文本流程"
- 初期不独立实现

**2.5 中置信度快速确认**
- 70-89%置信度的快速确认条
- 3秒自动消失

### Phase 3: 智能学习

1. **UserIncomeProfile 实现**
   - 从Transaction历史学习模式
   - 更新平均月收入、发薪日模式等

2. **置信度增强逻辑**
   - 基于用户画像提升置信度
   - 模式匹配（发薪日、金额范围等）

3. **收入预测服务**（按月统计）
   - IncomePredictionService
   - 基于历史数据 + 用户画像预测
   - 初期按月统计即可，不必实时

### Phase 4: 迁移和清理

1. **数据迁移脚本**
   - SalaryIncome → Transaction 转换
   - 保留原始数据备份

2. **删除旧功能模块**
   - SalaryIncomeSetupScreen
   - 工资配置相关Widgets
   - 工资预览和计算服务

3. **更新预算系统集成**
   - BudgetProvider 改为从Transaction统计
   - 收入预测改为基于Transaction历史

## ⚠️ 风险点与应对策略

| 风险 | 影响 | 应对策略 |
|------|------|----------|
| **LLM解析延迟 >2s** | 用户体验差 | 前端loading动画 + 本地缓存最近解析结果 |
| **用户输入模糊**（如"一万二"） | 金额识别错误 | Prompt强制要求LLM转为数字，反馈中显示"¥12,000"让用户确认 |
| **用户输入极模糊**（如"到账了"、"发钱了"） | 无法解析 | 低置信度流程中引导用户补充关键信息，提供示例按钮 |
| **转账类型混淆**（如"转账5000"） | 误判为收支 | Prompt明确区分transfer，识别为transfer时提示用户确认方向 |
| **同一收入被重复记录** | 数据重复 | ⚠️ 模糊去重 + 用户决策：检测到类似记录时提示"要再记一笔吗？[✓ 是] [↩️ 合并] [❌ 取消]" |
| **AI识别错误率高** | 用户信任度下降 | MVP包含完整错误恢复机制，让用户感受到"可修正" |
| **冷启动置信度虚高** | 初期错误率高 | 动态阈值：前5笔记录使用更严格阈值（0.95/0.85） |

## 📋 下一步行动

### 立即可以开始的工作

1. **细化服务接口定义**
   - NaturalLanguageTransactionService 扩展接口
   - UserIncomeProfile 数据结构
   - IncomePredictionService 接口设计

2. **设计统一记账入口交互原型**
   - 输入框设计
   - 置信度路由的UI反馈
   - 错误恢复的交互流程

3. **编写LLM Prompt模板**
   - 收支自动识别的Prompt
   - 收入专属解析的Prompt
   - A/B测试版本准备

4. **数据迁移方案设计**
   - SalaryIncome → Transaction 转换逻辑
   - 迁移脚本伪代码

---

**当前状态**：✅ 技术方案已确认，关键决策已明确

**下一步**：请选择希望优先细化的部分：
- [ ] 服务接口定义（NaturalLanguageTransactionService扩展）
- [ ] 统一记账入口交互原型设计
- [ ] LLM Prompt模板编写
- [ ] 数据迁移方案设计

