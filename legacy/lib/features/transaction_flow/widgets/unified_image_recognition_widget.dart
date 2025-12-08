import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/parsed_transaction.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/budget_provider.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/core/services/ai/bank_statement_recognition_service.dart';
import 'package:your_finance_flutter/core/services/ai/image_processing_service.dart';
import 'package:your_finance_flutter/core/services/ai/invoice_recognition_service.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/core/widgets/glass_notification.dart';

/// 识别类型
enum RecognitionType {
  singleTransaction, // 单笔交易（发票/收据）
  batchTransactions, // 批量交易（银行账单）
}

/// 统一图片识别组件
/// 整合发票识别和银行账单识别功能
class UnifiedImageRecognitionWidget extends StatefulWidget {
  const UnifiedImageRecognitionWidget({
    super.key,
    required this.onSingleTransactionRecognized,
    required this.onBatchTransactionsRecognized,
  });

  /// 单笔交易识别完成回调
  final void Function(ParsedTransaction parsed, String? imagePath)
      onSingleTransactionRecognized;

  /// 批量交易识别完成回调
  final void Function(List<ParsedTransaction> transactions)
      onBatchTransactionsRecognized;

  @override
  State<UnifiedImageRecognitionWidget> createState() =>
      _UnifiedImageRecognitionWidgetState();
}

class _UnifiedImageRecognitionWidgetState
    extends State<UnifiedImageRecognitionWidget> {
  RecognitionType? _selectedType;
  bool _isRecognizing = false;
  File? _selectedImage;
  String? _imagePath;

  // 单笔交易识别结果
  ParsedTransaction? _singleTransactionResult;

  // 批量交易识别结果
  BankStatementRecognitionResult? _batchTransactionsResult;
  final Set<int> _selectedTransactionIndices = {};

  final _imageService = ImageProcessingService.getInstance();
  final _invoiceService = InvoiceRecognitionService.getInstance();
  final _bankStatementService = BankStatementRecognitionService.getInstance();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 20,
                color: context.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                '拍照识别',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 根据状态显示不同内容
          if (_selectedType == null)
            _buildTypeSelector()
          else if (_selectedImage == null && !_isRecognizing)
            _buildImageCapture()
          else if (_isRecognizing)
            _buildRecognizingIndicator()
          else if (_selectedType == RecognitionType.singleTransaction &&
              _singleTransactionResult != null)
            _buildSingleTransactionResult()
          else if (_selectedType == RecognitionType.batchTransactions &&
              _batchTransactionsResult != null)
            _buildBatchTransactionsResult(),
        ],
      ),
    );
  }

  /// 构建类型选择器
  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择识别类型',
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTypeCard(
                type: RecognitionType.singleTransaction,
                icon: Icons.receipt_long,
                title: '单笔交易',
                subtitle: '发票/收据',
                color: const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeCard(
                type: RecognitionType.batchTransactions,
                icon: Icons.account_balance,
                title: '批量交易',
                subtitle: '银行账单',
                color: const Color(0xFF9C27B0),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建类型卡片
  Widget _buildTypeCard({
    required RecognitionType type,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建图片捕获界面
  Widget _buildImageCapture() {
    return Column(
      children: [
        // 返回按钮
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 20),
              onPressed: () {
                setState(() {
                  _selectedType = null;
                  _selectedImage = null;
                  _imagePath = null;
                  _singleTransactionResult = null;
                  _batchTransactionsResult = null;
                  _selectedTransactionIndices.clear();
                });
              },
            ),
            Text(
              _selectedType == RecognitionType.singleTransaction
                  ? '识别发票/收据'
                  : '识别银行账单',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isRecognizing ? null : _takePhotoAndRecognize,
                icon: const Icon(Icons.camera_alt),
                label: const Text('拍照识别'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isRecognizing ? null : _pickImageAndRecognize,
                icon: const Icon(Icons.photo_library),
                label: const Text('相册选择'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建识别中指示器
  Widget _buildRecognizingIndicator() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _selectedType == RecognitionType.singleTransaction
                  ? '正在识别发票/收据...'
                  : '正在识别银行账单...',
              style: context.textTheme.bodySmall?.copyWith(
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建单笔交易识别结果
  Widget _buildSingleTransactionResult() {
    if (_selectedImage == null || _singleTransactionResult == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 图片预览
        Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: context.borderColor,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              _selectedImage!,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 识别结果
        if (_singleTransactionResult!.isValid)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '识别成功！已自动填充表单',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
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
                    '识别结果：${_singleTransactionResult!.description ?? "无描述"}，金额：${_singleTransactionResult!.amount ?? "无"}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// 构建批量交易识别结果
  Widget _buildBatchTransactionsResult() {
    if (_batchTransactionsResult == null) return const SizedBox.shrink();

    final transactions = _batchTransactionsResult!.transactions;
    final parsedTransactions = _batchTransactionsResult!.toParsedTransactions(
      accounts: Provider.of<AccountProvider>(context, listen: false).accounts,
      existingTransactions:
          Provider.of<TransactionProvider>(context, listen: false).transactions,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 图片预览
        Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: context.borderColor,
            ),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(_imagePath!),
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image_not_supported),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  color: Colors.white,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    padding: const EdgeInsets.all(4),
                  ),
                  onPressed: () {
                    setState(() {
                      _imagePath = null;
                      _batchTransactionsResult = null;
                      _selectedTransactionIndices.clear();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 识别成功提示
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.green.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '识别到 ${transactions.length} 笔交易',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 汇总信息
        if (_batchTransactionsResult!.summary != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '汇总信息',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '总收入: ¥${_batchTransactionsResult!.summary!.totalIncome.toStringAsFixed(2)}',
                  style: context.textTheme.bodySmall,
                ),
                Text(
                  '总支出: ¥${_batchTransactionsResult!.summary!.totalExpense.toStringAsFixed(2)}',
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],

        // 交易列表
        const SizedBox(height: 12),
        const Text(
          '选择要导入的交易（默认全选）',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
            ),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: parsedTransactions.length,
            itemBuilder: (context, index) {
              final transaction = parsedTransactions[index];
              final isSelected = _selectedTransactionIndices.contains(index) ||
                  _selectedTransactionIndices.isEmpty;

              return CheckboxListTile(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedTransactionIndices.add(index);
                    } else {
                      _selectedTransactionIndices.remove(index);
                    }
                  });
                },
                title: Text(
                  transaction.description ?? '未知',
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  '${transaction.amount?.toStringAsFixed(2) ?? "0.00"}元 · ${transaction.category?.displayName ?? "未分类"}',
                  style: context.textTheme.bodySmall,
                ),
                secondary: transaction.type == TransactionType.income
                    ? const Icon(Icons.arrow_downward,
                        color: Colors.green, size: 20)
                    : const Icon(Icons.arrow_upward,
                        color: Colors.red, size: 20),
                dense: true,
              );
            },
          ),
        ),

        // 操作按钮
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _imagePath = null;
                    _batchTransactionsResult = null;
                    _selectedTransactionIndices.clear();
                  });
                },
                child: const Text('重新选择'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _importSelectedTransactions,
                child: Text(
                  '导入选中 (${_selectedTransactionIndices.isEmpty ? transactions.length : _selectedTransactionIndices.length})',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 拍照并识别
  Future<void> _takePhotoAndRecognize() async {
    try {
      final imageFile = await _imageService.takePhoto();
      if (imageFile == null || !mounted) return;

      setState(() {
        _selectedImage = imageFile;
        _isRecognizing = true;
        _singleTransactionResult = null;
        _batchTransactionsResult = null;
        _selectedTransactionIndices.clear();
      });

      await _recognizeImage(imageFile);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isRecognizing = false;
      });

      if (mounted) {
        GlassNotification.show(
          context,
          message: '拍照失败: ${e.toString()}',
          icon: Icons.error_outline,
          backgroundColor: Colors.red.withOpacity(0.2),
          textColor: Colors.red,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  /// 从相册选择并识别
  Future<void> _pickImageAndRecognize() async {
    try {
      final imageFile = await _imageService.pickImageFromGallery();
      if (imageFile == null || !mounted) return;

      setState(() {
        _selectedImage = imageFile;
        _isRecognizing = true;
        _singleTransactionResult = null;
        _batchTransactionsResult = null;
        _selectedTransactionIndices.clear();
      });

      await _recognizeImage(imageFile);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isRecognizing = false;
      });

      if (mounted) {
        GlassNotification.show(
          context,
          message: '选择图片失败: ${e.toString()}',
          icon: Icons.error_outline,
          backgroundColor: Colors.red.withOpacity(0.2),
          textColor: Colors.red,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  /// 识别图片
  Future<void> _recognizeImage(File imageFile) async {
    try {
      if (_selectedType == RecognitionType.singleTransaction) {
        // 单笔交易识别
        await _recognizeSingleTransaction(imageFile);
      } else if (_selectedType == RecognitionType.batchTransactions) {
        // 批量交易识别
        await _recognizeBatchTransactions(imageFile);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isRecognizing = false;
      });

      if (mounted) {
        GlassNotification.show(
          context,
          message: '识别失败: ${e.toString()}',
          icon: Icons.error_outline,
          backgroundColor: Colors.red.withOpacity(0.2),
          textColor: Colors.red,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  /// 识别单笔交易
  Future<void> _recognizeSingleTransaction(File imageFile) async {
    if (!mounted) return;

    final accountProvider = context.read<AccountProvider>();
    final budgetProvider = context.read<BudgetProvider>();

    final service = await _invoiceService;
    final parsed = await service.recognizeInvoice(
      imageFile: imageFile,
      accounts: accountProvider.activeAccounts,
      budgets: budgetProvider.envelopeBudgets,
    );

    if (!mounted) return;

    // 保存图片
    String? savedImagePath;
    try {
      savedImagePath = await _imageService.saveImageToAppDirectory(imageFile);
    } catch (e) {
      print('[UnifiedImageRecognitionWidget] ⚠️ 保存图片失败: $e');
    }

    if (!mounted) return;

    setState(() {
      _singleTransactionResult = parsed;
      _isRecognizing = false;
    });

    if (!mounted) return;

    if (parsed.isValid) {
      // 自动填充表单
      widget.onSingleTransactionRecognized(parsed, savedImagePath);

      if (mounted) {
        GlassNotification.show(
          context,
          message: '识别成功！已自动填充表单',
          icon: Icons.check_circle,
          backgroundColor: Colors.green.withOpacity(0.2),
          textColor: Colors.green,
          duration: const Duration(seconds: 2),
        );
      }
    } else {
      if (mounted) {
        GlassNotification.show(
          context,
          message: '识别完成，但信息不完整，请手动补充',
          icon: Icons.warning_amber_rounded,
          backgroundColor: Colors.orange.withOpacity(0.2),
          textColor: Colors.orange,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  /// 识别批量交易
  Future<void> _recognizeBatchTransactions(File imageFile) async {
    // 保存图片
    final savedPath = await _imageService.saveImageToAppDirectory(imageFile);
    
    if (!mounted) return;
    
    setState(() {
      _imagePath = savedPath;
    });

    final service = await _bankStatementService;
    final accountProvider = context.read<AccountProvider>();
    final transactionProvider = context.read<TransactionProvider>();

    final result = await service.recognizeBankStatement(
      imagePath: savedPath,
      accounts: accountProvider.accounts,
      existingTransactions: transactionProvider.transactions,
    );

    if (!mounted) return;

    setState(() {
      _batchTransactionsResult = result;
      _isRecognizing = false;
      // 默认全选
      _selectedTransactionIndices.clear();
    });
  }

  /// 导入选中的交易
  void _importSelectedTransactions() {
    if (_batchTransactionsResult == null) return;

    final parsedTransactions = _batchTransactionsResult!.toParsedTransactions(
      accounts: Provider.of<AccountProvider>(context, listen: false).accounts,
      existingTransactions:
          Provider.of<TransactionProvider>(context, listen: false).transactions,
    );

    final transactionsToImport = _selectedTransactionIndices.isEmpty
        ? parsedTransactions
        : parsedTransactions
            .where((t) => _selectedTransactionIndices
                .contains(parsedTransactions.indexOf(t)))
            .toList();

    if (transactionsToImport.isEmpty) {
      GlassNotification.show(
        context,
        message: '请至少选择一笔交易',
        icon: Icons.info_outline,
        backgroundColor: Colors.orange.withOpacity(0.2),
        textColor: Colors.orange,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // 批量创建交易
    _createTransactionsBatch(transactionsToImport);
  }

  /// 批量创建交易
  Future<void> _createTransactionsBatch(
    List<ParsedTransaction> transactions,
  ) async {
    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);

    int successCount = 0;
    int failCount = 0;

    for (final parsed in transactions) {
      try {
        final transaction = parsed.toTransaction();
        if (transaction != null) {
          await transactionProvider.addTransaction(transaction);
          successCount++;
        } else {
          failCount++;
        }
      } catch (e) {
        print(
          '[UnifiedImageRecognitionWidget._createTransactionsBatch] ❌ 创建交易失败: $e',
        );
        failCount++;
      }
    }

    if (mounted) {
      GlassNotification.show(
        context,
        message:
            '成功导入 $successCount 笔交易${failCount > 0 ? '，失败 $failCount 笔' : ''}',
        icon: failCount > 0 ? Icons.warning_amber_rounded : Icons.check_circle,
        backgroundColor:
            failCount > 0 ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
        textColor: failCount > 0 ? Colors.orange : Colors.green,
        duration: const Duration(seconds: 3),
      );

      // 调用回调
      widget.onBatchTransactionsRecognized(transactions);
    }
  }
}

