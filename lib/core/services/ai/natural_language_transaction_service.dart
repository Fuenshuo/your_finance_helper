import 'dart:convert';

import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/models/ai_config.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/models/parsed_transaction.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/services/ai/ai_config_service.dart';
import 'package:your_finance_flutter/core/services/ai/ai_service_factory.dart';
import 'package:your_finance_flutter/core/services/ai/prompts/prompt_loader.dart';
import 'package:your_finance_flutter/core/utils/ai_date_parser.dart';

/// 自然语言记账服务
/// 负责解析自然语言输入并提取交易信息
class NaturalLanguageTransactionService {
  NaturalLanguageTransactionService._();
  static NaturalLanguageTransactionService? _instance;

  static Future<NaturalLanguageTransactionService> getInstance() async {
    _instance ??= NaturalLanguageTransactionService._();
    return _instance!;
  }

  /// 解析自然语言输入
  ///
  /// [input] 用户输入的自然语言描述
  /// [userHistory] 用户历史交易数据（用于智能推荐）
  /// [accounts] 可用账户列表
  /// [budgets] 可用预算列表
  ///
  /// 返回解析后的交易数据
  Future<ParsedTransaction> parseNaturalLanguage({
    required String input,
    List<Transaction>? userHistory,
    List<Account>? accounts,
    List<EnvelopeBudget>? budgets,
  }) async {
    print(
      '[NaturalLanguageTransactionService.parseNaturalLanguage] 📝 开始解析自然语言: $input',
    );

    try {
      // 1. 获取AI配置
      final configService = await AiConfigService.getInstance();
      final config = await configService.loadConfig();

      if (config == null || !config.enabled) {
        throw Exception('AI服务未配置或已禁用');
      }

      // 2. 创建AI服务实例
      final aiService = AiServiceFactory.createService(config);

      // 3. 构建提示词
      final systemPrompt =
          await _buildSystemPrompt(userHistory, accounts, budgets);
      final userPrompt = _buildUserPrompt(input);

      // 4. 调用LLM模型
      final response = await aiService.sendMessage(
        messages: [
          AiMessage(role: 'system', content: systemPrompt),
          AiMessage(role: 'user', content: userPrompt),
        ],
        temperature: 0.3, // 降低温度以提高准确性
        maxTokens: 500,
      );

      print(
        '[NaturalLanguageTransactionService.parseNaturalLanguage] ✅ AI响应: ${response.content}',
      );

      // 5. 解析响应
      final parsed = _parseAiResponse(response.content, accounts, budgets);

      print(
        '[NaturalLanguageTransactionService.parseNaturalLanguage] ✅ 解析完成: ${parsed.toJson()}',
      );

      return parsed;
    } catch (e, stackTrace) {
      print(
        '[NaturalLanguageTransactionService.parseNaturalLanguage] ❌ 解析失败: $e',
      );
      print(
        '[NaturalLanguageTransactionService.parseNaturalLanguage] 堆栈: $stackTrace',
      );
      rethrow;
    }
  }

  /// 构建系统提示词
  Future<String> _buildSystemPrompt(
    List<Transaction>? userHistory,
    List<Account>? accounts,
    List<EnvelopeBudget>? budgets,
  ) async {
    // 准备账户数据
    List<Map<String, String>>? accountsData;
    if (accounts != null && accounts.isNotEmpty) {
      accountsData = accounts
          .map(
            (a) => {
              'name': a.name,
              'type': a.type.displayName,
            },
          )
          .toList();
    }

    // 准备预算数据
    List<Map<String, String>>? budgetsData;
    if (budgets != null && budgets.isNotEmpty) {
      budgetsData = budgets
          .map(
            (b) => {
              'name': b.name,
              'category': b.category.displayName,
            },
          )
          .toList();
    }

    // 构建用户历史部分
    String? userHistorySection;
    if (userHistory != null && userHistory.isNotEmpty) {
      final buffer = StringBuffer();
      buffer.writeln('## 用户历史偏好');
      final categoryCount = <TransactionCategory, int>{};

      for (final transaction in userHistory.take(20)) {
        categoryCount[transaction.category] =
            (categoryCount[transaction.category] ?? 0) + 1;
      }

      if (categoryCount.isNotEmpty) {
        buffer.writeln('常用分类：');
        final sortedCategories = categoryCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        for (final entry in sortedCategories.take(5)) {
          buffer.writeln('- ${entry.key.displayName}');
        }
        buffer.writeln();
      }
      userHistorySection = buffer.toString();
    }

    // 从文件加载提示词模板
    return PromptLoader.loadNaturalLanguagePrompt(
      accounts: accountsData,
      budgets: budgetsData,
      userHistorySection: userHistorySection,
    );
  }

  /// 构建用户提示词
  String _buildUserPrompt(String input) => '请从以下描述中提取交易信息：\n\n$input';

  /// 解析AI响应
  ParsedTransaction _parseAiResponse(
    String response,
    List<Account>? accounts,
    List<EnvelopeBudget>? budgets,
  ) {
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

      // 匹配账户
      String? accountId;
      String? accountName;
      if (json['accountName'] != null && accounts != null) {
        final accountNameStr = json['accountName'] as String;
        final matchedAccount = accounts.firstWhere(
          (a) =>
              a.name.contains(accountNameStr) ||
              accountNameStr.contains(a.name),
          orElse: () => accounts.first,
        );
        accountId = matchedAccount.id;
        accountName = matchedAccount.name;
      }

      // 匹配预算
      String? envelopeBudgetId;
      if (json['budgetCategory'] != null && budgets != null) {
        final budgetCategoryStr = json['budgetCategory'] as String;
        final matchedBudget = budgets.firstWhere(
          (b) =>
              b.category.displayName.contains(budgetCategoryStr) ||
              budgetCategoryStr.contains(b.category.displayName),
          orElse: () => budgets.first,
        );
        envelopeBudgetId = matchedBudget.id;
      }

      // 解析日期（使用统一的日期解析工具）
      // 对于自然语言输入，如果用户说"今天"、"昨天"等，需要正确解析
      // 如果AI返回的日期不合理，使用当前日期
      final dateStr = json['date'] as String?;
      DateTime? date;
      if (dateStr != null) {
        date = AiDateParser.parseDate(
          dateStr: dateStr,
          defaultDate: DateTime.now(),
        );
      }

      return ParsedTransaction(
        description: json['description'] as String?,
        amount: (json['amount'] as num?)?.toDouble(),
        type: json['type'] != null
            ? TransactionType.values.firstWhere(
                (e) => e.name == json['type'],
                orElse: () => TransactionType.expense,
              )
            : null,
        category: json['category'] != null
            ? TransactionCategory.values.firstWhere(
                (e) => e.name == json['category'],
                orElse: () => TransactionCategory.otherExpense,
              )
            : null,
        subCategory: json['subCategory'] as String?,
        accountId: accountId,
        accountName: accountName,
        envelopeBudgetId: envelopeBudgetId,
        date: date,
        notes: json['notes'] as String?,
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.8,
        source: ParsedTransactionSource.naturalLanguage,
        rawData: json,
      );
    } catch (e) {
      print(
        '[NaturalLanguageTransactionService._parseAiResponse] ❌ JSON解析失败: $e',
      );
      print(
        '[NaturalLanguageTransactionService._parseAiResponse] 响应内容: $response',
      );

      // 返回一个基础的解析结果
      return ParsedTransaction(
        description: response,
        confidence: 0.3,
        source: ParsedTransactionSource.naturalLanguage,
        rawData: {'raw': response},
      );
    }
  }
}
