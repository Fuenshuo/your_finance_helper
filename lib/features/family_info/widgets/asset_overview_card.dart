import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/providers/asset_provider.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/theme/responsive_text_styles.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';

class AssetOverviewCard extends StatelessWidget {
  const AssetOverviewCard({super.key});

  @override
  Widget build(BuildContext context) => Consumer<AssetProvider>(
        builder: (context, assetProvider, child) {
          final totalAssets = assetProvider.calculateTotalAssets();
          final netAssets = assetProvider.calculateNetAssets();
          final debtRatio = assetProvider.calculateDebtRatio();
          final lastUpdate = assetProvider.getLastUpdateDate();

          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 总资产标题和眼睛图标
                Row(
                  children: [
                    Text(
                      '总资产',
                      style: context.responsiveHeadlineMedium,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => assetProvider.toggleAmountVisibility(),
                      icon: Icon(
                        assetProvider.isAmountHidden
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: context.secondaryText,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.responsiveSpacing8),

                // 总资产金额
                Text(
                  '¥${totalAssets.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: context.spacing16),

                // 排除固定资产开关
                Container(
                  padding: EdgeInsets.all(context.spacing12),
                  decoration: BoxDecoration(
                    color: context.accentBackground,
                    borderRadius: BorderRadius.circular(context.borderRadius),
                  ),
                  child: Row(
                    children: [
                      Switch(
                        value: assetProvider.excludeFixedAssets,
                        onChanged: (_) =>
                            assetProvider.toggleExcludeFixedAssets(),
                        activeThumbColor: context.primaryAction,
                      ),
                      SizedBox(width: context.spacing8),
                      Expanded(
                        child: Text(
                          '排除固定资产',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.spacing16),

                // 分割线
                Divider(color: context.dividerColor),
                SizedBox(height: context.spacing16),

                // 净资产和负债率
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: '净资产',
                        value: assetProvider.formatAmount(netAssets),
                        valueColor: context.decreaseColor,
                        icon: Icons.trending_up_outlined,
                      ),
                    ),
                    SizedBox(width: context.spacing16),
                    Expanded(
                      child: StatCard(
                        title: '负债率',
                        value: '${debtRatio.toStringAsFixed(1)}%',
                        valueColor: debtRatio > 50
                            ? context.increaseColor
                            : context.secondaryText,
                        icon: Icons.pie_chart_outline,
                      ),
                    ),
                  ],
                ),

                // 最后更新日期
                if (lastUpdate != null) ...[
                  SizedBox(height: context.spacing16),
                  Divider(color: context.dividerColor),
                  SizedBox(height: context.spacing8),
                  Row(
                    children: [
                      Icon(
                        Icons.update_outlined,
                        size: 16,
                        color: context.secondaryText,
                      ),
                      SizedBox(width: context.spacing8),
                      Text(
                        '最近更新',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Text(
                        '${lastUpdate.year}-${lastUpdate.month.toString().padLeft(2, '0')}-${lastUpdate.day.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      );
}
