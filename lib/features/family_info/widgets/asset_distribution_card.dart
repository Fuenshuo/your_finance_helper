import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/asset_item.dart';
import 'package:your_finance_flutter/core/providers/asset_provider.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/theme/responsive_text_styles.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/core/widgets/sankey_chart_widget.dart';

class AssetDistributionCard extends StatefulWidget {
  const AssetDistributionCard({super.key});

  @override
  State<AssetDistributionCard> createState() => _AssetDistributionCardState();
}

class _AssetDistributionCardState extends State<AssetDistributionCard> {
  AssetCategory? _selectedCategory;
  bool _isLoadingAssets = false;

  // 处理分类标签点击
  void _handleCategoryTap(AssetCategory? category) {
    if (_selectedCategory != category) {
      setState(() {
        _isLoadingAssets = true;
      });

      // 延迟一下再切换，让用户看到清空效果
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _selectedCategory = category;
            _isLoadingAssets = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => Consumer<AssetProvider>(
        builder: (context, assetProvider, child) {
          final assets = assetProvider.assets;
          final totalAssets = assetProvider.calculateTotalAssets();

          return Column(
            children: [
              // 桑葚图卡片
              AppCard(
                margin: EdgeInsets.symmetric(
                  horizontal: context.responsiveSpacing16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '资产分布',
                      style: context.mobileTitle.copyWith(
                        color: context.primaryText,
                      ),
                    ),
                    SizedBox(height: context.responsiveSpacing16),

                    // 桑葚图
                    const SankeyChartWidget(),
                  ],
                ),
              ),

              SizedBox(height: context.responsiveSpacing16),

              // 横向滚动的资产概览卡片
              _buildAssetOverviewCards(assets, totalAssets, assetProvider),

              SizedBox(height: context.responsiveSpacing16),

              // 分类标签栏和详细列表
              _buildCategorySection(assets, assetProvider),
            ],
          );
        },
      );

  // 构建桑葚图

  // 构建横向滚动的资产概览卡片（按五大类分组）
  Widget _buildAssetOverviewCards(
    List<AssetItem> assets,
    double totalAssets,
    AssetProvider assetProvider,
  ) {
    // 按五大类分组
    final categoryGroups = <AssetCategory, List<AssetItem>>{};
    for (final asset in assets) {
      categoryGroups.putIfAbsent(asset.category, () => []).add(asset);
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: context.responsiveSpacing16),
        itemCount: AssetCategory.values.length,
        itemBuilder: (context, index) {
          final category = AssetCategory.values[index];
          final categoryAssets = categoryGroups[category] ?? [];
          final categoryTotal =
              categoryAssets.fold(0.0, (sum, asset) => sum + asset.amount);
          final percentage = totalAssets > 0
              ? (categoryTotal / totalAssets * 100).toStringAsFixed(1)
              : '0.0';

          return Container(
            width: 160,
            height: 120,
            margin: EdgeInsets.only(right: context.responsiveSpacing12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(context.responsiveSpacing12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题和占比
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          category.displayName,
                          style: context.mobileBody.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '$percentage%',
                        style: context.mobileCaption.copyWith(
                          color: _getCategoryColor(category),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.responsiveSpacing8),

                  // 资产额度
                  Expanded(
                    child: Text(
                      assetProvider.formatAmount(categoryTotal),
                      style: context.mobileTitle.copyWith(
                        color: _getCategoryColor(category),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: context.responsiveSpacing8),

                  // 账户数量
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.responsiveSpacing8,
                      vertical: context.responsiveSpacing4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(category).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${categoryAssets.length}个账户',
                      style: context.mobileCaption.copyWith(
                        color: _getCategoryColor(category),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 构建分类部分
  Widget _buildCategorySection(
    List<AssetItem> assets,
    AssetProvider assetProvider,
  ) =>
      AppCard(
        margin: EdgeInsets.symmetric(horizontal: context.responsiveSpacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '资产详情',
              style: context.mobileTitle.copyWith(
                color: context.primaryText,
              ),
            ),
            SizedBox(height: context.responsiveSpacing16),

            // 分类标签栏
            _buildCategoryTabs(assets, assetProvider),
            SizedBox(height: context.responsiveSpacing16),

            // 资产列表
            if (_isLoadingAssets)
              _buildLoadingState()
            else
              _buildAssetList(assets, _selectedCategory, assetProvider),
          ],
        ),
      );

  // 构建分类标签栏
  Widget _buildCategoryTabs(
    List<AssetItem> assets,
    AssetProvider assetProvider,
  ) {
    final totalAssets = assetProvider.calculateTotalAssets();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // 全部资产标签
          _AnimatedCategoryTab(
            title: '全部资产',
            category: null,
            count: assets.length,
            amount: totalAssets,
            totalAmount: totalAssets,
            isSelected: _selectedCategory == null,
            onTap: () => _handleCategoryTap(null),
          ),
          SizedBox(width: context.responsiveSpacing8),

          // 各分类标签
          ...AssetCategory.values.map((category) {
            final categoryAssets = _getCategoryAssets(assets, category);
            final categoryTotal = _calculateCategoryTotal(categoryAssets);

            return Padding(
              padding: EdgeInsets.only(right: context.responsiveSpacing8),
              child: _AnimatedCategoryTab(
                title: category.displayName,
                category: category,
                count: categoryAssets.length,
                amount: categoryTotal,
                totalAmount: totalAssets,
                isSelected: _selectedCategory == category,
                onTap: () => _handleCategoryTap(category),
              ),
            );
          }),
        ],
      ),
    );
  }

  // 构建资产列表
  Widget _buildAssetList(
    List<AssetItem> assets,
    AssetCategory? category,
    AssetProvider assetProvider,
  ) {
    final filteredAssets =
        category == null ? assets : _getCategoryAssets(assets, category);

    if (filteredAssets.isEmpty) {
      return _buildEmptyState(category);
    }

    return Column(
      children: filteredAssets
          .asMap()
          .entries
          .map(
            (entry) => AppAnimations.animatedListItem(
              index: entry.key,
              child: _buildAssetItem(entry.value, assetProvider),
            ),
          )
          .toList(),
    );
  }

  // 构建加载状态
  Widget _buildLoadingState() => SizedBox(
        height: 100,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.primaryAction,
                  ),
                ),
              ),
              SizedBox(height: context.responsiveSpacing8),
              Text(
                '加载中...',
                style: context.mobileCaption.copyWith(
                  color: context.secondaryText,
                ),
              ),
            ],
          ),
        ),
      );

  // 构建资产项（带动画）
  Widget _buildAssetItem(AssetItem asset, AssetProvider assetProvider) =>
      _AnimatedAssetItem(asset: asset, assetProvider: assetProvider);

  // 空状态
  Widget _buildEmptyState(AssetCategory? category) => Center(
        child: Padding(
          padding: EdgeInsets.all(context.responsiveSpacing32),
          child: Column(
            children: [
              Icon(
                category != null
                    ? _getCategoryIcon(category)
                    : Icons.account_balance_wallet_outlined,
                size: 48,
                color: context.secondaryText.withValues(alpha: 0.5),
              ),
              SizedBox(height: context.responsiveSpacing16),
              Text(
                category != null ? '暂无${category.displayName}' : '暂无资产',
                style: context.mobileTitle.copyWith(
                  color: context.secondaryText,
                ),
              ),
              SizedBox(height: context.responsiveSpacing8),
              Text(
                '点击右上角添加资产',
                style: context.mobileBody.copyWith(
                  color: context.secondaryText,
                ),
              ),
            ],
          ),
        ),
      );

  // 获取分类资产
  List<AssetItem> _getCategoryAssets(
    List<AssetItem> assets,
    AssetCategory category,
  ) =>
      assets.where((asset) => asset.category == category).toList();

  // 计算分类总金额
  double _calculateCategoryTotal(List<AssetItem> assets) =>
      assets.fold(0.0, (sum, asset) => sum + asset.amount);

  // 获取分类颜色
  Color _getCategoryColor(AssetCategory category) {
    switch (category) {
      case AssetCategory.liquidAssets:
        return context.successColor;
      case AssetCategory.realEstate:
        return context.errorColor;
      case AssetCategory.investments:
        return context.warningColor;
      case AssetCategory.consumptionAssets:
        return Colors.teal;
      case AssetCategory.receivables:
        return context.primaryAction;
      case AssetCategory.liabilities:
        return Colors.orange;
    }
  }

  // 获取分类图标
  IconData _getCategoryIcon(AssetCategory category) {
    switch (category) {
      case AssetCategory.liquidAssets:
        return Icons.payments_outlined;
      case AssetCategory.realEstate:
        return Icons.home_outlined;
      case AssetCategory.investments:
        return Icons.trending_up_outlined;
      case AssetCategory.consumptionAssets:
        return Icons.shopping_cart_outlined;
      case AssetCategory.receivables:
        return Icons.account_balance_wallet_outlined;
      case AssetCategory.liabilities:
        return Icons.credit_card_outlined;
    }
  }
}

// 带动画的资产项组件
class _AnimatedAssetItem extends StatefulWidget {
  const _AnimatedAssetItem({
    required this.asset,
    required this.assetProvider,
  });

  final AssetItem asset;
  final AssetProvider assetProvider;

  @override
  State<_AnimatedAssetItem> createState() => _AnimatedAssetItemState();
}

class _AnimatedAssetItemState extends State<_AnimatedAssetItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // 启动淡入动画
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.scale(
            scale: _isHovered ? _scaleAnimation.value : 1.0,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: Container(
                margin: EdgeInsets.only(bottom: context.responsiveSpacing8),
                padding: EdgeInsets.all(context.responsiveSpacing12),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? context.primaryAction.withValues(alpha: 0.05)
                      : context.primaryBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isHovered
                        ? context.primaryAction.withValues(alpha: 0.3)
                        : context.dividerColor,
                    width: _isHovered ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    // 图标（带动画）
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            _getCategoryColor(widget.asset.category).withValues(
                          alpha: _isHovered ? 0.15 : 0.1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AnimatedScale(
                        scale: _isHovered ? 1.1 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _getCategoryIcon(widget.asset.category),
                          color: _getCategoryColor(widget.asset.category),
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(width: context.responsiveSpacing12),

                    // 资产信息（带动画）
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: context.mobileBody.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _isHovered
                                  ? context.primaryAction
                                  : context.primaryText,
                            ),
                            child: Text(widget.asset.name),
                          ),
                          SizedBox(height: context.responsiveSpacing4),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: context.responsiveSpacing8,
                              vertical: context.responsiveSpacing4,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(widget.asset.category)
                                  .withValues(
                                alpha: _isHovered ? 0.2 : 0.1,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.asset.category.displayName,
                              style: context.mobileCaption.copyWith(
                                color: _getCategoryColor(widget.asset.category),
                                fontWeight: _isHovered
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 金额（带动画）
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: context.mobileBody.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _isHovered
                            ? context.primaryAction
                            : context.primaryText,
                      ),
                      child: Text(
                        widget.assetProvider.formatAmount(widget.asset.amount),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Color _getCategoryColor(AssetCategory category) {
    switch (category) {
      case AssetCategory.liquidAssets:
        return const Color(0xFF007AFF);
      case AssetCategory.realEstate:
        return const Color(0xFF34C759);
      case AssetCategory.investments:
        return const Color(0xFFFF9500);
      case AssetCategory.consumptionAssets:
        return const Color(0xFF30D158);
      case AssetCategory.receivables:
        return const Color(0xFFAF52DE);
      case AssetCategory.liabilities:
        return const Color(0xFFFF3B30);
    }
  }

  IconData _getCategoryIcon(AssetCategory category) {
    switch (category) {
      case AssetCategory.liquidAssets:
        return Icons.account_balance_wallet_outlined;
      case AssetCategory.realEstate:
        return Icons.home_outlined;
      case AssetCategory.investments:
        return Icons.trending_up_outlined;
      case AssetCategory.consumptionAssets:
        return Icons.shopping_cart_outlined;
      case AssetCategory.receivables:
        return Icons.account_balance_wallet_outlined;
      case AssetCategory.liabilities:
        return Icons.credit_card_outlined;
    }
  }
}

// 带动画的分类标签组件
class _AnimatedCategoryTab extends StatefulWidget {
  const _AnimatedCategoryTab({
    required this.title,
    required this.category,
    required this.count,
    required this.amount,
    required this.totalAmount,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final AssetCategory? category;
  final int count;
  final double amount;
  final double totalAmount;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_AnimatedCategoryTab> createState() => _AnimatedCategoryTabState();
}

class _AnimatedCategoryTabState extends State<_AnimatedCategoryTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = widget.totalAmount > 0
        ? (widget.amount / widget.totalAmount * 100).toStringAsFixed(1)
        : '0.0';

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          _animationController.forward();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _animationController.reverse();
        },
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) => Transform.scale(
            scale: _isHovered ? _scaleAnimation.value : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveSpacing12,
                vertical: context.responsiveSpacing8,
              ),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? context.primaryAction
                    : (_isHovered
                        ? context.primaryAction.withValues(alpha: 0.1)
                        : context.primaryBackground),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isSelected
                      ? context.primaryAction
                      : (_isHovered
                          ? context.primaryAction.withValues(alpha: 0.3)
                          : context.dividerColor),
                  width: _isHovered ? 1.5 : 1.0,
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: context.primaryAction.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: context.mobileBody.copyWith(
                      color: widget.isSelected
                          ? Colors.white
                          : (_isHovered
                              ? context.primaryAction
                              : context.primaryText),
                      fontWeight: FontWeight.w600,
                    ),
                    child: Text(widget.title),
                  ),
                  SizedBox(height: context.responsiveSpacing4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: context.mobileCaption.copyWith(
                      color: widget.isSelected
                          ? Colors.white.withValues(alpha: 0.8)
                          : (_isHovered
                              ? context.primaryAction.withValues(alpha: 0.7)
                              : context.secondaryText),
                      fontSize: 10,
                    ),
                    child: Text('${widget.count}个 • $percentage%'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 桑葚图绘制器
