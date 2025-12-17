import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_finance_flutter/core/models/asset_history.dart';
import 'package:your_finance_flutter/core/models/asset_item.dart';
import 'package:your_finance_flutter/core/services/base_service.dart';
import 'package:your_finance_flutter/core/services/storage_service.dart';

class AssetHistoryService extends BaseService {
  AssetHistoryService._();
  static const String _historyKey = 'asset_history_data';
  static AssetHistoryService? _instance;
  static StorageService? _storageService;
  static SharedPreferences? _prefs;

  bool _isInitialized = false;
  bool _isLoading = false;
  String? _lastError;

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get lastError => _lastError;

  @override
  String get serviceName => 'AssetHistoryService';

  static Future<AssetHistoryService> getInstance() async {
    _instance ??= AssetHistoryService._();
    _storageService ??= await StorageService.getInstance();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // 记录资产变化
  Future<void> recordAssetChange({
    required String assetId,
    required AssetChangeType changeType,
    AssetItem? oldAsset,
    AssetItem? newAsset,
    String? description,
  }) async {
    final history = AssetHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      assetId: assetId,
      asset: newAsset,
      changeType: changeType,
      changeDate: DateTime.now(),
      changeDescription: description,
    );

    final histories = await getAssetHistory();
    histories.add(history);

    // 保持最近1000条记录，避免数据过大
    if (histories.length > 1000) {
      histories.removeRange(0, histories.length - 1000);
    }

    await _saveAssetHistory(histories);
  }

  // 获取资产历史记录
  Future<List<AssetHistory>> getAssetHistory() async {
    final jsonString = _prefs!.getString(_historyKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => AssetHistory.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // 获取特定资产的历史记录
  Future<List<AssetHistory>> getAssetHistoryById(String assetId) async {
    final allHistory = await getAssetHistory();
    return allHistory.where((h) => h.assetId == assetId).toList()
      ..sort((a, b) => b.changeDate.compareTo(a.changeDate));
  }

  // 保存历史记录
  Future<void> _saveAssetHistory(List<AssetHistory> histories) async {
    final jsonList = histories.map((h) => h.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs!.setString(_historyKey, jsonString);
  }

  // 导出所有数据
  Future<String> exportAllData() async {
    final assets = await _storageService!.getAssets();
    final history = await getAssetHistory();

    final exportData = ExportData(
      assets: assets,
      assetHistory: history,
      exportDate: DateTime.now(),
    );

    final jsonString = jsonEncode(exportData.toJson());
    return jsonString;
  }

  // 导出到文件并分享
  Future<void> exportAndShare() async {
    try {
      final jsonString = await exportAllData();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'your_finance_export_$timestamp.json';

      if (kIsWeb) {
        // Web端：复制到剪贴板
        _copyToClipboard(jsonString);
      } else {
        // 移动端：保存到文件
        final directory = Directory.systemTemp;
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(jsonString);
        print('文件已保存到: ${file.path}');
      }
    } catch (e) {
      throw Exception('导出失败: $e');
    }
  }

  // Web端复制到剪贴板
  void _copyToClipboard(String content) {
    // 这里需要根据具体的Web平台实现
    // 可以使用 dart:html 的 Clipboard API
    print('Web端复制功能需要实现');
  }

  // 导入资产历史记录
  Future<void> importAssetHistory(List<AssetHistory> histories) async {
    await _saveAssetHistory(histories);
  }

  // 清空历史记录
  Future<void> clearHistory() async {
    await _prefs!.remove(_historyKey);
  }

  // 删除特定历史记录
  Future<void> deleteHistory(String historyId) async {
    final histories = await getAssetHistory();
    histories.removeWhere((history) => history.id == historyId);

    await _saveAssetHistory(histories);
  }

  // 获取历史统计信息
  Future<Map<String, dynamic>> getHistoryStats() async {
    final history = await getAssetHistory();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeek = today.subtract(Duration(days: today.weekday - 1));
    final thisMonth = DateTime(now.year, now.month);

    return {
      'totalChanges': history.length,
      'todayChanges': history.where((h) => h.changeDate.isAfter(today)).length,
      'weekChanges':
          history.where((h) => h.changeDate.isAfter(thisWeek)).length,
      'monthChanges':
          history.where((h) => h.changeDate.isAfter(thisMonth)).length,
      'createdAssets':
          history.where((h) => h.changeType == AssetChangeType.created).length,
      'updatedAssets':
          history.where((h) => h.changeType == AssetChangeType.updated).length,
      'deletedAssets':
          history.where((h) => h.changeType == AssetChangeType.deleted).length,
    };
  }

  // 计算本月资产变化
  Future<Map<String, double>> calculateMonthlyChange() async {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    final lastMonth = DateTime(now.year, now.month - 1);

    // 获取本月和上月的资产快照
    final thisMonthAssets = await _getAssetsSnapshot(thisMonth);
    final lastMonthAssets = await _getAssetsSnapshot(lastMonth);

    final thisMonthTotal =
        thisMonthAssets.values.fold(0.0, (sum, amount) => sum + amount);
    final lastMonthTotal =
        lastMonthAssets.values.fold(0.0, (sum, amount) => sum + amount);

    final changeAmount = thisMonthTotal - lastMonthTotal;
    final changePercentage =
        lastMonthTotal > 0 ? (changeAmount / lastMonthTotal) * 100 : 0.0;

    return {
      'changeAmount': changeAmount,
      'changePercentage': changePercentage,
      'thisMonthTotal': thisMonthTotal,
      'lastMonthTotal': lastMonthTotal,
    };
  }

  // 获取指定月份的资产快照
  Future<Map<String, double>> _getAssetsSnapshot(DateTime month) async {
    final history = await getAssetHistory();
    final monthEnd = DateTime(month.year, month.month + 1, 0);

    // 找到该月最后一天的资产状态
    final monthHistory = history
        .where(
          (h) =>
              h.changeDate.isAfter(month.subtract(const Duration(days: 1))) &&
              h.changeDate.isBefore(monthEnd.add(const Duration(days: 1))),
        )
        .toList()
      ..sort((a, b) => a.changeDate.compareTo(b.changeDate));

    final assets = <String, double>{};

    for (final record in monthHistory) {
      if (record.asset != null) {
        assets[record.assetId] = record.asset!.amount;
      } else if (record.changeType == AssetChangeType.deleted) {
        assets.remove(record.assetId);
      }
    }

    return assets;
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    try {
      // Initialization is already done in getInstance()
      _isInitialized = true;
      _lastError = null;
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  @override
  Future<void> reset() async {
    _isLoading = true;
    try {
      // Clear all history data by saving empty list
      await _saveAssetHistory([]);
      _lastError = null;
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  @override
  Future<void> dispose() async {
    // Clear references
    _storageService = null;
    _prefs = null;
    _isInitialized = false;
  }

  @override
  Future<bool> healthCheck() async {
    try {
      // Try to read history data
      await getAssetHistory();
      return true;
    } catch (e) {
      _lastError = e.toString();
      return false;
    }
  }

  @override
  Map<String, dynamic> getStats() => {
        'serviceName': serviceName,
        'isInitialized': isInitialized,
        'isLoading': isLoading,
        'lastError': lastError,
      };
}
