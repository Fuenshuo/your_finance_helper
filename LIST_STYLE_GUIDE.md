# 列表样式命名指南

本文档定义了应用中所有列表项的样式名称，**按样式特征命名**，方便快速引用和应用。

## 📋 样式列表

### 1. **圆角图标分隔列表样式** (`RoundedIconDividerListStyle`)
**命名：`圆角图标分隔列表样式` 或 `RoundedIconDividerListStyle`**

**样式特征：**
- 使用 `ListTile`，`contentPadding: EdgeInsets.zero`
- 左侧：40x40 圆角图标容器，分类图标，分类颜色背景
- 中间：`title` 为描述，`subtitle` 为 "分类 • 账户名称"
- 右侧：`trailing` 为金额（使用 `amountStyle`）
- 分隔：使用 `Divider(height: 1, color: Colors.grey[300])`

**使用位置：**
- `period_difference_analysis_screen.dart` - `_buildTransactionItem()` - 清账差额分析中的交易列表
- `transaction_flow_home_screen.dart` - `_buildRealTransactionItem()` - 收支流水页面的"最近交易"
- `period_summary_screen.dart` - `_buildTransactionItem()` - 清账总结页面的交易列表

**代码示例：**
```dart
ListTile(
  contentPadding: EdgeInsets.zero,
  leading: Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: categoryColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(categoryIcon, color: categoryColor, size: 20),
  ),
  title: Text(description, style: context.responsiveBodyLarge),
  subtitle: Text('$categoryName • $accountName', 
    style: context.responsiveBodySmall.copyWith(color: Colors.grey)),
  trailing: Text(amount, style: context.amountStyle(isPositive: isIncome)),
)
```

---

### 2. **圆形图标阴影卡片样式** (`CircleIconShadowCardStyle`)
**命名：`圆形图标阴影卡片样式` 或 `CircleIconShadowCardStyle`**

**样式特征：**
- 使用 `Container` + `Row`，白色背景 + 阴影
- 左侧：圆形图标容器（`BoxShape.circle`），收入/支出图标
- 中间：交易描述 + 账户/分类信息（两行）
- 右侧：金额 + 时间（两列）
- 支持批量选择复选框
- 支持滑动删除动效
- 使用 `iosSwipeableListItem` 包装

**使用位置：**
- `transaction_records_screen.dart` - `_buildTransactionItem()` - 交易记录页面的主列表

**代码示例：**
```dart
Container(
  margin: EdgeInsets.only(bottom: context.spacing8),
  padding: EdgeInsets.all(context.responsiveSpacing12),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(context.responsiveSpacing8),
    boxShadow: [BoxShadow(...)],
  ),
  child: Row(
    children: [
      // 圆形图标
      Container(
        padding: EdgeInsets.all(context.responsiveSpacing8),
        decoration: BoxDecoration(
          color: (isIncome ? successColor : errorColor).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(isIncome ? Icons.trending_up : Icons.trending_down),
      ),
      // 交易信息
      Expanded(child: Column(...)),
      // 金额和时间
      Column(...),
    ],
  ),
)
```

---

### 3. **简单图标卡片样式** (`SimpleIconCardStyle`)
**命名：`简单图标卡片样式` 或 `SimpleIconCardStyle`**

**样式特征：**
- 使用 `AppCard` 包裹
- 左侧：绿色 check 图标（`Icons.check_circle`）
- 中间：交易描述 + 日期（两行）
- 右侧：金额（绿色粗体）
- 支持滑动删除动效

**使用位置：**
- `repayment_history_screen.dart` - `_buildTransactionItem()` - 还款历史页面的交易列表

**代码示例：**
```dart
AppCard(
  child: Row(
    children: [
      Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description, style: TextStyle(fontWeight: FontWeight.w500)),
            Text(date, style: TextStyle(color: secondaryText, fontSize: 12)),
          ],
        ),
      ),
      Text('¥$amount', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
    ],
  ),
)
```

---

### 4. **状态操作分隔列表样式** (`StatusActionDividerListStyle`)
**命名：`状态操作分隔列表样式` 或 `StatusActionDividerListStyle`**

**样式特征：**
- 使用 `ListTile`，`contentPadding: EdgeInsets.zero`
- `title`：会话名称
- `subtitle`：周期描述 • 状态名称
- `trailing`：状态图标 + 删除按钮（未完成时）+ 右箭头
- 分隔：使用 `Divider(height: 1, color: Colors.grey[300])`

**使用位置：**
- `clearance_home_screen.dart` - `ListView.separated` 的 `itemBuilder` - 清账主页面的会话列表

**代码示例：**
```dart
ListTile(
  contentPadding: EdgeInsets.zero,
  title: Text(sessionName, style: context.responsiveBodyLarge),
  subtitle: Text('$periodDescription • $statusName', 
    style: context.responsiveBodySmall.copyWith(color: Colors.grey)),
  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (!isCompleted) IconButton(icon: Icon(Icons.delete_outline), ...),
      Icon(isCompleted ? Icons.check_circle : Icons.pending),
      Icon(Icons.chevron_right, color: Colors.grey),
    ],
  ),
)
```

---

### 5. **圆角图标删除列表样式** (`RoundedIconDeleteListStyle`)
**命名：`圆角图标删除列表样式` 或 `RoundedIconDeleteListStyle`**

**样式特征：**
- 使用 `ListTile`，`contentPadding: EdgeInsets.zero`
- 左侧：40x40 圆角图标容器，分类图标，分类颜色背景
- `title`：交易描述
- `subtitle`：分类名称 • 日期时间
- `trailing`：金额 + 删除按钮
- 支持滑动删除动效

**使用位置：**
- `account_detail_screen.dart` - `_buildTransactionItem()` - 账户详情页面的交易列表

**代码示例：**
```dart
ListTile(
  contentPadding: EdgeInsets.zero,
  leading: Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: categoryColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(categoryIcon, color: categoryColor, size: 20),
  ),
  title: Text(description, style: context.responsiveBodyLarge),
  subtitle: Text('$categoryName • $dateTime', 
    style: context.responsiveBodySmall.copyWith(color: Colors.grey)),
  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(amount, style: context.amountStyle(isPositive: isIncome)),
      SizedBox(width: context.responsiveSpacing8),
      InkWell(
        onTap: () => deleteTransaction(transaction),
        child: Icon(Icons.delete_outline, color: Colors.red, size: 20),
      ),
    ],
  ),
)
```

---

### 6. **分组头像卡片样式** (`GroupedAvatarCardStyle`)
**命名：`分组头像卡片样式` 或 `GroupedAvatarCardStyle`**

**样式特征：**
- 使用 `AppCard` 包裹日期分组
- 每个日期组内使用 `ListView.separated`
- 交易项使用 `CircleAvatar` 作为图标
- 支持批量选择复选框
- 支持搜索高亮动效

**使用位置：**
- `transaction_list_screen.dart` - `_buildDateGroup()` - 交易列表页面（按日期分组）

**代码示例：**
```dart
AppCard(
  child: Column(
    children: [
      // 日期标题
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date, style: context.mobileSubtitle),
          Text(totalAmount, style: context.mobileSubtitle.copyWith(...)),
        ],
      ),
      // 交易列表
      ...transactions.map((transaction) => Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: typeColor.withOpacity(0.1),
            child: Icon(categoryIcon, size: 20, color: typeColor),
          ),
          Expanded(child: Column(...)),
          Column(...), // 金额和时间
        ],
      )),
    ],
  ),
)
```

---

## 🎯 快速引用

以后只需要说：
- **"用圆角图标分隔列表样式"** → 应用 `RoundedIconDividerListStyle`
- **"用圆形图标阴影卡片样式"** → 应用 `CircleIconShadowCardStyle`
- **"用简单图标卡片样式"** → 应用 `SimpleIconCardStyle`
- **"用状态操作分隔列表样式"** → 应用 `StatusActionDividerListStyle`
- **"用圆角图标删除列表样式"** → 应用 `RoundedIconDeleteListStyle`
- **"用分组头像卡片样式"** → 应用 `GroupedAvatarCardStyle`

## 📝 样式对比表

| 样式名称 | 组件 | 图标形状 | 分隔方式 | 特殊功能 | 主要用途 |
|---------|------|---------|---------|---------|---------|
| 圆角图标分隔列表样式 | ListTile | 40x40圆角 | Divider | 无 | 清账相关交易列表 |
| 圆形图标阴影卡片样式 | Container+Row | 圆形 | 间距 | 滑动删除、批量选择 | 交易记录主列表 |
| 简单图标卡片样式 | AppCard+Row | Icon | 间距 | 滑动删除 | 还款历史列表 |
| 状态操作分隔列表样式 | ListTile | Icon | Divider | 状态图标、删除按钮 | 清账会话列表 |
| 圆角图标删除列表样式 | ListTile | 40x40圆角 | 间距 | 删除按钮 | 账户详情交易 |
| 分组头像卡片样式 | AppCard+ListView | CircleAvatar | 间距 | 日期分组、搜索高亮 | 按日期分组列表 |

## 🔍 样式特征速查

### 按图标形状分类：
- **圆角图标**：圆角图标分隔列表样式、圆角图标删除列表样式
- **圆形图标**：圆形图标阴影卡片样式
- **头像图标**：分组头像卡片样式
- **简单图标**：简单图标卡片样式、状态操作分隔列表样式

### 按分隔方式分类：
- **Divider分隔**：圆角图标分隔列表样式、状态操作分隔列表样式
- **间距分隔**：其他所有样式

### 按特殊功能分类：
- **支持删除**：圆角图标删除列表样式、状态操作分隔列表样式
- **支持滑动删除**：圆形图标阴影卡片样式、简单图标卡片样式
- **支持批量选择**：圆形图标阴影卡片样式、分组头像卡片样式

---

**最后更新：** 2024-11-11
**维护者：** AI Assistant
