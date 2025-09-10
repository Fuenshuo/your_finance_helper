# Web端数据持久化使用指南

## 问题背景

在开发阶段，每次重启Flutter应用或热重载时，浏览器的localStorage数据会丢失，导致用户辛苦录入的数据无法保存。为了解决这个问题，我们实现了完整的文件导入导出功能。

## 解决方案

### 1. 文件导出功能
- **功能**：将所有数据导出为JSON文件并自动下载
- **包含数据**：
  - 资产数据（包括固定资产、负债等）
  - 交易记录
  - 账户信息
  - 预算数据（信封预算、零基预算）
  - 资产历史记录
  - 导出时间和版本信息

### 2. 文件导入功能
- **功能**：从JSON文件导入所有数据
- **支持格式**：之前导出的JSON文件
- **数据恢复**：完整恢复所有功能模块的数据

## 使用方法

### 导出数据
1. 进入"资产管理"页面
2. 点击右上角的"🐛"调试按钮
3. 选择"导出数据到文件"
4. 系统会自动下载一个JSON文件到您的下载文件夹
5. 文件名格式：`your_finance_backup_时间戳.json`

### 导入数据
1. 进入"资产管理"页面
2. 点击右上角的"🐛"调试按钮
3. 选择"从文件导入数据"
4. 在弹出的文件选择器中选择之前导出的JSON文件
5. 系统会自动导入所有数据并刷新界面

### 开发工作流程
1. **开始使用**：直接添加数据，系统会自动保存到localStorage
2. **开发重启前**：导出数据到文件
3. **重启后**：导入之前导出的文件
4. **继续开发**：数据完全恢复，可以继续使用

## 技术实现

### 导出功能
```dart
// 下载文件
void _downloadFile(String content, String fileName) {
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..style.display = 'none'
    ..download = fileName;
  html.document.body?.children.add(anchor);
  anchor.click();
  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}
```

### 导入功能
```dart
// 上传文件
Future<String?> _uploadFile() async {
  final input = html.FileUploadInputElement()..accept = '.json';
  input.click();

  final completer = Completer<String?>();
  
  input.onChange.listen((e) {
    final files = input.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final reader = html.FileReader();
      
      reader.onLoadEnd.listen((e) {
        final result = reader.result as String?;
        completer.complete(result);
      });
      
      reader.readAsText(file);
    }
  });

  return completer.future;
}
```

## 数据格式

导出的JSON文件包含以下结构：
```json
{
  "assets": [...],
  "transactions": [...],
  "accounts": [...],
  "envelopeBudgets": [...],
  "zeroBasedBudgets": [...],
  "assetHistory": [...],
  "exportTime": "2025-01-27T10:30:00.000Z",
  "version": "2.2"
}
```

## 注意事项

1. **文件格式**：只支持JSON格式的文件
2. **数据完整性**：导出包含所有功能模块的数据
3. **版本兼容**：支持不同版本间的数据迁移
4. **备份建议**：建议定期导出数据作为备份
5. **文件安全**：导出的文件包含敏感财务信息，请妥善保管

## 故障排除

### 导入失败
- 检查文件格式是否为JSON
- 确认文件是之前导出的备份文件
- 检查文件是否损坏

### 导出失败
- 检查浏览器是否允许下载文件
- 确认有足够的数据可以导出
- 检查浏览器控制台是否有错误信息

### 数据不完整
- 确认导出时包含了所有需要的数据
- 检查导入时是否选择了正确的文件
- 确认文件没有在传输过程中损坏

## 最佳实践

1. **定期备份**：建议每天或每次重要操作后导出数据
2. **文件命名**：使用有意义的文件名，包含日期信息
3. **多份备份**：保留多个时间点的备份文件
4. **测试恢复**：定期测试导入功能，确保备份文件可用
5. **版本管理**：记录每次导出的版本信息

## 未来改进

1. **自动备份**：实现定时自动备份功能
2. **云端同步**：支持云端存储和同步
3. **增量备份**：只备份变更的数据
4. **压缩存储**：压缩备份文件减少存储空间
5. **加密保护**：对备份文件进行加密保护

这个解决方案完美解决了开发阶段数据丢失的问题，让您可以安心使用应用进行真实的财务管理，而不用担心数据丢失。
