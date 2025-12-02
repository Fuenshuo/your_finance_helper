import 'dart:convert';
import 'dart:io';

import 'package:your_finance_flutter/core/models/ai_config.dart';
import 'package:your_finance_flutter/core/services/ai/ai_config_service.dart';
import 'package:your_finance_flutter/core/services/ai/ai_service_factory.dart';
import 'package:your_finance_flutter/core/services/ai/image_processing_service.dart';
import 'package:your_finance_flutter/core/services/ai/prompts/prompt_loader.dart';

/// 资产识别结果（简化版 - 只识别品牌和型号，不估值）
class AssetValuationResult {
  final String brand;
  final String model;
  final double confidence;

  AssetValuationResult({
    required this.brand,
    required this.model,
    required this.confidence,
  });

  /// 获取资产名称（品牌 + 型号）
  String get assetName => '$brand $model'.trim();

  Map<String, dynamic> toJson() => {
        'brand': brand,
        'model': model,
        'confidence': confidence,
      };
}

/// 资产识别服务（简化版）
/// 通过照片识别资产的品牌和型号，不进行估值
class AssetValuationService {
  AssetValuationService._();
  static AssetValuationService? _instance;

  static Future<AssetValuationService> getInstance() async {
    _instance ??= AssetValuationService._();
    return _instance!;
  }

  /// 识别资产的品牌和型号（简化版 - 不估值）
  ///
  /// [imagePath] 资产照片路径
  ///
  /// 返回识别结果（品牌和型号）
  Future<AssetValuationResult> valuateAsset({
    required String imagePath,
  }) async {
    print(
      '[AssetValuationService.valuateAsset] 📸 开始识别资产型号: $imagePath',
    );

    try {
      // 1. 获取AI配置
      final configService = await AiConfigService.getInstance();
      final config = await configService.loadConfig();

      if (config == null || !config.enabled) {
        throw Exception('AI服务未配置或已禁用');
      }

      // 2. 创建AI服务实例
      final aiService = aiServiceFactory.createService(config);

      // 3. 处理图片
      final imageService = ImageProcessingService.getInstance();
      final imageFile = File(imagePath);
      final imageBase64 = await imageService.convertToBase64(imageFile);

      // 4. 构建提示词
      final systemPrompt = await PromptLoader.loadAssetValuationPrompt();

      // 5. 调用Vision模型
      final response = await aiService.sendVisionMessage(
        messages: [
          AiMessage(
            role: 'user',
            content: systemPrompt,
            images: [imageBase64],
          ),
        ],
        temperature: 0.3, // 降低温度以提高准确性
        maxTokens: 1000,
      );

      print(
        '[AssetValuationService.valuateAsset] ✅ AI响应: ${response.content}',
      );

      // 6. 解析响应
      final result = _parseAiResponse(response.content);

      print(
        '[AssetValuationService.valuateAsset] ✅ 识别完成: ${result.brand} ${result.model}, 置信度=${result.confidence}',
      );

      return result;
    } catch (e, stackTrace) {
      print(
        '[AssetValuationService.valuateAsset] ❌ 识别失败: $e',
      );
      print(
        '[AssetValuationService.valuateAsset] 堆栈: $stackTrace',
      );
      rethrow;
    }
  }

  /// 解析AI响应（简化版 - 只解析品牌和型号）
  AssetValuationResult _parseAiResponse(String response) {
    try {
      // 尝试提取JSON（可能包含markdown代码块）
      var jsonStr = response.trim();

      // 移除markdown代码块标记
      if (jsonStr.startsWith('```')) {
        final lines = jsonStr.split('\n');
        jsonStr = lines.skip(1).take(lines.length - 2).join('\n');
      }

      // 移除可能的json标记
      if (jsonStr.startsWith('json')) {
        jsonStr = jsonStr.substring(4).trim();
      }

      // 解析JSON
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;

      return AssetValuationResult(
        brand: json['brand'] as String? ?? '未知品牌',
        model: json['model'] as String? ?? '未知型号',
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      );
    } catch (e) {
      print(
        '[AssetValuationService._parseAiResponse] ❌ JSON解析失败: $e',
      );
      print(
        '[AssetValuationService._parseAiResponse] 响应内容: $response',
      );
      rethrow;
    }
  }
}

