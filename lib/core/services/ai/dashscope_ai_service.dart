import 'package:dio/dio.dart';
import 'package:your_finance_flutter/core/models/ai_config.dart';
import 'package:your_finance_flutter/core/services/ai/ai_service.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';

/// DashScope AI服务实现
class DashScopeAiService extends AiService {
  DashScopeAiService(super.config);

  static const String _baseUrl = 'https://dashscope.aliyuncs.com/api/v1';
  Dio? _dio;

  @override
  String get providerName => 'DashScope (阿里云)';

  /// 获取或初始化Dio客户端
  Dio get _getDio {
    if (_dio == null) {
      _dio = Dio(
        BaseOptions(
          baseUrl: config.baseUrl ?? _baseUrl,
          headers: {
            'Authorization': 'Bearer ${config.apiKey}',
            'Content-Type': 'application/json',
          },
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
    }
    return _dio!;
  }

  @override
  List<String> getAvailableLlmModels() {
    return [
      'qwen-turbo',
      'qwen-plus',
      'qwen-max',
      'qwen-max-longcontext',
    ];
  }

  @override
  List<String> getAvailableVisionModels() {
    return [
      'qwen-vl-plus',
      'qwen-vl-max',
    ];
  }

  @override
  Future<AiResponse> sendMessage({
    required List<AiMessage> messages,
    String? model,
    double? temperature,
    int? maxTokens,
    Map<String, dynamic>? extraParams,
  }) async {
    final selectedModel = model ?? config.llmModel ?? getAvailableLlmModels().first;
    final requestBody = {
      'model': selectedModel,
      'input': {
        'messages': messages.map((m) => m.toJson()).toList(),
      },
      'parameters': {
        if (temperature != null) 'temperature': temperature,
        if (maxTokens != null) 'max_tokens': maxTokens,
        ...?extraParams,
      },
    };

    try {
      Log.business('DashScopeAiService', '发送LLM请求', {
        'model': selectedModel,
        'messageCount': messages.length,
      });

      final response = await _getDio.post<Map<String, dynamic>>(
        '/services/aigc/text-generation/generation',
        data: requestBody,
      );

      if (response.data == null) {
        throw const AiServiceException('响应数据为空');
      }

      final aiResponse = _parseResponse(response.data!, selectedModel);
      
      Log.business('DashScopeAiService', 'LLM响应成功', {
        'model': aiResponse.model,
        'contentLength': aiResponse.content.length,
        'tokenUsage': aiResponse.tokenUsage != null
            ? {
                'promptTokens': aiResponse.tokenUsage!.promptTokens,
                'completionTokens': aiResponse.tokenUsage!.completionTokens,
                'totalTokens': aiResponse.tokenUsage!.totalTokens,
              }
            : null,
        'finishReason': aiResponse.finishReason,
      });

      return aiResponse;
    } on DioException catch (e) {
      throw AiServiceException(
        'DashScope请求失败: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw AiServiceException('DashScope请求异常: $e', originalError: e);
    }
  }

  @override
  Future<AiResponse> sendVisionMessage({
    required List<AiMessage> messages,
    String? model,
    double? temperature,
    int? maxTokens,
    Map<String, dynamic>? extraParams,
  }) async {
    final selectedModel = model ?? config.visionModel ?? getAvailableVisionModels().first;
    
    // 转换消息格式：DashScope也使用OpenAI兼容的content数组格式
    final formattedMessages = messages.map((m) {
      final json = m.toJson();
      
      // 如果有图片，需要转换为OpenAI兼容格式
      if (m.images != null && m.images!.isNotEmpty) {
        final content = <dynamic>[];
        
        // 添加文本内容
        if (m.content.isNotEmpty) {
          content.add({'type': 'text', 'text': m.content});
        }
        
        // 添加图片内容（OpenAI兼容格式）
        for (final imageUrl in m.images!) {
          content.add({
            'type': 'image_url',
            'image_url': {'url': imageUrl},
          });
        }
        
        json['content'] = content;
        // 移除images字段，因为已经转换为content格式
        json.remove('images');
      }
      
      return json;
    }).toList();
    
    final requestBody = {
      'model': selectedModel,
      'input': {
        'messages': formattedMessages,
      },
      'parameters': {
        if (temperature != null) 'temperature': temperature,
        if (maxTokens != null) 'max_tokens': maxTokens,
        ...?extraParams,
      },
    };

    try {
      // 调试日志：检查图片是否正确传递
      final hasImages = formattedMessages.any((m) => 
        m['content'] is List && 
        (m['content'] as List).any((item) => 
          item is Map && item['type'] == 'image_url'
        )
      );
      
      Log.business('DashScopeAiService', '发送Vision请求', {
        'model': selectedModel,
        'messageCount': messages.length,
        'hasImages': hasImages,
        'imageCount': messages.fold<int>(0, (sum, m) => sum + (m.images?.length ?? 0)),
      });

      final response = await _getDio.post<Map<String, dynamic>>(
        '/services/aigc/multimodal-generation/generation',
        data: requestBody,
      );

      if (response.data == null) {
        throw const AiServiceException('响应数据为空');
      }

      final aiResponse = _parseResponse(response.data!, selectedModel);
      
      Log.business('DashScopeAiService', 'Vision响应成功', {
        'model': aiResponse.model,
        'contentLength': aiResponse.content.length,
        'tokenUsage': aiResponse.tokenUsage != null
            ? {
                'promptTokens': aiResponse.tokenUsage!.promptTokens,
                'completionTokens': aiResponse.tokenUsage!.completionTokens,
                'totalTokens': aiResponse.tokenUsage!.totalTokens,
              }
            : null,
        'finishReason': aiResponse.finishReason,
      });

      return aiResponse;
    } on DioException catch (e) {
      throw AiServiceException(
        'DashScope Vision请求失败: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw AiServiceException('DashScope Vision请求异常: $e', originalError: e);
    }
  }

  /// 解析DashScope响应
  AiResponse _parseResponse(Map<String, dynamic> data, String model) {
    try {
      final output = data['output'] as Map<String, dynamic>?;
      if (output == null) {
        throw const AiServiceException('响应格式错误：缺少output字段');
      }

      final choices = output['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        throw const AiServiceException('响应格式错误：缺少choices字段');
      }

      final firstChoice = choices.first as Map<String, dynamic>;
      final message = firstChoice['message'] as Map<String, dynamic>?;
      final content = message?['content'] as String? ?? '';

      final usage = data['usage'] as Map<String, dynamic>?;
      final tokenUsage = usage != null
          ? TokenUsage(
              promptTokens: usage['input_tokens'] as int? ?? 0,
              completionTokens: usage['output_tokens'] as int? ?? 0,
              totalTokens: (usage['input_tokens'] as int? ?? 0) +
                  (usage['output_tokens'] as int? ?? 0),
            )
          : null;

      return AiResponse(
        content: content,
        model: model,
        tokenUsage: tokenUsage,
        finishReason: firstChoice['finish_reason'] as String?,
      );
    } catch (e) {
      throw AiServiceException('解析DashScope响应失败: $e', originalError: e);
    }
  }

  @override
  Future<bool> validateApiKey() async {
    try {
      // 发送一个简单的测试请求来验证API Key
      final testResponse = await sendMessage(
        messages: const [
          AiMessage(role: 'user', content: 'test'),
        ],
        maxTokens: 10,
      );
      return testResponse.content.isNotEmpty;
    } catch (e) {
      Log.error('DashScopeAiService', 'API Key验证失败', {'error': e.toString()});
      return false;
    }
  }
}

