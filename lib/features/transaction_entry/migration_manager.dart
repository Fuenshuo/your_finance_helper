import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/transaction_entry_screen.dart';
import '../../legacy/screens/unified_transaction_entry_screen.dart';

/// 迁移阶段枚举
enum MigrationStage {
  /// 完全使用旧架构
  legacyOnly,

  /// A/B测试阶段（部分用户使用新架构）
  abTesting,

  /// 新架构为主，旧架构为备用
  newPrimary,

  /// 完全迁移到新架构
  migrated,
}

/// 功能开关状态
class MigrationFlags {
  final bool useNewTransactionEntry;
  final bool useNewValidation;
  final bool useNewPersistence;
  final bool useNewPerformanceMonitoring;
  final MigrationStage currentStage;

  const MigrationFlags({
    this.useNewTransactionEntry = true, // 默认使用新架构
    this.useNewValidation = true,
    this.useNewPersistence = true,
    this.useNewPerformanceMonitoring = true,
    this.currentStage = MigrationStage.migrated, // 默认完全迁移状态
  });

  MigrationFlags copyWith({
    bool? useNewTransactionEntry,
    bool? useNewValidation,
    bool? useNewPersistence,
    bool? useNewPerformanceMonitoring,
    MigrationStage? currentStage,
  }) {
    return MigrationFlags(
      useNewTransactionEntry: useNewTransactionEntry ?? this.useNewTransactionEntry,
      useNewValidation: useNewValidation ?? this.useNewValidation,
      useNewPersistence: useNewPersistence ?? this.useNewPersistence,
      useNewPerformanceMonitoring: useNewPerformanceMonitoring ?? this.useNewPerformanceMonitoring,
      currentStage: currentStage ?? this.currentStage,
    );
  }

  /// 根据阶段自动配置功能开关
  factory MigrationFlags.forStage(MigrationStage stage) {
    switch (stage) {
      case MigrationStage.legacyOnly:
        return const MigrationFlags(
          currentStage: MigrationStage.legacyOnly,
        );
      case MigrationStage.abTesting:
        return const MigrationFlags(
          useNewTransactionEntry: true, // 50%用户使用新架构
          useNewValidation: true,
          useNewPersistence: false, // 保持数据一致性
          useNewPerformanceMonitoring: true,
          currentStage: MigrationStage.abTesting,
        );
      case MigrationStage.newPrimary:
        return const MigrationFlags(
          useNewTransactionEntry: true,
          useNewValidation: true,
          useNewPersistence: true,
          useNewPerformanceMonitoring: true,
          currentStage: MigrationStage.newPrimary,
        );
      case MigrationStage.migrated:
        return const MigrationFlags(
          useNewTransactionEntry: true, // 完全使用新架构
          useNewValidation: true,
          useNewPersistence: true,
          useNewPerformanceMonitoring: true,
          currentStage: MigrationStage.migrated,
        );
    }
  }
}

/// 迁移管理器Provider
class MigrationManager extends StateNotifier<MigrationFlags> {
  static const String _prefsKey = 'transaction_entry_migration_flags';
  SharedPreferences? _prefs;

  MigrationManager._(this._prefs) : super(const MigrationFlags()) {
    if (_prefs != null) {
      _loadFlags();
    }
  }

  static Future<MigrationManager> _create() async {
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (e) {
      // 如果SharedPreferences初始化失败，使用默认状态
      debugPrint('Failed to initialize SharedPreferences: $e');
    }
    return MigrationManager._(prefs);
  }

  /// 加载保存的功能开关状态
  Future<void> _loadFlags() async {
    final stageIndex = _prefs.getInt('${_prefsKey}_stage') ?? 0;
    final stage = MigrationStage.values[stageIndex];

    state = MigrationFlags.forStage(stage);

    // 允许手动覆盖个别开关（用于调试）
    final manualOverrides = _prefs.getString('${_prefsKey}_overrides');
    if (manualOverrides != null) {
      // 解析手动覆盖设置
      _applyManualOverrides(manualOverrides);
    }
  }

  /// 保存功能开关状态
  Future<void> _saveFlags() async {
    await _prefs.setInt('${_prefsKey}_stage', state.currentStage.index);
    await _prefs.setString('${_prefsKey}_overrides', _serializeOverrides());
  }

  /// 切换到下一个迁移阶段
  Future<void> advanceStage() async {
    final nextStageIndex = (state.currentStage.index + 1) % MigrationStage.values.length;
    final nextStage = MigrationStage.values[nextStageIndex];

    state = MigrationFlags.forStage(nextStage);
    await _saveFlags();

    debugPrint('迁移到阶段: ${nextStage.name}');
  }

  /// 手动设置功能开关（调试用）
  Future<void> setFlag({
    bool? useNewTransactionEntry,
    bool? useNewValidation,
    bool? useNewPersistence,
    bool? useNewPerformanceMonitoring,
  }) async {
    state = state.copyWith(
      useNewTransactionEntry: useNewTransactionEntry,
      useNewValidation: useNewValidation,
      useNewPersistence: useNewPersistence,
      useNewPerformanceMonitoring: useNewPerformanceMonitoring,
    );
    await _saveFlags();
  }

  /// 重置为默认状态
  Future<void> reset() async {
    state = const MigrationFlags();
    await _saveFlags();
  }

  /// 获取当前使用的交易录入组件
  Widget getTransactionEntryWidget() {
    return state.useNewTransactionEntry
        ? const TransactionEntryScreenPage()
        : const UnifiedTransactionEntryScreen();
  }

  /// 检查是否在A/B测试模式
  bool get isInABTesting => state.currentStage == MigrationStage.abTesting;

  /// 获取迁移进度百分比
  double get migrationProgress {
    switch (state.currentStage) {
      case MigrationStage.legacyOnly:
        return 0.0;
      case MigrationStage.abTesting:
        return 0.25;
      case MigrationStage.newPrimary:
        return 0.75;
      case MigrationStage.migrated:
        return 1.0;
    }
  }

  String _serializeOverrides() {
    // 简化的序列化实现
    return '';
  }

  void _applyManualOverrides(String overrides) {
    // 简化的反序列化实现
  }
}

/// MigrationManager Provider
final migrationManagerProvider = StateNotifierProvider<MigrationManager, MigrationFlags>((ref) {
  // 初始化时直接创建MigrationManager，延迟加载SharedPreferences
  return MigrationManager._create();
});

/// 创建MigrationManager的Provider
final migrationManagerInitializer = FutureProvider<MigrationManager>((ref) async {
  return MigrationManager._create();
});

/// 便捷的交易录入组件Provider
final transactionEntryWidgetProvider = Provider<Widget>((ref) {
  final migrationFlags = ref.watch(migrationManagerProvider);
  return migrationFlags.useNewTransactionEntry
      ? const TransactionEntryScreenPage()
      : const UnifiedTransactionEntryScreen();
});

/// 迁移状态监控Provider
final migrationStatusProvider = Provider<Map<String, dynamic>>((ref) {
  final flags = ref.watch(migrationManagerProvider);
  final manager = ref.watch(migrationManagerProvider.notifier);

  return {
    'currentStage': flags.currentStage.name,
    'migrationProgress': manager.migrationProgress,
    'flags': {
      'useNewTransactionEntry': flags.useNewTransactionEntry,
      'useNewValidation': flags.useNewValidation,
      'useNewPersistence': flags.useNewPersistence,
      'useNewPerformanceMonitoring': flags.useNewPerformanceMonitoring,
    },
    'isInABTesting': manager.isInABTesting,
  };
});
