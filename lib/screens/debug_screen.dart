import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:your_finance_flutter/core/router/app_router.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/financial_animations_example.dart';
import 'package:your_finance_flutter/ios_animation_showcase.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  String _logPath = '获取中...';
  List<String> _logLines = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getLogPath();
  }

  Future<void> _getLogPath() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logPath = '${directory.path}/salary_calculation.log';
      setState(() {
        _logPath = logPath;
      });
    } catch (e) {
      setState(() {
        _logPath = '获取路径失败: $e';
      });
    }
  }

  Future<void> _loadLogContent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final file = File(_logPath);
      if (await file.exists()) {
        final lines = await file.readAsLines();
        // Get last 100 lines or all lines if less than 100
        final start = lines.length > 100 ? lines.length - 100 : 0;
        setState(() {
          _logLines = lines.sublist(start);
        });
      } else {
        setState(() {
          _logLines = ['日志文件不存在'];
        });
      }
    } catch (e) {
      setState(() {
        _logLines = ['读取日志失败: $e'];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearLog() async {
    try {
      final file = File(_logPath);
      if (await file.exists()) {
        await file.writeAsString('');
        setState(() {
          _logLines = ['日志已清空'];
        });
      }
    } catch (e) {
      setState(() {
        _logLines = ['清空日志失败: $e'];
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            '调试信息',
            style: context.textTheme.headlineMedium,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(context.responsiveSpacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 日志文件路径
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(context.responsiveSpacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '日志文件路径',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: context.responsiveSpacing8),
                      SelectableText(
                        _logPath,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: context.responsiveSpacing12),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: _loadLogContent,
                            child: const Text('加载日志内容'),
                          ),
                          SizedBox(width: context.responsiveSpacing12),
                          OutlinedButton(
                            onPressed: _clearLog,
                            child: const Text('清空日志'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: context.responsiveSpacing24),

              // 动画演示入口
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(context.responsiveSpacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.animation,
                            color: Colors.blue,
                            size: 24,
                          ),
                          SizedBox(width: context.responsiveSpacing8),
                          Text(
                            '🎨 动画特效演示',
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.responsiveSpacing8),
                      Text(
                        '测试和验证应用中的各种动画特效，包括金融记账相关的动效。',
                        style: context.textTheme.bodyMedium,
                      ),
                      SizedBox(height: context.responsiveSpacing16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<IOSAnimationShowcase>(
                                    builder: (context) =>
                                        const IOSAnimationShowcase(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.play_circle_outline),
                              label: const Text('快速演示'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: context.responsiveSpacing12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<FinancialAnimationsExample>(
                                    builder: (context) =>
                                        const FinancialAnimationsExample(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.fullscreen),
                              label: const Text('完整演示'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue,
                                side: const BorderSide(color: Colors.blue),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: context.responsiveSpacing24),

              // iOS风格动效展示
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(context.responsiveSpacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.apple,
                            color: Colors.black,
                            size: 24,
                          ),
                          SizedBox(width: context.responsiveSpacing8),
                          Text(
                            '🍎 iOS风格动效展示',
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.responsiveSpacing8),
                      Text(
                        '体验72款精心设计的iOS风格动画特效，包括手势反馈、状态过渡、数据可视化等完整动画库。',
                        style: context.textTheme.bodyMedium,
                      ),
                      SizedBox(height: context.responsiveSpacing16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<IOSAnimationShowcase>(
                              builder: (context) =>
                                  const IOSAnimationShowcase(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.smartphone),
                        label: const Text('进入iOS动效展示'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: context.responsiveSpacing24),

              // 统一提示系统演示
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(context.responsiveSpacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.notifications_active,
                            color: Colors.green,
                            size: 24,
                          ),
                          SizedBox(width: context.responsiveSpacing8),
                          Text(
                            '🔔 统一提示系统演示',
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.responsiveSpacing8),
                      Text(
                        '体验全新的统一提示系统，包括智能路由、毛玻璃效果、上下文感知等多种提示方式。',
                        style: context.textTheme.bodyMedium,
                      ),
                      SizedBox(height: context.responsiveSpacing16),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.goNotificationDemo();
                        },
                        icon: const Icon(Icons.notifications),
                        label: const Text('进入提示系统演示'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: context.responsiveSpacing24),

              // 日志内容
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_logLines.isNotEmpty)
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(context.responsiveSpacing16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '日志内容 (最后100行)',
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: context.responsiveSpacing12),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 400),
                          child: SingleChildScrollView(
                            child: SelectableText(
                              _logLines.join('\n'),
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
}
