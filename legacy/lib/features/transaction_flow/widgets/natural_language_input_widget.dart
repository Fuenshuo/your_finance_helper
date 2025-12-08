import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/parsed_transaction.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/budget_provider.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/core/services/ai/natural_language_transaction_service.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/core/widgets/glass_notification.dart';

/// 自然语言输入组件
/// 提供自然语言记账功能
class NaturalLanguageInputWidget extends StatefulWidget {
  const NaturalLanguageInputWidget({
    super.key,
    required this.onParsed,
  });

  /// 解析完成回调
  final void Function(ParsedTransaction) onParsed;

  @override
  State<NaturalLanguageInputWidget> createState() => _NaturalLanguageInputWidgetState();
}

class _NaturalLanguageInputWidgetState extends State<NaturalLanguageInputWidget> {
  final _textController = TextEditingController();
  final _service = NaturalLanguageTransactionService.getInstance();
  bool _isParsing = false;
  ParsedTransaction? _parsedResult;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// 解析自然语言输入
  Future<void> _parseInput() async {
    final input = _textController.text.trim();
    if (input.isEmpty) {
      GlassNotification.show(
        context,
        message: '请输入交易描述',
        icon: Icons.info_outline,
        backgroundColor: Colors.blue.withOpacity(0.2),
        textColor: Colors.blue,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    setState(() {
      _isParsing = true;
      _parsedResult = null;
    });

    try {
      // 获取用户历史数据和账户、预算列表
      final transactionProvider = context.read<TransactionProvider>();
      final accountProvider = context.read<AccountProvider>();
      final budgetProvider = context.read<BudgetProvider>();

      final service = await _service;
      final parsed = await service.parseNaturalLanguage(
        input: input,
        userHistory: transactionProvider.transactions.take(20).toList(),
        accounts: accountProvider.activeAccounts,
        budgets: budgetProvider.envelopeBudgets,
      );

      setState(() {
        _parsedResult = parsed;
        _isParsing = false;
      });

      if (parsed.isValid) {
        // 自动填充表单
        widget.onParsed(parsed);
        
        // 清空输入框
        _textController.clear();
        
        GlassNotification.show(
          context,
          message: '解析成功！已自动填充表单',
          icon: Icons.check_circle,
          backgroundColor: Colors.green.withOpacity(0.2),
          textColor: Colors.green,
          duration: const Duration(seconds: 2),
        );
      } else {
        GlassNotification.show(
          context,
          message: '解析完成，但信息不完整，请手动补充',
          icon: Icons.warning_amber_rounded,
          backgroundColor: Colors.orange.withOpacity(0.2),
          textColor: Colors.orange,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      setState(() {
        _isParsing = false;
      });

      GlassNotification.show(
        context,
        message: '解析失败: ${e.toString()}',
        icon: Icons.error_outline,
        backgroundColor: Colors.red.withOpacity(0.2),
        textColor: Colors.red,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: context.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI智能记账',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: '例如：今天在星巴克买了杯拿铁，花了35块，用的支付宝',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _isParsing
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _parseInput,
                      ),
              ),
              maxLines: 2,
              enabled: !_isParsing,
              onSubmitted: (_) => _parseInput(),
            ),
            if (_parsedResult != null && !_parsedResult!.isValid) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '解析结果：${_parsedResult!.description ?? "无描述"}，金额：${_parsedResult!.amount ?? "无"}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
}

