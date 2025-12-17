import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// 日志服务类，用于将日志写入文件而不是控制台
class LoggingService {
  factory LoggingService() => _instance;
  LoggingService._internal();
  static final LoggingService _instance = LoggingService._internal();

  File? _logFile;
  bool _initialized = false;

  /// 初始化日志服务
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final logPath = '${directory.path}/salary_calculation.log';
      _logFile = File(logPath);

      // 创建文件（如果不存在）
      if (!await _logFile!.exists()) {
        await _logFile!.create();
      }

      _initialized = true;
      await log('=== 日志服务初始化完成 ===');
    } catch (e) {
      // 如果无法初始化文件日志，则回退到控制台日志
      print('无法初始化文件日志: $e');
    }
  }

  /// 写入日志
  Future<void> log(String message) async {
    if (!_initialized) {
      // 如果未初始化，直接打印到控制台
      print(message);
      return;
    }

    try {
      final timestamp = DateTime.now().toString();
      final logMessage = '[$timestamp] $message\n';

      // 追加到文件
      await _logFile?.writeAsString(logMessage, mode: FileMode.append);
    } catch (e) {
      // 如果写入文件失败，打印到控制台
      print('写入日志文件失败: $e');
      print(message);
    }
  }

  /// 清除日志文件
  Future<void> clearLogs() async {
    if (!_initialized) return;

    try {
      await _logFile?.writeAsString('');
    } catch (e) {
      print('清除日志文件失败: $e');
    }
  }

  /// 获取日志文件路径
  String? get logFilePath => _logFile?.path;
}
