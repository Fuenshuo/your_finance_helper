import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:your_finance_flutter/core/services/data_migration_service.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';

/// 开发者模式页面
class DeveloperModeScreen extends StatefulWidget {
  const DeveloperModeScreen({super.key});

  @override
  State<DeveloperModeScreen> createState() => _DeveloperModeScreenState();
}

class _DeveloperModeScreenState extends State<DeveloperModeScreen>
    with LoggingMixin, PerformanceMixin {
  String _logContent = '';
  String _logFileSize = '0 KB';
  bool _isLoading = false;
  LogLevel _selectedLogLevel = Logger.currentLevel;
  bool _fileLoggingEnabled = Logger.fileLoggingEnabled;

  @override
  void initState() {
    super.initState();
    logMethodStart('initState');
    _loadLogs();
    logMethodEnd('initState');
  }

  @override
  void dispose() {
    logMethod('dispose');
    super.dispose();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);

    await monitorAsync('loadLogs', () async {
      final content = await Logger.getAllLogs();
      final size = await Logger.getLogFileSize();

      if (mounted) {
        setState(() {
          _logContent = content;
          _logFileSize = size;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _clearLogs() async {
    await monitorAsync('clearLogs', () async {
      await Logger.clearLogs();
      await _loadLogs();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('日志已清除')),
      );
    }
  }

  /// 强制重新执行数据迁移
  Future<void> _forceDataMigration() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ 强制数据迁移'),
        content: const Text('此操作将重新执行所有数据迁移，可能恢复丢失的工资数据。\n\n'
            '注意：此操作可能会覆盖现有数据，建议先备份重要数据。\n\n'
            '确定要继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
            ),
            child: const Text('确定执行'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final migrationService = await DataMigrationService.getInstance();
      await migrationService.forceReMigration();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 数据迁移完成，请重新启动应用查看结果'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 数据迁移失败: $e'),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _shareLogs() async {
    await monitorAsync('shareLogs', () async {
      await Share.share(_logContent, subject: 'YourFinance应用日志');
    });
  }

  Future<void> _changeLogLevel(LogLevel level) async {
    setState(() => _selectedLogLevel = level);
    Logger.setLogLevel(level);

    logStateChange(
      'logLevel',
      level.displayName,
      {'old': _selectedLogLevel.displayName, 'new': level.displayName},
    );
  }

  Future<void> _toggleFileLogging(bool enabled) async {
    setState(() => _fileLoggingEnabled = enabled);
    await Logger.setFileLoggingEnabled(enabled);

    logStateChange('fileLogging', enabled ? 'enabled' : 'disabled');
  }

  void _addTestLog() {
    Logger.debug('测试调试日志', 'DeveloperMode');
    Logger.info('测试信息日志', 'DeveloperMode');
    Logger.warning('测试警告日志', 'DeveloperMode');
    Logger.error('测试错误日志', 'DeveloperMode');

    Log.page('DeveloperModeScreen', 'Test Logs Added');
    Log.business('DeveloperMode', 'User Action', {'action': 'addTestLogs'});

    // 重新加载日志
    Future.delayed(const Duration(milliseconds: 500), _loadLogs);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            '开发者模式',
            style: context.textTheme.headlineMedium,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _loadLogs,
              icon: const Icon(Icons.refresh),
              tooltip: '刷新日志',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(context.responsiveSpacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 日志设置
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '日志设置',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.spacing16),

                    // 日志级别设置
                    Row(
                      children: [
                        const Text('日志级别:'),
                        SizedBox(width: context.spacing16),
                        DropdownButton<LogLevel>(
                          value: _selectedLogLevel,
                          items: LogLevel.values
                              .map(
                                (level) => DropdownMenuItem(
                                  value: level,
                                  child: Text(level.displayName),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _changeLogLevel(value);
                            }
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: context.spacing12),

                    // 文件日志开关
                    Row(
                      children: [
                        const Text('文件日志:'),
                        SizedBox(width: context.spacing16),
                        Switch(
                          value: _fileLoggingEnabled,
                          onChanged: _toggleFileLogging,
                        ),
                      ],
                    ),

                    SizedBox(height: context.spacing12),

                    // 日志文件大小
                    Text(
                      '日志文件大小: $_logFileSize',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.spacing16),

              // 日志操作
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '日志操作',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.spacing16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _addTestLog,
                            icon: const Icon(Icons.add),
                            label: const Text('添加测试日志'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: context.spacing12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _clearLogs,
                            icon: const Icon(Icons.clear),
                            label: const Text('清除日志'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.spacing12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _shareLogs,
                        icon: const Icon(Icons.share),
                        label: const Text('导出日志'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.spacing16),

              // 数据管理
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '数据管理',
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'DEBUG模式',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.spacing16),

                    // 快速开启debug模式按钮
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final debugManager = DebugModeManager();
                              debugManager.forceEnableDebugMode();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('🔧 Debug模式已开启'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            },
                            icon: const Icon(Icons.bug_report),
                            label: const Text('开启Debug模式'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: context.spacing12),

                    // 数据恢复按钮
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _forceDataMigration,
                            icon: const Icon(Icons.restore),
                            label: const Text('强制数据迁移'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B6B),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: context.spacing8),

                    Text(
                      '⚠️ 此操作将重新执行所有数据迁移，可能恢复丢失的工资数据',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFFF6B6B),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.spacing16),

              // 日志内容
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '日志内容',
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_logContent.split('\n').length} 行',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.secondaryText,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.spacing16),
                    if (_isLoading)
                      const Center(
                        child: CircularProgressIndicator(),
                      )
                    else if (_logContent.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('暂无日志内容'),
                        ),
                      )
                    else
                      Container(
                        constraints: const BoxConstraints(maxHeight: 400),
                        child: SingleChildScrollView(
                          child: SelectableText(
                            _logContent,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: context.spacing32),
            ],
          ),
        ),
      );
}
