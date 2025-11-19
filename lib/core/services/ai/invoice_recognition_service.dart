import 'dart:convert';
import 'dart:io';

import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/models/ai_config.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/models/parsed_transaction.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/services/ai/ai_config_service.dart';
import 'package:your_finance_flutter/core/services/ai/ai_service_factory.dart';
import 'package:your_finance_flutter/core/services/ai/image_processing_service.dart';
import 'package:your_finance_flutter/core/services/ai/prompts/prompt_loader.dart';
import 'package:your_finance_flutter/core/utils/ai_date_parser.dart';

/// 发票/收据识别服务
/// 负责识别发票和收据中的交易信息
class InvoiceRecognitionService {
  InvoiceRecognitionService._();
  static InvoiceRecognitionService? _instance;

  static Future<InvoiceRecognitionService> getInstance() async {
    _instance ??= InvoiceRecognitionService._();
    return _instance!;
  }

  final ImageProcessingService _imageService =
      ImageProcessingService.getInstance();

  /// 识别发票/收据
  ///
  /// [imageFile] 图片文件
  /// [accounts] 可用账户列表（用于匹配）
  /// [budgets] 可用预算列表（用于匹配）
  ///
  /// 返回解析后的交易数据
  Future<ParsedTransaction> recognizeInvoice({
    required File imageFile,
    List<Account>? accounts,
    List<EnvelopeBudget>? budgets,
  }) async {
    print('[InvoiceRecognitionService.recognizeInvoice] 🧾 开始识别发票');

    try {
      // 1. 获取AI配置
      final configService = await AiConfigService.getInstance();
      final config = await configService.loadConfig();

      if (config == null || !config.enabled) {
        throw Exception('AI服务未配置或已禁用');
      }

      // 2. 检查图片大小（限制在10MB以内）
      final imageSize = await _imageService.getImageSize(imageFile);
      if (imageSize > 10 * 1024 * 1024) {
        throw Exception('图片大小超过10MB限制');
      }

      // 3. 转换为Base64
      final base64Image = await _imageService.convertToBase64(imageFile);
      print(
        '[InvoiceRecognitionService.recognizeInvoice] ✅ 图片转换完成，大小: ${imageSize / 1024}KB',
      );
      print(
        '[InvoiceRecognitionService.recognizeInvoice] 🔍 Base64预览: ${base64Image.substring(0, base64Image.length > 100 ? 100 : base64Image.length)}...',
      );

      // 4. 创建AI服务实例
      final aiService = AiServiceFactory.createService(config);

      // 5. 构建提示词
      final systemPrompt = await _buildSystemPrompt(accounts, budgets);
      final userPrompt = _buildUserPrompt();

      // 6. 调用Vision模型
      final response = await aiService.sendVisionMessage(
        messages: [
          AiMessage(role: 'system', content: systemPrompt),
          AiMessage(
            role: 'user',
            content: userPrompt,
            images: [base64Image], // 传递Base64图片
          ),
        ],
        temperature: 0.2, // 降低温度以提高准确性
        maxTokens: 800,
      );

      print(
        '[InvoiceRecognitionService.recognizeInvoice] ✅ AI响应: ${response.content}',
      );

      // 7. 解析响应
      final parsed = _parseAiResponse(response.content, accounts, budgets);

      print(
        '[InvoiceRecognitionService.recognizeInvoice] ✅ 识别完成: ${parsed.toJson()}',
      );

      return parsed;
    } catch (e, stackTrace) {
      print('[InvoiceRecognitionService.recognizeInvoice] ❌ 识别失败: $e');
      print('[InvoiceRecognitionService.recognizeInvoice] 堆栈: $stackTrace');
      rethrow;
    }
  }

  /// 构建系统提示词
  Future<String> _buildSystemPrompt(
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

    // 从文件加载提示词模板
    return PromptLoader.loadInvoiceRecognitionPrompt(
      accounts: accountsData,
    );
  }

  /// 构建用户提示词
  String _buildUserPrompt() => '请仔细识别这张图片中的所有信息。这可能是一张发票、收据、支付凭证、转账记录或支付确认页面。'
      '请提取所有可见的关键信息，包括但不限于：商家名称、金额、日期时间、支付方式、转账单号、收款方备注、支付状态、商品明细等。'
      '必须完整提取图片中的所有文字和数字信息，不要遗漏任何重要细节。';

  /// 解析AI响应
  ParsedTransaction _parseAiResponse(
    String response,
    List<Account>? accounts,
    List<EnvelopeBudget>? budgets,
  ) {
    try {
      // 尝试提取JSON
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

      // 提取详细信息
      final merchant = json['merchant'] as String? ?? '';
      final items = json['items'] as List<dynamic>?;
      final paymentMethod = json['paymentMethod'] as String?;
      final orderNumber = json['orderNumber'] as String?;
      final payeeRemark = json['payeeRemark'] as String?;
      final status = json['status'] as String?;
      final timeStr = json['time'] as String?;

      // 生成详细描述
      var description = merchant;
      if (items != null && items.isNotEmpty) {
        description = '$merchant - ${items.take(3).join('、')}';
      }
      if (paymentMethod != null && paymentMethod.isNotEmpty) {
        description = '$description（$paymentMethod）';
      }

      // 智能匹配账户（根据支付方式）
      String? accountId;
      String? accountName;
      if (accounts != null && accounts.isNotEmpty) {
        if (paymentMethod != null && paymentMethod.isNotEmpty) {
          // 根据支付方式匹配账户
          final paymentLower = paymentMethod.toLowerCase();

          // 匹配银行账户
          if (paymentLower.contains('银行') ||
              paymentLower.contains('储蓄卡') ||
              paymentLower.contains('借记卡')) {
            // 提取银行名称和卡号后4位
            String? bankName;
            String? cardLast4;

            // 提取银行名称（如"招商银行"）
            if (paymentLower.contains('招商'))
              bankName = '招商';
            else if (paymentLower.contains('工商'))
              bankName = '工商';
            else if (paymentLower.contains('建设'))
              bankName = '建设';
            else if (paymentLower.contains('农业'))
              bankName = '农业';
            else if (paymentLower.contains('中国'))
              bankName = '中国';
            else if (paymentLower.contains('交通'))
              bankName = '交通';
            else if (paymentLower.contains('邮储'))
              bankName = '邮储';
            else if (paymentLower.contains('民生'))
              bankName = '民生';
            else if (paymentLower.contains('兴业'))
              bankName = '兴业';
            else if (paymentLower.contains('浦发'))
              bankName = '浦发';
            else if (paymentLower.contains('光大'))
              bankName = '光大';
            else if (paymentLower.contains('华夏'))
              bankName = '华夏';
            else if (paymentLower.contains('平安'))
              bankName = '平安';
            else if (paymentLower.contains('广发'))
              bankName = '广发';
            else if (paymentLower.contains('中信')) bankName = '中信';

            // 提取卡号后4位（格式如"招商银行储蓄卡(6249)"）
            final cardMatch = RegExp(r'\((\d{4})\)').firstMatch(paymentMethod);
            if (cardMatch != null) {
              cardLast4 = cardMatch.group(1);
            }

            // 多级匹配策略
            var matchedAccounts = <Account>[];

            // 优先级1：卡号后4位精确匹配（最准确）
            if (cardLast4 != null) {
              matchedAccounts = accounts.where((a) {
                if (a.type != AccountType.bank) return false;
                // 检查cardNumber字段的后4位
                if (a.cardNumber != null &&
                    a.cardNumber!.length >= 4 &&
                    a.cardNumber!.substring(a.cardNumber!.length - 4) ==
                        cardLast4) {
                  return true;
                }
                // 检查accountNumber字段的后4位（有些账户可能用accountNumber存储卡号）
                if (a.accountNumber != null &&
                    a.accountNumber!.length >= 4 &&
                    a.accountNumber!.substring(a.accountNumber!.length - 4) ==
                        cardLast4) {
                  return true;
                }
                return false;
              }).toList();

              if (matchedAccounts.isNotEmpty) {
                accountId = matchedAccounts.first.id;
                accountName = matchedAccounts.first.name;
                print(
                  '[InvoiceRecognitionService._parseAiResponse] ✅ 通过卡号后4位匹配: $cardLast4 -> ${matchedAccounts.first.name}',
                );
              }
            }

            // 优先级2：银行名称匹配 + 账户名称包含银行关键词（如果卡号未匹配）
            if (accountId == null && bankName != null) {
              matchedAccounts = accounts.where((a) {
                if (a.type != AccountType.bank) return false;
                // 检查bankName字段
                final matchesBankName =
                    a.bankName != null && a.bankName!.contains(bankName!);
                // 检查账户名称包含银行关键词（如"招行"、"招商"）
                final matchesAccountName = a.name.contains(bankName!) ||
                    a.name.contains(bankName.replaceAll('银行', '')) ||
                    (bankName == '招商' &&
                        (a.name.contains('招行') || a.name.contains('CMB'))) ||
                    (bankName == '工商' &&
                        (a.name.contains('工行') || a.name.contains('ICBC'))) ||
                    (bankName == '建设' &&
                        (a.name.contains('建行') || a.name.contains('CCB'))) ||
                    (bankName == '农业' &&
                        (a.name.contains('农行') || a.name.contains('ABC')));

                return matchesBankName || matchesAccountName;
              }).toList();

              if (matchedAccounts.isNotEmpty) {
                // 优先选择bankName匹配的账户
                final bankNameMatched = matchedAccounts
                    .where(
                      (a) =>
                          a.bankName != null && a.bankName!.contains(bankName!),
                    )
                    .toList();

                accountId = (bankNameMatched.isNotEmpty
                        ? bankNameMatched.first
                        : matchedAccounts.first)
                    .id;
                accountName = (bankNameMatched.isNotEmpty
                        ? bankNameMatched.first
                        : matchedAccounts.first)
                    .name;
                print(
                  '[InvoiceRecognitionService._parseAiResponse] ✅ 通过银行名称匹配: $bankName -> $accountName',
                );
              }
            }

            // 优先级3：仅银行名称匹配（bankName字段）
            if (accountId == null && bankName != null) {
              matchedAccounts = accounts
                  .where(
                    (a) =>
                        a.type == AccountType.bank &&
                        a.bankName != null &&
                        a.bankName!.contains(bankName!),
                  )
                  .toList();

              if (matchedAccounts.isNotEmpty) {
                accountId = matchedAccounts.first.id;
                accountName = matchedAccounts.first.name;
                print(
                  '[InvoiceRecognitionService._parseAiResponse] ✅ 通过bankName字段匹配: $bankName -> $accountName',
                );
              }
            }

            // 优先级4：账户名称包含银行关键词（如果以上都未匹配）
            if (accountId == null && bankName != null) {
              matchedAccounts = accounts.where((a) {
                if (a.type != AccountType.bank) return false;
                return a.name.contains(bankName!) ||
                    a.name.contains(bankName.replaceAll('银行', ''));
              }).toList();

              if (matchedAccounts.isNotEmpty) {
                accountId = matchedAccounts.first.id;
                accountName = matchedAccounts.first.name;
                print(
                  '[InvoiceRecognitionService._parseAiResponse] ✅ 通过账户名称匹配: $bankName -> $accountName',
                );
              }
            }

            // 优先级5：任意银行账户（最后兜底）
            if (accountId == null) {
              final bankAccounts =
                  accounts.where((a) => a.type == AccountType.bank).toList();
              if (bankAccounts.isNotEmpty) {
                accountId = bankAccounts.first.id;
                accountName = bankAccounts.first.name;
                print(
                  '[InvoiceRecognitionService._parseAiResponse] ⚠️ 使用默认银行账户: $accountName',
                );
              }
            }
          }
          // 匹配支付宝
          else if (paymentLower.contains('支付宝')) {
            final alipayAccounts = accounts
                .where(
                  (a) => a.name.contains('支付宝') || a.name.contains('Alipay'),
                )
                .toList();
            if (alipayAccounts.isNotEmpty) {
              accountId = alipayAccounts.first.id;
              accountName = alipayAccounts.first.name;
            }
          }
          // 匹配微信
          else if (paymentLower.contains('微信') ||
              paymentLower.contains('wechat')) {
            final wechatAccounts = accounts
                .where(
                  (a) => a.name.contains('微信') || a.name.contains('WeChat'),
                )
                .toList();
            if (wechatAccounts.isNotEmpty) {
              accountId = wechatAccounts.first.id;
              accountName = wechatAccounts.first.name;
            }
          }
          // 匹配现金
          else if (paymentLower.contains('现金')) {
            final cashAccounts = accounts
                .where(
                  (a) => a.name.contains('现金') || a.type == AccountType.cash,
                )
                .toList();
            if (cashAccounts.isNotEmpty) {
              accountId = cashAccounts.first.id;
              accountName = cashAccounts.first.name;
            }
          }
        }

        // 如果没有匹配到，使用默认策略
        if (accountId == null) {
          // 优先选择支付宝、微信等常用账户
          final commonAccounts = accounts
              .where(
                (a) =>
                    a.name.contains('支付宝') ||
                    a.name.contains('微信') ||
                    a.name.contains('现金'),
              )
              .toList();

          accountId = commonAccounts.isNotEmpty
              ? commonAccounts.first.id
              : accounts.first.id;
          accountName = commonAccounts.isNotEmpty
              ? commonAccounts.first.name
              : accounts.first.name;
        }
      }

      // 匹配预算
      String? envelopeBudgetId;
      if (json['category'] != null && budgets != null && budgets.isNotEmpty) {
        final categoryStr = json['category'] as String;
        try {
          final category = TransactionCategory.values.firstWhere(
            (e) => e.name == categoryStr,
          );
          final matchedBudget = budgets.firstWhere(
            (b) => b.category == category,
            orElse: () => budgets.first,
          );
          envelopeBudgetId = matchedBudget.id;
        } catch (e) {
          // 分类匹配失败，使用第一个预算
          envelopeBudgetId = budgets.first.id;
        }
      }

      // 解析日期和时间（使用统一的日期解析工具）
      // 对于发票识别，如果AI返回的日期不合理（如未来日期或过远的过去日期），使用当前日期
      final dateStr = json['date'] as String?;
      var date = AiDateParser.parseDate(
        dateStr: dateStr,
        defaultDate: DateTime.now(),
      );

      // 如果有具体时间，合并到日期中
      if (timeStr != null && timeStr.isNotEmpty) {
        try {
          final timeParts = timeStr.split(':');
          if (timeParts.length >= 2) {
            final hour = int.parse(timeParts[0]);
            final minute = int.parse(timeParts[1]);
            final second = timeParts.length >= 3 ? int.parse(timeParts[2]) : 0;
            date =
                DateTime(date.year, date.month, date.day, hour, minute, second);
          }
        } catch (e) {
          print(
            '[InvoiceRecognitionService._parseAiResponse] ⚠️ 时间解析失败: $timeStr',
          );
        }
      }

      // 确定交易类型（默认为支出）
      const type = TransactionType.expense;

      // 确定分类
      var category = TransactionCategory.otherExpense;
      if (json['category'] != null) {
        try {
          category = TransactionCategory.values.firstWhere(
            (e) => e.name == json['category'],
            orElse: () => TransactionCategory.otherExpense,
          );
        } catch (e) {
          category = TransactionCategory.otherExpense;
        }
      }

      // 构建详细的备注信息
      final notesBuffer = StringBuffer();
      if (merchant.isNotEmpty) {
        notesBuffer.writeln('商家：$merchant');
      }
      if (paymentMethod != null && paymentMethod.isNotEmpty) {
        notesBuffer.writeln('支付方式：$paymentMethod');
      }
      if (orderNumber != null && orderNumber.isNotEmpty) {
        notesBuffer.writeln('转账单号：$orderNumber');
      }
      if (payeeRemark != null && payeeRemark.isNotEmpty) {
        notesBuffer.writeln('收款方备注：$payeeRemark');
      }
      if (status != null && status.isNotEmpty) {
        notesBuffer.writeln('支付状态：$status');
      }
      if (items != null && items.isNotEmpty && items.length > 1) {
        notesBuffer.writeln('商品明细：${items.join('、')}');
      }

      final notes = notesBuffer.toString().trim();

      return ParsedTransaction(
        description: description,
        amount: (json['amount'] as num?)?.toDouble(),
        type: type,
        category: category,
        subCategory:
            items?.isNotEmpty ?? false ? items?.first.toString() : null,
        accountId: accountId,
        accountName: accountName,
        envelopeBudgetId: envelopeBudgetId,
        date: date,
        notes: notes.isNotEmpty ? notes : null,
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.8,
        source: ParsedTransactionSource.invoice,
        rawData: json,
      );
    } catch (e) {
      print('[InvoiceRecognitionService._parseAiResponse] ❌ JSON解析失败: $e');
      print('[InvoiceRecognitionService._parseAiResponse] 响应内容: $response');

      // 返回一个基础的解析结果
      return ParsedTransaction(
        description: '发票识别',
        confidence: 0.3,
        source: ParsedTransactionSource.invoice,
        rawData: {'raw': response},
      );
    }
  }
}
