import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/parsed_transaction.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/budget_provider.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/features/transaction_flow/screens/add_transaction_screen.dart';
import 'package:your_finance_flutter/features/transaction_flow/widgets/natural_language_input_widget.dart';
import 'package:your_finance_flutter/features/transaction_flow/widgets/unified_image_recognition_widget.dart';

/// AI智能记账入口组件
/// 提供自然语言输入和发票识别两种AI记账方式
class AiSmartAccountingWidget extends StatelessWidget {
  const AiSmartAccountingWidget({super.key});

  /// 显示AI智能记账选择对话框
  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AiSmartAccountingDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _AiSmartAccountingDialog extends StatefulWidget {
  const _AiSmartAccountingDialog();

  @override
  State<_AiSmartAccountingDialog> createState() =>
      _AiSmartAccountingDialogState();
}

class _AiSmartAccountingDialogState extends State<_AiSmartAccountingDialog> {
  AiSmartAccountingMode _selectedMode = AiSmartAccountingMode.naturalLanguage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.primaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽指示器
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 标题
          Padding(
            padding: EdgeInsets.all(context.responsiveSpacing16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🤖 AI智能记账',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // 模式选择
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.responsiveSpacing16),
            child: Row(
              children: [
                Expanded(
                  child: _buildModeButton(
                    context,
                    mode: AiSmartAccountingMode.naturalLanguage,
                    icon: Icons.chat_bubble_outline,
                    title: '语音输入',
                    subtitle: '自然语言描述',
                    color: const Color(0xFF2196F3),
                  ),
                ),
                SizedBox(width: context.spacing12),
                Expanded(
                  child: _buildModeButton(
                    context,
                    mode: AiSmartAccountingMode.imageRecognition,
                    icon: Icons.camera_alt_outlined,
                    title: '拍照识别',
                    subtitle: '发票/账单',
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: context.spacing16),

          // AI功能组件
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.responsiveSpacing16),
              child: _buildAiContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context, {
    required AiSmartAccountingMode mode,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final isSelected = _selectedMode == mode;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMode = mode;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(context.responsiveSpacing12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 28,
            ),
            SizedBox(height: context.spacing8),
            Text(
              title,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : Colors.grey[700],
              ),
            ),
            SizedBox(height: context.spacing2),
            Text(
              subtitle,
              style: context.textTheme.bodySmall?.copyWith(
                color: isSelected ? color.withOpacity(0.7) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiContent(BuildContext context) {
    // 确保Provider已注册（用于子组件）
    context.watch<AccountProvider>();
    context.watch<BudgetProvider>();

    switch (_selectedMode) {
      case AiSmartAccountingMode.naturalLanguage:
        return NaturalLanguageInputWidget(
          onParsed: (parsed) => _handleParsedTransaction(context, parsed, null),
        );
      case AiSmartAccountingMode.imageRecognition:
        return UnifiedImageRecognitionWidget(
          onSingleTransactionRecognized: (parsed, imagePath) =>
              _handleParsedTransaction(context, parsed, imagePath),
          onBatchTransactionsRecognized: (transactions) =>
              _handleBankStatementResult(context, transactions),
        );
    }
  }

  void _handleParsedTransaction(
    BuildContext context,
    ParsedTransaction parsed,
    String? imagePath,
  ) {
    // 关闭对话框
    Navigator.of(context).pop();

    // 导航到添加交易页面，并传递解析结果
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => AddTransactionScreen(
          parsedTransaction: parsed,
          imagePath: imagePath,
        ),
      ),
    );
  }

  void _handleBankStatementResult(
    BuildContext context,
    List<ParsedTransaction> transactions,
  ) {
    // 银行账单识别会直接批量创建交易，不需要导航
    // Widget内部已经处理了批量创建逻辑
    // 这里只需要关闭对话框
    Navigator.of(context).pop();
  }
}

enum AiSmartAccountingMode {
  naturalLanguage,
  imageRecognition, // 统一的拍照识别（包含发票和银行账单）
}

