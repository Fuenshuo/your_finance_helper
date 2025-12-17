import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/providers/theme_provider.dart';
import 'package:your_finance_flutter/core/providers/theme_style_provider.dart';
import 'package:your_finance_flutter/core/router/flux_router.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';
import 'package:your_finance_flutter/core/widgets/composite/navigable_list_item.dart';
import 'package:your_finance_flutter/core/widgets/composite/switch_control_list_item.dart';
import 'package:your_finance_flutter/screens/ai_config_screen.dart';

/// 设置页面
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('设置'),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(FluxRoutes.dashboard),
            tooltip: '返回',
          ),
        ),
        body: ColoredBox(
          color: AppDesignTokens.pageBackground(context),
          child: ListView(
            children: [
              _buildSection(
                context,
                'AI 配置',
                [
                  _buildNavigableItem(
                    context,
                    'AI 服务配置',
                    '配置AI解析服务的API密钥',
                    Icons.smart_toy,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const AiConfigScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              _buildSection(
                context,
                '外观',
                [
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) =>
                        _buildSwitchItem(
                      context,
                      '深色模式',
                      themeProvider.isDarkMode,
                      (value) => themeProvider.toggleTheme(),
                    ),
                  ),
                  Consumer<ThemeStyleProvider>(
                    builder: (context, themeStyleProvider, child) =>
                        _buildNavigableItem(
                      context,
                      '主题风格',
                      themeStyleProvider
                          .getStyleDisplayName(themeStyleProvider.currentStyle),
                      Icons.palette,
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('主题风格切换功能开发中'),
                            backgroundColor: AppDesignTokens.warningColor,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              _buildSection(
                context,
                '关于',
                [
                  _buildNavigableItem(
                    context,
                    '版本信息',
                    'Flux Ledger v1.0.0',
                    Icons.info_outline,
                    () {
                      showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppDesignTokens.surface(context),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDesignTokens.radiusMedium(context),
                            ),
                          ),
                          title: Text(
                            '关于 Flux Ledger',
                            style: AppDesignTokens.headline(context),
                          ),
                          content: Text(
                            '🌊 流式记账应用\n\n'
                            '让复杂的财务管理变得简单而愉悦\n\n'
                            '📱 版本: 1.0.0\n'
                            '🤖 基于 Flutter + AI 技术',
                            style: AppDesignTokens.body(context),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                '确定',
                                style: TextStyle(
                                  color: AppDesignTokens.primaryAction(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDesignTokens.globalHorizontalPadding,
              vertical: AppDesignTokens.spacing16,
            ),
            child: Text(
              title,
              style: AppDesignTokens.title1(context),
            ),
          ),
          // Section items
          ColoredBox(
            color: AppDesignTokens.surface(context),
            child: Column(
              children: children,
            ),
          ),
          const SizedBox(height: AppDesignTokens.spacing16),
        ],
      );

  Widget _buildNavigableItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) =>
      NavigableListItem(
        title: title,
        leading: Icon(icon, color: AppDesignTokens.primaryAction(context)),
        onTap: onTap,
        spacing: AppDesignTokens.spacing8,
      );

  Widget _buildSwitchItem(
    BuildContext context,
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) =>
      SwitchControlListItem(
        title: title,
        value: value,
        onChanged: onChanged,
        spacing: AppDesignTokens.spacing8,
      );
}
