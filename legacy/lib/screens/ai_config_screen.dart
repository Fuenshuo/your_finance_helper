import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/models/ai_config.dart';
import 'package:your_finance_flutter/core/services/ai/ai_config_service.dart';
import 'package:your_finance_flutter/core/services/ai/ai_service_factory.dart' as ai_factory;
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/core/widgets/glass_notification.dart';

/// AI配置页面
class AiConfigScreen extends StatefulWidget {
  const AiConfigScreen({super.key});

  @override
  State<AiConfigScreen> createState() => _AiConfigScreenState();
}

class _AiConfigScreenState extends State<AiConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  AiProvider _selectedProvider = AiProvider.dashscope;
  bool _isLoading = false;
  bool _isValidating = false;
  AiConfig? _currentConfig;
  bool _enabled = true;
  String? _selectedLlmModel;
  String? _selectedVisionModel;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  /// 加载现有配置
  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);
    try {
      final configService = await AiConfigService.getInstance();
      final config = await configService.loadConfig();
      if (config != null) {
        setState(() {
          _currentConfig = config;
          _selectedProvider = config.provider;
          _apiKeyController.text = config.apiKey;
          _baseUrlController.text = config.baseUrl ?? '';
          _enabled = config.enabled;
          _selectedLlmModel = config.llmModel;
          _selectedVisionModel = config.visionModel;
        });
      }
    } catch (e) {
      if (mounted) {
        GlassNotification.show(
          context,
          message: '加载配置失败: $e',
          icon: Icons.error_outline,
          backgroundColor: Colors.red.withOpacity(0.2),
          textColor: Colors.red,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 保存配置
  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final config = AiConfig(
        provider: _selectedProvider,
        apiKey: _apiKeyController.text.trim(),
        baseUrl: _baseUrlController.text.trim().isEmpty
            ? null
            : _baseUrlController.text.trim(),
        enabled: _enabled,
        llmModel: _selectedLlmModel,
        visionModel: _selectedVisionModel,
        customModels: _currentConfig?.customModels ?? {},
        createdAt: _currentConfig?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final configService = await AiConfigService.getInstance();
      await configService.saveConfig(config);

      if (mounted) {
        setState(() => _currentConfig = config);
        
        // 保存当前 context 的引用
        final currentContext = context;
        
        // 先返回上一级
        Navigator.of(context).pop();
        
        // 返回后立即显示保存成功提示（使用下一帧确保页面已返回）
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // 延迟一点时间确保页面已完全返回
          Future.delayed(const Duration(milliseconds: 100), () {
            // 使用保存的 context，但需要检查是否仍然有效
            if (currentContext.mounted) {
              GlassNotification.show(
                currentContext,
                message: 'AI配置已保存',
                icon: Icons.check_circle,
                backgroundColor: Colors.green.withOpacity(0.2),
                textColor: Colors.green,
                duration: const Duration(seconds: 2),
              );
            }
          });
        });
      }
    } catch (e) {
      if (mounted) {
        GlassNotification.show(
          context,
          message: '保存配置失败: $e',
          icon: Icons.error_outline,
          backgroundColor: Colors.red.withOpacity(0.2),
          textColor: Colors.red,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 验证API Key
  Future<void> _validateApiKey() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isValidating = true);
    try {
      final config = AiConfig(
        provider: _selectedProvider,
        apiKey: _apiKeyController.text.trim(),
        baseUrl: _baseUrlController.text.trim().isEmpty
            ? null
            : _baseUrlController.text.trim(),
        enabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final service = ai_factory.aiServiceFactory.createService(config);
      final isValid = await service.validateApiKey();

      if (mounted) {
        GlassNotification.show(
          context,
          message: isValid ? 'API Key验证成功' : 'API Key验证失败',
          icon: isValid ? Icons.check_circle : Icons.error_outline,
          backgroundColor: isValid 
              ? Colors.green.withOpacity(0.2) 
              : Colors.red.withOpacity(0.2),
          textColor: isValid ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (mounted) {
        GlassNotification.show(
          context,
          message: '验证失败: $e',
          icon: Icons.error_outline,
          backgroundColor: Colors.red.withOpacity(0.2),
          textColor: Colors.red,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isValidating = false);
      }
    }
  }

  /// 删除配置
  Future<void> _deleteConfig() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除AI配置吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final configService = await AiConfigService.getInstance();
      await configService.deleteConfig();

      if (mounted) {
        setState(() {
          _currentConfig = null;
          _apiKeyController.clear();
          _baseUrlController.clear();
        });
        GlassNotification.show(
          context,
          message: '配置已删除',
          icon: Icons.check_circle,
          backgroundColor: Colors.green.withOpacity(0.2),
          textColor: Colors.green,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (mounted) {
        GlassNotification.show(
          context,
          message: '删除配置失败: $e',
          icon: Icons.error_outline,
          backgroundColor: Colors.red.withOpacity(0.2),
          textColor: Colors.red,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('AI配置'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        backgroundColor: context.primaryBackground,
        body: _isLoading && _currentConfig == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 配置说明
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI服务配置',
                              style: context.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '配置AI服务提供商和API Key，以启用大语言分析和图文分析功能。',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 服务提供商选择
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '服务提供商',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...AiProvider.values.map((provider) {
                              return RadioListTile<AiProvider>(
                                title: Text(_getProviderName(provider)),
                                subtitle: Text(_getProviderDescription(provider)),
                                value: provider,
                                groupValue: _selectedProvider,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedProvider = value;
                                      // 切换提供商时重置模型选择，使用新提供商的配置
                                      final newConfig = _currentConfig?.copyWith(provider: value);
                                      if (newConfig != null) {
                                        _selectedLlmModel = newConfig.llmModel;
                                        _selectedVisionModel = newConfig.visionModel;
                                      } else {
                                        _selectedLlmModel = null;
                                        _selectedVisionModel = null;
                                      }
                                    });
                                  }
                                },
                              );
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 模型选择
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '模型选择',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // LLM模型选择
                            Text(
                              '大语言模型（LLM）',
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildModelDropdown(
                              'LLM',
                              _selectedLlmModel,
                              _getAvailableLlmModels(),
                              (value) => setState(() => _selectedLlmModel = value),
                            ),
                            const SizedBox(height: 16),
                            // Vision模型选择
                            Text(
                              '图文分析模型（Vision）',
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildModelDropdown(
                              'Vision',
                              _selectedVisionModel,
                              _getAvailableVisionModels(),
                              (value) => setState(() => _selectedVisionModel = value),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '留空将使用默认模型',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // API Key输入
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'API Key',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _apiKeyController,
                              decoration: InputDecoration(
                                labelText: '请输入API Key',
                                hintText: 'sk-...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.visibility),
                                  onPressed: () {
                                    // TODO: 实现显示/隐藏功能
                                  },
                                ),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '请输入API Key';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 自定义Base URL（可选）
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '自定义Base URL（可选）',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _baseUrlController,
                              decoration: InputDecoration(
                                labelText: 'Base URL',
                                hintText: '留空使用默认地址',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '大多数情况下无需填写，使用默认地址即可',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 启用开关
                      AppCard(
                        child: SwitchListTile(
                          title: const Text('启用AI服务'),
                          subtitle: const Text('关闭后将无法使用AI功能'),
                          value: _enabled,
                          onChanged: (value) {
                            setState(() => _enabled = value);
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 操作按钮
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isValidating ? null : _validateApiKey,
                              icon: _isValidating
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.check_circle),
                              label: const Text('验证API Key'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _saveConfig,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.save),
                              label: const Text('保存配置'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (_currentConfig != null) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _deleteConfig,
                            icon: const Icon(Icons.delete),
                            label: const Text('删除配置'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      );

  String _getProviderName(AiProvider provider) {
    switch (provider) {
      case AiProvider.dashscope:
        return 'DashScope (阿里云)';
      case AiProvider.siliconFlow:
        return 'SiliconFlow';
    }
  }

  String _getProviderDescription(AiProvider provider) {
    switch (provider) {
      case AiProvider.dashscope:
        return '阿里云DashScope，支持通义千问系列模型';
      case AiProvider.siliconFlow:
        return 'SiliconFlow，支持多种开源模型';
    }
  }

  /// 获取可用的LLM模型列表（仅用户自定义模型）
  List<String> _getAvailableLlmModels() {
    return _currentConfig?.getCustomLlmModels(_selectedProvider) ?? [];
  }

  /// 获取可用的Vision模型列表（仅用户自定义模型）
  List<String> _getAvailableVisionModels() {
    return _currentConfig?.getCustomVisionModels(_selectedProvider) ?? [];
  }

  /// 构建模型下拉选择器
  Widget _buildModelDropdown(
    String label,
    String? selectedValue,
    List<String> options,
    void Function(String?) onChanged,
  ) {
    // 特殊值用于标识「新增模型」选项
    const String addNewModelValue = '__ADD_NEW_MODEL__';
    
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: '选择$label模型',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      isExpanded: true,
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text(
            '使用默认模型',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ...options.map((model) => DropdownMenuItem<String>(
              value: model,
              child: Text(
                model,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            )),
        const DropdownMenuItem<String>(
          value: addNewModelValue,
          child: Row(
            children: [
              Icon(Icons.add_circle_outline, size: 18, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                '新增模型',
                style: TextStyle(color: Colors.blue),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
      selectedItemBuilder: (context) => [
        if (selectedValue == null)
          const Text(
            '使用默认模型',
            overflow: TextOverflow.ellipsis,
          )
        else if (selectedValue == addNewModelValue)
          const Text(
            '新增模型',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.blue),
          )
        else
          Text(
            selectedValue,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ...options.map((model) => Text(
              model,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            )),
        const Text(
          '新增模型',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.blue),
        ),
      ],
      onChanged: (value) {
        if (value == addNewModelValue) {
          // 显示添加模型对话框
          _showAddModelDialog(label, options, onChanged);
        } else {
          onChanged(value);
        }
      },
    );
  }

  /// 显示添加模型对话框
  Future<void> _showAddModelDialog(
    String label,
    List<String> existingModels,
    void Function(String?) onChanged,
  ) async {
    final controller = TextEditingController();
    
    try {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text('新增$label模型'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: '模型名称',
                hintText: '请输入模型名称，如：gpt-4-turbo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              autofocus: true,
              onSubmitted: (value) {
                final modelName = value.trim();
                if (modelName.isEmpty) {
                  GlassNotification.show(
                    context,
                    message: '请输入模型名称',
                    icon: Icons.error_outline,
                    backgroundColor: Colors.red.withOpacity(0.2),
                    textColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  );
                  return;
                }
                if (existingModels.contains(modelName)) {
                  GlassNotification.show(
                    context,
                    message: '该模型已存在',
                    icon: Icons.warning_amber_rounded,
                    backgroundColor: Colors.orange.withOpacity(0.2),
                    textColor: Colors.orange,
                    duration: const Duration(seconds: 2),
                  );
                  return;
                }
                Navigator.of(context).pop(modelName);
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  final modelName = controller.text.trim();
                  if (modelName.isEmpty) {
                    GlassNotification.show(
                      context,
                      message: '请输入模型名称',
                      icon: Icons.error_outline,
                      backgroundColor: Colors.red.withOpacity(0.2),
                      textColor: Colors.red,
                      duration: const Duration(seconds: 2),
                    );
                    return;
                  }
                  if (existingModels.contains(modelName)) {
                    GlassNotification.show(
                      context,
                      message: '该模型已存在',
                      icon: Icons.warning_amber_rounded,
                      backgroundColor: Colors.orange.withOpacity(0.2),
                      textColor: Colors.orange,
                      duration: const Duration(seconds: 2),
                    );
                    return;
                  }
                  Navigator.of(context).pop(modelName);
                },
                child: const Text('添加'),
              ),
            ],
          ),
        ),
      );

      // 对话框关闭后，延迟 dispose 确保动画完成
      await Future<void>.delayed(const Duration(milliseconds: 300));
      controller.dispose();

      if (result != null && result.isNotEmpty) {
        // 添加模型到配置（按提供商和类型区分）
        final currentCustomModels = Map<String, List<String>>.from(
          _currentConfig?.customModels ?? {},
        );
        
        final providerKey = _selectedProvider.name;
        final modelTypeKey = label == 'LLM' ? '${providerKey}_llm' : '${providerKey}_vision';
        
        final currentModels = currentCustomModels[modelTypeKey] ?? [];
        if (!currentModels.contains(result)) {
          currentCustomModels[modelTypeKey] = [...currentModels, result];
        }
        
        // 更新配置并保存
        await _saveModelToConfig(customModels: currentCustomModels);
        
        // 选择新添加的模型
        onChanged(result);
      }
    } catch (e) {
      // 确保即使出错也 dispose controller
      controller.dispose();
      rethrow;
    }
  }

  /// 保存模型到配置
  Future<void> _saveModelToConfig({
    required Map<String, List<String>> customModels,
  }) async {
    try {
      final configService = await AiConfigService.getInstance();
      final currentConfig = _currentConfig;
      
      if (currentConfig != null) {
        final updatedConfig = currentConfig.copyWith(
          customModels: customModels,
          updatedAt: DateTime.now(),
        );
        await configService.saveConfig(updatedConfig);
        setState(() {
          _currentConfig = updatedConfig;
        });
      } else {
        // 如果没有配置，创建一个临时配置来保存模型列表
        final tempConfig = AiConfig(
          provider: _selectedProvider,
          apiKey: _apiKeyController.text.trim().isEmpty
              ? 'temp'
              : _apiKeyController.text.trim(),
          customModels: customModels,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await configService.saveConfig(tempConfig);
        setState(() {
          _currentConfig = tempConfig;
        });
      }
    } catch (e) {
      if (mounted) {
        GlassNotification.show(
          context,
          message: '保存模型失败: $e',
          icon: Icons.error_outline,
          backgroundColor: Colors.red.withOpacity(0.2),
          textColor: Colors.red,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }
}

