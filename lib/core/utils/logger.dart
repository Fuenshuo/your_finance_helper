import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

/// 日志级别枚举
enum LogLevel {
  debug('DEBUG'),
  info('INFO'),
  warning('WARNING'),
  error('ERROR');

  const LogLevel(this.displayName);
  final String displayName;
}

/// 日志工具类
class Logger {
  static const String _tag = 'YourFinance';
  static LogLevel _currentLevel = LogLevel.info;
  static bool _fileLoggingEnabled = false;
  static File? _logFile;
  static const int _maxLogLines = 1000;
  static final List<String> _logBuffer = [];

  /// 初始化日志系统
  static Future<void> init({
    LogLevel level = LogLevel.info,
    bool enableFileLogging = false,
  }) async {
    _currentLevel = level;
    _fileLoggingEnabled = enableFileLogging;

    if (_fileLoggingEnabled) {
      await _initLogFile();
    }

    info('Logger initialized',
        'Level: $_currentLevel, FileLogging: $_fileLoggingEnabled');
  }

  /// 初始化日志文件
  static Future<void> _initLogFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _logFile = File('${logDir.path}/app_$dateStr.log');
    } catch (e) {
      // 如果文件初始化失败，禁用文件日志
      _fileLoggingEnabled = false;
      print('Failed to initialize log file: $e');
    }
  }

  /// 写入日志到文件
  static Future<void> _writeToFile(String message) async {
    if (!_fileLoggingEnabled || _logFile == null) return;

    try {
      _logBuffer.add(message);

      // 如果缓冲区满了，写入文件
      if (_logBuffer.length >= 100) {
        await _flushBuffer();
      }
    } catch (e) {
      print('Failed to write to log file: $e');
    }
  }

  /// 刷新缓冲区到文件
  static Future<void> _flushBuffer() async {
    if (_logBuffer.isEmpty || _logFile == null) return;

    try {
      final content = '${_logBuffer.join('\n')}\n';
      await _logFile!.writeAsString(content, mode: FileMode.append);
      _logBuffer.clear();
    } catch (e) {
      print('Failed to flush log buffer: $e');
    }
  }

  /// 关闭日志系统
  static Future<void> dispose() async {
    await _flushBuffer();
  }

  /// 获取所有日志内容
  static Future<String> getAllLogs() async {
    if (_logFile == null || !await _logFile!.exists()) {
      return 'No log file available';
    }

    try {
      var content = await _logFile!.readAsString();

      // 添加缓冲区中的日志
      if (_logBuffer.isNotEmpty) {
        content += '\n${_logBuffer.join('\n')}';
      }

      return content;
    } catch (e) {
      return 'Failed to read log file: $e';
    }
  }

  /// 清除日志文件
  static Future<void> clearLogs() async {
    if (_logFile != null && await _logFile!.exists()) {
      await _logFile!.writeAsString('');
    }
    _logBuffer.clear();
  }

  /// 获取日志文件大小
  static Future<String> getLogFileSize() async {
    if (_logFile == null || !await _logFile!.exists()) {
      return '0 KB';
    }

    try {
      final bytes = await _logFile!.length();
      final kb = bytes / 1024;
      return '${kb.toStringAsFixed(2)} KB';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// 基础日志方法
  static void _log(LogLevel level, String message, [String? tag]) {
    if (level.index < _currentLevel.index) return;

    final timestamp =
        DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now());
    final logMessage =
        '[$timestamp] [$_tag] [${level.displayName}] ${tag != null ? '[$tag] ' : ''}$message';

    // 控制台输出
    print(logMessage);

    // 文件输出
    _writeToFile(logMessage);
  }

  /// 调试日志
  static void debug(String message, [String? tag]) =>
      _log(LogLevel.debug, message, tag);

  /// 信息日志
  static void info(String message, [String? tag]) =>
      _log(LogLevel.info, message, tag);

  /// 警告日志
  static void warning(String message, [String? tag]) =>
      _log(LogLevel.warning, message, tag);

  /// 错误日志
  static void error(String message, [String? tag]) =>
      _log(LogLevel.error, message, tag);

  /// 获取当前日志级别
  static LogLevel get currentLevel => _currentLevel;

  /// 获取文件日志是否启用
  static bool get fileLoggingEnabled => _fileLoggingEnabled;

  /// 设置日志级别
  static void setLogLevel(LogLevel level) {
    _currentLevel = level;
    info('Log level changed to: $_currentLevel');
  }

  /// 启用/禁用文件日志
  static Future<void> setFileLoggingEnabled(bool enabled) async {
    _fileLoggingEnabled = enabled;
    if (enabled && _logFile == null) {
      await _initLogFile();
    }
    info('File logging ${enabled ? 'enabled' : 'disabled'}');
  }
}

/// 日志工具类 - 提供便捷的方法
class Log {
  /// 页面日志
  static void page(String pageName, String action,
      [Map<String, dynamic>? params]) {
    final message = '$action${params != null ? ': ${jsonEncode(params)}' : ''}';
    Logger.info(message, pageName);
  }

  /// 方法日志
  static void method(String className, String methodName, [String? details]) {
    final message = '$methodName${details != null ? ': $details' : ''}';
    Logger.debug(message, className);
  }

  /// 数据操作日志
  static void data(String operation, String dataType, [details]) {
    final detailsStr =
        details is Map ? jsonEncode(details) : details?.toString() ?? '';
    final message =
        '$operation $dataType${detailsStr.isNotEmpty ? ': $detailsStr' : ''}';
    Logger.info(message, 'DataService');
  }

  /// 警告日志
  static void warning(String location, String message) {
    Logger.warning(message, location);
  }

  /// 业务流程日志
  static void business(String process, String step,
      [Map<String, dynamic>? context]) {
    final message = '$step${context != null ? ': ${jsonEncode(context)}' : ''}';
    Logger.info(message, process);
  }

  /// 性能日志
  static void performance(String operation, Duration duration,
      [Map<String, dynamic>? metrics]) {
    final message =
        '$operation completed in ${duration.inMilliseconds}ms${metrics != null ? ', metrics: ${jsonEncode(metrics)}' : ''}';
    Logger.info(message, 'Performance');
  }

  /// 错误日志
  static void error(String location, String error, [Object? stackTrace]) {
    Logger.error(
        '$error${stackTrace != null ? '\n$stackTrace' : ''}', location);
  }
}

/// 日志切面Mixin - 类似AOP的功能
mixin LoggingMixin {
  String get logTag => runtimeType.toString();

  /// 记录方法调用
  void logMethod(String methodName, [Map<String, dynamic>? params]) {
    Log.method(logTag, methodName, params != null ? jsonEncode(params) : null);
  }

  /// 记录方法开始
  void logMethodStart(String methodName, [Map<String, dynamic>? params]) {
    Log.method(logTag, '$methodName started',
        params != null ? jsonEncode(params) : null);
  }

  /// 记录方法结束
  void logMethodEnd(String methodName, [result]) {
    final resultStr = result != null ? ' -> $result' : '';
    Log.method(logTag, '$methodName completed$resultStr');
  }

  /// 记录状态变更
  void logStateChange(String from, String to, [Map<String, dynamic>? context]) {
    Log.business(logTag, 'State changed: $from -> $to', context);
  }

  /// 记录数据变更
  void logDataChange(String operation, String dataType, [details]) {
    Log.data(operation, dataType, details?.toString());
  }
}

/// 性能监控Mixin
mixin PerformanceMixin {
  String get performanceTag => runtimeType.toString();
  final Map<String, DateTime> _performanceTimers = {};

  /// 开始性能监控
  void startPerformance(String operation) {
    _performanceTimers[operation] = DateTime.now();
    Log.performance(
        '$operation started', Duration.zero, {'tag': performanceTag});
  }

  /// 结束性能监控
  void endPerformance(String operation,
      [Map<String, dynamic>? additionalMetrics]) {
    final startTime = _performanceTimers.remove(operation);
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      Log.performance(operation, duration, {
        'tag': performanceTag,
        ...?additionalMetrics,
      });
    }
  }

  /// 监控异步操作性能
  Future<T> monitorAsync<T>(
      String operation, Future<T> Function() asyncFunction) async {
    startPerformance(operation);
    try {
      final result = await asyncFunction();
      endPerformance(operation, {'success': true});
      return result;
    } catch (e) {
      endPerformance(operation, {'success': false, 'error': e.toString()});
      rethrow;
    }
  }
}
