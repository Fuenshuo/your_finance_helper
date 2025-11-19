import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/parsed_transaction.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/budget_provider.dart';
import 'package:your_finance_flutter/core/services/ai/image_processing_service.dart';
import 'package:your_finance_flutter/core/services/ai/invoice_recognition_service.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/core/widgets/glass_notification.dart';

/// 发票识别组件
/// 提供拍照识别发票/收据功能
class InvoiceRecognitionWidget extends StatefulWidget {
  const InvoiceRecognitionWidget({
    super.key,
    required this.onRecognized,
  });

  /// 识别完成回调
  final void Function(ParsedTransaction, String? imagePath) onRecognized;

  @override
  State<InvoiceRecognitionWidget> createState() => _InvoiceRecognitionWidgetState();
}

class _InvoiceRecognitionWidgetState extends State<InvoiceRecognitionWidget> {
  final _imageService = ImageProcessingService.getInstance();
  final _recognitionService = InvoiceRecognitionService.getInstance();
  bool _isRecognizing = false;
  File? _selectedImage;
  ParsedTransaction? _recognizedResult;

  /// 拍照识别
  Future<void> _takePhotoAndRecognize() async {
    try {
      final imageFile = await _imageService.takePhoto();
      if (imageFile == null) return;

      setState(() {
        _selectedImage = imageFile;
        _isRecognizing = true;
        _recognizedResult = null;
      });

      await _recognizeImage(imageFile);
    } catch (e) {
      setState(() {
        _isRecognizing = false;
      });

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

  /// 从相册选择并识别
  Future<void> _pickImageAndRecognize() async {
    try {
      final imageFile = await _imageService.pickImageFromGallery();
      if (imageFile == null) return;

      setState(() {
        _selectedImage = imageFile;
        _isRecognizing = true;
        _recognizedResult = null;
      });

      await _recognizeImage(imageFile);
    } catch (e) {
      setState(() {
        _isRecognizing = false;
      });

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

  /// 识别图片
  Future<void> _recognizeImage(File imageFile) async {
    try {
      // 获取账户和预算列表
      final accountProvider = context.read<AccountProvider>();
      final budgetProvider = context.read<BudgetProvider>();

      final service = await _recognitionService;
      final parsed = await service.recognizeInvoice(
        imageFile: imageFile,
        accounts: accountProvider.activeAccounts,
        budgets: budgetProvider.envelopeBudgets,
      );

      // 保存图片
      String? savedImagePath;
      try {
        savedImagePath = await _imageService.saveImageToAppDirectory(imageFile);
      } catch (e) {
        print('[InvoiceRecognitionWidget] ⚠️ 保存图片失败: $e');
      }

      setState(() {
        _recognizedResult = parsed;
        _isRecognizing = false;
      });

      if (parsed.isValid) {
        // 自动填充表单
        widget.onRecognized(parsed, savedImagePath);

        GlassNotification.show(
          context,
          message: '识别成功！已自动填充表单',
          icon: Icons.check_circle,
          backgroundColor: Colors.green.withOpacity(0.2),
          textColor: Colors.green,
          duration: const Duration(seconds: 2),
        );
      } else {
        GlassNotification.show(
          context,
          message: '识别完成，但信息不完整，请手动补充',
          icon: Icons.warning_amber_rounded,
          backgroundColor: Colors.orange.withOpacity(0.2),
          textColor: Colors.orange,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      setState(() {
        _isRecognizing = false;
      });

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

  @override
  Widget build(BuildContext context) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 20,
                  color: context.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '发票/收据识别',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
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
                    icon: _isRecognizing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.camera_alt),
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
            if (_selectedImage != null && _recognizedResult != null) ...[
              const SizedBox(height: 12),
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
              if (!_recognizedResult!.isValid) ...[
                const SizedBox(height: 8),
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
                          '识别结果：${_recognizedResult!.description ?? "无描述"}，金额：${_recognizedResult!.amount ?? "无"}',
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
          ],
        ),
      );
}

