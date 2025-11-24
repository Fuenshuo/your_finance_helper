import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../theme/app_design_tokens.dart';

/// S25: 收支流水列表项样式
/// 应用中最常用、最高频的列表展示项
/// 
/// **样式特征：**
/// - 左侧（图标/分类名），中间（描述/账户），右侧（金额，收入绿色，支出红色）
/// - 可点击（带波纹效果），点击后跳转至交易详情
/// - 分类名使用 `AppDesignTokens.headline`，金额使用 `AppDesignTokens.headline`（加粗）
class TransactionFlowListItem extends StatelessWidget {
  /// 左侧图标
  final IconData icon;
  
  /// 分类名称
  final String categoryName;
  
  /// 账户名称（副标题）
  final String accountName;
  
  /// 金额
  final double amount;
  
  /// 是否为收入（true=收入/绿色，false=支出/红色）
  final bool isIncome;
  
  /// 分类颜色（用于图标背景）
  final Color categoryColor;
  
  /// 点击回调
  final VoidCallback? onTap;
  
  /// 自定义图标大小
  final double? iconSize;
  
  /// 自定义图标容器大小
  final double? iconContainerSize;

  const TransactionFlowListItem({
    super.key,
    required this.icon,
    required this.categoryName,
    required this.accountName,
    required this.amount,
    required this.isIncome,
    required this.categoryColor,
    this.onTap,
    this.iconSize,
    this.iconContainerSize,
  });

  @override
  Widget build(BuildContext context) {
    // 收入使用鲜草绿，支出使用明确的朱红色
    final amountColor = isIncome 
        ? AppDesignTokens.successColor(context) // #8BC34A 鲜草绿
        : const Color(0xFFE53935); // 朱红色（更明确的支出色）
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDesignTokens.globalHorizontalPadding, // 使用全局水平边距
          vertical: AppDesignTokens.spacingMedium, // 至少 16pt 垂直间距，拉开行高和对比度
        ),
        child: Row(
          children: [
            // 左侧颜色指示条（5px 宽，8pt 圆角）- 强化盈亏识别
            Container(
              width: 5, // 5px 宽度，更明显
              height: 40,
              decoration: BoxDecoration(
                color: amountColor,
                borderRadius: BorderRadius.circular(4), // 8pt 圆角的一半
              ),
            ),
            const SizedBox(width: AppDesignTokens.spacing12),
            // 左侧图标/分类
            Container(
              width: iconContainerSize ?? 40,
              height: iconContainerSize ?? 40,
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium(context)),
              ),
              child: Icon(
                icon,
                color: categoryColor,
                size: iconSize,
              ),
            ),
            const SizedBox(width: AppDesignTokens.spacing12),
            // 中间描述
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    style: AppDesignTokens.subtitle(context).copyWith(
                      fontWeight: FontWeight.w600, // 14pt SemiBold，拉开对比
                    ),
                  ),
                  SizedBox(height: AppDesignTokens.spacingMinor), // Minor spacing
                  Text(
                    accountName,
                    style: AppDesignTokens.label(context).copyWith(
                      color: AppDesignTokens.label(context).color!.withOpacity(0.6), // 12pt Grey Regular
                    ),
                  ),
                ],
              ),
            ),
            // 右侧金额（强化颜色对比，使用主要数值样式）
            Text(
              isIncome 
                  ? '+¥${amount.toStringAsFixed(2)}' 
                  : '-¥${amount.toStringAsFixed(2)}',
              style: AppDesignTokens.primaryValue(context).copyWith(
                fontSize: 18, // 列表项中稍小一些，但仍保持突出
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

