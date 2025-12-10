import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/draft_transaction.dart';

/// 交易解析服务接口
abstract class TransactionParserService {
  /// 解析输入文本为交易草稿
  Future<DraftTransaction> parseTransaction(String input);

  /// 解析金额字符串
  double? parseAmount(String input);

  /// 解析描述
  String? parseDescription(String input);

  /// 智能判断交易类型
  TransactionType? inferTransactionType(String input);

  /// 计算解析置信度
  double calculateConfidence(DraftTransaction draft);
}

/// 默认交易解析服务实现
class DefaultTransactionParserService implements TransactionParserService {
  static const String _amountPattern = r'(\d+(?:\.\d{1,2})?)';
  static const String _currencyPattern = r'[¥$€£]';
  static const List<String> _expenseKeywords = [
    '买', '购买', '消费', '支出', '花', '付', '支付', '花费',
    '超市', '商场', '餐厅', '吃饭', '餐饮', '购物', '淘宝', '京东',
    '地铁', '公交', '打车', '加油', '停车', '医药', '医疗', '药店',
    '水费', '电费', '煤气费', '网费', '话费', '宽带', '物业费', '房租'
  ];
  static const List<String> _incomeKeywords = [
    '收入', '工资', '薪水', '奖金', '报酬', '收益', '利息', '分红',
    '退款', '返现', '补贴', '津贴', '奖金', '分红', '投资收益', '租金'
  ];
  static const List<String> _transferKeywords = [
    '转账', '转给', '收到', '汇款', '打款', '还款', '借给', '借入'
  ];

  @override
  Future<DraftTransaction> parseTransaction(String input) async {
    final cleanInput = input.trim();
    if (cleanInput.isEmpty) {
      throw ArgumentError('输入不能为空');
    }

    try {
      final amount = parseAmount(cleanInput);
      final description = parseDescription(cleanInput);
      final type = inferTransactionType(cleanInput);

      if (amount == null) {
        throw ArgumentError('无法解析金额，请检查输入格式');
      }

      final draft = DraftTransaction(
        amount: amount,
        description: description,
        type: type,
        confidence: 0.0, // 临时值，后续计算
      );

      final confidence = calculateConfidence(draft);
      return draft.copyWith(confidence: confidence);
    } catch (e) {
      throw Exception('解析交易失败: ${e.toString()}');
    }
  }

  @override
  double? parseAmount(String input) {
    // 移除货币符号和空格
    final cleanInput = input.replaceAll(RegExp(_currencyPattern), '').trim();

    // 查找金额模式
    final amountRegex = RegExp(_amountPattern);
    final matches = amountRegex.allMatches(cleanInput);

    if (matches.isEmpty) return null;

    // 返回最大的金额（通常是主要金额）
    double maxAmount = 0;
    for (final match in matches) {
      final amount = double.tryParse(match.group(1) ?? '');
      if (amount != null && amount > maxAmount) {
        maxAmount = amount;
      }
    }

    return maxAmount > 0 ? maxAmount : null;
  }

  @override
  String? parseDescription(String input) {
    // 移除金额相关内容
    var description = input.replaceAll(RegExp(r'\d+(?:\.\d{1,2})?'), '').trim();

    // 移除货币符号
    description = description.replaceAll(RegExp(_currencyPattern), '').trim();

    // 移除常见的分隔符和多余空格
    description = description.replaceAll(RegExp(r'[,\.\-\s]+'), ' ').trim();

    // 如果描述太短或只包含无意义字符，返回null
    if (description.length < 2 || RegExp(r'^[^\w\u4e00-\u9fff]+$').hasMatch(description)) {
      return null;
    }

    return description;
  }

  @override
  TransactionType? inferTransactionType(String input) {
    final lowerInput = input.toLowerCase();

    // 检查收入关键词
    final hasIncomeKeywords = _incomeKeywords.any((keyword) =>
      lowerInput.contains(keyword.toLowerCase()));

    // 检查支出关键词
    final hasExpenseKeywords = _expenseKeywords.any((keyword) =>
      lowerInput.contains(keyword.toLowerCase()));

    if (hasIncomeKeywords && !hasExpenseKeywords) {
      return TransactionType.income;
    } else if (hasExpenseKeywords && !hasIncomeKeywords) {
      return TransactionType.expense;
    }

    // 默认判断为支出（消费更常见）
    return TransactionType.expense;
  }

  @override
  double calculateConfidence(DraftTransaction draft) {
    double confidence = 0.0;

    // 金额存在性 (30%)
    if (draft.amount != null && draft.amount! > 0) {
      confidence += 0.3;
    }

    // 描述存在性 (20%)
    if (draft.description != null && draft.description!.isNotEmpty) {
      confidence += 0.2;
    }

    // 交易类型明确性 (20%)
    if (draft.type != null) {
      confidence += 0.2;
    }

    // 金额合理性 (15%) - 金额在合理范围内
    if (draft.amount != null &&
        draft.amount! > 0 &&
        draft.amount! < 1000000) { // 假设单笔交易不超过100万
      confidence += 0.15;
    }

    // 描述长度合理性 (15%) - 不太短也不太长
    if (draft.description != null &&
        draft.description!.length >= 2 &&
        draft.description!.length <= 50) {
      confidence += 0.15;
    }

    return confidence.clamp(0.0, 1.0);
  }
}

/// TransactionParserService Provider
final transactionParserServiceProvider = Provider<TransactionParserService>((ref) {
  return DefaultTransactionParserService();
});
