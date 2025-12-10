# Legacy Import 服务文档

## 概述

`core/services/legacy_import/` 是Flux Ledger的数据迁移和遗留系统集成的核心模块，负责从旧版本或外部系统导入数据，确保用户数据的连续性和完整性。

**文件统计**: 3个Dart文件，实现完整的数据导入和适配功能

## 架构定位

### 层级关系
```
外部数据源 (旧版本/第三方系统)      # 数据来源
    ↓ (数据导入/格式转换)
core/services/legacy_import/         # 🔵 当前层级 - 数据迁移
    ↓ (数据验证/清洗)
core/database/ + core/models/        # 目标数据存储
    ↓ (数据同步)
UI Layer (数据展示)                  # 最终展示
```

### 职责边界
- ✅ **数据迁移**: 从旧版本或外部系统导入数据
- ✅ **格式转换**: 处理不同数据格式的兼容性
- ✅ **数据验证**: 确保导入数据的完整性和正确性
- ✅ **错误处理**: 处理迁移过程中的异常情况
- ❌ **数据展示**: 不负责数据的UI展示
- ❌ **业务逻辑**: 不包含具体的财务业务规则

## 核心组件

### 1. 主导入服务 (1个文件)

#### FileLocator (`file_locator.dart`)
**职责**: 遗留数据文件的定位和发现服务

**核心功能**:
- 扫描设备存储中的遗留数据文件
- 支持多种文件格式识别（JSON, CSV, XML等）
- 文件完整性校验
- 导入历史记录管理

**关联关系**:
- **依赖**: 设备文件系统API
- **被依赖**: `ImportReport` (文件发现阶段)
- **级联影响**: 数据导入的自动化程度

### 2. 导入报告服务 (1个文件)

#### ImportReport (`import_report.dart`)
**职责**: 数据导入过程的报告生成和管理

**核心功能**:
- 导入过程的详细日志记录
- 成功/失败项目的统计
- 数据冲突和异常的详细报告
- 导入历史的持久化存储

**关联关系**:
- **依赖**: `FileLocator` (获取文件信息)
- **被依赖**: UI层 (展示导入结果)
- **级联影响**: 用户对导入过程的透明度

### 3. 数据适配器系统 (1个文件)

#### AssetsAdapter (`adapters/assets_adapter.dart`)
**职责**: 资产数据导入专用适配器

**核心功能**:
- 旧版资产数据格式转换
- 数据字段映射和兼容性处理
- 资产分类的智能识别
- 数据去重和合并逻辑

**关联关系**:
- **实现**: 数据适配器接口契约
- **依赖**: `core/models/AssetItem` (目标数据模型)
- **被依赖**: 资产导入流程
- **级联影响**: 资产数据的完整迁移

## 导入流程架构

### 标准导入流程
```
文件发现 → 格式识别 → 数据解析 → 字段映射 → 验证检查 → 冲突处理 → 数据写入 → 报告生成
```

### 数据转换管道
```dart
class AssetsAdapter implements DataAdapter<AssetItem> {
  Future<List<AssetItem>> convertLegacyData(dynamic legacyData) async {
    // 1. 格式解析
    final parsedData = _parseLegacyFormat(legacyData);

    // 2. 字段映射
    final mappedData = _mapFields(parsedData);

    // 3. 数据验证
    final validatedData = await _validateData(mappedData);

    // 4. 冲突处理
    final resolvedData = await _resolveConflicts(validatedData);

    return resolvedData;
  }
}
```

## 数据兼容性策略

### 版本兼容性
- **向后兼容**: 支持从旧版本导入数据
- **格式转换**: 处理数据结构的变化
- **默认值填充**: 为缺失字段提供合理的默认值

### 外部系统集成
- **标准格式支持**: JSON, CSV, XML等常见格式
- **自定义适配器**: 为特定系统提供专用适配器
- **批量处理**: 支持大量数据的分批导入

## 错误处理和恢复

### 异常处理机制
- **部分失败处理**: 单条数据失败不影响整体导入
- **回滚机制**: 导入失败时的数据清理
- **恢复重试**: 支持中断导入的恢复继续

### 数据验证策略
- **格式验证**: 确保数据格式的正确性
- **业务规则验证**: 检查业务逻辑的合理性
- **完整性检查**: 验证数据关系的完整性

## 性能优化

### 1. 分批处理
大文件的分批读取和处理，控制内存使用。

### 2. 并发处理
数据验证和转换的并发执行。

### 3. 进度监控
实时导入进度反馈，提升用户体验。

### 4. 资源管理
文件句柄和内存的及时释放。

## 安全考虑

### 1. 数据隐私
- 导入数据的本地处理，不上传到服务器
- 用户确认机制，确保用户知情权
- 数据清理，导入后的临时文件清理

### 2. 数据完整性
- 校验和验证，确保数据在传输和转换过程中不被篡改
- 备份机制，导入前的数据备份

### 3. 权限控制
- 文件访问权限检查
- 用户操作权限验证

## 测试策略

### 单元测试
- 数据适配器逻辑测试
- 文件定位功能测试
- 报告生成功能测试

### 集成测试
- 端到端导入流程测试
- 多种数据格式测试
- 错误场景恢复测试

### 数据验证测试
- 导入数据准确性测试
- 数据完整性测试
- 边界条件测试

## 扩展开发

### 添加新的数据适配器
```dart
class CustomDataAdapter implements DataAdapter<TargetModel> {
  Future<List<TargetModel>> convertLegacyData(dynamic legacyData) async {
    // 实现数据转换逻辑
  }
}
```

### 支持新的文件格式
```dart
class NewFormatLocator extends FileLocator {
  @override
  Future<List<FileInfo>> locateFiles() async {
    // 实现新的文件格式识别逻辑
  }
}
```

## 使用示例

### 基本导入流程
```dart
final importService = LegacyImportService();
final report = await importService.importFromFile(filePath);

// 检查导入结果
if (report.hasErrors) {
  // 处理错误
  for (final error in report.errors) {
    print('Import error: ${error.message}');
  }
} else {
  print('Successfully imported ${report.successCount} items');
}
```

## 相关文档

- [Core Services总文档](../README.md)
- [数据迁移服务](../data_migration_service.dart)
- [存储服务](../storage_service.dart)
