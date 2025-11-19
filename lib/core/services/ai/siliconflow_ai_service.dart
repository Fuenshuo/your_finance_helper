import 'package:dio/dio.dart';
import 'package:your_finance_flutter/core/models/ai_config.dart';
import 'package:your_finance_flutter/core/services/ai/ai_service.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';

/// SiliconFlow AI服务实现
class SiliconFlowAiService extends AiService {
  SiliconFlowAiService(super.config);

  static const String _baseUrl = 'https://api.siliconflow.cn/v1';
  Dio? _dio;

  @override
  String get providerName => 'SiliconFlow';

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
      'Qwen/Qwen2.5-72B-Instruct',
      'Qwen/Qwen2.5-32B-Instruct',
      'Qwen/Qwen2.5-14B-Instruct',
      'Qwen/Qwen2.5-7B-Instruct',
      'deepseek-ai/DeepSeek-V3',
      'meta-llama/Meta-Llama-3.1-70B-Instruct',
    ];
  }

  @override
  List<String> getAvailableVisionModels() {
    return [
      'Qwen/Qwen2-VL-7B-Instruct',
      'Qwen/Qwen2-VL-2B-Instruct',
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
      'messages': messages.map((m) => m.toJson()).toList(),
      if (temperature != null) 'temperature': temperature,
      if (maxTokens != null) 'max_tokens': maxTokens,
      ...?extraParams,
    };

    try {
      Log.business('SiliconFlowAiService', '发送LLM请求', {
        'model': selectedModel,
        'messageCount': messages.length,
      });

      final response = await _getDio.post<Map<String, dynamic>>(
        '/chat/completions',
        data: requestBody,
      );

      if (response.data == null) {
        throw const AiServiceException('响应数据为空');
      }

      final aiResponse = _parseResponse(response.data!, selectedModel);
      
      Log.business('SiliconFlowAiService', 'LLM响应成功', {
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
        'SiliconFlow请求失败: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw AiServiceException('SiliconFlow请求异常: $e', originalError: e);
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
    
    // 转换消息格式：将图片转换为OpenAI兼容的content数组格式
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
      'messages': formattedMessages,
      if (temperature != null) 'temperature': temperature,
      if (maxTokens != null) 'max_tokens': maxTokens,
      ...?extraParams,
    };

    try {
      // 调试日志：检查图片是否正确传递
      final hasImages = formattedMessages.any((m) => 
        m['content'] is List && 
        (m['content'] as List).any((item) => 
          item is Map && item['type'] == 'image_url'
        )
      );
      
      Log.business('SiliconFlowAiService', '发送Vision请求', {
        'model': selectedModel,
        'messageCount': messages.length,
        'hasImages': hasImages,
        'imageCount': messages.fold<int>(0, (sum, m) => sum + (m.images?.length ?? 0)),
      });

      final response = await _getDio.post<Map<String, dynamic>>(
        '/chat/completions',
        data: requestBody,
      );

      if (response.data == null) {
        throw const AiServiceException('响应数据为空');
      }

      final aiResponse = _parseResponse(response.data!, selectedModel);
      
      Log.business('SiliconFlowAiService', 'Vision响应成功', {
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
        'SiliconFlow Vision请求失败: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw AiServiceException('SiliconFlow Vision请求异常: $e', originalError: e);
    }
  }

  /// 解析SiliconFlow响应（OpenAI兼容格式）
  AiResponse _parseResponse(Map<String, dynamic> data, String model) {
    try {
      final choices = data['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        throw const AiServiceException('响应格式错误：缺少choices字段');
      }

      final firstChoice = choices.first as Map<String, dynamic>;
      final message = firstChoice['message'] as Map<String, dynamic>?;
      final content = message?['content'] as String? ?? '';

      final usage = data['usage'] as Map<String, dynamic>?;
      final tokenUsage = usage != null
          ? TokenUsage(
              promptTokens: usage['prompt_tokens'] as int? ?? 0,
              completionTokens: usage['completion_tokens'] as int? ?? 0,
              totalTokens: usage['total_tokens'] as int? ?? 0,
            )
          : null;

      return AiResponse(
        content: content,
        model: model,
        tokenUsage: tokenUsage,
        finishReason: firstChoice['finish_reason'] as String?,
      );
    } catch (e) {
      throw AiServiceException('解析SiliconFlow响应失败: $e', originalError: e);
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
      Log.error('SiliconFlowAiService', 'API Key验证失败', {'error': e.toString()});
      return false;
    }
  }
}

