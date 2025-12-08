import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/parsed_transaction.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/core/services/ai/bank_statement_recognition_service.dart';
import 'package:your_finance_flutter/core/services/ai/image_processing_service.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';

/// 银行账单识别Widget
/// 识别银行对账单并批量创建交易记录
class BankStatementRecognitionWidget extends StatefulWidget {
  const BankStatementRecognitionWidget({
    super.key,
    required this.onRecognized,
  });

  final void Function(List<ParsedTransaction> transactions) onRecognized;

  @override
  State<BankStatementRecognitionWidget> createState() =>
      _BankStatementRecognitionWidgetState();
}

class _BankStatementRecognitionWidgetState
    extends State<BankStatementRecognitionWidget> {
  bool _isRecognizing = false;
  String? _imagePath;
  BankStatementRecognitionResult? _recognitionResult;
  final Set<int> _selectedTransactionIndices = {};

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance,
                size: 20,
                color: context.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                '银行账单识别',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 图片选择按钮
          if (_imagePath == null)
            _buildImageSelectionButtons()
          else
            _buildImagePreview(),

          // 识别结果
          if (_isRecognizing) ...[
            const SizedBox(height: 12),
            _buildRecognizingIndicator(),
          ] else if (_recognitionResult != null) ...[
            const SizedBox(height: 12),
            _buildRecognitionResult(),
          ],
        ],
      ),
    );
  }

  /// 构建图片选择按钮
  Widget _buildImageSelectionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isRecognizing ? null : _pickImageFromGallery,
            icon: _isRecognizing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.photo_library),
            label: const Text('相册选择'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isRecognizing ? null : _takePhoto,
            icon: const Icon(Icons.camera_alt),
            label: const Text('拍照识别'),
          ),
        ),
      ],
    );
  }

  /// 构建图片预览
  Widget _buildImagePreview() {
    return Container(
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
                  _recognitionResult = null;
                  _selectedTransactionIndices.clear();
                });
              },
            ),
          ),
        ],
      ),
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
              '正在识别银行账单...',
              style: context.textTheme.bodySmall?.copyWith(
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建识别结果
  Widget _buildRecognitionResult() {
    if (_recognitionResult == null) return const SizedBox.shrink();

    final transactions = _recognitionResult!.transactions;
    final parsedTransactions = _recognitionResult!.toParsedTransactions(
      accounts: Provider.of<AccountProvider>(context, listen: false).accounts,
      existingTransactions:
          Provider.of<TransactionProvider>(context, listen: false).transactions,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        if (_recognitionResult!.summary != null) ...[
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
                  '总收入: ¥${_recognitionResult!.summary!.totalIncome.toStringAsFixed(2)}',
                  style: context.textTheme.bodySmall,
                ),
                Text(
                  '总支出: ¥${_recognitionResult!.summary!.totalExpense.toStringAsFixed(2)}',
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
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
                    ? const Icon(Icons.arrow_downward, color: Colors.green, size: 20)
                    : const Icon(Icons.arrow_upward, color: Colors.red, size: 20),
                dense: true,
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _imagePath = null;
                    _recognitionResult = null;
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

  /// 从相册选择图片
  Future<void> _pickImageFromGallery() async {
    try {
      final imageService = ImageProcessingService.getInstance();
      final imageFile = await imageService.pickImageFromGallery();
      if (imageFile == null) return;

      final savedPath = await imageService.saveImageToAppDirectory(imageFile);
      setState(() {
        _imagePath = savedPath;
      });

      // 自动开始识别
      _recognizeBankStatement();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片失败: $e')),
        );
      }
    }
  }

  /// 拍照
  Future<void> _takePhoto() async {
    try {
      final imageService = ImageProcessingService.getInstance();
      final imageFile = await imageService.takePhoto();
      if (imageFile == null) return;

      final savedPath = await imageService.saveImageToAppDirectory(imageFile);
      setState(() {
        _imagePath = savedPath;
      });

      // 自动开始识别
      _recognizeBankStatement();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('拍照失败: $e')),
        );
      }
    }
  }

  /// 识别银行账单
  Future<void> _recognizeBankStatement() async {
    if (_imagePath == null) return;

    setState(() {
      _isRecognizing = true;
      _recognitionResult = null;
      _selectedTransactionIndices.clear();
    });

    try {
      final service = await BankStatementRecognitionService.getInstance();
      final accountProvider =
          Provider.of<AccountProvider>(context, listen: false);
      final transactionProvider =
          Provider.of<TransactionProvider>(context, listen: false);

      final result = await service.recognizeBankStatement(
        imagePath: _imagePath!,
        accounts: accountProvider.accounts,
        existingTransactions: transactionProvider.transactions,
      );

      if (mounted) {
        setState(() {
          _recognitionResult = result;
          _isRecognizing = false;
          // 默认全选
          _selectedTransactionIndices.clear();
        });
      }
    } catch (e) {
      print(
        '[BankStatementRecognitionWidget._recognizeBankStatement] ❌ 识别失败: $e',
      );
      if (mounted) {
        setState(() {
          _isRecognizing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('识别失败: $e')),
        );
      }
    }
  }

  /// 导入选中的交易
  void _importSelectedTransactions() {
    if (_recognitionResult == null) return;

    final parsedTransactions = _recognitionResult!.toParsedTransactions(
      accounts: Provider.of<AccountProvider>(context, listen: false).accounts,
      existingTransactions:
          Provider.of<TransactionProvider>(context, listen: false).transactions,
    );

    final transactionsToImport = _selectedTransactionIndices.isEmpty
        ? parsedTransactions
        : parsedTransactions
            .where((t) =>
                _selectedTransactionIndices.contains(
                    parsedTransactions.indexOf(t)))
            .toList();

    if (transactionsToImport.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少选择一笔交易')),
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
          '[BankStatementRecognitionWidget._createTransactionsBatch] ❌ 创建交易失败: $e',
        );
        failCount++;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '成功导入 $successCount 笔交易${failCount > 0 ? '，失败 $failCount 笔' : ''}',
          ),
          backgroundColor: failCount > 0 ? Colors.orange : Colors.green,
        ),
      );

      // 关闭对话框并返回
      Navigator.of(context).pop();
    }
  }
}

