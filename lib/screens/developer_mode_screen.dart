import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:share_plus/share_plus.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/core/services/clearance_service.dart';
import 'package:your_finance_flutter/core/services/data_migration_service.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/utils/debug_mode_manager.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';
import 'package:your_finance_flutter/core/utils/unified_notifications.dart';
import 'package:your_finance_flutter/core/router/app_router.dart';
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
  final PeriodClearanceService _clearanceService = PeriodClearanceService();

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
      unifiedNotifications.showSuccess(context, '日志已清除');
    }
  }

  /// 预览遗留数据导入
  Future<void> _previewLegacyImport() async {
    setState(() => _isLoading = true);

    try {
      final migrationService = await DataMigrationService.getInstance();
      final report = await migrationService.importLegacyData();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.analytics_outlined),
                const SizedBox(width: 8),
                const Text('导入预览'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('资产: ${report.modules['assets']!.total} 条记录'),
                  Text('账户: ${report.modules['accounts']!.total} 条记录'),
                  Text('交易: ${report.modules['transactions']!.total} 条记录'),
                  Text('预算: ${report.modules['budgets']!.total} 条记录'),
                  Text('薪资: ${report.modules['salary']!.total} 条记录'),
                  Text('历史: ${report.modules['history']!.total} 条记录'),
                  if (report.errors.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_outlined, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Text(
                          '发现问题:',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ],
                    ),
                    ...report.errors.map((e) => Text('• $e')),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('关闭'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        unifiedNotifications.showError(
          context,
          '预览失败: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 执行遗留数据导入
  Future<void> _performLegacyImport() async {
    final confirmed = await unifiedNotifications.showConfirmation(
      context,
      title: '导入遗留数据',
      message: '此操作将从SharedPreferences和JSON文件导入遗留数据到Drift数据库。\n\n'
          '将导入：资产、账户、交易、预算、薪资等所有数据。\n\n'
          '原始数据将被备份，导入的数据将与现有数据合并。\n\n'
          '确定要继续吗？',
      confirmLabel: '开始导入',
      confirmColor: const Color(0xFF4CAF50),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final migrationService = await DataMigrationService.getInstance();
      // Force re-migration to trigger legacy import
      await migrationService.forceReMigration();

      if (mounted) {
        unifiedNotifications.showSuccess(
          context,
          '遗留数据导入完成，请重启应用查看结果',
        );
      }
    } catch (e) {
      if (mounted) {
        unifiedNotifications.showError(
          context,
          '导入失败: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _forceDataMigration() async {
    final confirmed = await unifiedNotifications.showConfirmation(
      context,
      title: '强制数据迁移',
      message: '此操作将重新执行所有数据迁移，可能恢复丢失的工资数据。\n\n'
          '注意：此操作可能会覆盖现有数据，建议先备份重要数据。\n\n'
          '确定要继续吗？',
      confirmLabel: '确定执行',
      confirmColor: const Color(0xFFFF6B6B),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final migrationService = await DataMigrationService.getInstance();
      await migrationService.forceReMigration();

      if (mounted) {
        unifiedNotifications.showSuccess(
          context,
          '数据迁移完成，请重新启动应用查看结果',
        );
      }
    } catch (e) {
      if (mounted) {
        unifiedNotifications.showError(
          context,
          '数据迁移失败: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 处理历史清账数据：将已完成清账的交易转换为实际交易记录
  Future<void> _processHistoricalClearanceData() async {
    final confirmed = await unifiedNotifications.showConfirmation(
      context,
      title: '处理历史清账数据',
      message: '此操作将扫描所有已完成的清账会话，将其中的交易记录转换为实际交易记录。\n\n'
          '转换后的交易将出现在交易列表中，钱包余额会自动更新。\n\n'
          '已存在的交易不会被重复添加。\n\n'
          '确定要继续吗？',
      confirmLabel: '开始处理',
      confirmColor: const Color(0xFF2196F3),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await _clearanceService.initialize();
      final convertedCount = await _clearanceService.processHistoricalClearanceData();

      // 刷新交易数据
      try {
        final transactionProvider = provider.Provider.of<TransactionProvider>(context, listen: false);
        await transactionProvider.refresh();
      } catch (e) {
        Logger.debug('刷新交易数据失败: $e');
      }

      if (mounted) {
        if (convertedCount > 0) {
          unifiedNotifications.showSuccess(
            context,
            '已处理 $convertedCount 个历史清账会话，交易记录已更新',
          );
        } else {
          unifiedNotifications.showInfo(
            context,
            '没有需要处理的历史清账数据',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        unifiedNotifications.showError(
          context,
          '处理失败: $e',
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

              // UI工具
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UI工具',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.spacing16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.goDebugUIKit(),
                        icon: const Icon(Icons.palette_outlined),
                        label: const Text('UI Gallery / 组件测试'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9C27B0),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
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
                              unifiedNotifications.showWarning(
                                context,
                                '🔧 Debug模式已开启',
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

                    SizedBox(height: context.spacing12),

                    // 处理历史清账数据按钮
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _processHistoricalClearanceData,
                            icon: const Icon(Icons.history),
                            label: const Text('处理历史清账数据'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: context.spacing8),

                    Text(
                      '强制数据迁移：重新执行所有数据迁移，可能恢复丢失的工资数据',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFFF6B6B),
                      ),
                    ),
                    SizedBox(height: context.spacing4),
                    Text(
                      '处理历史清账数据：将已完成清账的交易转换为实际交易记录',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF2196F3),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.spacing16),

              // 遗留数据导入
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '遗留数据导入',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.spacing12),
                    Text(
                      '从JSON文件导入遗留数据到新的Drift数据库',
                      style: context.textTheme.bodyMedium,
                    ),
                    SizedBox(height: context.spacing16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _previewLegacyImport,
                            icon: const Icon(Icons.preview),
                            label: const Text('预览导入'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: context.spacing12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _performLegacyImport,
                            icon: const Icon(Icons.cloud_upload),
                            label: const Text('执行导入'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.spacing8),
                    Text(
                      '查找路径: legacy/ 或 应用文档目录\n'
                      '支持文件: assets.json, accounts.json, transactions.json, budgets.json, salary.json\n'
                      '导入后数据将存储在Drift数据库中，原始文件会被备份',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.spacing16),

              // iOS动效展示
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'iOS动效展示',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.spacing12),
                    Text(
                      '体验完整的iOS风格动效系统，基于Notion动效标杆实现',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.secondaryText,
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
