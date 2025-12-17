import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/core/services/drift_database_service.dart';
import 'package:your_finance_flutter/core/services/legacy_import/adapters/assets_adapter.dart';
import 'package:your_finance_flutter/core/services/legacy_import/file_locator.dart';
import 'package:your_finance_flutter/core/services/legacy_import/import_report.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';

/// 数据迁移服务
/// 负责处理应用版本升级时的数据迁移工作
class DataMigrationService {
  DataMigrationService._();
  static const String _migrationVersionKey = 'data_migration_version';
  static const int _currentVersion = 4; // 当前数据版本

  static DataMigrationService? _instance;
  SharedPreferences? _prefs;

  static Future<DataMigrationService> getInstance() async {
    _instance ??= DataMigrationService._();
    _instance!._prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  /// 检查并执行数据迁移
  Future<void> checkAndMigrateData() async {
    try {
      final currentVersion = await _getCurrentMigrationVersion();

      if (currentVersion >= _currentVersion) {
        // Even if we're at the latest version, check if we need to import legacy data
        // This handles the case where the user manually triggered import
        await _importLegacyJsonIfPresent();
        return;
      }

      // 执行迁移逻辑
      await _performMigrations(currentVersion);

      // 更新迁移版本
      await _setCurrentMigrationVersion(_currentVersion);
    } catch (e) {
      Logger.debug('❌ 数据迁移失败: $e');
      // 迁移失败不应该阻止应用启动
    }
  }

  /// 执行数据迁移
  static Future<void> runMigrations({
    required AccountProvider accountProvider,
    required TransactionProvider transactionProvider,
  }) async {
    Logger.debug('🔄 执行账户余额到交易的迁移...');

    // 执行账户余额到交易的迁移
    try {
      await accountProvider
          .migrateAccountBalancesToTransactions(transactionProvider);
      Logger.debug('✅ 账户余额迁移完成');
    } catch (e) {
      Logger.debug('❌ 账户余额迁移失败: $e');
      // 迁移失败不应该阻止应用启动
    }
  }

  Future<int> _getCurrentMigrationVersion() async =>
      _prefs?.getInt(_migrationVersionKey) ?? 0;

  Future<void> _setCurrentMigrationVersion(int version) async {
    await _prefs?.setInt(_migrationVersionKey, version);
  }

  Future<void> _performMigrations(int fromVersion) async {
    // 根据版本执行不同的迁移逻辑
    if (fromVersion < 4) {
      Logger.debug('📊 执行 v4 迁移: 账户余额到交易迁移');
      // 这个迁移将在Provider初始化后通过 runMigrations 执行
    }

    // New: Legacy JSON → Drift import (idempotent)
    await _importLegacyJsonIfPresent();
  }

  /// 强制重新执行数据迁移 (开发者模式专用)
  Future<void> forceReMigration() async {
    Logger.debug('🔄 强制重新执行数据迁移...');
    try {
      // 重置迁移版本为0
      await _setCurrentMigrationVersion(0);
      Logger.debug('✅ 迁移版本已重置，将在下次应用启动时重新执行迁移');
    } catch (e) {
      Logger.debug('❌ 强制重新迁移失败: $e');
      rethrow;
    }
  }

  /// 手动导入遗留JSON数据 (开发者模式专用)
  Future<ImportReport> importLegacyData({bool dryRun = true}) async {
    Logger.debug('🔄 开始${dryRun ? '预览' : '导入'}遗留数据...');
    final report = ImportReport();
    final backupDir = await LegacyFileLocator.createBackupDir();

    // Assets
    final assetsFile = await LegacyFileLocator.tryGetFile('assets.json');
    if (assetsFile != null) {
      Logger.debug('📁 发现资产数据文件: ${assetsFile.path}');
      await _backupFile(assetsFile, backupDir);
      final items = await LegacyAssetsAdapter.parse(assetsFile);
      report.modules['assets']!.total = items.length;
      Logger.debug('📊 解析出 ${items.length} 条资产记录');

      if (!dryRun) {
        try {
          final db = await DriftDatabaseService.getInstance();
          await db.upsertAssets(items);
          report.modules['assets']!.imported = items.length;
          Logger.debug('✅ 成功导入 ${items.length} 条资产记录');
        } catch (e) {
          report.modules['assets']!.failed = items.length;
          report.errors.add('Assets import failed: $e');
          Logger.debug('❌ 资产导入失败: $e');
        }
      }
    } else {
      Logger.debug('⚠️ 未找到资产数据文件');
    }

    // Save report
    await _saveReport(report);
    Logger.debug('📄 ${dryRun ? '预览' : '导入'}报告已保存');

    return report;
  }

  // ---------------------------------------------------------------------------
  // Legacy JSON Import Orchestration
  // ---------------------------------------------------------------------------
  Future<void> _importLegacyJsonIfPresent({bool dryRun = false}) async {
    final report = ImportReport();
    final backupDir = await LegacyFileLocator.createBackupDir();

    Logger.debug('🔍 开始扫描遗留数据...');

    // Import from SharedPreferences (current app data)
    await _importFromSharedPreferences(report, dryRun);

    // Import from legacy JSON files if they exist
    await _importFromLegacyFiles(report, backupDir, dryRun);

    Logger.debug('📋 遗留数据导入完成');
    Logger.debug('📄 导入报告已保存');

    // Save report
    await _saveReport(report);
  }

  /// Import data from SharedPreferences (current app storage)
  Future<void> _importFromSharedPreferences(
    ImportReport report,
    bool dryRun,
  ) async {
    Logger.debug('📱 检查SharedPreferences数据...');

    // Assets from SharedPreferences
    final assetsJson = _prefs!.getString('assets_data');
    if (assetsJson != null && assetsJson.isNotEmpty) {
      Logger.debug('💾 发现SharedPreferences资产数据');
      final items =
          await LegacyAssetsAdapter.parseSharedPreferences(assetsJson);
      report.modules['assets']!.total += items.length;
      Logger.debug('📊 SharedPreferences资产记录: ${items.length}');

      if (!dryRun) {
        try {
          final db = await DriftDatabaseService.getInstance();
          await db.upsertAssets(items);
          report.modules['assets']!.imported += items.length;
          Logger.debug('✅ SharedPreferences资产数据导入成功');
        } catch (e) {
          report.modules['assets']!.failed += items.length;
          report.errors.add('SharedPreferences assets import failed: $e');
          Logger.debug('❌ SharedPreferences资产数据导入失败: $e');
        }
      }
    }
  }

  /// Import data from legacy JSON files
  Future<void> _importFromLegacyFiles(
    ImportReport report,
    Directory backupDir,
    bool dryRun,
  ) async {
    Logger.debug('📁 检查遗留JSON文件...');

    // Assets from JSON files
    final assetsFile = await LegacyFileLocator.tryGetFile('assets.json');
    if (assetsFile != null) {
      Logger.debug('📁 发现资产JSON文件: ${assetsFile.path}');
      await _backupFile(assetsFile, backupDir);
      final items = await LegacyAssetsAdapter.parse(assetsFile);
      report.modules['assets']!.total += items.length;
      Logger.debug('📊 JSON文件资产记录: ${items.length}');

      if (!dryRun) {
        try {
          final db = await DriftDatabaseService.getInstance();
          await db.upsertAssets(items);
          report.modules['assets']!.imported += items.length;
          Logger.debug('✅ JSON文件资产数据导入成功');
        } catch (e) {
          report.modules['assets']!.failed += items.length;
          report.errors.add('JSON assets import failed: $e');
          Logger.debug('❌ JSON文件资产数据导入失败: $e');
        }
      }
    }
  }

  Future<void> _backupFile(File src, Directory backupDir) async {
    try {
      final name = p.basename(src.path);
      await src.copy(p.join(backupDir.path, name));
    } catch (_) {}
  }

  Future<void> _saveReport(ImportReport report) async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final out = File(p.join(docs.path, 'migration_report.json'));
      await out.writeAsString(
        const JsonEncoder.withIndent('  ').convert(report.toJson()),
      );
    } catch (_) {}
  }
}
