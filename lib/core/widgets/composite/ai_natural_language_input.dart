import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../theme/app_design_tokens.dart';
import '../app_text_field.dart';
import '../app_card.dart';

/// S26: AI 自然语言输入框样式
/// 交易录入的最高效入口
/// 
/// **样式特征：**
/// - 文本输入框 + 语音图标按钮 + AI解析结果预览区域
/// - 占位符文案强调自然语言能力
class AINaturalLanguageInput extends StatelessWidget {
  /// 输入框控制器
  final TextEditingController? controller;
  
  /// 标签文本
  final String? labelText;
  
  /// 占位符文本
  final String hintText;
  
  /// 语音输入回调
  final VoidCallback? onVoiceInput;
  
  /// AI 解析结果预览（如果为 null，则不显示预览区域）
  final String? aiPreview;
  
  /// 输入框值变化回调
  final ValueChanged<String>? onChanged;
  
  /// 提交回调
  final ValueChanged<String>? onFieldSubmitted;

  const AINaturalLanguageInput({
    super.key,
    this.controller,
    this.labelText,
    this.hintText = '一句话记录交易，如：今天星巴克拿铁35元',
    this.onVoiceInput,
    this.aiPreview,
    this.onChanged,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: controller,
                labelText: labelText,
                hintText: hintText,
                prefixIcon: const Icon(CupertinoIcons.chat_bubble_text),
                onChanged: onChanged,
                onFieldSubmitted: onFieldSubmitted,
              ),
            ),
            if (onVoiceInput != null) ...[
              const SizedBox(width: AppDesignTokens.spacing8),
              IconButton(
                icon: const Icon(CupertinoIcons.mic),
                onPressed: onVoiceInput,
                tooltip: '语音输入',
              ),
            ],
          ],
        ),
        if (aiPreview != null) ...[
          const SizedBox(height: AppDesignTokens.spacing12),
          AppCard(
            padding: const EdgeInsets.all(AppDesignTokens.spacing12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI 解析结果：',
                  style: AppDesignTokens.caption(context),
                ),
                const SizedBox(height: AppDesignTokens.spacing4),
                Text(
                  aiPreview!,
                  style: AppDesignTokens.body(context),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

