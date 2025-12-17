import 'package:your_finance_flutter/core/models/ai_config.dart';
import 'package:your_finance_flutter/core/services/ai/ai_service.dart';

/// AI服务工厂接口
abstract class AiServiceFactory {
  /// 根据配置创建AI服务实例
  AiService createService(AiConfig config);
}

/// AI服务工厂 - 根据配置创建对应的AI服务实例
class AiServiceFactoryImpl implements AiServiceFactory {
  /// 根据配置创建AI服务实例
  AiService createService(AiConfig config) {
    // 目前只支持基础的AI服务，具体实现由子类决定
    throw UnimplementedError('AI service creation not implemented for ${config.provider}');
  }

  /// 根据提供商创建默认配置的服务实例
  AiService createServiceWithProvider(
    AiProvider provider,
    String apiKey, {
    String? baseUrl,
  }) {
    final config = AiConfig(
      provider: provider,
      apiKey: apiKey,
      baseUrl: baseUrl,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return createService(config);
  }
}

/// 全局AI服务工厂实例
final aiServiceFactory = AiServiceFactoryImpl();
