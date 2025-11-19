import 'package:equatable/equatable.dart';

/// AI服务提供商枚举
enum AiProvider {
  /// 阿里云DashScope
  dashscope,

  /// SiliconFlow
  siliconFlow,
}

/// AI模型类型枚举
enum AiModelType {
  /// 大语言模型（文本生成、对话）
  llm,

  /// 图文分析模型（多模态）
  vision,
}

/// AI配置模型
class AiConfig extends Equatable {
  const AiConfig({
    required this.provider,
    required this.apiKey,
    required this.createdAt,
    required this.updatedAt,
    this.baseUrl,
    this.enabled = true,
    this.llmModel,
    this.visionModel,
    this.customModels = const {},
  });

  /// 从JSON创建
  factory AiConfig.fromJson(Map<String, dynamic> json) {
    // 兼容旧版本：如果有 customLlmModels 和 customVisionModels，转换为新格式
    Map<String, List<String>> customModels = {};
    if (json['customModels'] != null) {
      final modelsMap = json['customModels'] as Map<String, dynamic>;
      customModels = modelsMap.map(
        (key, value) => MapEntry(key, List<String>.from(value as List)),
      );
    } else {
      // 兼容旧版本数据
      final providerName = json['provider'] as String? ?? 'dashscope';
      if (json['customLlmModels'] != null || json['customVisionModels'] != null) {
        customModels[providerName] = [
          ...(json['customLlmModels'] != null
              ? List<String>.from(json['customLlmModels'] as List)
              : []),
          ...(json['customVisionModels'] != null
              ? List<String>.from(json['customVisionModels'] as List)
              : []),
        ];
      }
    }

    return AiConfig(
      provider: AiProvider.values.firstWhere(
        (p) => p.name == json['provider'],
        orElse: () => AiProvider.dashscope,
      ),
      apiKey: json['apiKey'] as String,
      baseUrl: json['baseUrl'] as String?,
      enabled: json['enabled'] as bool? ?? true,
      llmModel: json['llmModel'] as String?,
      visionModel: json['visionModel'] as String?,
      customModels: customModels,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// 服务提供商
  final AiProvider provider;

  /// API Key
  final String apiKey;

  /// 基础URL（可选，某些提供商可能需要自定义）
  final String? baseUrl;

  /// 是否启用
  final bool enabled;

  /// LLM模型（大语言模型）
  final String? llmModel;

  /// Vision模型（图文分析模型）
  final String? visionModel;

  /// 用户自定义的模型列表，按提供商和模型类型分组
  /// 格式：{ 'provider_name': ['model1', 'model2'], ... }
  /// 或者：{ 'provider_name_llm': ['model1', 'model2'], 'provider_name_vision': ['model3'] }
  final Map<String, List<String>> customModels;

  /// 获取指定提供商的LLM模型列表
  List<String> getCustomLlmModels(AiProvider provider) {
    final key = '${provider.name}_llm';
    return customModels[key] ?? [];
  }

  /// 获取指定提供商的Vision模型列表
  List<String> getCustomVisionModels(AiProvider provider) {
    final key = '${provider.name}_vision';
    return customModels[key] ?? [];
  }

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
        'provider': provider.name,
        'apiKey': apiKey,
        'baseUrl': baseUrl,
        'enabled': enabled,
        'llmModel': llmModel,
        'visionModel': visionModel,
        'customModels': customModels.map(
          (key, value) => MapEntry(key, value),
        ),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  /// 复制并更新
  AiConfig copyWith({
    AiProvider? provider,
    String? apiKey,
    String? baseUrl,
    bool? enabled,
    String? llmModel,
    String? visionModel,
    Map<String, List<String>>? customModels,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      AiConfig(
        provider: provider ?? this.provider,
        apiKey: apiKey ?? this.apiKey,
        baseUrl: baseUrl ?? this.baseUrl,
        enabled: enabled ?? this.enabled,
        llmModel: llmModel ?? this.llmModel,
        visionModel: visionModel ?? this.visionModel,
        customModels: customModels ?? this.customModels,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [
        provider,
        apiKey,
        baseUrl,
        enabled,
        llmModel,
        visionModel,
        customModels,
        createdAt,
        updatedAt,
      ];
}

/// AI请求消息
class AiMessage {
  const AiMessage({
    required this.role,
    required this.content,
    this.images,
  });

  /// 角色：user, assistant, system
  final String role;

  /// 消息内容
  final String content;

  /// 图片URL（用于多模态）
  final List<String>? images;

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
        if (images != null && images!.isNotEmpty) 'images': images,
      };
}

/// AI响应结果
class AiResponse {
  const AiResponse({
    required this.content,
    required this.model,
    this.tokenUsage,
    this.finishReason,
  });

  factory AiResponse.fromJson(Map<String, dynamic> json) => AiResponse(
        content: json['content'] as String,
        model: json['model'] as String,
        tokenUsage: json['tokenUsage'] != null
            ? TokenUsage.fromJson(json['tokenUsage'] as Map<String, dynamic>)
            : null,
        finishReason: json['finishReason'] as String?,
      );

  /// 响应内容
  final String content;

  /// 使用的模型
  final String model;

  /// Token使用情况
  final TokenUsage? tokenUsage;

  /// 完成原因
  final String? finishReason;
}

/// Token使用情况
class TokenUsage {
  const TokenUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory TokenUsage.fromJson(Map<String, dynamic> json) => TokenUsage(
        promptTokens: json['promptTokens'] as int? ?? 0,
        completionTokens: json['completionTokens'] as int? ?? 0,
        totalTokens: json['totalTokens'] as int? ?? 0,
      );

  /// 输入Token数
  final int promptTokens;

  /// 输出Token数
  final int completionTokens;

  /// 总Token数
  final int totalTokens;
}
