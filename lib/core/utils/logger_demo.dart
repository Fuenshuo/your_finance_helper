/// 日志系统使用示例和演示
/// 这个文件展示了如何在代码中使用新的日志系统
library;

import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';

/// 演示如何在Widget中使用日志系统
class LoggerDemoWidget extends StatefulWidget {
  const LoggerDemoWidget({super.key});

  @override
  State<LoggerDemoWidget> createState() => _LoggerDemoWidgetState();
}

class _LoggerDemoWidgetState extends State<LoggerDemoWidget> {
  @override
  void initState() {
    super.initState();
    Log.method('LoggerDemoWidget', 'initState started');

    // 演示不同的日志类型
    Logger.info('Widget initialized', 'LoggerDemoWidget');
    Logger.debug('Debug information', 'LoggerDemoWidget');
    Logger.warning('Warning message', 'LoggerDemoWidget');

    // 使用便捷的Log类
    Log.page('LoggerDemoWidget', 'Page loaded');
    Log.business('LoggerDemoWidget', 'User Action', {'action': 'view_demo'});

    Log.method('LoggerDemoWidget', 'initState completed');
  }

  Future<void> _performAsyncOperation() async {
    Log.performance('Async Operation', Duration.zero, {'status': 'started'});

    try {
      // 模拟异步操作
      await Future.delayed(const Duration(seconds: 2));

      // 记录业务操作
      Log.business('LoggerDemoWidget', 'Async Operation Completed');
      Log.performance('Async Operation', const Duration(seconds: 2),
          {'status': 'completed'});
    } catch (e) {
      Log.error('LoggerDemoWidget', 'Async operation failed', e);
      Log.performance('Async Operation', const Duration(seconds: 2),
          {'status': 'failed', 'error': e.toString()});
    }
  }

  void _simulateError() {
    try {
      // 模拟错误
      throw Exception('This is a demo error');
    } catch (e, stackTrace) {
      // 使用Log.error记录错误
      Log.error('LoggerDemoWidget', 'Demo error occurred: $e', stackTrace);
    }
  }

  void _logDataOperation() {
    // 记录数据操作
    Log.data('DemoData', 'Load: items=10, source=local');
    Log.data('DemoData', 'Save: items=5, target=remote');
  }

  @override
  Widget build(BuildContext context) {
    Log.method('LoggerDemoWidget', 'build', 'Building widget');

    return Scaffold(
      appBar: AppBar(
        title: const Text('日志系统演示'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _performAsyncOperation,
              child: const Text('执行异步操作'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _simulateError,
              child: const Text('模拟错误'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _logDataOperation,
              child: const Text('记录数据操作'),
            ),
            const SizedBox(height: 32),
            const Text(
              '查看控制台或开发者模式界面\n来查看日志输出',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/// AOP风格的日志示例 - 继承LoggingMixin
class DemoService with LoggingMixin {
  @override
  String get logTag => 'DemoService';

  Future<String> performOperation(String param) async {
    logMethodStart('performOperation', {'param': param});

    try {
      // 模拟业务逻辑
      await Future.delayed(const Duration(seconds: 1));

      logMethodEnd('performOperation', 'Success');
      return 'Operation completed with: $param';
    } catch (e) {
      logMethodEnd('performOperation', 'Error: $e');
      rethrow;
    }
  }
}

/// 性能监控示例
class PerformanceDemo with PerformanceMixin {
  @override
  String get performanceTag => 'PerformanceDemo';

  Future<void> slowOperation() async {
    startPerformance('slowOperation');

    try {
      // 模拟慢操作
      await Future.delayed(const Duration(seconds: 3));

      endPerformance('slowOperation', {'status': 'success'});
    } catch (e) {
      endPerformance(
          'slowOperation', {'status': 'error', 'error': e.toString()});
      rethrow;
    }
  }
}

/*
日志系统使用指南：

1. 基本日志方法：
   Logger.debug('调试信息')
   Logger.info('普通信息')
   Logger.warning('警告信息')
   Logger.error('错误信息')

2. 便捷日志类：
   Log.page('页面名', '操作')
   Log.business('模块名', '业务操作', {'额外数据': '值'})
   Log.data('数据类型', '操作', {'参数': '值'})
   Log.performance('操作名', Duration, {'额外指标': '值'})

3. AOP风格的日志：
   class MyWidget with LoggingMixin {
     void myMethod() {
       logMethodStart('myMethod');
       // 业务逻辑
       logMethodEnd('myMethod');
     }
   }

4. 性能监控：
   class MyService with PerformanceMixin {
     Future<void> myMethod() async {
       startPerformance('myMethod');
       // 异步操作
       endPerformance('myMethod');
     }
   }

5. 开发者模式：
   - 连续点击应用标题5次开启debug模式
   - 在debug模式下，AppBar会显示开发者模式按钮
   - 点击开发者模式按钮进入日志管理界面
   - 可以在开发者模式中查看、导出、清除日志

6. 日志级别控制：
   Logger.setLogLevel(LogLevel.debug); // 显示所有日志
   Logger.setLogLevel(LogLevel.info);  // 显示info及以上
   Logger.setLogLevel(LogLevel.warning); // 只显示警告和错误

7. 文件日志：
   Logger.setFileLoggingEnabled(true); // 开启文件日志
   // 日志文件保存在: Documents/logs/app_YYYY-MM-DD.log

日志格式示例：
[2024-01-15 14:30:25.123] [YourFinance] [INFO] [DemoService] Operation started: param=test
[2024-01-15 14:30:26.456] [YourFinance] [DEBUG] [DemoService] Operation completed: Success
*/
