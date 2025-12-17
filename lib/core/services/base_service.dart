import 'package:flutter/foundation.dart';

/// 基础服务接口 - 定义所有服务的通用行为
abstract class BaseService {
  /// 服务是否已初始化
  bool get isInitialized;

  /// 服务是否正在加载
  bool get isLoading;

  /// 最后一次错误信息
  String? get lastError;

  /// 服务名称（用于日志和调试）
  String get serviceName;

  /// 初始化服务
  Future<void> initialize();

  /// 重置服务状态
  Future<void> reset();

  /// 清理资源
  Future<void> dispose();

  /// 验证服务健康状态
  Future<bool> healthCheck();

  /// 获取服务统计信息
  Map<String, dynamic> getStats();
}

/// 服务初始化异常
class ServiceInitializationException implements Exception {
  const ServiceInitializationException(this.message, {this.cause});

  final String message;
  final dynamic cause;

  @override
  String toString() =>
      'ServiceInitializationException: $message${cause != null ? ' (cause: $cause)' : ''}';
}

/// 服务操作异常
class ServiceOperationException implements Exception {
  const ServiceOperationException(this.message, {this.operation, this.cause});

  final String message;
  final String? operation;
  final dynamic cause;

  @override
  String toString() =>
      'ServiceOperationException: $message${operation != null ? ' (operation: $operation)' : ''}${cause != null ? ' (cause: $cause)' : ''}';
}

/// 服务状态枚举
enum ServiceState {
  uninitialized,
  initializing,
  initialized,
  error,
  disposed,
}

/// 服务配置基类
abstract class ServiceConfig {
  const ServiceConfig();

  /// 验证配置是否有效
  bool get isValid;

  /// 获取配置的字符串表示（用于日志，不包含敏感信息）
  String get maskedConfig;

  /// 创建配置副本
  ServiceConfig copyWith();
}

/// 带状态管理的服务基类
abstract class StatefulService implements BaseService {
  @override
  bool get isInitialized => _state == ServiceState.initialized;

  @override
  bool get isLoading => _state == ServiceState.initializing;

  ServiceState _state = ServiceState.uninitialized;
  String? _lastError;

  @override
  String? get lastError => _lastError;

  /// 当前服务状态
  ServiceState get state => _state;

  /// 设置服务状态
  @protected
  void setState(ServiceState newState, {String? error}) {
    _state = newState;
    if (error != null) {
      _lastError = error;
    } else if (newState != ServiceState.error) {
      _lastError = null;
    }
  }

  /// 执行异步操作，自动处理状态和错误
  @protected
  Future<T> executeOperation<T>(
    String operationName,
    Future<T> Function() operation, {
    T? defaultValue,
  }) async {
    try {
      setState(ServiceState.initializing);
      final result = await operation();
      setState(ServiceState.initialized);
      return result;
    } catch (e) {
      final error = ServiceOperationException(
        'Operation failed: $operationName',
        operation: operationName,
        cause: e,
      );
      setState(ServiceState.error, error: error.toString());
      if (defaultValue != null) {
        return defaultValue;
      }
      rethrow;
    }
  }

  /// 执行同步操作，自动处理状态和错误
  @protected
  T executeSyncOperation<T>(
    String operationName,
    T Function() operation, {
    T? defaultValue,
  }) {
    try {
      final result = operation();
      return result;
    } catch (e) {
      final error = ServiceOperationException(
        'Sync operation failed: $operationName',
        operation: operationName,
        cause: e,
      );
      setState(ServiceState.error, error: error.toString());
      if (defaultValue != null) {
        return defaultValue;
      }
      rethrow;
    }
  }

  @override
  Future<void> reset() async {
    setState(ServiceState.uninitialized);
    _lastError = null;
  }

  @override
  Future<void> dispose() async {
    setState(ServiceState.disposed);
    _lastError = null;
  }

  @override
  Future<bool> healthCheck() async {
    return _state == ServiceState.initialized && _lastError == null;
  }

  @override
  Map<String, dynamic> getStats() {
    return {
      'state': _state.name,
      'lastError': _lastError,
    };
  }
}

/// 服务管理器 - 统一管理所有服务的生命周期
class ServiceManager {
  ServiceManager._();
  static final ServiceManager _instance = ServiceManager._();
  static ServiceManager get instance => _instance;

  final Map<String, BaseService> _services = {};
  final Map<String, ServiceState> _serviceStates = {};

  /// 注册服务
  void registerService(String name, BaseService service) {
    _services[name] = service;
    _serviceStates[name] = ServiceState.uninitialized;
  }

  /// 获取服务
  T? getService<T extends BaseService>(String name) {
    return _services[name] as T?;
  }

  /// 初始化所有服务
  Future<void> initializeAllServices() async {
    debugPrint('🔄 开始初始化所有服务...');

    final initFutures = <Future<void>>[];
    for (final entry in _services.entries) {
      initFutures.add(_initializeService(entry.key, entry.value));
    }

    await Future.wait(initFutures);
    debugPrint('✅ 所有服务初始化完成');
  }

  Future<void> _initializeService(String name, BaseService service) async {
    try {
      _serviceStates[name] = ServiceState.initializing;
      await service.initialize();
      _serviceStates[name] = ServiceState.initialized;
      debugPrint('✅ 服务 $name 初始化成功');
    } catch (e) {
      _serviceStates[name] = ServiceState.error;
      debugPrint('❌ 服务 $name 初始化失败: $e');
      rethrow;
    }
  }

  /// 获取所有服务状态
  Map<String, ServiceState> getAllServiceStates() =>
      Map.unmodifiable(_serviceStates);

  /// 获取服务统计信息
  Map<String, dynamic> getServiceStats() {
    final stats = <String, dynamic>{};
    for (final entry in _services.entries) {
      stats[entry.key] = entry.value.getStats();
    }
    return stats;
  }

  /// 健康检查 - 检查所有服务是否正常
  Future<Map<String, bool>> healthCheck() async {
    final results = <String, bool>{};
    for (final entry in _services.entries) {
      try {
        results[entry.key] = await entry.value.healthCheck();
      } catch (e) {
        results[entry.key] = false;
        debugPrint('❌ 服务 ${entry.key} 健康检查失败: $e');
      }
    }
    return results;
  }

  /// 清理所有服务
  Future<void> disposeAllServices() async {
    debugPrint('🧹 开始清理所有服务...');

    final disposeFutures = <Future<void>>[];
    for (final service in _services.values) {
      disposeFutures.add(service.dispose());
    }

    await Future.wait(disposeFutures);
    _services.clear();
    _serviceStates.clear();

    debugPrint('✅ 所有服务已清理');
  }
}

/// 服务配置提供者接口
abstract class ServiceConfigProvider<T extends ServiceConfig> {
  /// 获取服务配置
  Future<T> getConfig();

  /// 保存服务配置
  Future<void> saveConfig(T config);

  /// 重置为默认配置
  Future<T> resetToDefault();
}

/// 服务工厂接口
abstract class ServiceFactory<T extends BaseService, C extends ServiceConfig> {
  /// 根据配置创建服务实例
  T createService(C config);

  /// 获取服务类型
  Type get serviceType;

  /// 获取配置类型
  Type get configType;
}

/// 服务注册器 - 用于注册和发现服务
class ServiceRegistry {
  ServiceRegistry._();
  static final ServiceRegistry _instance = ServiceRegistry._();
  static ServiceRegistry get instance => _instance;

  final Map<Type, ServiceFactory> _factories = {};
  final Map<String, dynamic> _configs = {};

  /// 注册服务工厂
  void registerFactory<T extends BaseService, C extends ServiceConfig>(
    ServiceFactory<T, C> factory,
  ) {
    _factories[T] = factory;
  }

  /// 注册服务配置
  void registerConfig<T>(String key, T config) {
    _configs[key] = config;
  }

  /// 获取服务工厂
  ServiceFactory<T, C>?
      getFactory<T extends BaseService, C extends ServiceConfig>() {
    return _factories[T] as ServiceFactory<T, C>?;
  }

  /// 获取服务配置
  T? getConfig<T>(String key) {
    return _configs[key] as T?;
  }

  /// 创建服务实例
  T? createService<T extends BaseService, C extends ServiceConfig>(C config) {
    final factory = getFactory<T, C>();
    return factory?.createService(config);
  }
}
