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

  /// 加载自然语言记账提示词
  static Future<String> loadNaturalLanguagePrompt({
    List<Map<String, String>>? accounts,
    List<Map<String, String>>? budgets,
    String? userHistorySection,
  }) async {
    final template = await _loadTemplate(_naturalLanguagePromptPath);
    return _replacePlaceholders(
      template,
      accounts: accounts,
      budgets: budgets,
      userHistorySection: userHistorySection,
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

  /// 加载模板文件
  static Future<String> _loadTemplate(String path) async {
    try {
      return await rootBundle.loadString(path);
    } catch (e) {
      // 如果从bundle加载失败，尝试从文件系统加载（用于开发调试）
      try {
        final file = File(path);
        if (await file.exists()) {
          return await file.readAsString();
        }
      } catch (_) {
        // 忽略文件系统错误
      }
      throw Exception('Failed to load prompt template: $path');
    }
  }

  /// 替换占位符
  static String _replacePlaceholders(
    String template, {
    List<Map<String, String>>? accounts,
    List<Map<String, String>>? budgets,
    String? userHistorySection,
    TransactionType? transactionType,
  }) {
    var result = template;

    // 替换账户部分
    if (accounts != null && accounts.isNotEmpty) {
      final accountsSection = StringBuffer();
      accountsSection.writeln('## 可用账户');
      for (final account in accounts) {
        accountsSection.writeln(
          '- ${account['name']} (${account['type']})',
        );
      }
      accountsSection.writeln();
      result =
          result.replaceAll('{{ACCOUNTS_SECTION}}', accountsSection.toString());
    } else {
      result = result.replaceAll('{{ACCOUNTS_SECTION}}', '');
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
}
