import 'dart:io';

import 'package:flutter/services.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';

/// 提示词加载器
/// 负责从文件加载提示词模板并替换占位符
class PromptLoader {
  static const String _naturalLanguagePromptPath =
      'lib/core/services/ai/prompts/natural_language_prompt.txt';
  static const String _invoiceRecognitionPromptPath =
      'lib/core/services/ai/prompts/invoice_recognition_prompt.txt';
  static const String _categoryRecommendationPromptPath =
      'lib/core/services/ai/prompts/category_recommendation_prompt.txt';
  static const String _bankStatementRecognitionPromptPath =
      'lib/core/services/ai/prompts/bank_statement_recognition_prompt.txt';
  static const String _payrollRecognitionPromptPath =
      'lib/core/services/ai/prompts/payroll_recognition_prompt.txt';
  static const String _assetValuationPromptPath =
      'lib/core/services/ai/prompts/asset_valuation_prompt.txt';
  static const String _transactionAnalysisPromptPath =
      'lib/core/services/ai/prompts/transaction_analysis_prompt.txt';

  /// 加载自然语言记账提示词
  static Future<String> loadNaturalLanguagePrompt({
    List<Map<String, String>>? accounts,
    List<Map<String, String>>? budgets,
    String? userHistorySection,
    DateTime? currentDate,
    String? dateReference,
    String templatePath = _naturalLanguagePromptPath,
  }) async {
    final template = await _loadTemplate(templatePath);
    return _replacePlaceholders(
      template,
      accounts: accounts,
      budgets: budgets,
      userHistorySection: userHistorySection,
      currentDate: currentDate ?? DateTime.now(),
      dateReference: dateReference,
    );
  }

  /// 加载发票识别提示词
  static Future<String> loadInvoiceRecognitionPrompt({
    List<Map<String, String>>? accounts,
  }) async {
    final template = await _loadTemplate(_invoiceRecognitionPromptPath);
    return _replacePlaceholders(
      template,
      accounts: accounts,
    );
  }

  /// 加载分类推荐提示词
  static Future<String> loadCategoryRecommendationPrompt({
    String? userHistorySection,
    TransactionType? transactionType,
  }) async {
    final template = await _loadTemplate(_categoryRecommendationPromptPath);
    return _replacePlaceholders(
      template,
      userHistorySection: userHistorySection,
      transactionType: transactionType,
    );
  }

  /// 加载银行账单识别提示词
  static Future<String> loadBankStatementRecognitionPrompt({
    List<Map<String, String>>? accounts,
  }) async {
    final template = await _loadTemplate(_bankStatementRecognitionPromptPath);
    return _replacePlaceholders(
      template,
      accounts: accounts,
    );
  }

  /// 加载工资条识别提示词
  static Future<String> loadPayrollRecognitionPrompt() async {
    final template = await _loadTemplate(_payrollRecognitionPromptPath);
    return template; // 工资条识别不需要替换占位符
  }

  /// 加载资产估值提示词
  static Future<String> loadAssetValuationPrompt() async {
    final template = await _loadTemplate(_assetValuationPromptPath);
    return template; // 资产估值不需要替换占位符
  }

  /// 加载交易分析提示词
  static Future<String> loadTransactionAnalysisPrompt() async {
    final template = await _loadTemplate(_transactionAnalysisPromptPath);
    return template; // 交易分析提示词将在调用处替换占位符
  }

  /// 加载模板文件
  /// 开发模式：优先从文件系统加载（修改后立即生效）
  /// 生产模式：从bundle加载（已编译的资源）
  static Future<String> _loadTemplate(String path) async {
    // 优先从文件系统加载（开发调试时修改prompt文件后立即生效）
    try {
      final file = File(path);
      if (await file.exists()) {
        final content = await file.readAsString();
        print('[PromptLoader._loadTemplate] ✅ 从文件系统加载: $path');
        return content;
      }
    } catch (e) {
      print('[PromptLoader._loadTemplate] ⚠️ 文件系统加载失败: $e，尝试从bundle加载');
    }

    // 如果文件系统加载失败，从bundle加载（生产环境）
    try {
      final content = await rootBundle.loadString(path);
      print('[PromptLoader._loadTemplate] ✅ 从bundle加载: $path');
      return content;
    } catch (e) {
      throw Exception(
        'Failed to load prompt template: $path (both file system and bundle failed)',
      );
    }
  }

  /// 从账户名称生成可能的别名列表
  /// 例如："招商银行工资卡" -> ["招行", "工资卡", "招商"]
  static List<String> _generateAliases(String accountName, String accountType) {
    final aliases = <String>[];
    final nameLower = accountName.toLowerCase();

    // 提取银行名称的简称
    if (nameLower.contains('招商')) aliases.add('招行');
    if (nameLower.contains('工商')) aliases.add('工行');
    if (nameLower.contains('建设')) aliases.add('建行');
    if (nameLower.contains('农业')) aliases.add('农行');
    if (nameLower.contains('中国银行')) aliases.add('中行');
    if (nameLower.contains('交通')) aliases.add('交行');
    if (nameLower.contains('浦发')) aliases.add('浦发');
    if (nameLower.contains('民生')) aliases.add('民生');
    if (nameLower.contains('兴业')) aliases.add('兴业');
    if (nameLower.contains('光大')) aliases.add('光大');
    if (nameLower.contains('华夏')) aliases.add('华夏');
    if (nameLower.contains('平安')) aliases.add('平安');
    if (nameLower.contains('中信')) aliases.add('中信');

    // 提取账户类型关键词
    if (nameLower.contains('工资')) aliases.add('工资卡');
    if (nameLower.contains('储蓄')) aliases.add('储蓄卡');
    if (nameLower.contains('信用卡')) aliases.add('信用卡');
    if (nameLower.contains('借记卡')) aliases.add('借记卡');
    if (nameLower.contains('余额宝')) aliases.add('余额宝');
    if (nameLower.contains('支付宝')) aliases.add('支付宝');
    if (nameLower.contains('微信')) aliases.add('微信');
    if (nameLower.contains('零钱')) aliases.add('零钱');

    // 提取数字（卡号后4位等）
    final numberMatch = RegExp(r'\d{4,}').firstMatch(accountName);
    if (numberMatch != null) {
      final last4 = numberMatch.group(0)!.substring(
            numberMatch.group(0)!.length - 4,
          );
      aliases.add('尾号$last4');
    }

    return aliases;
  }

  /// 替换占位符
  static String _replacePlaceholders(
    String template, {
    List<Map<String, String>>? accounts,
    List<Map<String, String>>? budgets,
    String? userHistorySection,
    TransactionType? transactionType,
    DateTime? currentDate,
    String? dateReference,
  }) {
    var result = template;

    // 替换日期占位符
    final now = currentDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final currentDateStr = _formatDate(today);
    final yesterdayDateStr = _formatDate(yesterday);

    result = result.replaceAll('{{CURRENT_DATE}}', currentDateStr);
    result = result.replaceAll('{{YESTERDAY_DATE}}', yesterdayDateStr);
    result = result.replaceAll('{{DATE_REFERENCE}}', dateReference ?? '');

    // 替换账户部分（使用XML格式，包含真实账户ID和aliases属性）
    if (accounts != null && accounts.isNotEmpty) {
      final accountsSection = StringBuffer();
      accountsSection.writeln('<accounts>');
      for (final account in accounts) {
        final accountId = account['id'] ?? ''; // 使用真实账户ID
        final accountName = account['name']!;
        final accountType = account['type']!;

        // 生成别名列表（从账户名称中提取可能的别名）
        final aliases = _generateAliases(accountName, accountType);
        final aliasesAttr =
            aliases.isNotEmpty ? ' aliases="${aliases.join(',')}"' : '';

        accountsSection.writeln(
          '<acc id="$accountId" name="$accountName"$aliasesAttr type="$accountType" />',
        );
      }
      accountsSection.writeln('</accounts>');
      final accountsSectionStr = accountsSection.toString();

      // 适配新的占位符名称
      result = result.replaceAll(
        '{{ACCOUNTS_LIST_WITH_IDS_XML}}',
        accountsSectionStr,
      );
      // 兼容旧的占位符（如果存在）
      result = result.replaceAll('{{ACCOUNTS_SECTION}}', accountsSectionStr);

      print(
        '[PromptLoader._replacePlaceholders] 💳 账户部分已替换:\n$accountsSectionStr',
      );
    } else {
      result = result.replaceAll('{{ACCOUNTS_LIST_WITH_IDS_XML}}', '');
      result = result.replaceAll('{{ACCOUNTS_SECTION}}', '');
      print(
        '[PromptLoader._replacePlaceholders] ⚠️ 账户列表为空，已移除账户部分',
      );
    }

    // 替换预算部分
    if (budgets != null && budgets.isNotEmpty) {
      final budgetsSection = StringBuffer();
      budgetsSection.writeln('## 可用预算');
      for (final budget in budgets) {
        budgetsSection.writeln(
          '- ${budget['name']} (${budget['category']})',
        );
      }
      budgetsSection.writeln();
      result =
          result.replaceAll('{{BUDGETS_SECTION}}', budgetsSection.toString());
    } else {
      result = result.replaceAll('{{BUDGETS_SECTION}}', '');
    }

    // 替换用户历史部分
    if (userHistorySection != null && userHistorySection.isNotEmpty) {
      result =
          result.replaceAll('{{USER_HISTORY_SECTION}}', userHistorySection);
    } else {
      result = result.replaceAll('{{USER_HISTORY_SECTION}}', '');
    }

    // 替换交易类型部分（如果有）
    if (transactionType != null) {
      final typeHint = transactionType == TransactionType.income
          ? '\n\n注意：这是一笔收入交易，请从收入分类中选择。'
          : '\n\n注意：这是一笔支出交易，请从支出分类中选择。';
      result = result.replaceAll('{{TRANSACTION_TYPE_HINT}}', typeHint);
    } else {
      result = result.replaceAll('{{TRANSACTION_TYPE_HINT}}', '');
    }

    return result;
  }

  /// 格式化日期为 YYYY-MM-DD
  static String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
