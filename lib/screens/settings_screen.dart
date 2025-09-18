import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/utils/debug_mode_manager.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/screens/developer_mode_screen.dart';

/// 设置页面
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DebugModeManager _debugManager = DebugModeManager();

  @override
  void initState() {
    super.initState();
    _debugManager.addListener(_onDebugModeChanged);
  }

  @override
  void dispose() {
    _debugManager.removeListener(_onDebugModeChanged);
    super.dispose();
  }

  void _onDebugModeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('设置'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        backgroundColor: context.primaryBackground,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 应用信息
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '应用信息',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoItem('版本号', 'V3.0'),
                    _buildInfoItem('架构', '三层财务模型'),
                    _buildInfoItem('状态', '开发中'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 开发者选项
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '开发者选项',
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_debugManager.isDebugModeEnabled)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '已开启',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Debug模式状态
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _debugManager.isDebugModeEnabled
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _debugManager.isDebugModeEnabled
                              ? Colors.orange
                              : Colors.grey,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _debugManager.isDebugModeEnabled
                                ? Icons.developer_mode
                                : Icons.developer_mode_outlined,
                            color: _debugManager.isDebugModeEnabled
                                ? Colors.orange
                                : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Debug模式',
                                  style:
                                      context.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  _debugManager.isDebugModeEnabled
                                      ? '开发者模式已开启，可以访问调试工具'
                                      : '连续点击顶部标题5次开启开发者模式',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: context.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_debugManager.isDebugModeEnabled)
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  AppAnimations.createRoute(
                                    const DeveloperModeScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.arrow_forward_ios),
                              color: Colors.orange,
                              iconSize: 16,
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 快速开启按钮
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _debugManager.forceEnableDebugMode();
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
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 关于应用
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '关于应用',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '家庭资产记账应用是一个现代化的个人财务管理工具，采用三层财务模型架构：\n\n'
                      '• 家庭信息维护：管理工资、资产、钱包等静态信息\n'
                      '• 财务计划：制定收入和支出计划\n'
                      '• 交易流水：记录和分析实际交易\n\n'
                      '应用支持多种资产类型、预算管理、税务计算等功能。',
                      style: context.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildInfoItem(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.secondaryText,
              ),
            ),
            Text(
              value,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
}

