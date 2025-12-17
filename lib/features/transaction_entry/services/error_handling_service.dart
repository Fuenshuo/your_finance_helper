import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 错误类型枚举
enum ErrorType {
  /// 网络错误
  network,

  /// 验证错误
  validation,

  /// 解析错误
  parsing,

  /// 保存错误
  save,

  /// 权限错误
  permission,

  /// 数据错误
  data,

  /// 未知错误
  unknown,
}

/// 错误信息类
class ErrorInfo {
  ErrorInfo({
    required this.type,
    required this.message,
    this.details,
    DateTime? timestamp,
    this.source,
    this.originalError,
    this.stackTrace,
  }) : timestamp = timestamp ?? DateTime.now();

  /// 创建网络错误
  factory ErrorInfo.network(String message, {String? details, Object? error}) =>
      ErrorInfo(
        type: ErrorType.network,
        message: message,
        details: details,
        originalError: error,
      );

  /// 创建验证错误
  factory ErrorInfo.validation(
    String message, {
    String? details,
    String? source,
  }) =>
      ErrorInfo(
        type: ErrorType.validation,
        message: message,
        details: details,
        source: source,
      );

  /// 创建解析错误
  factory ErrorInfo.parsing(String message, {String? details, Object? error}) =>
      ErrorInfo(
        type: ErrorType.parsing,
        message: message,
        details: details,
        originalError: error,
      );

  /// 创建保存错误
  factory ErrorInfo.save(String message, {String? details, Object? error}) =>
      ErrorInfo(
        type: ErrorType.save,
        message: message,
        details: details,
        originalError: error,
      );
  final ErrorType type;
  final String message;
  final String? details;
  final DateTime timestamp;
  final String? source;
  final dynamic originalError;
  final StackTrace? stackTrace;

  /// 获取用户友好的错误消息
  String get userFriendlyMessage => switch (type) {
        ErrorType.network => '网络连接失败，请检查网络后重试',
        ErrorType.validation => message, // 验证错误直接使用原始消息
        ErrorType.parsing => '无法解析输入内容，请检查格式',
        ErrorType.save => '保存失败，请稍后重试',
        ErrorType.permission => '权限不足，无法执行操作',
        ErrorType.data => '数据异常，请联系客服',
        ErrorType.unknown => '发生未知错误，请重试',
      };

  /// 获取恢复建议
  String get recoverySuggestion => switch (type) {
        ErrorType.network => '检查网络连接，或稍后重试',
        ErrorType.validation => '请检查输入内容并修正错误',
        ErrorType.parsing => '请使用更清晰的描述，或查看帮助文档',
        ErrorType.save => '检查存储空间，或稍后重试',
        ErrorType.permission => '请检查应用权限设置',
        ErrorType.data => '请尝试刷新页面，或重新启动应用',
        ErrorType.unknown => '请尝试重新启动应用，或联系客服',
      };
}

/// 错误处理服务接口
abstract class ErrorHandlingService {
  /// 报告错误
  void reportError(ErrorInfo error);

  /// 获取错误历史
  List<ErrorInfo> getErrorHistory();

  /// 清空错误历史
  void clearErrorHistory();

  /// 检查是否有未处理的错误
  bool hasUnhandledErrors();

  /// 获取最新错误
  ErrorInfo? getLatestError();

  /// 监听错误事件
  Stream<ErrorInfo> listenErrors();
}

/// 默认错误处理服务实现
class DefaultErrorHandlingService implements ErrorHandlingService {
  final StreamController<ErrorInfo> _errorController =
      StreamController.broadcast();
  final List<ErrorInfo> _errorHistory = [];
  static const int _maxHistorySize = 50;

  @override
  void reportError(ErrorInfo error) {
    // 添加到历史记录
    _errorHistory.add(error);
    if (_errorHistory.length > _maxHistorySize) {
      _errorHistory.removeAt(0);
    }

    // 发送错误事件
    _errorController.add(error);

    // 记录到控制台（开发模式）
    // debugPrint('[ERROR] ${error.type}: ${error.message}');
    if (error.details != null) {
      // debugPrint('Details: ${error.details}');
    }
    if (error.stackTrace != null) {
      // debugPrint('StackTrace: ${error.stackTrace}');
    }
  }

  @override
  List<ErrorInfo> getErrorHistory() => List.unmodifiable(_errorHistory);

  @override
  void clearErrorHistory() => _errorHistory.clear();

  @override
  bool hasUnhandledErrors() => _errorHistory.isNotEmpty;

  @override
  ErrorInfo? getLatestError() =>
      _errorHistory.isNotEmpty ? _errorHistory.last : null;

  @override
  Stream<ErrorInfo> listenErrors() => _errorController.stream;

  /// 关闭服务
  void dispose() {
    _errorController.close();
  }
}

/// 状态同步服务接口
abstract class StateSynchronizationService {
  /// 同步状态变更
  Future<void> syncStateChange(String stateKey, Object? newValue);

  /// 获取状态值
  Object? getStateValue(String stateKey);

  /// 监听状态变更
  Stream<MapEntry<String, Object?>> listenStateChanges();

  /// 批量同步状态
  Future<void> syncMultipleStates(Map<String, Object?> states);
}

/// 默认状态同步服务实现
class DefaultStateSynchronizationService
    implements StateSynchronizationService {
  final StreamController<MapEntry<String, Object?>> _stateController =
      StreamController.broadcast();
  final Map<String, Object?> _stateStore = {};

  @override
  Future<void> syncStateChange(String stateKey, Object? newValue) async {
    final oldValue = _stateStore[stateKey];
    if (oldValue != newValue) {
      _stateStore[stateKey] = newValue;
      _stateController.add(MapEntry(stateKey, newValue));
    }
  }

  @override
  Object? getStateValue(String stateKey) => _stateStore[stateKey];

  @override
  Stream<MapEntry<String, Object?>> listenStateChanges() =>
      _stateController.stream;

  @override
  Future<void> syncMultipleStates(Map<String, Object?> states) async {
    for (final entry in states.entries) {
      await syncStateChange(entry.key, entry.value);
    }
  }

  /// 关闭服务
  void dispose() {
    _stateController.close();
  }
}

/// ErrorHandlingService Provider
final errorHandlingServiceProvider =
    Provider<ErrorHandlingService>((ref) => DefaultErrorHandlingService());

/// StateSynchronizationService Provider
final stateSynchronizationServiceProvider =
    Provider<StateSynchronizationService>(
  (ref) => DefaultStateSynchronizationService(),
);

/// 扩展方法：用于在UI层处理错误
extension ErrorHandlingExtensions on WidgetRef {
  /// 报告错误
  void reportError(ErrorInfo error) =>
      read(errorHandlingServiceProvider).reportError(error);

  /// 同步状态变更
  Future<void> syncState(String key, Object? value) async {
    final service = read(stateSynchronizationServiceProvider);
    await service.syncStateChange(key, value);
  }

  /// 监听错误事件
  Stream<ErrorInfo> listenErrors() {
    final service = read(errorHandlingServiceProvider);
    return service.listenErrors();
  }

  /// 监听状态变更
  Stream<MapEntry<String, dynamic>> listenStateChanges() {
    final service = read(stateSynchronizationServiceProvider);
    return service.listenStateChanges();
  }
}
