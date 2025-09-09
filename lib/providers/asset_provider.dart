import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/asset_item.dart';
import '../services/storage_service.dart';

class AssetProvider with ChangeNotifier {
  List<AssetItem> _assets = [];
  bool _isAmountHidden = false;
  bool _excludeFixedAssets = false;

  List<AssetItem> get assets => _assets;
  bool get isAmountHidden => _isAmountHidden;
  bool get excludeFixedAssets => _excludeFixedAssets;

  StorageService? _storageService;

  Future<void> initialize() async {
    _storageService = await StorageService.getInstance();
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
    notifyListeners();
  }

  // 更新资产
  Future<void> updateAsset(AssetItem asset) async {
    if (_storageService == null) return;
    await _storageService!.updateAsset(asset);
    final index = _assets.indexWhere((a) => a.id == asset.id);
    if (index != -1) {
      _assets[index] = asset;
      notifyListeners();
    }
  }

  // 删除资产
  Future<void> deleteAsset(String assetId) async {
    if (_storageService == null) return;
    await _storageService!.deleteAsset(assetId);
    _assets.removeWhere((asset) => asset.id == assetId);
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
  double calculateTotalAssets() {
    return _assets
        .where((asset) {
          if (_excludeFixedAssets && asset.category == AssetCategory.fixedAssets) {
            return false;
          }
          return asset.category != AssetCategory.liabilities;
        })
        .fold(0.0, (sum, asset) => sum + asset.amount);
  }

  // 计算总负债
  double calculateTotalLiabilities() {
    return _assets
        .where((asset) => asset.category == AssetCategory.liabilities)
        .fold(0.0, (sum, asset) => sum + asset.amount);
  }

  // 计算净资产
  double calculateNetAssets() {
    return calculateTotalAssets() - calculateTotalLiabilities();
  }

  // 计算负债率
  double calculateDebtRatio() {
    final totalAssets = calculateTotalAssets();
    if (totalAssets == 0) return 0;
    return (calculateTotalLiabilities() / totalAssets) * 100;
  }

  // 按分类获取资产
  Map<AssetCategory, double> getAssetsByCategory() {
    final Map<AssetCategory, double> categoryTotals = {};
    
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
    return _assets.map((asset) => asset.updateDate).reduce((a, b) => a.isAfter(b) ? a : b);
  }

  // 格式化金额
  String formatAmount(double amount) {
    if (_isAmountHidden) return '****';
    
    final formatter = NumberFormat.currency(
      locale: 'zh_CN',
      symbol: '¥',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
