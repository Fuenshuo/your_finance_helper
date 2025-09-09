import 'package:your_finance_flutter/models/asset_item.dart';

// 资产变化类型
enum AssetChangeType {
  created('创建'),
  updated('更新'),
  deleted('删除');

  const AssetChangeType(this.displayName);
  final String displayName;
}

// 资产历史记录
class AssetHistory {
  // 可选的变更描述

  AssetHistory({
    required this.id,
    required this.assetId,
    required this.changeType,
    required this.changeDate,
    this.asset,
    this.changeDescription,
  });

  factory AssetHistory.fromJson(Map<String, dynamic> json) => AssetHistory(
        id: json['id'] as String,
        assetId: json['assetId'] as String,
        asset: json['asset'] != null
            ? AssetItem.fromJson(json['asset'] as Map<String, dynamic>)
            : null,
        changeType: AssetChangeType.values.firstWhere(
          (e) => e.name == json['changeType'] as String,
        ),
        changeDate: DateTime.parse(json['changeDate'] as String),
        changeDescription: json['changeDescription'] as String?,
      );
  final String id;
  final String assetId;
  final AssetItem? asset; // 删除时为null
  final AssetChangeType changeType;
  final DateTime changeDate;
  final String? changeDescription;

  Map<String, dynamic> toJson() => {
        'id': id,
        'assetId': assetId,
        'asset': asset?.toJson(),
        'changeType': changeType.name,
        'changeDate': changeDate.toIso8601String(),
        'changeDescription': changeDescription,
      };
}

// 导出数据模型
class ExportData {
  ExportData({
    required this.assets,
    required this.assetHistory,
    required this.exportDate,
    this.version = '1.0',
  });

  factory ExportData.fromJson(Map<String, dynamic> json) => ExportData(
        version: (json['version'] as String?) ?? '1.0',
        exportDate: DateTime.parse(json['exportDate'] as String),
        assets: (json['assets'] as List)
            .map((a) => AssetItem.fromJson(a as Map<String, dynamic>))
            .toList(),
        assetHistory: (json['assetHistory'] as List)
            .map((h) => AssetHistory.fromJson(h as Map<String, dynamic>))
            .toList(),
      );
  final List<AssetItem> assets;
  final List<AssetHistory> assetHistory;
  final DateTime exportDate;
  final String version;

  Map<String, dynamic> toJson() => {
        'version': version,
        'exportDate': exportDate.toIso8601String(),
        'assets': assets.map((a) => a.toJson()).toList(),
        'assetHistory': assetHistory.map((h) => h.toJson()).toList(),
      };
}
