import 'package:your_finance_flutter/core/models/ai_config.dart';

/// AI服务异常
class AiServiceException implements Exception {
  const AiServiceException(
    this.message, {
    this.statusCode,
    this.originalError,
  });
  final String message;
  final int? statusCode;
  final dynamic originalError;

  @override
  String toString() => 'AiServiceException: $message';
}

/// AI服务抽象接口
abstract class AiService {
  AiService(this.config);

  /// 配置信息
  final AiConfig config;

  /// 发送文本消息（大语言模型）
  Future<AiResponse> sendMessage({
    required List<AiMessage> messages,
    String? model,
    double? temperature,
    int? maxTokens,
    Map<String, dynamic>? extraParams,
  });

  /// 发送图文消息（多模态模型）
  Future<AiResponse> sendVisionMessage({
    required List<AiMessage> messages,
    String? model,
    double? temperature,
    int? maxTokens,
    Map<String, dynamic>? extraParams,
  });

  /// 获取可用的LLM模型列表
  List<String> getAvailableLlmModels();

  /// 获取可用的Vision模型列表
  List<String> getAvailableVisionModels();

  /// 验证API Key是否有效
  Future<bool> validateApiKey();

  /// 获取服务提供商名称
  String get providerName;
}
