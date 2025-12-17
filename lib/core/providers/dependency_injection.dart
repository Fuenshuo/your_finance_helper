import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_finance_flutter/core/services/ai/ai_service_factory.dart';
import 'package:your_finance_flutter/core/services/asset_history_service.dart';
import 'package:your_finance_flutter/core/services/base_service.dart';
import 'package:your_finance_flutter/core/services/drift_database_service.dart';
import 'package:your_finance_flutter/core/services/hybrid_storage_service.dart';
import 'package:your_finance_flutter/core/services/storage_service.dart';
import 'package:your_finance_flutter/features/insights/providers/insights_provider.dart';

/// 依赖注入配置 - 统一管理所有服务的依赖关系
class DependencyInjection {
  /// 获取所有提供者的列表，用于应用初始化
  static List<Override> getOverrides() => [
        // 基础设施服务
        _storageServiceProvider
            .overrideWith((ref) => throw UnimplementedError()),
        _hybridStorageServiceProvider
            .overrideWith((ref) => throw UnimplementedError()),
        _driftDatabaseServiceProvider
            .overrideWith((ref) => throw UnimplementedError()),

        // 业务服务
        _assetHistoryServiceProvider
            .overrideWith((ref) => throw UnimplementedError()),
        _insightsProviderProvider
            .overrideWith((ref) => throw UnimplementedError()),

        // AI服务
        _aiServiceFactoryProvider.overrideWithValue(aiServiceFactory),
      ];

  /// 异步初始化所有服务的提供者
  static Future<List<Override>> getAsyncOverrides() async {
    final overrides = <Override>[];

    try {
      // 初始化基础设施服务
      final storageService = await StorageService.getInstance();
      final hybridStorageService = await HybridStorageService.getInstance();
      final driftService = await DriftDatabaseService.getInstance();

      // 初始化业务服务
      final assetHistoryService = await AssetHistoryService.getInstance();

      overrides.addAll([
        _storageServiceProvider.overrideWithValue(storageService),
        _hybridStorageServiceProvider.overrideWithValue(hybridStorageService),
        _driftDatabaseServiceProvider.overrideWithValue(driftService),
        _assetHistoryServiceProvider.overrideWithValue(assetHistoryService),
      ]);

      // 注册到服务管理器
      final serviceManager = ServiceManager.instance;
      serviceManager.registerService('StorageService', storageService);
      serviceManager.registerService(
        'HybridStorageService',
        hybridStorageService,
      );
      serviceManager.registerService('DriftDatabaseService', driftService);
      serviceManager.registerService(
        'AssetHistoryService',
        assetHistoryService,
      );
    } catch (e) {
      // 如果异步初始化失败，提供默认的错误处理
      overrides.addAll([
        _storageServiceProvider.overrideWith(
          (ref) => throw StateError('StorageService 初始化失败: $e'),
        ),
        _hybridStorageServiceProvider.overrideWith(
          (ref) => throw StateError('HybridStorageService 初始化失败: $e'),
        ),
        _driftDatabaseServiceProvider.overrideWith(
          (ref) => throw StateError('DriftDatabaseService 初始化失败: $e'),
        ),
        _assetHistoryServiceProvider.overrideWith(
          (ref) => throw StateError('AssetHistoryService 初始化失败: $e'),
        ),
      ]);
    }

    return overrides;
  }

  /// 健康检查 - 验证所有依赖是否正确注入
  static Future<Map<String, bool>> healthCheck(
    ProviderContainer container,
  ) async {
    final results = <String, bool>{};

    try {
      // 检查基础设施服务
      container.read(_storageServiceProvider);
      results['StorageService'] = true;
    } catch (e) {
      results['StorageService'] = false;
    }

    try {
      container.read(_hybridStorageServiceProvider);
      results['HybridStorageService'] = true;
    } catch (e) {
      results['HybridStorageService'] = false;
    }

    try {
      container.read(_driftDatabaseServiceProvider);
      results['DriftDatabaseService'] = true;
    } catch (e) {
      results['DriftDatabaseService'] = false;
    }

    try {
      container.read(_assetHistoryServiceProvider);
      results['AssetHistoryService'] = true;
    } catch (e) {
      results['AssetHistoryService'] = false;
    }

    try {
      container.read(_aiServiceFactoryProvider);
      results['AiServiceFactory'] = true;
    } catch (e) {
      results['AiServiceFactory'] = false;
    }

    return results;
  }
}

// ============================================================================
// 基础设施服务提供者
// ============================================================================

/// StorageService 提供者
final _storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError(
    'StorageService must be provided via DependencyInjection.getAsyncOverrides()',
  );
});

/// HybridStorageService 提供者
final _hybridStorageServiceProvider = Provider<HybridStorageService>((ref) {
  throw UnimplementedError(
    'HybridStorageService must be provided via DependencyInjection.getAsyncOverrides()',
  );
});

/// DriftDatabaseService 提供者
final _driftDatabaseServiceProvider = Provider<DriftDatabaseService>((ref) {
  throw UnimplementedError(
    'DriftDatabaseService must be provided via DependencyInjection.getAsyncOverrides()',
  );
});

// ============================================================================
// 业务服务提供者
// ============================================================================

/// AssetHistoryService 提供者
final _assetHistoryServiceProvider = Provider<AssetHistoryService>((ref) {
  throw UnimplementedError(
    'AssetHistoryService must be provided via DependencyInjection.getAsyncOverrides()',
  );
});

/// InsightsProvider 提供者
final _insightsProviderProvider = Provider<InsightsProvider?>((ref) {
  // InsightsProvider 可能为null，依赖于功能标志
  return null;
});

// ============================================================================
// AI服务提供者
// ============================================================================

/// AiServiceFactory 提供者
final _aiServiceFactoryProvider =
    Provider<AiServiceFactory>((ref) => aiServiceFactory);

// ============================================================================
// 组合提供者 - 组合多个服务的功能
// ============================================================================

/// 资产相关的组合服务提供者
final assetServicesProvider = Provider<AssetServices>(
  (ref) => AssetServices(
    storage: ref.watch(_hybridStorageServiceProvider),
    history: ref.watch(_assetHistoryServiceProvider),
    database: ref.watch(_driftDatabaseServiceProvider),
  ),
);

/// 资产相关的组合服务类
class AssetServices {
  const AssetServices({
    required this.storage,
    required this.history,
    required this.database,
  });

  final HybridStorageService storage;
  final AssetHistoryService history;
  final DriftDatabaseService database;

  /// 统一的资产健康检查
  Future<Map<String, bool>> healthCheck() async {
    final results = <String, bool>{};

    try {
      await storage.getAssets();
      results['storage'] = true;
    } catch (e) {
      results['storage'] = false;
    }

    try {
      await history.getAssetHistory();
      results['history'] = true;
    } catch (e) {
      results['history'] = false;
    }

    try {
      await database.getAssets();
      results['database'] = true;
    } catch (e) {
      results['database'] = false;
    }

    return results;
  }
}

/// 预算相关的组合服务提供者
final budgetServicesProvider = Provider<BudgetServices>(
  (ref) => BudgetServices(
    storage: ref.watch(_storageServiceProvider),
  ),
);

/// 预算相关的组合服务类
class BudgetServices {
  const BudgetServices({
    required this.storage,
  });

  final StorageService storage;

  /// 预算数据健康检查
  Future<Map<String, bool>> healthCheck() async {
    final results = <String, bool>{};

    try {
      await storage.loadEnvelopeBudgets();
      results['envelopeBudgets'] = true;
    } catch (e) {
      results['envelopeBudgets'] = false;
    }

    try {
      await storage.loadZeroBasedBudgets();
      results['zeroBasedBudgets'] = true;
    } catch (e) {
      results['zeroBasedBudgets'] = false;
    }

    try {
      await storage.loadSalaryIncomes();
      results['salaryIncomes'] = true;
    } catch (e) {
      results['salaryIncomes'] = false;
    }

    return results;
  }
}

// ============================================================================
// 环境特定的提供者配置
// ============================================================================

/// 开发环境配置
class DevelopmentDependencyInjection extends DependencyInjection {
  static List<Override> getOverrides() => [
        ...DependencyInjection.getOverrides(),
        // 开发环境特定的覆盖
      ];
}

/// 测试环境配置
class TestDependencyInjection extends DependencyInjection {
  static List<Override> getOverrides() => [
        ...DependencyInjection.getOverrides(),
        // 测试环境特定的mock覆盖
      ];
}

/// 生产环境配置
class ProductionDependencyInjection extends DependencyInjection {
  static List<Override> getOverrides() => [
        ...DependencyInjection.getOverrides(),
        // 生产环境特定的覆盖
      ];
}

// ============================================================================
// 提供者暴露给外部使用
// ============================================================================

/// 导出核心服务提供者供外部使用
final storageServiceProvider = _storageServiceProvider;
final hybridStorageServiceProvider = _hybridStorageServiceProvider;
final driftDatabaseServiceProvider = _driftDatabaseServiceProvider;
final assetHistoryServiceProvider = _assetHistoryServiceProvider;
final insightsProviderProvider = _insightsProviderProvider;
final aiServiceFactoryProvider = _aiServiceFactoryProvider;
