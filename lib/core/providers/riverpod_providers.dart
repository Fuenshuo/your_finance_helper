// ============================================================================
// Riverpod Providers for Asset Management (Working Demo Version)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_finance_flutter/core/models/asset_item.dart';
import 'package:your_finance_flutter/core/services/drift_database_service.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';

// ============================================================================
// Database Service Provider
// ============================================================================

/// Initialized database service provider
final databaseServiceProvider = FutureProvider<DriftDatabaseService>((ref) async {
  return DriftDatabaseService.getInstance();
});

// ============================================================================
// Simple Asset Management (Working Version)
// ============================================================================

/// Simple asset list provider using in-memory list for demo
final assetsProvider = StateNotifierProvider<AssetsNotifier, List<AssetItem>>((ref) {
  return AssetsNotifier();
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
    Log.business('AssetsNotifier', 'Asset added', {'name': asset.name, 'amount': asset.amount});
  }

  /// Remove an asset by ID
  void removeAsset(String assetId) {
    state = state.where((asset) => asset.id != assetId).toList();
    Log.business('AssetsNotifier', 'Asset removed', {'id': assetId});
  }

  /// Update an existing asset
  void updateAsset(AssetItem updatedAsset) {
    state = state.map((asset) =>
      asset.id == updatedAsset.id ? updatedAsset : asset
    ).toList();
    Log.business('AssetsNotifier', 'Asset updated', {'id': updatedAsset.id});
  }

  /// Clear all assets
  void clearAssets() {
    state = [];
    Log.business('AssetsNotifier', 'All assets cleared');
  }

  /// Load assets from database (for future integration)
  Future<void> loadFromDatabase() async {
    // TODO: Implement database loading
    Log.business('AssetsNotifier', 'Load from database called (not implemented yet)');
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
  final AssetsNotifier _assetsNotifier;

  AssetCrudService(this._assetsNotifier);

  /// Add a new asset
  Future<void> addAsset(AssetItem asset) async {
    _assetsNotifier.addAsset(asset);
  }

  /// Get a specific asset by ID
  AssetItem? getAssetById(String assetId) {
    final assets = _assetsNotifier.state;
    return assets.firstWhere(
      (asset) => asset.id == assetId,
      orElse: () => null as AssetItem,
    );
  }

  /// Export all assets
  List<AssetItem> exportAssets() {
    return _assetsNotifier.state;
  }
}


