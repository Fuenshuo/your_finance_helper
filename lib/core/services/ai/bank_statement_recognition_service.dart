import 'dart:convert';

import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/models/ai_config.dart';
import 'package:your_finance_flutter/core/models/parsed_transaction.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/services/ai/ai_config_service.dart';
import 'package:your_finance_flutter/core/services/ai/ai_service_factory.dart';
import 'dart:io';

import 'package:your_finance_flutter/core/services/ai/image_processing_service.dart';
import 'package:your_finance_flutter/core/services/ai/prompts/prompt_loader.dart';
import 'package:your_finance_flutter/core/utils/ai_date_parser.dart';

/// 银行账单识别结果
class BankStatementRecognitionResult {
  final BankAccountInfo? accountInfo;
  final List<BankTransaction> transactions;
  final BankStatementSummary? summary;

  BankStatementRecognitionResult({
    this.accountInfo,
    required this.transactions,
    this.summary,
  });

  /// 转换为ParsedTransaction列表
  List<ParsedTransaction> toParsedTransactions({
    List<Account>? accounts,
    List<Transaction>? existingTransactions,
  }) {
    final parsedList = <ParsedTransaction>[];

    for (final transaction in transactions) {
      // 检查是否已存在（去重）
      if (existingTransactions != null) {
        final isDuplicate = existingTransactions.any((existing) {
          return existing.date.year == transaction.date.year &&
              existing.date.month == transaction.date.month &&
              existing.date.day == transaction.date.day &&
              (existing.amount - transaction.amount.abs()).abs() < 0.01 &&
              existing.description.contains(transaction.merchant);
        });

        if (isDuplicate) {
          print(
            '[BankStatementRecognitionResult.toParsedTransactions] ⏭️ 跳过重复交易: ${transaction.merchant} ${transaction.amount}',
          );
          continue;
        }
      }

      // 匹配账户
      String? accountId;
      String? accountName;
      if (accountInfo != null && accounts != null) {
        accountId = BankStatementRecognitionService._matchAccount(
          accountInfo!,
          accounts,
        );
        if (accountId != null) {
          accountName = accounts.firstWhere((a) => a.id == accountId).name;
        }
      }

      // 确定交易类型
      final type = transaction.amount >= 0
          ? TransactionType.income
          : TransactionType.expense;

      // 确定分类（根据交易类型和商户名称）
      final category = BankStatementRecognitionService._determineCategory(
        transaction,
        type,
      );

      parsedList.add(ParsedTransaction(
        description: transaction.merchant,
        amount: transaction.amount.abs(),
        type: type,
        category: category,
        subCategory: transaction.location,
        accountId: accountId,
        accountName: accountName,
        date: transaction.date,
        notes: transaction.notes,
        confidence: 0.9,
        source: ParsedTransactionSource.bankStatement,
        rawData: transaction.toJson(),
      ));
    }

    return parsedList;
  }
}

/// 银行账户信息
class BankAccountInfo {
  final String? bankName;
  final String? cardNumberLast4;
  final String? accountType;

  BankAccountInfo({
    this.bankName,
    this.cardNumberLast4,
    this.accountType,
  });

  Map<String, dynamic> toJson() => {
        'bankName': bankName,
        'cardNumberLast4': cardNumberLast4,
        'accountType': accountType,
      };
}

/// 银行交易记录
class BankTransaction {
  final DateTime date;
  final String? time;
  final double amount;
  final String merchant;
  final String type;
  final String? location;
  final String? notes;

  BankTransaction({
    required this.date,
    this.time,
    required this.amount,
    required this.merchant,
    required this.type,
    this.location,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'time': time,
        'amount': amount,
        'merchant': merchant,
        'type': type,
        'location': location,
        'notes': notes,
      };
}

/// 账单汇总信息
class BankStatementSummary {
  final double totalIncome;
  final double totalExpense;
  final double? balance;

  BankStatementSummary({
    required this.totalIncome,
    required this.totalExpense,
    this.balance,
  });

  Map<String, dynamic> toJson() => {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'balance': balance,
      };
}

/// 银行账单识别服务
/// 识别银行对账单和信用卡账单，批量提取交易记录
class BankStatementRecognitionService {
  BankStatementRecognitionService._();
  static BankStatementRecognitionService? _instance;

  static Future<BankStatementRecognitionService> getInstance() async {
    _instance ??= BankStatementRecognitionService._();
    return _instance!;
  }

  /// 识别银行账单
  ///
  /// [imagePath] 账单图片路径
  /// [accounts] 可用账户列表（用于匹配）
  /// [existingTransactions] 已有交易列表（用于去重）
  ///
  /// 返回识别结果
  Future<BankStatementRecognitionResult> recognizeBankStatement({
    required String imagePath,
    List<Account>? accounts,
    List<Transaction>? existingTransactions,
  }) async {
    print(
      '[BankStatementRecognitionService.recognizeBankStatement] 📸 开始识别银行账单: $imagePath',
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

      // 3. 处理图片
      final imageService = ImageProcessingService.getInstance();
      final imageFile = File(imagePath);
      final imageBase64 = await imageService.convertToBase64(imageFile);

      // 4. 构建提示词
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
      final systemPrompt = await PromptLoader.loadBankStatementRecognitionPrompt(
        accounts: accountsData,
      );

      // 5. 调用Vision模型
      final response = await aiService.sendVisionMessage(
        messages: [
          AiMessage(
            role: 'user',
            content: systemPrompt,
            images: [imageBase64],
          ),
        ],
        temperature: 0.2, // 降低温度以提高准确性
        maxTokens: 2000, // 账单可能有多条交易，需要更多token
      );

      print(
        '[BankStatementRecognitionService.recognizeBankStatement] ✅ AI响应: ${response.content}',
      );

      // 6. 解析响应
      final result = _parseAiResponse(response.content);

      print(
        '[BankStatementRecognitionService.recognizeBankStatement] ✅ 识别完成: ${result.transactions.length}条交易',
      );

      return result;
    } catch (e, stackTrace) {
      print(
        '[BankStatementRecognitionService.recognizeBankStatement] ❌ 识别失败: $e',
      );
      print(
        '[BankStatementRecognitionService.recognizeBankStatement] 堆栈: $stackTrace',
      );
      rethrow;
    }
  }

  /// 解析AI响应
  BankStatementRecognitionResult _parseAiResponse(String response) {
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

      // 解析账户信息
      BankAccountInfo? accountInfo;
      if (json['accountInfo'] != null) {
        final accountInfoJson = json['accountInfo'] as Map<String, dynamic>;
        accountInfo = BankAccountInfo(
          bankName: accountInfoJson['bankName'] as String?,
          cardNumberLast4: accountInfoJson['cardNumberLast4'] as String?,
          accountType: accountInfoJson['accountType'] as String?,
        );
      }

      // 解析交易列表
      final transactions = <BankTransaction>[];
      if (json['transactions'] != null) {
        final transactionsJson = json['transactions'] as List<dynamic>;
        for (final transactionJson in transactionsJson) {
          final t = transactionJson as Map<String, dynamic>;

          // 解析日期
          final dateStr = t['date'] as String?;
          var date = AiDateParser.parseDate(
            dateStr: dateStr,
            defaultDate: DateTime.now(),
          );

          // 如果有时间，合并到日期中
          final timeStr = t['time'] as String?;
          if (timeStr != null && timeStr.isNotEmpty) {
            try {
              final timeParts = timeStr.split(':');
              if (timeParts.length >= 2) {
                final hour = int.parse(timeParts[0]);
                final minute = int.parse(timeParts[1]);
                final second = timeParts.length >= 3 ? int.parse(timeParts[2]) : 0;
                date = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  hour,
                  minute,
                  second,
                );
              }
            } catch (e) {
              print(
                '[BankStatementRecognitionService._parseAiResponse] ⚠️ 时间解析失败: $timeStr',
              );
            }
          }

          transactions.add(BankTransaction(
            date: date,
            time: timeStr,
            amount: (t['amount'] as num).toDouble(),
            merchant: t['merchant'] as String? ?? '未知商户',
            type: t['type'] as String? ?? '其他',
            location: t['location'] as String?,
            notes: t['notes'] as String?,
          ));
        }
      }

      // 解析汇总信息
      BankStatementSummary? summary;
      if (json['summary'] != null) {
        final summaryJson = json['summary'] as Map<String, dynamic>;
        summary = BankStatementSummary(
          totalIncome: (summaryJson['totalIncome'] as num?)?.toDouble() ?? 0.0,
          totalExpense:
              (summaryJson['totalExpense'] as num?)?.toDouble() ?? 0.0,
          balance: (summaryJson['balance'] as num?)?.toDouble(),
        );
      }

      return BankStatementRecognitionResult(
        accountInfo: accountInfo,
        transactions: transactions,
        summary: summary,
      );
    } catch (e) {
      print(
        '[BankStatementRecognitionService._parseAiResponse] ❌ JSON解析失败: $e',
      );
      print(
        '[BankStatementRecognitionService._parseAiResponse] 响应内容: $response',
      );
      rethrow;
    }
  }

  /// 匹配账户（复用发票识别的匹配逻辑）
  static String? _matchAccount(BankAccountInfo accountInfo, List<Account> accounts) {
    // 优先级1: 卡号后4位精确匹配
    if (accountInfo.cardNumberLast4 != null &&
        accountInfo.cardNumberLast4!.isNotEmpty) {
      for (final account in accounts) {
        if (account.name.contains(accountInfo.cardNumberLast4!)) {
          print(
            '[BankStatementRecognitionService._matchAccount] ✅ 卡号匹配: ${account.name}',
          );
          return account.id;
        }
      }
    }

    // 优先级2: 银行名称 + 账户名称匹配
    if (accountInfo.bankName != null && accountInfo.bankName!.isNotEmpty) {
      final bankKeywords = _getBankKeywords(accountInfo.bankName!);
      for (final keyword in bankKeywords) {
        for (final account in accounts) {
          if (account.name.contains(keyword)) {
            print(
              '[BankStatementRecognitionService._matchAccount] ✅ 银行名称匹配: ${account.name}',
            );
            return account.id;
          }
        }
      }
    }

    // 优先级3: 账户类型匹配
    if (accountInfo.accountType != null) {
      AccountType? accountType;
      if (accountInfo.accountType!.contains('信用卡')) {
        accountType = AccountType.creditCard;
      } else if (accountInfo.accountType!.contains('储蓄') ||
          accountInfo.accountType!.contains('借记')) {
        accountType = AccountType.bank;
      }

      if (accountType != null) {
        for (final account in accounts) {
          if (account.type == accountType) {
            print(
              '[BankStatementRecognitionService._matchAccount] ✅ 账户类型匹配: ${account.name}',
            );
            return account.id;
          }
        }
      }
    }

    return null;
  }

  /// 获取银行关键词（复用发票识别的逻辑）
  static List<String> _getBankKeywords(String bankName) {
    final keywords = <String>[];
    final lowerName = bankName.toLowerCase();

    if (lowerName.contains('招商') || lowerName.contains('cmb')) {
      keywords.addAll(['招行', 'CMB', '招商']);
    } else if (lowerName.contains('工商') || lowerName.contains('icbc')) {
      keywords.addAll(['工行', 'ICBC', '工商']);
    } else if (lowerName.contains('建设') || lowerName.contains('ccb')) {
      keywords.addAll(['建行', 'CCB', '建设']);
    } else if (lowerName.contains('农业') || lowerName.contains('abc')) {
      keywords.addAll(['农行', 'ABC', '农业']);
    }

    return keywords;
  }

  /// 确定交易分类
  static TransactionCategory _determineCategory(
    BankTransaction transaction,
    TransactionType type,
  ) {
    if (type == TransactionType.income) {
      return TransactionCategory.otherIncome;
    }

    // 根据商户名称和交易类型推断分类
    final merchant = transaction.merchant.toLowerCase();

    if (merchant.contains('星巴克') ||
        merchant.contains('咖啡') ||
        merchant.contains('餐厅') ||
        merchant.contains('饭店') ||
        merchant.contains('食堂')) {
      return TransactionCategory.food;
    } else if (merchant.contains('地铁') ||
        merchant.contains('公交') ||
        merchant.contains('出租车') ||
        merchant.contains('滴滴')) {
      return TransactionCategory.transport;
    } else if (merchant.contains('超市') ||
        merchant.contains('购物') ||
        merchant.contains('商场')) {
      return TransactionCategory.shopping;
    } else {
      return TransactionCategory.otherExpense;
    }
  }
}

