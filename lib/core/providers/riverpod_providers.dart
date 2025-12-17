// ============================================================================
// Riverpod Providers for Asset Management (Working Demo Version)
// ============================================================================

// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_finance_flutter/core/models/asset_item.dart';
import 'package:your_finance_flutter/core/services/drift_database_service.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';

// ============================================================================
// Database Service Provider
// ============================================================================

/// Initialized database service provider
final databaseServiceProvider = FutureProvider<DriftDatabaseService>(
  (ref) async => DriftDatabaseService.getInstance(),
);

// ============================================================================
// Database-Backed Asset Management
// ============================================================================

/// Database-backed asset list provider that loads from Drift
final assetsProvider =
    StateNotifierProvider<AssetsNotifier, List<AssetItem>>((ref) {
  final notifier = AssetsNotifier();

  // Load data from database on initialization
  ref.listen<AsyncValue<DriftDatabaseService>>(databaseServiceProvider,
      (previous, next) {
    next.whenData((db) async {
      try {
        final assets = await db.getAssets();
        if (assets.isNotEmpty) {
          notifier.loadFromDatabase(assets);
        }
      } catch (e) {
        Log.business(
          'Riverpod',
          'Failed to load assets from database',
          {'error': e.toString()},
        );
      }
    });
  });

  return notifier;
});

/// Total assets calculation provider
final totalAssetsProvider = Provider<double>((ref) {
  final assets = ref.watch(assetsProvider);
  return assets.fold<double>(0, (sum, asset) => sum + asset.amount);
});

/// Asset count provider
final assetCountProvider = Provider<int>((ref) {
  final assets = ref.watch(assetsProvider);
  return assets.length;
});

// ============================================================================
// Asset Notifier for State Management
// ============================================================================

class AssetsNotifier extends StateNotifier<List<AssetItem>> {
  AssetsNotifier() : super([]);

  /// Add a new asset
  void addAsset(AssetItem asset) {
    state = [...state, asset];
    Log.business(
      'AssetsNotifier',
      'Asset added',
      {'name': asset.name, 'amount': asset.amount},
    );
  }

  /// Remove an asset by ID
  void removeAsset(String assetId) {
    state = state.where((asset) => asset.id != assetId).toList();
    Log.business('AssetsNotifier', 'Asset removed', {'id': assetId});
  }

  /// Update an existing asset
  void updateAsset(AssetItem updatedAsset) {
    state = state
        .map(
          (asset) => asset.id == updatedAsset.id ? updatedAsset : asset,
        )
        .toList();
    Log.business('AssetsNotifier', 'Asset updated', {'id': updatedAsset.id});
  }

  /// Clear all assets
  void clearAssets() {
    state = [];
    Log.business('AssetsNotifier', 'All assets cleared');
  }

  /// Load assets from database
  void loadFromDatabase(List<AssetItem> assets) {
    state = assets;
    Log.business(
      'AssetsNotifier',
      'Loaded assets from database',
      {'count': assets.length},
    );
  }

  /// Load assets from database (async version for future use)
  Future<void> loadFromDatabaseAsync() async {
    // This method can be used if we need async loading in the future
    Log.business('AssetsNotifier', 'Async database loading not implemented');
  }
}

// ============================================================================
// Asset CRUD Service (Simplified)
// ============================================================================

/// Asset CRUD operations provider
final assetCrudProvider = Provider<AssetCrudService>((ref) {
  final assetsNotifier = ref.watch(assetsProvider.notifier);
  return AssetCrudService(assetsNotifier);
});

class AssetCrudService {
  AssetCrudService(this._assetsNotifier);
  final AssetsNotifier _assetsNotifier;

  /// Add a new asset
  Future<void> addAsset(AssetItem asset) async {
    _assetsNotifier.addAsset(asset);
  }

  /// Get a specific asset by ID
  AssetItem? getAssetById(String assetId) {
    final assets = _assetsNotifier.state;
    try {
      return assets.firstWhere((asset) => asset.id == assetId);
    } catch (e) {
      return null;
    }
  }

  /// Export all assets
  List<AssetItem> exportAssets() => _assetsNotifier.state;
}
