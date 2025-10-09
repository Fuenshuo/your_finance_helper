import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';

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
        print('✅ 数据已是最新版本 v$currentVersion');
        return;
      }

      print('🔄 开始数据迁移: v$currentVersion -> v$_currentVersion');

      // 执行迁移逻辑
      await _performMigrations(currentVersion);

      // 更新迁移版本
      await _setCurrentMigrationVersion(_currentVersion);
      print('✅ 数据迁移完成');
    } catch (e) {
      print('❌ 数据迁移失败: $e');
      // 迁移失败不应该阻止应用启动
    }
  }

  /// 执行数据迁移
  static Future<void> runMigrations({
    required AccountProvider accountProvider,
    required TransactionProvider transactionProvider,
  }) async {
    print('🔄 执行账户余额到交易的迁移...');

    // 执行账户余额到交易的迁移
    try {
      await accountProvider
          .migrateAccountBalancesToTransactions(transactionProvider);
      print('✅ 账户余额迁移完成');
    } catch (e) {
      print('❌ 账户余额迁移失败: $e');
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
      print('📊 执行 v4 迁移: 账户余额到交易迁移');
      // 这个迁移将在Provider初始化后通过 runMigrations 执行
    }
  }

  /// 强制重新执行数据迁移 (开发者模式专用)
  Future<void> forceReMigration() async {
    print('🔄 强制重新执行数据迁移...');
    try {
      // 重置迁移版本为0
      await _setCurrentMigrationVersion(0);
      print('✅ 迁移版本已重置，将在下次应用启动时重新执行迁移');
    } catch (e) {
      print('❌ 强制重新迁移失败: $e');
      rethrow;
    }
  }
}
