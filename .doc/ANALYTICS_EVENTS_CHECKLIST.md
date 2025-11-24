# 统一记账入口 - 埋点事件清单

## 🎯 埋点目标

**数据驱动优化**：通过埋点数据验证设计假设，优化用户体验

### 核心指标

1. **转化率**：各流程的转化率（自动保存 vs 快速确认 vs 降级补全）
2. **修正频率**：用户修正操作的触发频率和路径
3. **A/B测试**：快速入口对用户行为的影响
4. **错误率**：AI识别错误率及用户反馈

---

## 📊 事件分类

### 1. 入口事件（Entry Events）

#### 1.1 统一输入框展示
```json
{
  "event": "transaction_entry_shown",
  "properties": {
    "entry_type": "unified",  // "unified" | "quick_income" | "quick_expense" | "quick_transfer"
    "user_id": "xxx",
    "timestamp": "2025-01-20T10:00:00Z"
  }
}
```

#### 1.2 快速入口点击
```json
{
  "event": "quick_entry_clicked",
  "properties": {
    "entry_type": "income",  // "income" | "expense" | "transfer"
    "user_id": "xxx",
    "timestamp": "2025-01-20T10:00:00Z"
  }
}
```

---

### 2. 输入事件（Input Events）

#### 2.1 用户输入
```json
{
  "event": "transaction_input_submitted",
  "properties": {
    "input_type": "text",  // "text" | "image" | "voice" | "paste"
    "input_length": 10,
    "has_amount": true,  // 输入中是否包含金额
    "has_type_keyword": true,  // 输入中是否包含类型关键词
    "user_id": "xxx",
    "timestamp": "2025-01-20T10:00:00Z"
  }
}
```

#### 2.2 多模态入口点击
```json
{
  "event": "multimodal_entry_clicked",
  "properties": {
    "modality": "camera",  // "camera" | "voice" | "paste"
    "user_id": "xxx",
    "timestamp": "2025-01-20T10:00:00Z"
  }
}
```

---

### 3. AI解析事件（AI Parsing Events）

#### 3.1 AI解析开始
```json
{
  "event": "ai_parsing_started",
  "properties": {
    "input_type": "text",
    "input_length": 10,
    "user_id": "xxx",
    "timestamp": "2025-01-20T10:00:00Z"
  }
}
```

#### 3.2 AI解析完成
```json
{
  "event": "ai_parsing_completed",
  "properties": {
    "parsing_time_ms": 1200,  // 解析耗时（毫秒）
    "result_type": "income",  // "income" | "expense" | "transfer" | "unclear"
    "result_category": "salary",
    "result_amount": 12000,
    "confidence": 0.95,
    "has_uncertainty": false,  // 是否有不确定性说明
    "user_id": "xxx",
    "timestamp": "2025-01-20T10:00:00Z"
  }
}
```

#### 3.3 AI解析失败
```json
{
  "event": "ai_parsing_failed",
  "properties": {
    "error_type": "timeout",  // "timeout" | "parse_error" | "api_error"
    "error_message": "API timeout",
    "parsing_time_ms": 5000,
    "user_id": "xxx",
    "timestamp": "2025-01-20T10:00:00Z"
  }
}
```

---

### 4. 路由事件（Routing Events）

#### 4.1 进入自动保存流程
```json
{
  "event": "auto_save_flow_entered",
  "properties": {
    "confidence": 0.95,
    "result_type": "income",
    "result_category": "salary",
    "result_amount": 12000,
    "user_id": "xxx",
    "timestamp": "2025-01-20T10:00:00Z"
  }
}
```

#### 4.2 进入快速确认流程
```json
{
  "event": "quick_confirm_flow_entered",
  "properties": {
    "confidence": 0.85,
    "result_type": "income",
    "result_category": "bonus",
    "result_amount": 80000,
    "user_id": "xxx",
    "timestamp": "2025-01-20T10:00:00Z"
  }
}
```

#### 4.3 进入降级补全流程
```json
{
  "event": "clarify_flow_entered",
  "properties": {
    "confidence": 0.45,
    "has_amount": false,  // 是否提取到金额
    "has_type": true,  // 是否提取到类型
    "uncertainty": "用户说'发钱了'但未提金额",
    "user_id": "xxx",
    "timestamp": "2025-01-20T10:00:00Z"
  }
}
```

#### 4.4 进入转账确认流程
```json
{
  "event": "transfer_confirm_flow_entered",
  "properties": {
    "confidence": 0.75,
    "result_amount": 5000,
    "user_id": "xxx",
    "timestamp": "2025-01-20T10:00:00Z"
  }
}
```

---

### 5. 用户操作事件（User Action Events）

#### 5.1 自动保存确认
```json
{
  "event": "auto_save_confirmed",
  "properties": {
    "result_type": "income",
    "result_category": "salary",
    "result_amount": 12000,
    "user_id": "xxx",
    "timestamp": "2025-01-20T10:00:00Z"
  }
}
```

#### 5.2 快速确认选择
```json
{
  "event": "quick_confirm_selected",
  "properties": {
    "selected_option": "yes",  // "yes" | "alternative_category" | "other"
    "original_category": "bonus",
    "selected_category": "bonus",  // 用户选择的分类
    "result_amount": 80000,
    "user_id": "xxx",
    "timestamp": "2025-01-20T10:00:00Z"
  }
}
```

#### 5.3 快速确认关闭
```json
{
  "event": "quick_confirm_dismissed",
  "properties": {
    "dismiss_method": "auto",  // "auto" | "manual" | "timeout"
    "original_category": "bonus",
    "result_amount": 80000,
    "user_id": "xxx",
    "timestamp": "2025-01-20T10:00:00Z"
  }
}
```

#### 5.4 降级补全完成
```json
{
  "event": "clarify_completed",
  "properties": {
    "completed_fields": ["amount", "category", "date"],  // 用户补充的字段
    "used_example": true,  // 是否使用了示例按钮
    "example_index": 0,  // 使用的示例索引
    "final_type": "income",
    "final_category": "salary",
    "final_amount": 12000,
    "user_id": "xxx",
    "timestamp": "2025-01-20T10:00:00Z"
  }
}
```

#### 5.5 转账方向选择
```json
{
  "event": "transfer_direction_selected",
  "properties": {
    "direction": "received",  // "sent" | "received" | "internal"
    "result_amount": 5000,
    "user_id": "xxx",
    "timestamp": "2025-01-20T10:00:00Z"
  }
}
```

---

### 6. 错误恢复事件（Error Recovery Events）

#### 6.1 Toast点击修正
```json
{
  "event": "toast_correction_clicked",
  "properties": {
    "original_type": "income",
    "original_category": "salary",
    "original_amount": 12000,
    "user_id": "xxx",
    "timestamp": "2025-01-20T10:00:00Z"
  }
}
```

#### 6.2 快速编辑完成
```json
{
  "event": "quick_edit_completed",
  "properties": {
    "edit_type": "toast",  // "toast" | "recent_record" | "long_press"
    "fields_changed": ["amount", "category"],  // 修改的字段
    "original_amount": 12000,
    "final_amount": 15000,
    "original_category": "salary",
    "final_category": "bonus",
    "user_id": "xxx",
    "timestamp": "2025-01-20T10:00:00Z"
  }
}
```

#### 6.3 快速编辑删除
```json
{
  "event": "quick_edit_deleted",
  "properties": {
    "edit_type": "toast",
    "original_type": "income",
    "original_category": "salary",
    "original_amount": 12000,
    "user_id": "xxx",
    "timestamp": "2025-01-20T10:00:00Z"
  }
}
```

#### 6.4 最近记录查看
```json
{
  "event": "recent_records_viewed",
  "properties": {
    "trigger_method": "long_press",  // "long_press" | "swipe_down" | "fixed_display"
    "records_count": 3,
    "user_id": "xxx",
    "timestamp": "2025-01-20T10:00:00Z"
  }
}
```

#### 6.5 "识别错了？"点击
```json
{
  "event": "recognition_error_clicked",
  "properties": {
    "flow_type": "quick_confirm",  // "quick_confirm" | "clarify"
    "original_type": "income",
    "original_category": "salary",
    "original_amount": 12000,
    "user_id": "xxx",
    "timestamp": "2025-01-20T10:00:00Z"
  }
}
```

---

### 7. 去重事件（Deduplication Events）

#### 7.1 去重检测触发
```json
{
  "event": "duplicate_detected",
  "properties": {
    "similar_record_id": "xxx",
    "similar_record_amount": 12350,
    "similar_record_date": "2025-01-20",
    "similar_record_category": "salary",
    "time_difference_hours": 1,
    "amount_difference": 350,
    "user_id": "xxx",
    "timestamp": "2025-01-20T10:00:00Z"
  }
}
```

#### 7.2 去重选择
```json
{
  "event": "duplicate_action_selected",
  "properties": {
    "action": "record_again",  // "record_again" | "merge" | "cancel"
    "similar_record_id": "xxx",
    "user_id": "xxx",
    "timestamp": "2025-01-20T10:00:00Z"
  }
}
```

---

### 8. 保存事件（Save Events）

#### 8.1 交易保存成功
```json
{
  "event": "transaction_saved",
  "properties": {
    "transaction_id": "xxx",
    "transaction_type": "income",
    "transaction_category": "salary",
    "transaction_amount": 12000,
    "save_flow": "auto_save",  // "auto_save" | "quick_confirm" | "clarify" | "transfer_confirm"
    "confidence": 0.95,
    "parsing_time_ms": 1200,
    "total_time_ms": 2000,  // 从输入到保存的总耗时
    "user_id": "xxx",
    "timestamp": "2025-01-20T10:00:00Z"
  }
}
```

#### 8.2 交易保存失败
```json
{
  "event": "transaction_save_failed",
  "properties": {
    "error_type": "validation_error",  // "validation_error" | "network_error" | "database_error"
    "error_message": "Amount is required",
    "save_flow": "clarify",
    "user_id": "xxx",
    "timestamp": "2025-01-20T10:00:00Z"
  }
}
```

---

### 9. A/B测试事件（A/B Test Events）

#### 9.1 A/B测试分组
```json
{
  "event": "ab_test_assigned",
  "properties": {
    "test_name": "quick_entry_visibility",
    "variant": "A",  // "A" | "B"
    "variant_description": "with_quick_entry",  // "with_quick_entry" | "without_quick_entry"
    "user_id": "xxx",
    "timestamp": "2025-01-20T10:00:00Z"
  }
}
```

---

## 📈 关键指标计算

### 1. 转化率指标

```sql
-- 自动保存转化率
SELECT 
  COUNT(DISTINCT CASE WHEN save_flow = 'auto_save' THEN user_id END) * 100.0 / 
  COUNT(DISTINCT user_id) as auto_save_rate
FROM transaction_saved
WHERE date >= '2025-01-01';

-- 快速确认转化率
SELECT 
  COUNT(DISTINCT CASE WHEN save_flow = 'quick_confirm' THEN user_id END) * 100.0 / 
  COUNT(DISTINCT user_id) as quick_confirm_rate
FROM transaction_saved
WHERE date >= '2025-01-01';

-- 降级补全转化率
SELECT 
  COUNT(DISTINCT CASE WHEN save_flow = 'clarify' THEN user_id END) * 100.0 / 
  COUNT(DISTINCT user_id) as clarify_rate
FROM transaction_saved
WHERE date >= '2025-01-01';
```

### 2. 修正频率指标

```sql
-- 修正操作触发率
SELECT 
  COUNT(DISTINCT user_id) * 100.0 / 
  (SELECT COUNT(DISTINCT user_id) FROM transaction_saved) as correction_rate
FROM quick_edit_completed
WHERE date >= '2025-01-01';

-- 修正路径分布
SELECT 
  edit_type,
  COUNT(*) as count,
  COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() as percentage
FROM quick_edit_completed
WHERE date >= '2025-01-01'
GROUP BY edit_type;
```

### 3. A/B测试指标

```sql
-- 快速入口使用率（版本A）
SELECT 
  COUNT(DISTINCT user_id) * 100.0 / 
  (SELECT COUNT(DISTINCT user_id) FROM ab_test_assigned WHERE variant = 'A') as quick_entry_usage_rate
FROM quick_entry_clicked
WHERE date >= '2025-01-01';

-- 留存率对比
SELECT 
  variant,
  COUNT(DISTINCT user_id) as retained_users,
  COUNT(DISTINCT user_id) * 100.0 / 
  (SELECT COUNT(DISTINCT user_id) FROM ab_test_assigned WHERE variant = variant) as retention_rate
FROM transaction_saved ts
JOIN ab_test_assigned ab ON ts.user_id = ab.user_id
WHERE ts.date >= '2025-01-01' AND ts.date <= '2025-01-07'
GROUP BY variant;
```

### 4. 错误率指标

```sql
-- AI识别错误率（通过修正操作推断）
SELECT 
  COUNT(DISTINCT user_id) * 100.0 / 
  (SELECT COUNT(DISTINCT user_id) FROM transaction_saved) as error_rate
FROM quick_edit_completed
WHERE fields_changed IS NOT NULL
AND date >= '2025-01-01';

-- 置信度分布
SELECT 
  CASE 
    WHEN confidence >= 0.9 THEN 'high'
    WHEN confidence >= 0.7 THEN 'medium'
    ELSE 'low'
  END as confidence_level,
  COUNT(*) as count,
  AVG(confidence) as avg_confidence
FROM ai_parsing_completed
WHERE date >= '2025-01-01'
GROUP BY confidence_level;
```

---

## 🎯 埋点实施检查清单

### 开发阶段

- [ ] 埋点SDK集成（如Firebase Analytics、Mixpanel等）
- [ ] 事件定义文档同步给前端/后端
- [ ] 测试环境埋点验证
- [ ] 生产环境埋点开关（可控制开启/关闭）

### 上线前

- [ ] 所有关键事件已埋点
- [ ] 事件属性完整且正确
- [ ] 数据上报延迟测试（<100ms）
- [ ] 隐私合规检查（不收集敏感信息）

### 上线后

- [ ] 数据看板搭建
- [ ] 关键指标监控告警
- [ ] 异常数据排查机制
- [ ] 定期数据报告（周报/月报）

---

## 📊 数据看板建议

### 核心看板指标

1. **整体转化漏斗**
   - 输入 → AI解析 → 路由 → 保存
   - 各环节转化率

2. **流程分布**
   - 自动保存 vs 快速确认 vs 降级补全占比
   - 各流程的平均耗时

3. **修正操作分析**
   - 修正触发率
   - 修正路径分布
   - 修正字段分布（金额/类型/日期）

4. **A/B测试结果**
   - 快速入口使用率
   - 留存率对比
   - 用户满意度对比

5. **错误率监控**
   - AI识别错误率趋势
   - 置信度分布
   - 常见错误模式

---

**文档版本**：v1.0  
**最后更新**：2025-01-20  
**下一步**：与数据团队对齐，确定埋点SDK和看板工具

