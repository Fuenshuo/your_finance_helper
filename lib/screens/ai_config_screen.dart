import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/models/ai_config.dart';
import '../core/router/flux_router.dart';
import '../core/services/ai/ai_config_service.dart';
import '../core/theme/app_design_tokens.dart';
import '../core/widgets/composite/switch_control_list_item.dart';

/// AI配置页面
class AiConfigScreen extends StatefulWidget {
  const AiConfigScreen({super.key});

  @override
  State<AiConfigScreen> createState() => _AiConfigScreenState();
}

class _AiConfigScreenState extends State<AiConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  String _selectedProvider = 'dashscope';
  bool _isEnabled = false;
  bool _isLoading = false;

  final List<Map<String, String>> _providers = [
    {'id': 'dashscope', 'name': '阿里云DashScope', 'envKey': 'DASHSCOPE_API_KEY'},
    {
      'id': 'siliconFlow',
      'name': 'SiliconFlow',
      'envKey': 'SILICONFLOW_API_KEY'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  Future<void> _loadCurrentConfig() async {
    final configService = await AiConfigService.getInstance();
    final config = await configService.loadConfig();

    if (config != null) {
      setState(() {
        _selectedProvider = config.provider.name;
        _isEnabled = config.enabled;
        _apiKeyController.text = config.apiKey;
      });
    }
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final configService = await AiConfigService.getInstance();

      // 解析提供商
      final provider = _selectedProvider == 'dashscope'
          ? AiProvider.dashscope
          : AiProvider.siliconFlow;

      final config = AiConfig(
        provider: provider,
        apiKey: _apiKeyController.text.trim(),
        enabled: _isEnabled,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await configService.saveConfig(config);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI配置已保存')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 服务配置'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(FluxRoutes.streams),
          tooltip: '返回',
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveConfig,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    '保存',
                    style: TextStyle(
                      color: AppDesignTokens.primaryAction(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: Container(
        color: AppDesignTokens.pageBackground(context),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSection(context, '基本设置', [
                SwitchControlListItem(
                  title: '启用 AI 服务',
                  value: _isEnabled,
                  onChanged: (value) => setState(() => _isEnabled = value),
                ),
              ]),
              _buildSection(context, 'AI 服务提供商', _buildProviderSelection()),
              _buildSection(context, 'API 配置', [_buildApiKeyField()]),
              SizedBox(height: AppDesignTokens.spacing24),
              _buildTestSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDesignTokens.globalHorizontalPadding,
            vertical: AppDesignTokens.spacing16,
          ),
          child: Text(
            title,
            style: AppDesignTokens.title1(context),
          ),
        ),
        Container(
          color: AppDesignTokens.surface(context),
          child: Column(children: children),
        ),
        SizedBox(height: AppDesignTokens.spacing16),
      ],
    );
  }

  List<Widget> _buildProviderSelection() {
    return _providers.map((provider) {
      final isSelected = _selectedProvider == provider['id'];
      return Container(
        margin: EdgeInsets.symmetric(
            horizontal: AppDesignTokens.globalHorizontalPadding),
        child: RadioListTile<String>(
          title: Text(
            provider['name']!,
            style: AppDesignTokens.body(context).copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          subtitle: Text(
            '环境变量: ${provider['envKey']}',
            style: AppDesignTokens.caption(context),
          ),
          value: provider['id']!,
          groupValue: _selectedProvider,
          onChanged: (value) => setState(() => _selectedProvider = value!),
          activeColor: AppDesignTokens.primaryAction(context),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppDesignTokens.spacing16,
            vertical: AppDesignTokens.spacing8,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildApiKeyField() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: AppDesignTokens.globalHorizontalPadding),
      child: TextFormField(
        controller: _apiKeyController,
        style: AppDesignTokens.body(context),
        decoration: InputDecoration(
          labelText: 'API Key',
          hintText: '输入你的 API Key',
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppDesignTokens.radiusMedium(context)),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        obscureText: true,
        validator: (value) {
          if (!_isEnabled) return null;
          if (value == null || value.trim().isEmpty) {
            return '请输入 API Key';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTestSection() {
    return Padding(
      padding: EdgeInsets.all(AppDesignTokens.globalHorizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '测试配置',
            style: AppDesignTokens.title1(context),
          ),
          SizedBox(height: AppDesignTokens.spacing12),
          Text(
            '保存配置后，可以通过交易录入界面测试 AI 解析功能。例如：输入"午饭20元"，AI 将自动解析为交易记录。',
            style: AppDesignTokens.body(context),
          ),
          SizedBox(height: AppDesignTokens.spacing24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.go(FluxRoutes.streams),
                  child: const Text('返回'),
                ),
              ),
              SizedBox(width: AppDesignTokens.spacing16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveConfig,
                  child: const Text('保存配置'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
}
