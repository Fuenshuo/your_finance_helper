import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../models/parsed_transaction.dart';
import '../../models/transaction.dart';

/// AI服务Isolate包装器
/// 将AI返回的复杂JSON解析放到Isolate中运行，避免阻塞UI线程
class AIServiceIsolate {
  /// 在Isolate中解析AI响应
  /// 返回解析后的交易数据
  static Future<ParsedTransaction> parseAIResponseInIsolate({
    required String response,
    required Map<String, dynamic> contextData,
  }) async {
    return compute(_parseAIResponse, {
      'response': response,
      'contextData': contextData,
    });
  }

  /// Isolate中的解析函数
  static ParsedTransaction _parseAIResponse(Map<String, dynamic> data) {
    final response = data['response'] as String;

    try {
      // 尝试提取JSON（可能包含markdown代码块）
      String jsonStr = response.trim();

      // 移除markdown代码块标记
      if (jsonStr.startsWith('```json')) {
        jsonStr = jsonStr.substring(7);
      } else if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr.substring(3);
      }
      if (jsonStr.endsWith('```')) {
        jsonStr = jsonStr.substring(0, jsonStr.length - 3);
      }
      jsonStr = jsonStr.trim();

      // 解析JSON
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;

      // 验证必需字段
      if (!json.containsKey('amount') || json['amount'] == null) {
        throw ValidationException('缺少必需字段: amount');
      }

      if (!json.containsKey('type') || json['type'] == null) {
        throw ValidationException('缺少必需字段: type');
      }

      if (!json.containsKey('category') || json['category'] == null) {
        throw ValidationException('缺少必需字段: category');
      }

      // 构建ParsedTransaction
      return ParsedTransaction.fromJson(json);
    } catch (e) {
      // 如果解析失败，返回无效的ParsedTransaction
      return ParsedTransaction(
        description: response,
        amount: 0,
        type: TransactionType.expense,
        category: TransactionCategory.otherExpense,
        confidence: 0.0,
        rawData: {'error': e.toString()},
      );
    }
  }
}

/// 验证异常
class ValidationException implements Exception {
  ValidationException(this.message);
  final String message;
  @override
  String toString() => message;
}
