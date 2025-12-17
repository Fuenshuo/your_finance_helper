import 'package:drift/drift.dart';
import 'package:your_finance_flutter/core/database/app_database.dart' as db;
import 'package:your_finance_flutter/core/models/asset_item.dart';
import 'package:your_finance_flutter/core/services/base_service.dart';

/// Drift database service - provides type-safe database operations
/// Acts as a bridge between the existing app logic and the new Drift database
class DriftDatabaseService extends BaseService {
  DriftDatabaseService._();
  static DriftDatabaseService? _instance;
  late final db.AppDatabase _database;

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
  String get serviceName => 'DriftDatabaseService';

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    try {
      // Database initialization is already done in getInstance()
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
      // Close and reopen database
      await _database.close();
      // Re-initialize would be done by getInstance()
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
    await _database.close();
    _isInitialized = false;
  }

  @override
  Future<bool> healthCheck() async {
    try {
      // Simple health check - try to query the database
      await _database.getAllAssets();
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
        'databaseSchemaVersion': _database.schemaVersion,
        'lastError': lastError,
      };

  static Future<DriftDatabaseService> getInstance() async {
    if (_instance == null) {
      _instance = DriftDatabaseService._();
      await _instance!._initialize();
    }
    return _instance!;
  }

  Future<void> _initialize() async {
    _database = db.AppDatabase();
    _database.schemaVersion;
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
