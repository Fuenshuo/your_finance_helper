import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_finance_flutter/core/models/asset_history.dart';
import 'package:your_finance_flutter/core/models/asset_item.dart';
import 'package:your_finance_flutter/core/services/asset_history_service.dart';
import 'package:your_finance_flutter/core/services/depreciation_service.dart';
import 'package:your_finance_flutter/core/services/drift_database_service.dart';
import 'package:your_finance_flutter/core/services/hybrid_storage_service.dart';

/// Asset state for Riverpod
@immutable
sealed class AssetState {
  const AssetState();

  bool get isInitial => this is AssetStateInitial;
  bool get isLoading => this is AssetStateLoading;
  bool get isLoaded => this is AssetStateLoaded;
  bool get isError => this is AssetStateError;

  List<AssetItem> get assets => this is AssetStateLoaded ? (this as AssetStateLoaded).assets : [];
  String get errorMessage => this is AssetStateError ? (this as AssetStateError).message : '';
  bool get isAmountHidden => this is AssetStateLoaded ? (this as AssetStateLoaded).isAmountHidden : false;
  bool get excludeFixedAssets => this is AssetStateLoaded ? (this as AssetStateLoaded).excludeFixedAssets : false;
  bool get isInitialized => this is AssetStateLoaded ? (this as AssetStateLoaded).isInitialized : false;
}

class AssetStateInitial extends AssetState {
  const AssetStateInitial();
}

class AssetStateLoading extends AssetState {
  const AssetStateLoading();
}

class AssetStateLoaded extends AssetState {
  const AssetStateLoaded(
    this.assets, {
    required this.isAmountHidden,
    required this.excludeFixedAssets,
    required this.isInitialized,
  });

  final List<AssetItem> assets;
  final bool isAmountHidden;
  final bool excludeFixedAssets;
  final bool isInitialized;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetStateLoaded &&
          runtimeType == other.runtimeType &&
          listEquals(assets, other.assets) &&
          isAmountHidden == other.isAmountHidden &&
          excludeFixedAssets == other.excludeFixedAssets &&
          isInitialized == other.isInitialized;

  @override
  int get hashCode => Object.hash(
        assets,
        isAmountHidden,
        excludeFixedAssets,
        isInitialized,
      );
}

class AssetStateError extends AssetState {
  const AssetStateError(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetStateError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

/// Asset notifier for Riverpod state management
class AssetNotifier extends StateNotifier<AssetState> {
  AssetNotifier(
    this._storageService,
    this._historyService,
    this._driftService,
  ) : super(const AssetStateInitial()) {
    _depreciationService = DepreciationService();
    initialize();
  }

  final HybridStorageService _storageService;
  final AssetHistoryService _historyService;
  final DriftDatabaseService _driftService;
  late final DepreciationService _depreciationService;

  Future<void> initialize() async {
    state = const AssetStateLoading();
    try {
      await loadAssets();
      state = AssetStateLoaded(
        [],
        isAmountHidden: false,
        excludeFixedAssets: false,
        isInitialized: true,
      );
    } catch (e) {
      state = AssetStateError(e.toString());
    }
  }

  // 加载资产数据 - 优先从Drift加载，如果失败则从SharedPreferences加载
  Future<void> loadAssets() async {
    try {
      // 首先尝试从Drift数据库加载
      try {
        final driftAssets = await _driftService.getAssets();
        if (driftAssets.isNotEmpty) {
          state = AssetStateLoaded(
            driftAssets,
            isAmountHidden: state.isLoaded ? state.isAmountHidden : false,
            excludeFixedAssets: state.isLoaded ? state.excludeFixedAssets : false,
            isInitialized: true,
          );
          return;
        }
      } catch (e) {
        // 如果Drift加载失败，继续使用SharedPreferences
      }

      // 从SharedPreferences加载
      final assets = await _storageService.getAssets();
      state = AssetStateLoaded(
        assets,
        isAmountHidden: state.isLoaded ? state.isAmountHidden : false,
        excludeFixedAssets: state.isLoaded ? state.excludeFixedAssets : false,
        isInitialized: true,
      );
    } catch (e) {
      state = AssetStateError(e.toString());
    }
  }

  // 添加资产
  Future<void> addAsset(AssetItem asset) async {
    try {
      await _storageService.addAsset(asset);

      final currentAssets = state.assets;
      final newAssets = [...currentAssets, asset];

      // 记录历史
      await _historyService.recordAssetChange(
        assetId: asset.id,
        newAsset: asset,
        changeType: AssetChangeType.created,
        description: '新增资产: ${asset.name}',
      );

      state = AssetStateLoaded(
        newAssets,
        isAmountHidden: state.isAmountHidden,
        excludeFixedAssets: state.excludeFixedAssets,
        isInitialized: state.isInitialized,
      );
    } catch (e) {
      state = AssetStateError(e.toString());
    }
  }

  // 更新资产
  Future<void> updateAsset(AssetItem asset) async {
    try {
      final currentAssets = state.assets;
      final oldAsset = currentAssets.firstWhere((a) => a.id == asset.id);

      await _storageService.updateAsset(asset);

      final newAssets = currentAssets.map((a) => a.id == asset.id ? asset : a).toList();

      // 记录历史
      await _historyService.recordAssetChange(
        assetId: asset.id,
        oldAsset: oldAsset,
        newAsset: asset,
        changeType: AssetChangeType.updated,
        description: '更新资产: ${asset.name}',
      );

      state = AssetStateLoaded(
        newAssets,
        isAmountHidden: state.isAmountHidden,
        excludeFixedAssets: state.excludeFixedAssets,
        isInitialized: state.isInitialized,
      );
    } catch (e) {
      state = AssetStateError(e.toString());
    }
  }

  // 删除资产
  Future<void> deleteAsset(String assetId) async {
    try {
      final currentAssets = state.assets;
      final assetToDelete = currentAssets.firstWhere((a) => a.id == assetId);

      await _storageService.deleteAsset(assetId);

      final newAssets = currentAssets.where((a) => a.id != assetId).toList();

      // 记录历史
      await _historyService.recordAssetChange(
        assetId: assetId,
        oldAsset: assetToDelete,
        changeType: AssetChangeType.deleted,
        description: '删除资产: ${assetToDelete.name}',
      );

      state = AssetStateLoaded(
        newAssets,
        isAmountHidden: state.isAmountHidden,
        excludeFixedAssets: state.excludeFixedAssets,
        isInitialized: state.isInitialized,
      );
    } catch (e) {
      state = AssetStateError(e.toString());
    }
  }

  // 切换金额隐藏状态
  void toggleAmountVisibility() {
    if (!state.isLoaded) return;

    state = AssetStateLoaded(
      state.assets,
      isAmountHidden: !state.isAmountHidden,
      excludeFixedAssets: state.excludeFixedAssets,
      isInitialized: state.isInitialized,
    );
  }

  // 切换排除固定资产状态
  void toggleExcludeFixedAssets() {
    if (!state.isLoaded) return;

    state = AssetStateLoaded(
      state.assets,
      isAmountHidden: state.isAmountHidden,
      excludeFixedAssets: !state.excludeFixedAssets,
      isInitialized: state.isInitialized,
    );
  }

  // 计算总资产（使用实际价值）
  double calculateTotalAssets() {
    return state.assets.where((asset) {
      if (state.excludeFixedAssets && asset.isFixedAsset) {
        return false;
      }
      return asset.category.isAsset;
    }).fold(0.0, (sum, asset) => sum + asset.effectiveValue);
  }

  // 计算总负债
  double calculateTotalLiabilities() {
    return state.assets
        .where((asset) => asset.category.isLiability)
        .fold(0.0, (sum, asset) => sum + asset.amount);
  }

  // 计算净资产
  double calculateNetAssets() => calculateTotalAssets() - calculateTotalLiabilities();

  // 计算负债率
  double calculateDebtRatio() {
    final totalAssets = calculateTotalAssets();
    if (totalAssets == 0) return 0;
    return (calculateTotalLiabilities() / totalAssets) * 100;
  }

  // 按分类获取资产（使用实际价值）
  Map<AssetCategory, double> getAssetsByCategory() {
    final categoryTotals = <AssetCategory, double>{};

    for (final category in AssetCategory.values) {
      final total = state.assets
          .where((asset) => asset.category == category)
          .fold(0.0, (sum, asset) => sum + asset.effectiveValue);
      categoryTotals[category] = total;
    }

    return categoryTotals;
  }

  // 获取最后更新日期
  DateTime? getLastUpdateDate() {
    if (state.assets.isEmpty) return null;
    return state.assets
        .map((asset) => asset.updateDate)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  // 替换所有资产
  Future<void> replaceAllAssets(List<AssetItem> newAssets) async {
    try {
      // 记录批量更新历史
      await _historyService.recordAssetChange(
        assetId: 'batch_update_${DateTime.now().millisecondsSinceEpoch}',
        changeType: AssetChangeType.updated,
        description: '批量更新资产 (${state.assets.length} -> ${newAssets.length})',
      );

      // 清空现有资产
      for (final asset in state.assets) {
        await _storageService.deleteAsset(asset.id);
      }

      // 添加新资产
      for (final asset in newAssets) {
        await _storageService.addAsset(asset);
      }

      state = AssetStateLoaded(
        newAssets,
        isAmountHidden: state.isAmountHidden,
        excludeFixedAssets: state.excludeFixedAssets,
        isInitialized: state.isInitialized,
      );
    } catch (e) {
      state = AssetStateError(e.toString());
    }
  }

  // 获取本月资产变化数据
  Future<Map<String, double>> getMonthlyChange() async {
    return _historyService.calculateMonthlyChange();
  }

  // 固定资产管理相关方法

  /// 更新固定资产的折旧设置
  Future<void> updateAssetDepreciation(
    String assetId, {
    DepreciationMethod? depreciationMethod,
    double? depreciationRate,
    DateTime? purchaseDate,
    double? currentValue,
  }) async {
    try {
      final currentAssets = state.assets;
      final assetIndex = currentAssets.indexWhere((a) => a.id == assetId);
      if (assetIndex == -1) return;

      final oldAsset = currentAssets[assetIndex];
      final updatedAsset = oldAsset.copyWith(
        depreciationMethod: depreciationMethod,
        depreciationRate: depreciationRate,
        purchaseDate: purchaseDate,
        currentValue: currentValue,
        updateDate: DateTime.now(),
      );

      await updateAsset(updatedAsset);
    } catch (e) {
      state = AssetStateError(e.toString());
    }
  }

  /// 设置固定资产为闲置状态
  Future<void> setAssetIdle(String assetId, double idleValue) async {
    try {
      final currentAssets = state.assets;
      final assetIndex = currentAssets.indexWhere((a) => a.id == assetId);
      if (assetIndex == -1) return;

      final oldAsset = currentAssets[assetIndex];
      final updatedAsset = oldAsset.copyWith(
        isIdle: true,
        idleValue: idleValue,
        updateDate: DateTime.now(),
      );

      await updateAsset(updatedAsset);
    } catch (e) {
      state = AssetStateError(e.toString());
    }
  }

  /// 取消固定资产的闲置状态
  Future<void> unsetAssetIdle(String assetId) async {
    try {
      final currentAssets = state.assets;
      final assetIndex = currentAssets.indexWhere((a) => a.id == assetId);
      if (assetIndex == -1) return;

      final oldAsset = currentAssets[assetIndex];
      final updatedAsset = oldAsset.copyWith(
        isIdle: false,
        updateDate: DateTime.now(),
      );

      await updateAsset(updatedAsset);
    } catch (e) {
      state = AssetStateError(e.toString());
    }
  }

  /// 批量更新固定资产的折旧价值
  Future<void> updateDepreciatedValues() async {
    try {
      final currentAssets = state.assets;
      var hasChanges = false;
      final newAssets = <AssetItem>[];

      for (final asset in currentAssets) {
        if (asset.requiresDepreciation &&
            asset.depreciationMethod == DepreciationMethod.smartEstimate) {
          final depreciatedValue = _depreciationService.calculateDepreciatedValue(asset);
          if (asset.currentValue != depreciatedValue) {
            newAssets.add(asset.copyWith(
              currentValue: depreciatedValue,
              updateDate: DateTime.now(),
            ));
            hasChanges = true;
          } else {
            newAssets.add(asset);
          }
        } else {
          newAssets.add(asset);
        }
      }

      if (hasChanges) {
        // 批量保存到存储
        for (final asset in newAssets) {
          await _storageService.updateAsset(asset);
        }

        state = AssetStateLoaded(
          newAssets,
          isAmountHidden: state.isAmountHidden,
          excludeFixedAssets: state.excludeFixedAssets,
          isInitialized: state.isInitialized,
        );
      }
    } catch (e) {
      state = AssetStateError(e.toString());
    }
  }

  /// 获取固定资产列表（不动产 + 消费资产）
  List<AssetItem> getFixedAssets() => state.assets.where((asset) => asset.isFixedAsset).toList();

  /// 获取闲置资产列表
  List<AssetItem> getIdleAssets() => state.assets.where((asset) => asset.isIdle).toList();

  /// 获取需要折旧的资产列表
  List<AssetItem> getDepreciableAssets() => state.assets.where((asset) => asset.requiresDepreciation).toList();

  /// 计算固定资产的总折旧额
  double calculateTotalDepreciation() {
    var totalDepreciation = 0.0;

    for (final asset in state.assets) {
      if (asset.requiresDepreciation && asset.depreciationMethod != DepreciationMethod.none) {
        final originalValue = asset.amount;
        final currentValue = asset.effectiveValue;
        totalDepreciation += originalValue - currentValue;
      }
    }

    return totalDepreciation;
  }

  /// 获取资产的折旧历史
  Map<DateTime, double> getAssetDepreciationHistory(
    String assetId, {
    required DateTime startDate,
    required DateTime endDate,
    int interval = 1,
  }) {
    final asset = state.assets.firstWhere((a) => a.id == assetId);
    return _depreciationService.getDepreciationHistory(
      asset,
      startDate: startDate,
      endDate: endDate,
      interval: interval,
    );
  }
}

/// Riverpod providers for asset management
final hybridStorageServiceProvider = Provider<HybridStorageService>((ref) {
  throw UnimplementedError('HybridStorageService must be provided');
});

final assetHistoryServiceProvider = Provider<AssetHistoryService>((ref) {
  throw UnimplementedError('AssetHistoryService must be provided');
});

final driftDatabaseServiceProvider = Provider<DriftDatabaseService>((ref) {
  throw UnimplementedError('DriftDatabaseService must be provided');
});

final assetProvider = StateNotifierProvider<AssetNotifier, AssetState>((ref) {
  final storageService = ref.watch(hybridStorageServiceProvider);
  final historyService = ref.watch(assetHistoryServiceProvider);
  final driftService = ref.watch(driftDatabaseServiceProvider);
  return AssetNotifier(storageService, historyService, driftService);
});

/// Computed providers for derived asset data
final assetListProvider = Provider<List<AssetItem>>((ref) {
  return ref.watch(assetProvider).assets;
});

final isAssetLoadingProvider = Provider<bool>((ref) {
  return ref.watch(assetProvider).isLoading;
});

final isAssetInitializedProvider = Provider<bool>((ref) {
  return ref.watch(assetProvider).isInitialized;
});

final assetErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(assetProvider);
  return state.isError ? state.errorMessage : null;
});

final isAmountHiddenProvider = Provider<bool>((ref) {
  return ref.watch(assetProvider).isAmountHidden;
});

final excludeFixedAssetsProvider = Provider<bool>((ref) {
  return ref.watch(assetProvider).excludeFixedAssets;
});

final totalAssetsProvider = Provider<double>((ref) {
  // This is a simple computed provider - in a real app you might want to use
  // a more sophisticated caching strategy
  final notifier = ref.watch(assetProvider.notifier);
  return notifier.calculateTotalAssets();
});

final totalLiabilitiesProvider = Provider<double>((ref) {
  final notifier = ref.watch(assetProvider.notifier);
  return notifier.calculateTotalLiabilities();
});

final netAssetsProvider = Provider<double>((ref) {
  final notifier = ref.watch(assetProvider.notifier);
  return notifier.calculateNetAssets();
});

final debtRatioProvider = Provider<double>((ref) {
  final notifier = ref.watch(assetProvider.notifier);
  return notifier.calculateDebtRatio();
});

final assetsByCategoryProvider = Provider<Map<AssetCategory, double>>((ref) {
  final notifier = ref.watch(assetProvider.notifier);
  return notifier.getAssetsByCategory();
});

final lastUpdateDateProvider = Provider<DateTime?>((ref) {
  final notifier = ref.watch(assetProvider.notifier);
  return notifier.getLastUpdateDate();
});

final fixedAssetsProvider = Provider<List<AssetItem>>((ref) {
  final notifier = ref.watch(assetProvider.notifier);
  return notifier.getFixedAssets();
});

final idleAssetsProvider = Provider<List<AssetItem>>((ref) {
  final notifier = ref.watch(assetProvider.notifier);
  return notifier.getIdleAssets();
});

final depreciableAssetsProvider = Provider<List<AssetItem>>((ref) {
  final notifier = ref.watch(assetProvider.notifier);
  return notifier.getDepreciableAssets();
});

final totalDepreciationProvider = Provider<double>((ref) {
  final notifier = ref.watch(assetProvider.notifier);
  return notifier.calculateTotalDepreciation();
});
