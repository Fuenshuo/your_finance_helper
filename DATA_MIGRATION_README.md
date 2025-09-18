# 数据迁移说明文档

## 📋 概述

本应用在架构重构过程中保持了向后兼容性，确保用户现有数据不会丢失。本文档说明数据迁移的实现原理和使用方法。

## 🔄 迁移内容

### 版本1迁移：资产分类修复
- **问题**: 旧版本使用 `fixedAssets` 分类，新版本改为 `realEstate`
- **解决**: 自动将 `fixedAssets` 映射为 `realEstate`
- **影响**: 用户的房产等固定资产分类将自动更新为不动产分类

### 版本2迁移：交易类型兼容性
- **问题**: 旧版本使用简单的 `TransactionType`，新版本使用 `TransactionFlow`
- **解决**: 根据交易类型自动推断资金流向
- **映射规则**:
  - `income` → `externalToWallet` (外部->钱包)
  - `expense` → `walletToExternal` (钱包->外部)
  - `transfer` → `walletToWallet` (钱包->钱包)

## 🚀 自动迁移

### 启动时自动执行
应用启动时会自动检测数据版本并执行必要的迁移：

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 执行数据迁移
  final migrationService = await DataMigrationService.getInstance();
  await migrationService.checkAndMigrateData();

  runApp(const MyApp());
}
```

### 迁移状态检查
- 应用会在主界面显示迁移状态提醒
- 如果检测到数据问题，会提示用户执行迁移
- 用户可以选择"执行迁移"或"稍后提醒"

## 🛠️ 手动迁移

### 使用数据迁移服务
```dart
final migrationService = await DataMigrationService.getInstance();

// 执行完整迁移
await migrationService.checkAndMigrateData();

// 验证数据完整性
final isValid = await migrationService.validateDataIntegrity();

// 强制重新迁移（紧急修复）
await migrationService.forceMigrateAllData();
```

### 查看迁移历史
```dart
final history = migrationService.getMigrationHistory();
print('迁移历史: $history');
```

## 🔍 数据兼容性

### AssetItem 向后兼容
```dart
// 自动处理旧分类名称
AssetCategory _parseAssetCategory(String categoryName) {
  switch (categoryName) {
    case 'fixedAssets':
      return AssetCategory.realEstate; // 自动映射
    default:
      return AssetCategory.values.firstWhere(
        (e) => e.name == categoryName,
        orElse: () => AssetCategory.liquidAssets,
      );
  }
}
```

### Transaction 向后兼容
```dart
// 从旧类型推断新流向
TransactionFlow? _inferTransactionFlow(String typeName, Map<String, dynamic> transactionJson) {
  switch (TransactionType.values.firstWhere((e) => e.name == typeName)) {
    case TransactionType.income:
      return TransactionFlow.externalToWallet;
    case TransactionType.expense:
      return TransactionFlow.walletToExternal;
    case TransactionType.transfer:
      return TransactionFlow.walletToWallet;
  }
}
```

## 🧪 测试验证

运行数据迁移测试：

```bash
dart test_data_migration.dart
```

测试内容：
- ✅ 创建模拟旧格式数据
- ✅ 执行自动迁移
- ✅ 验证迁移结果正确性
- ✅ 确认数据完整性

## 📊 数据版本管理

| 版本 | 说明 | 迁移内容 |
|------|------|----------|
| 0 | 初始版本 | 无迁移 |
| 1 | 资产分类更新 | fixedAssets → realEstate |
| 2 | 交易流向优化 | TransactionType → TransactionFlow |

## ⚠️ 注意事项

### 数据备份
- 虽然迁移过程安全，但建议在重要操作前备份数据
- SharedPreferences 数据存储在应用私有目录中

### 迁移失败处理
- 如果迁移失败，应用会继续使用旧数据格式
- 不会丢失任何用户数据
- 可以多次尝试迁移

### 性能影响
- 迁移只在版本升级时执行
- 对应用启动时间影响很小（通常<1秒）
- 迁移完成后不再执行

## 🔧 故障排除

### 问题：迁移卡住或失败
**解决方法**:
```dart
// 强制重置迁移状态
final migrationService = await DataMigrationService.getInstance();
await migrationService.resetMigrationVersion();
await migrationService.checkAndMigrateData();
```

### 问题：数据显示异常
**解决方法**:
1. 清除应用数据（会丢失所有数据）
2. 重新安装应用
3. 或者联系开发者获取支持

## 📞 技术支持

如果遇到数据迁移相关问题，请：

1. 查看应用日志中的迁移信息
2. 尝试手动执行迁移
3. 联系开发者并提供以下信息：
   - 应用版本
   - 迁移历史记录
   - 错误日志

---

**最后更新**: 2024年12月
**版本**: v2.0.0
