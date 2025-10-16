import 'package:drift/drift.dart';
import 'package:your_finance_flutter/core/database/app_database.dart' as db;
import 'package:your_finance_flutter/core/models/asset_item.dart';

/// Drift database service - provides type-safe database operations
/// Acts as a bridge between the existing app logic and the new Drift database
class DriftDatabaseService {
  DriftDatabaseService._();
  static DriftDatabaseService? _instance;
  late final db.AppDatabase _database;

  static Future<DriftDatabaseService> getInstance() async {
    if (_instance == null) {
      _instance = DriftDatabaseService._();
      await _instance!._initialize();
    }
    return _instance!;
  }

  Future<void> _initialize() async {
    _database = db.AppDatabase();
    // Database is lazy-loaded, so no explicit initialization needed
  }

  // ============================================================================
  // Asset Operations (Simplified for Demo)
  // ============================================================================

  Future<List<AssetItem>> getAssets() async {
    final assets = await _database.getAllAssets();
    return assets.map(_assetFromDrift).toList();
  }

  Future<List<AssetItem>> getAllAssets() async => getAssets();

  Future<AssetItem?> getAsset(String id) async {
    final asset = await _database.getAssetById(id);
    return asset != null ? _assetFromDrift(asset) : null;
  }

  Future<AssetItem?> getAssetById(String id) async => getAsset(id);

  Future<void> saveAsset(AssetItem asset) async {
    final companion = _assetToDrift(asset);
    await _database.insertAsset(companion);
  }

  Future<void> insertAsset(AssetItem asset) async => saveAsset(asset);

  Future<void> updateAsset(AssetItem asset) async {
    final companion = _assetToDrift(asset);
    await _database.updateAsset(companion);
  }

  Future<void> deleteAsset(String id) async {
    await _database.deleteAsset(id);
  }

  /// Watch assets with reactive streams
  Stream<List<AssetItem>> watchAssets() => _database.watchAllAssets().map(
        (assets) => assets.map(_assetFromDrift).toList(),
      );

  // ============================================================================
  // Conversion Methods - Assets (Simplified)
  // ============================================================================

  AssetItem _assetFromDrift(db.Asset asset) => AssetItem(
        id: asset.id,
        name: asset.name,
        amount: asset.amount,
        category: AssetCategory.values.firstWhere(
          (e) => e.name == asset.category,
          orElse: () => AssetCategory.liquidAssets,
        ),
        subCategory: asset.subCategory,
        creationDate: asset.creationDate,
        updateDate: asset.updateDate,
      );

  db.AssetsCompanion _assetToDrift(AssetItem asset) => db.AssetsCompanion(
        id: Value(asset.id),
        name: Value(asset.name),
        amount: Value(asset.amount),
        category: Value(asset.category.name),
        subCategory: Value(asset.subCategory),
        creationDate: Value(asset.creationDate),
        updateDate: Value(asset.updateDate),
      );
}

extension DriftBulkUpserts on DriftDatabaseService {
  /// Idempotent bulk upsert for assets.
  /// If a row with the same id exists, it will be replaced.
  Future<void> upsertAssets(List<AssetItem> items) async {
    if (items.isEmpty) return;
    await _database.batch((b) {
      b.insertAllOnConflictUpdate(
        _database.assets,
        items.map(_assetToDrift).toList(),
      );
    });
  }
}
