import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/models/ai_config.dart';
import 'package:your_finance_flutter/core/models/ai_nlp_tuning_config.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/models/parsed_transaction.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/services/ai/ai_config_service.dart';
import 'package:your_finance_flutter/core/services/ai/ai_service_factory.dart';
import 'package:your_finance_flutter/core/services/ai/ai_tuning_config_service.dart';
import 'package:your_finance_flutter/core/services/ai/prompts/prompt_loader.dart';
import 'package:your_finance_flutter/core/services/user_income_profile_service.dart';
import 'package:your_finance_flutter/core/utils/ai_date_parser.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';

/// 自然语言记账服务
/// 负责解析自然语言输入并提取交易信息
class NaturalLanguageTransactionService {
  NaturalLanguageTransactionService._();
  static NaturalLanguageTransactionService? _instance;
  static const String _promptBaseDir = 'lib/core/services/ai/prompts';
  static const String _defaultPromptFilename = 'natural_language_prompt.txt';

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
      // 0. 读取AI调参配置
      final tuningService = await AiTuningConfigService.getInstance();
      final tuningConfig = await tuningService.loadConfig();

      // 1. 获取AI配置
      final configService = await AiConfigService.getInstance();
      final config = await configService.loadConfig();

      if (config == null || !config.enabled) {
        throw Exception('AI服务未配置或已禁用');
      }

      // 2. 创建AI服务实例
      final aiService = AiServiceFactory.createService(config);

      // 3. 构建提示词
      final systemPrompt = await _buildSystemPrompt(
        userHistory,
        accounts,
        budgets,
        tuningConfig,
      );
      final userPrompt = _buildUserPrompt(input);

      // 打印完整的prompt用于调试
      print(
        '[NaturalLanguageTransactionService.parseNaturalLanguage] 📋 System Prompt:\n$systemPrompt',
      );
      print(
        '[NaturalLanguageTransactionService.parseNaturalLanguage] 📋 User Prompt:\n$userPrompt',
      );
      print(
        '[NaturalLanguageTransactionService.parseNaturalLanguage] 📋 账户列表: ${accounts?.map((a) => a.name).toList() ?? []}',
      );

      // 4. 调用LLM模型（使用小模型加速识别）
      final response = await aiService.sendMessage(
        messages: [
          AiMessage(role: 'system', content: systemPrompt),
          AiMessage(role: 'user', content: userPrompt),
        ],
        model: tuningConfig.modelId,
        temperature: tuningConfig.temperature,
        maxTokens: tuningConfig.maxTokens,
      );

      _recordDebugSnapshot(
        tuningConfig: tuningConfig,
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
        response: response,
      );

      print(
        '[NaturalLanguageTransactionService.parseNaturalLanguage] ✅ AI响应: ${response.content}',
      );

      // 5. 解析响应
      print(
        '[NaturalLanguageTransactionService.parseNaturalLanguage] 🔍 开始解析AI响应，账户列表: ${accounts?.map((a) => a.name).toList() ?? []}',
      );
      final parsed =
          _parseAiResponse(response.content, input, accounts, budgets);

      print(
        '[NaturalLanguageTransactionService.parseNaturalLanguage] ✅ 解析完成: ${parsed.toJson()}',
      );
      print(
        '[NaturalLanguageTransactionService.parseNaturalLanguage] 💳 最终账户匹配结果: accountId=${parsed.accountId}, accountName=${parsed.accountName}',
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
    AiNlpTuningConfig tuningConfig,
  ) async {
    // 准备账户数据（包含ID，用于prompt中的accountId匹配）
    List<Map<String, String>>? accountsData;
    if (accounts != null && accounts.isNotEmpty) {
      accountsData = accounts
          .map(
            (a) => {
              'id': a.id, // 新增：包含账户真实ID
              'name': a.name,
              'type': a.type.displayName,
            },
          )
          .toList();

      print(
        '[NaturalLanguageTransactionService._buildSystemPrompt] 💳 准备账户数据: ${accountsData.map((a) => '${a['name']} (${a['type']}, ID: ${a['id']})').join(', ')}',
      );
    } else {
      print(
        '[NaturalLanguageTransactionService._buildSystemPrompt] ⚠️ 账户列表为空或null',
      );
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

    // 从文件加载提示词模板（传入当前日期，用于时间识别）
    final now = DateTime.now();
    final dateReference =
        tuningConfig.enableDateCheatSheet ? _generateDateReference(now) : '';

    return PromptLoader.loadNaturalLanguagePrompt(
      accounts: accountsData,
      budgets: budgetsData,
      userHistorySection: userHistorySection,
      currentDate: now,
      dateReference: dateReference,
      templatePath: _resolvePromptTemplatePath(tuningConfig.promptFilename),
    );
  }

  /// 构建用户提示词
  String _buildUserPrompt(String input) => '请从以下描述中提取交易信息：\n\n$input';

  /// 解析AI响应
  ParsedTransaction _parseAiResponse(
    String response,
    String originalInput,
    List<Account>? accounts,
    List<EnvelopeBudget>? budgets,
  ) {
    try {
      // 尝试提取JSON（可能包含markdown代码块或前缀）
      var jsonStr = response.trim();
      if (!jsonStr.startsWith('{')) {
        final start = jsonStr.indexOf('{');
        final end = jsonStr.lastIndexOf('}');
        if (start != -1 && end != -1 && end >= start) {
          jsonStr = jsonStr.substring(start, end + 1).trim();
        }
      }

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

      print(
        '[NaturalLanguageTransactionService._parseAiResponse] 📦 AI返回的JSON: $json',
      );
      print(
        '[NaturalLanguageTransactionService._parseAiResponse] 💰 AI返回的amount字段: ${json['amount']}',
      );
      print(
        '[NaturalLanguageTransactionService._parseAiResponse] 🔍 AI返回的accountId字段: ${json['accountId']}',
      );
      print(
        '[NaturalLanguageTransactionService._parseAiResponse] 🔍 AI返回的accountName字段: ${json['accountName']}',
      );

      // 匹配账户（优先使用accountId，兼容accountName）
      String? accountId;
      String? accountName;

      // 优先：如果LLM直接返回了accountId，直接使用
      if (json['accountId'] != null &&
          accounts != null &&
          accounts.isNotEmpty) {
        final accountIdStr = json['accountId'] as String;
        print(
          '[NaturalLanguageTransactionService._parseAiResponse] 💳 AI返回了accountId: "$accountIdStr"，开始验证',
        );

        // 验证accountId是否在账户列表中
        Account? matchedAccount;
        try {
          matchedAccount = accounts.firstWhere((a) => a.id == accountIdStr);
          accountId = matchedAccount.id;
          accountName = matchedAccount.name;
          print(
            '[NaturalLanguageTransactionService._parseAiResponse] ✅ 账户ID验证成功: "$accountIdStr" -> "${matchedAccount.name}"',
          );
        } catch (e) {
          print(
            '[NaturalLanguageTransactionService._parseAiResponse] ⚠️ 账户ID验证失败: "$accountIdStr" 不在账户列表中',
          );
          print(
            '[NaturalLanguageTransactionService._parseAiResponse] 📋 可用账户ID列表: ${accounts.map((a) => '${a.name}(${a.id})').join(', ')}',
          );
        }
      }
      // 兜底：如果LLM返回了accountName，通过名称查找ID
      else if (json['accountName'] != null &&
          accounts != null &&
          accounts.isNotEmpty) {
        final accountNameStr = json['accountName'] as String;
        print(
          '[NaturalLanguageTransactionService._parseAiResponse] 💳 AI返回了accountName: "$accountNameStr"，开始通过名称查找ID',
        );

        // 通过名称匹配账户
        Account? matchedAccount;
        try {
          matchedAccount = accounts.firstWhere((a) => a.name == accountNameStr);
          accountId = matchedAccount.id;
          accountName = matchedAccount.name;
          print(
            '[NaturalLanguageTransactionService._parseAiResponse] ✅ 账户名称验证成功: "$accountNameStr" -> ID: "${matchedAccount.id}", Name: "${matchedAccount.name}"',
          );
        } catch (e) {
          print(
            '[NaturalLanguageTransactionService._parseAiResponse] ⚠️ 账户名称验证失败: "$accountNameStr" 不在账户列表中',
          );
          print(
            '[NaturalLanguageTransactionService._parseAiResponse] 📋 可用账户列表: ${accounts.map((a) => a.name).join(', ')}',
          );
        }
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
        uncertainty: json['uncertainty'] as String?,
        nextStuff: json['nextStuff'] as String?,
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

      final fallbackNextStuff = _extractNextStuff(response);
      // 返回一个基础的解析结果（限制description长度，避免超长文本）
      final sanitizedDescription = _sanitizeDescription(response);

      return ParsedTransaction(
        description: sanitizedDescription,
        confidence: 0.3,
        source: ParsedTransactionSource.naturalLanguage,
        nextStuff: fallbackNextStuff,
        rawData: {'raw': response},
      );
    }
  }

  /// 清理description内容，限制长度并移除技术性内容
  String _sanitizeDescription(String? rawDescription) {
    if (rawDescription == null || rawDescription.isEmpty) {
      return '';
    }

    // 移除可能的技术性prompt内容
    var cleaned = rawDescription.trim();

    // 移除Markdown代码块
    cleaned = cleaned.replaceAll(RegExp(r'```[a-z]*\n?'), '');
    cleaned = cleaned.replaceAll(RegExp('```'), '');

    // 移除XML标签
    cleaned = cleaned.replaceAll(RegExp('<[^>]+>'), '');

    // 移除JSON结构标记
    cleaned = cleaned.replaceAll(RegExp(r'\{[^}]*\}'), '');

    // 移除技术性描述
    final technicalPatterns = [
      RegExp('小模型财务意图解析.*?', caseSensitive: false),
      RegExp('Prompt.*?Engineering.*?', caseSensitive: false),
      RegExp('核心策略.*?', caseSensitive: false),
      RegExp('第一部分.*?', caseSensitive: false),
      RegExp('针对小模型.*?', caseSensitive: false),
      RegExp('核心 Prompt 模板.*?', caseSensitive: false),
      RegExp('请将以下模板.*?', caseSensitive: false),
      RegExp('# Role.*?', caseSensitive: false),
      RegExp('# Context.*?', caseSensitive: false),
      RegExp('以下是用户当前.*?', caseSensitive: false),
      RegExp('根据提供的描述.*?', caseSensitive: false),
      RegExp('假设当前日期.*?', caseSensitive: false),
      RegExp('用户输入.*?', caseSensitive: false),
      RegExp('构建 Prompt.*?', caseSensitive: false),
      RegExp('将用户输入.*?', caseSensitive: false),
    ];

    for (final pattern in technicalPatterns) {
      cleaned = cleaned.replaceAll(pattern, '').trim();
    }

    // 限制长度（最多50个字符）
    if (cleaned.length > 50) {
      cleaned = '${cleaned.substring(0, 50)}...';
    }

    // 清理多余空格和换行
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    return cleaned.isEmpty ? '解析失败，请重新输入' : cleaned;
  }

  String? _extractNextStuff(String response) {
    final match = RegExp(r'"nextStuff"\s*:\s*"([^"]+)"').firstMatch(response);
    if (match != null) {
      return match.group(1)?.trim();
    }
    return null;
  }

  String _generateDateReference(DateTime now) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    const weekDayNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

    final buffer = StringBuffer();
    buffer.writeln('【日期参考表 (Date Cheat Sheet)】');
    buffer.writeln(
      '- 今天 (${weekDayNames[now.weekday - 1]}): ${dateFormat.format(now)}',
    );
    buffer.writeln(
      '- 昨天: ${dateFormat.format(now.subtract(const Duration(days: 1)))}',
    );
    buffer.writeln(
      '- 前天: ${dateFormat.format(now.subtract(const Duration(days: 2)))}',
    );

    final thisMonday = now.subtract(Duration(days: now.weekday - 1));
    final lastMonday = thisMonday.subtract(const Duration(days: 7));
    buffer.writeln('- 上周日期对应:');
    for (var i = 0; i < 7; i++) {
      final day = lastMonday.add(Duration(days: i));
      buffer.writeln(
        '  * 上${weekDayNames[i]}: ${dateFormat.format(day)}',
      );
    }

    return buffer.toString();
  }

  String _resolvePromptTemplatePath(String filename) {
    final baseDir = p.normalize(_promptBaseDir);
    final sanitized = filename.trim();
    final requestedPath =
        sanitized.isEmpty ? _defaultPromptFilename : sanitized;

    if (p.isAbsolute(requestedPath)) {
      throw ArgumentError(
        'Prompt template path must be relative to $_promptBaseDir',
      );
    }

    final candidate = requestedPath.startsWith(baseDir)
        ? p.normalize(requestedPath)
        : p.normalize(p.join(baseDir, requestedPath));

    final isWithinBase = candidate == baseDir || p.isWithin(baseDir, candidate);

    if (!isWithinBase) {
      throw ArgumentError(
        'Prompt template path must stay within $_promptBaseDir. Received: $filename',
      );
    }

    return candidate;
  }

  void _recordDebugSnapshot({
    required AiNlpTuningConfig tuningConfig,
    required String systemPrompt,
    required String userPrompt,
    required AiResponse response,
  }) {
    const previewLimit = 1500;
    String preview(String text) => text.length > previewLimit
        ? '${text.substring(0, previewLimit)}...'
        : text;

    Log.data(
      'AI Snapshot',
      'NaturalLanguageTransaction',
      {
        'model': tuningConfig.modelId,
        'temperature': tuningConfig.temperature,
        'maxTokens': tuningConfig.maxTokens,
        'promptFile': tuningConfig.promptFilename,
        'dateCheatSheet': tuningConfig.enableDateCheatSheet,
        'systemPrompt': preview(systemPrompt),
        'userPrompt': userPrompt,
        'response': preview(response.content),
      },
    );
  }

  /// 统一记账入口：解析交易（支持收支自动识别）
  ///
  /// [input] 用户输入的自然语言描述
  /// [userHistory] 用户历史交易数据（用于智能推荐）
  /// [accounts] 可用账户列表
  /// [budgets] 可用预算列表
  ///
  /// 返回解析结果和置信度路由动作
  Future<TransactionParseResult> parseTransaction({
    required String input,
    List<Transaction>? userHistory,
    List<Account>? accounts,
    List<EnvelopeBudget>? budgets,
  }) async {
    print(
      '[NaturalLanguageTransactionService.parseTransaction] 📝 统一记账入口: $input',
    );

    try {
      // 1. 加载用户画像
      final profileService = await UserIncomeProfileService.getInstance();
      final userProfile = await profileService.loadProfile();

      // 2. 解析自然语言
      final parsed = await parseNaturalLanguage(
        input: input,
        userHistory: userHistory,
        accounts: accounts,
        budgets: budgets,
      );

      // 3. 应用用户画像增强置信度
      final enhancedConfidence = userProfile.enhanceConfidence(
        parsed.confidence,
        parsed.type,
        parsed.category,
        parsed.amount,
        parsed.date,
      );

      final enhancedParsed = parsed.copyWith(confidence: enhancedConfidence);

      // 4. 获取置信度阈值
      final thresholds = await profileService.getConfidenceThresholds();

      // 5. 置信度路由
      String action;
      if (enhancedConfidence >= thresholds.autoSave) {
        action = 'auto_save';
      } else if (enhancedConfidence >= thresholds.quickConfirm) {
        action = 'quick_confirm';
      } else {
        action = 'clarify';
      }

      // 6. 转账类型特殊处理
      if (enhancedParsed.type == TransactionType.transfer) {
        action = 'transfer_confirm';
      }

      print(
        '[NaturalLanguageTransactionService.parseTransaction] ✅ 解析完成: type=${enhancedParsed.type}, confidence=$enhancedConfidence, action=$action',
      );

      return TransactionParseResult(
        parsed: enhancedParsed,
        action: action,
        thresholds: thresholds,
      );
    } catch (e, stackTrace) {
      print(
        '[NaturalLanguageTransactionService.parseTransaction] ❌ 解析失败: $e',
      );
      print(
        '[NaturalLanguageTransactionService.parseTransaction] 堆栈: $stackTrace',
      );
      rethrow;
    }
  }
}

/// 交易解析结果
class TransactionParseResult {
  const TransactionParseResult({
    required this.parsed,
    required this.action,
    required this.thresholds,
  });

  /// 解析后的交易数据
  final ParsedTransaction parsed;

  /// 置信度路由动作
  /// "auto_save": 自动保存（≥0.9或0.95）
  /// "quick_confirm": 快速确认（0.7-0.9或0.85-0.95）
  /// "clarify": 降级补全（<0.7或<0.85）
  /// "transfer_confirm": 转账确认
  final String action;

  /// 置信度阈值配置
  final ConfidenceThresholds thresholds;
}
