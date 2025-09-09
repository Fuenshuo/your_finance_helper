import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:your_finance_flutter/theme/app_theme.dart';
import 'package:your_finance_flutter/theme/responsive_text_styles.dart';
import 'package:your_finance_flutter/widgets/app_card.dart';

class ResponsiveTestScreen extends StatelessWidget {
  const ResponsiveTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: context.primaryBackground,
      appBar: AppBar(
        title: const Text('响应式样式测试'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.responsiveSpacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 设备信息
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '设备信息',
                    style: context.mobileTitle,
                  ),
                  SizedBox(height: context.responsiveSpacing12),
                  _buildInfoRow(
                      '屏幕宽度', '${mediaQuery.size.width.toStringAsFixed(1)}px'),
                  _buildInfoRow(
                      '屏幕高度', '${mediaQuery.size.height.toStringAsFixed(1)}px'),
                  _buildInfoRow('像素密度',
                      '${mediaQuery.devicePixelRatio.toStringAsFixed(2)}x'),
                  _buildInfoRow('平台', kIsWeb ? 'Web' : 'Mobile'),
                ],
              ),
            ),

            SizedBox(height: context.responsiveSpacing16),

            // 字体大小测试
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '字体大小测试',
                    style: context.mobileTitle,
                  ),
                  SizedBox(height: context.responsiveSpacing12),
                  Text(
                    '大标题 (Display Large)',
                    style: context.responsiveDisplayLarge,
                  ),
                  SizedBox(height: context.responsiveSpacing8),
                  Text(
                    '中标题 (Display Medium)',
                    style: context.responsiveDisplayMedium,
                  ),
                  SizedBox(height: context.responsiveSpacing8),
                  Text(
                    '小标题 (Headline Medium)',
                    style: context.responsiveHeadlineMedium,
                  ),
                  SizedBox(height: context.responsiveSpacing8),
                  Text(
                    '正文 (Body Large)',
                    style: context.responsiveBodyLarge,
                  ),
                  SizedBox(height: context.responsiveSpacing8),
                  Text(
                    '辅助文本 (Body Medium)',
                    style: context.responsiveBodyMedium,
                  ),
                  SizedBox(height: context.responsiveSpacing8),
                  Text(
                    '标签 (Label Large)',
                    style: context.responsiveLabelLarge,
                  ),
                ],
              ),
            ),

            SizedBox(height: context.responsiveSpacing16),

            // 移动端优化样式测试
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '移动端优化样式',
                    style: context.mobileTitle,
                  ),
                  SizedBox(height: context.responsiveSpacing12),
                  Text(
                    '移动端标题',
                    style: context.mobileTitle,
                  ),
                  SizedBox(height: context.responsiveSpacing8),
                  Text(
                    '移动端副标题',
                    style: context.mobileSubtitle,
                  ),
                  SizedBox(height: context.responsiveSpacing8),
                  Text(
                    '移动端正文',
                    style: context.mobileBody,
                  ),
                  SizedBox(height: context.responsiveSpacing8),
                  Text(
                    '移动端说明文字',
                    style: context.mobileCaption,
                  ),
                ],
              ),
            ),

            SizedBox(height: context.responsiveSpacing16),

            // 金额样式测试
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '金额样式测试',
                    style: context.mobileTitle,
                  ),
                  SizedBox(height: context.responsiveSpacing12),
                  Text(
                    '收入金额',
                    style: context.amountStyle(),
                  ),
                  SizedBox(height: context.responsiveSpacing8),
                  Text(
                    '支出金额',
                    style: context.amountStyle(isPositive: false),
                  ),
                  SizedBox(height: context.responsiveSpacing8),
                  Text(
                    '大金额收入',
                    style: context.largeAmountStyle(),
                  ),
                  SizedBox(height: context.responsiveSpacing8),
                  Text(
                    '大金额支出',
                    style: context.largeAmountStyle(isPositive: false),
                  ),
                ],
              ),
            ),

            SizedBox(height: context.responsiveSpacing16),

            // 间距测试
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '响应式间距测试',
                    style: context.mobileTitle,
                  ),
                  SizedBox(height: context.responsiveSpacing12),
                  Container(
                    width: double.infinity,
                    height: context.responsiveSpacing4,
                    color: Colors.red.withOpacity(0.3),
                    child: const Center(child: Text('4pt')),
                  ),
                  SizedBox(height: context.responsiveSpacing8),
                  Container(
                    width: double.infinity,
                    height: context.responsiveSpacing8,
                    color: Colors.orange.withOpacity(0.3),
                    child: const Center(child: Text('8pt')),
                  ),
                  SizedBox(height: context.responsiveSpacing8),
                  Container(
                    width: double.infinity,
                    height: context.responsiveSpacing12,
                    color: Colors.yellow.withOpacity(0.3),
                    child: const Center(child: Text('12pt')),
                  ),
                  SizedBox(height: context.responsiveSpacing8),
                  Container(
                    width: double.infinity,
                    height: context.responsiveSpacing16,
                    color: Colors.green.withOpacity(0.3),
                    child: const Center(child: Text('16pt')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
}
