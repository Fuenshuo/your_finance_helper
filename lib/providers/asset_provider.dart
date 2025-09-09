import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:your_finance_flutter/models/asset_history.dart';
import 'package:your_finance_flutter/models/asset_item.dart';
import 'package:your_finance_flutter/services/asset_history_service.dart';
import 'package:your_finance_flutter/services/storage_service.dart';

class AssetProvider with ChangeNotifier {
  List<AssetItem> _assets = [];
  bool _isAmountHidden = false;
  bool _excludeFixedAssets = false;

  List<AssetItem> get assets => _assets;
  bool get isAmountHidden => _isAmountHidden;
  bool get excludeFixedAssets => _excludeFixedAssets;

  StorageService? _storageService;
  AssetHistoryService? _historyService;

  Future<void> initialize() async {
    _storageService = await StorageService.getInstance();
    _historyService = await AssetHistoryService.getInstance();
    await loadAssets();
  }

  // 加载资产数据
  Future<void> loadAssets() async {
    if (_storageService == null) return;
    _assets = await _storageService!.getAssets();
    notifyListeners();
  }

  // 添加资产
  Future<void> addAsset(AssetItem asset) async {
    if (_storageService == null) return;
    await _storageService!.addAsset(asset);
    _assets.add(asset);

    // 记录历史
    await _historyService?.recordAssetChange(
      assetId: asset.id,
      newAsset: asset,
      changeType: AssetChangeType.created,
      description: '新增资产: ${asset.name}',
    );

    notifyListeners();
  }

  // 更新资产
  Future<void> updateAsset(AssetItem asset) async {
    if (_storageService == null) return;

    // 获取旧资产用于历史记录
    final oldAsset = _assets.firstWhere((a) => a.id == asset.id);

    await _storageService!.updateAsset(asset);
    final index = _assets.indexWhere((a) => a.id == asset.id);
    if (index != -1) {
      _assets[index] = asset;
    }

    // 记录历史
    await _historyService?.recordAssetChange(
      assetId: asset.id,
      oldAsset: oldAsset,
      newAsset: asset,
      changeType: AssetChangeType.updated,
      description: '更新资产: ${asset.name}',
    );

    notifyListeners();
  }

  // 删除资产
  Future<void> deleteAsset(String assetId) async {
    if (_storageService == null) return;

    // 获取要删除的资产用于历史记录
    final assetToDelete = _assets.firstWhere((a) => a.id == assetId);

    await _storageService!.deleteAsset(assetId);
    _assets.removeWhere((asset) => asset.id == assetId);

    // 记录历史
    await _historyService?.recordAssetChange(
      assetId: assetId,
      oldAsset: assetToDelete,
      changeType: AssetChangeType.deleted,
      description: '删除资产: ${assetToDelete.name}',
    );

    notifyListeners();
  }

  // 切换金额隐藏状态
  void toggleAmountVisibility() {
    _isAmountHidden = !_isAmountHidden;
    notifyListeners();
  }

  // 切换排除固定资产状态
  void toggleExcludeFixedAssets() {
    _excludeFixedAssets = !_excludeFixedAssets;
    notifyListeners();
  }

  // 计算总资产
  double calculateTotalAssets() => _assets.where((asset) {
        if (_excludeFixedAssets &&
            asset.category == AssetCategory.fixedAssets) {
          return false;
        }
        return asset.category != AssetCategory.liabilities;
      }).fold(0.0, (sum, asset) => sum + asset.amount);

  // 计算总负债
  double calculateTotalLiabilities() => _assets
      .where((asset) => asset.category == AssetCategory.liabilities)
      .fold(0.0, (sum, asset) => sum + asset.amount);

  // 计算净资产
  double calculateNetAssets() =>
      calculateTotalAssets() - calculateTotalLiabilities();

  // 计算负债率
  double calculateDebtRatio() {
    final totalAssets = calculateTotalAssets();
    if (totalAssets == 0) return 0;
    return (calculateTotalLiabilities() / totalAssets) * 100;
  }

  // 按分类获取资产
  Map<AssetCategory, double> getAssetsByCategory() {
    final categoryTotals = <AssetCategory, double>{};

    for (final category in AssetCategory.values) {
      final total = _assets
          .where((asset) => asset.category == category)
          .fold(0.0, (sum, asset) => sum + asset.amount);
      categoryTotals[category] = total;
    }

    return categoryTotals;
  }

  // 获取最后更新日期
  DateTime? getLastUpdateDate() {
    if (_assets.isEmpty) return null;
    return _assets
        .map((asset) => asset.updateDate)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  // 格式化金额
  // 替换所有资产
  Future<void> replaceAllAssets(List<AssetItem> newAssets) async {
    if (_storageService == null) return;

    // 记录批量更新历史
    await _historyService?.recordAssetChange(
      assetId: 'batch_update_${DateTime.now().millisecondsSinceEpoch}',
      changeType: AssetChangeType.updated,
      description: '批量更新资产 (${_assets.length} -> ${newAssets.length})',
    );

    // 清空现有资产
    for (final asset in _assets) {
      await _storageService!.deleteAsset(asset.id);
    }

    // 添加新资产
    for (final asset in newAssets) {
      await _storageService!.addAsset(asset);
    }

    _assets = List.from(newAssets);
    notifyListeners();
  }

  String formatAmount(double amount) {
    if (_isAmountHidden) return '****';

    final formatter = NumberFormat.currency(
      locale: 'zh_CN',
      symbol: '¥',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // 获取本月资产变化数据
  Future<Map<String, double>> getMonthlyChange() async {
    if (_historyService == null) {
      return {
        'changeAmount': 0.0,
        'changePercentage': 0.0,
        'thisMonthTotal': calculateNetAssets(),
        'lastMonthTotal': calculateNetAssets(),
      };
    }

    return _historyService!.calculateMonthlyChange();
  }
}
