import 'dart:convert';

import 'package:your_finance_flutter/core/models/ai_config.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/services/ai/ai_config_service.dart';
import 'package:your_finance_flutter/core/services/ai/ai_service_factory.dart';
import 'package:your_finance_flutter/core/services/ai/prompts/prompt_loader.dart';

/// 分类推荐结果
class CategoryRecommendation {
  final TransactionCategory category;
  final String? subCategory;
  final double confidence;
  final String? reason;

  CategoryRecommendation({
    required this.category,
    this.subCategory,
    required this.confidence,
    this.reason,
  });

  Map<String, dynamic> toJson() => {
        'category': category.name,
        'subCategory': subCategory,
        'confidence': confidence,
        'reason': reason,
      };
}

/// 智能分类推荐服务
/// 基于历史交易数据和语义理解，推荐最合适的交易分类
class CategoryRecommendationService {
  CategoryRecommendationService._();
  static CategoryRecommendationService? _instance;

  static Future<CategoryRecommendationService> getInstance() async {
    _instance ??= CategoryRecommendationService._();
    return _instance!;
  }

  /// 推荐分类
  ///
  /// [description] 交易描述
  /// [userHistory] 用户历史交易数据（用于学习用户习惯）
  /// [transactionType] 交易类型（收入/支出，可选，如果不提供则根据描述推断）
  ///
  /// 返回推荐结果
  Future<CategoryRecommendation> recommendCategory({
    required String description,
    List<Transaction>? userHistory,
    TransactionType? transactionType,
  }) async {
    print(
      '[CategoryRecommendationService.recommendCategory] 📝 开始推荐分类: $description',
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

      // 3. 构建提示词
      final systemPrompt =
          await _buildSystemPrompt(userHistory, transactionType);
      final userPrompt = _buildUserPrompt(description);

      // 4. 调用LLM模型
      final response = await aiService.sendMessage(
        messages: [
          AiMessage(role: 'system', content: systemPrompt),
          AiMessage(role: 'user', content: userPrompt),
        ],
        temperature: 0.3, // 降低温度以提高准确性
        maxTokens: 300,
      );

      print(
        '[CategoryRecommendationService.recommendCategory] ✅ AI响应: ${response.content}',
      );

      // 5. 解析响应
      final recommendation = _parseAiResponse(response.content);

      print(
        '[CategoryRecommendationService.recommendCategory] ✅ 推荐完成: ${recommendation.toJson()}',
      );

      return recommendation;
    } catch (e, stackTrace) {
      print(
        '[CategoryRecommendationService.recommendCategory] ❌ 推荐失败: $e',
      );
      print(
        '[CategoryRecommendationService.recommendCategory] 堆栈: $stackTrace',
      );

      // 返回默认推荐
      return CategoryRecommendation(
        category: transactionType == TransactionType.income
            ? TransactionCategory.otherIncome
            : TransactionCategory.otherExpense,
        confidence: 0.3,
        reason: 'AI服务不可用，使用默认分类',
      );
    }
  }

  /// 构建系统提示词
  Future<String> _buildSystemPrompt(
    List<Transaction>? userHistory,
    TransactionType? transactionType,
  ) async {
    // 构建用户历史部分
    String? userHistorySection;
    if (userHistory != null && userHistory.isNotEmpty) {
      final buffer = StringBuffer();
      buffer.writeln('## 用户历史偏好');

      // 统计分类使用频率
      final categoryCount = <TransactionCategory, int>{};
      final descriptionCategoryMap = <String, TransactionCategory>{};

      // 分析最近50条交易
      final recentTransactions = userHistory.take(50).toList();
      for (final transaction in recentTransactions) {
        categoryCount[transaction.category] =
            (categoryCount[transaction.category] ?? 0) + 1;

        // 记录描述和分类的映射（用于相似描述匹配）
        if (transaction.description.isNotEmpty) {
          descriptionCategoryMap[transaction.description.toLowerCase()] =
              transaction.category;
        }
      }

      // 输出常用分类
      if (categoryCount.isNotEmpty) {
        buffer.writeln('常用分类（按使用频率排序）：');
        final sortedCategories = categoryCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        for (final entry in sortedCategories.take(5)) {
          buffer.writeln(
            '- ${entry.key.displayName}: ${entry.value}次',
          );
        }
        buffer.writeln();
      }

      // 输出相似描述示例（如果有）
      if (descriptionCategoryMap.isNotEmpty) {
        buffer.writeln('相似交易示例：');
        final examples = descriptionCategoryMap.entries.take(10).toList();
        for (final entry in examples) {
          buffer.writeln(
            '- "${entry.key}": ${entry.value.displayName}',
          );
        }
        buffer.writeln();
      }

      userHistorySection = buffer.toString();
    }

    // 从文件加载提示词模板
    final template = await PromptLoader.loadCategoryRecommendationPrompt(
      userHistorySection: userHistorySection,
      transactionType: transactionType,
    );

    return template;
  }

  /// 构建用户提示词
  String _buildUserPrompt(String description) =>
      '请为以下交易描述推荐最合适的分类：\n\n$description';

  /// 解析AI响应
  CategoryRecommendation _parseAiResponse(String response) {
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

      // 解析分类
      TransactionCategory category;
      if (json['category'] != null) {
        try {
          category = TransactionCategory.values.firstWhere(
            (e) => e.name == json['category'],
            orElse: () => TransactionCategory.otherExpense,
          );
        } catch (e) {
          print(
            '[CategoryRecommendationService._parseAiResponse] ⚠️ 分类解析失败: ${json['category']}',
          );
          category = TransactionCategory.otherExpense;
        }
      } else {
        category = TransactionCategory.otherExpense;
      }

      // 解析子分类
      final subCategory = json['subCategory'] as String?;

      // 解析置信度
      final confidence = (json['confidence'] as num?)?.toDouble() ?? 0.5;

      // 解析推荐理由
      final reason = json['reason'] as String?;

      return CategoryRecommendation(
        category: category,
        subCategory: subCategory,
        confidence: confidence,
        reason: reason,
      );
    } catch (e) {
      print(
        '[CategoryRecommendationService._parseAiResponse] ❌ JSON解析失败: $e',
      );
      print(
        '[CategoryRecommendationService._parseAiResponse] 响应内容: $response',
      );

      // 返回默认推荐
      return CategoryRecommendation(
        category: TransactionCategory.otherExpense,
        confidence: 0.3,
        reason: '解析失败，使用默认分类',
      );
    }
  }
}
