import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/providers/asset_provider.dart';
import 'package:your_finance_flutter/theme/app_theme.dart';
import 'package:your_finance_flutter/theme/responsive_text_styles.dart';
import 'package:your_finance_flutter/widgets/app_card.dart';

class AssetListOverviewCard extends StatelessWidget {
  const AssetListOverviewCard({super.key});

  @override
  Widget build(BuildContext context) => Consumer<AssetProvider>(
        builder: (context, assetProvider, child) {
          final totalAssets = assetProvider.calculateTotalAssets();
          final netAssets = assetProvider.calculateNetAssets();
          final debtRatio = assetProvider.calculateDebtRatio();
          final lastUpdate = assetProvider.getLastUpdateDate();

          // 从历史数据计算真实的变化
          return FutureBuilder<Map<String, double>>(
            future: assetProvider.getMonthlyChange(),
            builder: (context, snapshot) {
              final changeData = snapshot.data ??
                  {
                    'changeAmount': 0.0,
                    'changePercentage': 0.0,
                  };
              final changeAmount = changeData['changeAmount'] ?? 0.0;
              final changePercentage = changeData['changePercentage'] ?? 0.0;

              return AppCard(
                margin: EdgeInsets.all(context.responsiveSpacing16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFEAEAFB), // 温柔紫
                        Color(0xFFE8F4FD), // 淡蓝色
                        Color(0xFFF0F8FF), // 极淡蓝
                      ],
                      stops: [0.0, 0.6, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(context.borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEAEAFB).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.8),
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(context.responsiveSpacing16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 标题和开关
                        Row(
                          children: [
                            Text(
                              '总资产净值',
                              style: context.mobileTitle.copyWith(
                                color: context.primaryText,
                              ),
                            ),
                            SizedBox(width: context.responsiveSpacing8),
                            // 排除固定资产开关
                            GestureDetector(
                              onTap: () =>
                                  assetProvider.toggleExcludeFixedAssets(),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.responsiveSpacing8,
                                  vertical: context.responsiveSpacing4,
                                ),
                                decoration: BoxDecoration(
                                  color: assetProvider.excludeFixedAssets
                                      ? context.primaryAction.withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: assetProvider.excludeFixedAssets
                                        ? context.primaryAction
                                        : context.secondaryText
                                            .withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      assetProvider.excludeFixedAssets
                                          ? Icons.check_circle_outline
                                          : Icons.radio_button_unchecked,
                                      size: 14,
                                      color: assetProvider.excludeFixedAssets
                                          ? context.primaryAction
                                          : context.secondaryText,
                                    ),
                                    SizedBox(width: context.responsiveSpacing4),
                                    Text(
                                      '排除固定资产',
                                      style: context.mobileCaption.copyWith(
                                        color: assetProvider.excludeFixedAssets
                                            ? context.primaryAction
                                            : context.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () =>
                                  assetProvider.toggleAmountVisibility(),
                              icon: Icon(
                                assetProvider.isAmountHidden
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: context.secondaryText,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: context.responsiveSpacing12),

                        // 总资产金额 - 使用动画数字
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.responsiveSpacing12,
                            vertical: context.responsiveSpacing8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            assetProvider.formatAmount(netAssets),
                            style: context.responsiveDisplayLarge.copyWith(
                              color: context.primaryText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(height: context.responsiveSpacing16),

                        // 涨跌信息
                        Container(
                          padding: EdgeInsets.all(context.responsiveSpacing12),
                          decoration: BoxDecoration(
                            color: (changeAmount >= 0
                                    ? context.successColor
                                    : context.errorColor)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: (changeAmount >= 0
                                      ? context.successColor
                                      : context.errorColor)
                                  .withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding:
                                    EdgeInsets.all(context.responsiveSpacing4),
                                decoration: BoxDecoration(
                                  color: (changeAmount >= 0
                                          ? context.successColor
                                          : context.errorColor)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  changeAmount >= 0
                                      ? Icons.trending_up_outlined
                                      : Icons.trending_down_outlined,
                                  size: 16,
                                  color: changeAmount >= 0
                                      ? context.successColor
                                      : context.errorColor,
                                ),
                              ),
                              SizedBox(width: context.responsiveSpacing8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${changeAmount >= 0 ? '+' : ''}${assetProvider.formatAmount(changeAmount)}',
                                    style: context.mobileBody.copyWith(
                                      color: changeAmount >= 0
                                          ? context.successColor
                                          : context.errorColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '(${changePercentage >= 0 ? '+' : ''}${changePercentage.toStringAsFixed(2)}%)',
                                    style: context.mobileCaption.copyWith(
                                      color: changeAmount >= 0
                                          ? context.successColor
                                          : context.errorColor,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                '本月变化',
                                style: context.mobileCaption.copyWith(
                                  color: context.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: context.responsiveSpacing16),

                        // 总资产和负债率信息
                        Row(
                          children: [
                            // 总资产
                            Expanded(
                              child: Container(
                                padding:
                                    EdgeInsets.all(context.responsiveSpacing12),
                                decoration: BoxDecoration(
                                  color:
                                      context.primaryAction.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        context.primaryAction.withOpacity(0.1),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '总资产',
                                      style: context.mobileCaption.copyWith(
                                        color: context.secondaryText,
                                      ),
                                    ),
                                    SizedBox(
                                        height: context.responsiveSpacing4),
                                    Text(
                                      assetProvider.formatAmount(totalAssets),
                                      style: context.mobileBody.copyWith(
                                        color: context.primaryText,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: context.responsiveSpacing12),
                            // 负债率
                            Expanded(
                              child: Container(
                                padding:
                                    EdgeInsets.all(context.responsiveSpacing12),
                                decoration: BoxDecoration(
                                  color: context.errorColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: context.errorColor.withOpacity(0.1),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '负债率',
                                      style: context.mobileCaption.copyWith(
                                        color: context.secondaryText,
                                      ),
                                    ),
                                    SizedBox(
                                        height: context.responsiveSpacing4),
                                    Text(
                                      '${debtRatio.toStringAsFixed(1)}%',
                                      style: context.mobileBody.copyWith(
                                        color: context.errorColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: context.responsiveSpacing16),

                        // 趋势图 - 暂时禁用以提升性能
                        // OverviewTrendChart(
                        //   data: _generateTrendData(totalAssets),
                        //   title: '资产趋势',
                        //   subtitle: '近7天变化',
                        //   color: changeAmount >= 0
                        //       ? context.successColor
                        //       : context.errorColor,
                        // ),

                        // 最后更新日期
                        if (lastUpdate != null) ...[
                          SizedBox(height: context.responsiveSpacing16),
                          Divider(color: context.dividerColor),
                          SizedBox(height: context.responsiveSpacing8),
                          Row(
                            children: [
                              Icon(
                                Icons.update_outlined,
                                size: 14,
                                color: context.secondaryText,
                              ),
                              SizedBox(width: context.responsiveSpacing4),
                              Text(
                                '最近更新',
                                style: context.mobileCaption,
                              ),
                              const Spacer(),
                              Text(
                                '${lastUpdate.year}-${lastUpdate.month.toString().padLeft(2, '0')}-${lastUpdate.day.toString().padLeft(2, '0')}',
                                style: context.mobileCaption,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
}
