import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:your_finance_flutter/core/models/clearance_entry.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/services/clearance_service.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/theme/responsive_text_styles.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/core/widgets/glass_notification.dart';

class PeriodSummaryScreen extends ConsumerStatefulWidget {
  final PeriodClearanceSession session;

  const PeriodSummaryScreen({
    super.key,
    required this.session,
  });

  @override
  ConsumerState<PeriodSummaryScreen> createState() => _PeriodSummaryScreenState();
}

class _PeriodSummaryScreenState extends ConsumerState<PeriodSummaryScreen> {
  final PeriodClearanceService _clearanceService = PeriodClearanceService();
  final WidgetsToImageController _widgetsToImageController = WidgetsToImageController();
  final GlobalKey _contentKey = GlobalKey();
  
  PeriodSummary? _summary;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadSummary();
  }

  Future<void> _initializeAndLoadSummary() async {
    await _clearanceService.initialize();
    await _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() => _isLoading = true);
    
    try {
      final summary = await _clearanceService.generatePeriodSummary(widget.session.id);
      setState(() {
        _summary = summary;
      });
    } catch (e) {
      Logger.debug('生成总结失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('生成总结失败: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('财务总结', style: context.responsiveHeadlineMedium),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _shareReport,
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _summary == null
              ? _buildErrorState()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;
                    final contentWidth = screenWidth - context.responsiveSpacing16 * 2;
                    return Stack(
                      children: [
                        // 用户看到的可滚动内容
                        SingleChildScrollView(
                          padding: EdgeInsets.all(context.responsiveSpacing16),
                          child: _buildContent(),
                        ),
                        // 隐藏的完整内容用于截图（移到屏幕外但保持渲染）
                        Positioned(
                          left: -screenWidth * 2,
                          top: 0,
                          child: IgnorePointer(
                            child: RepaintBoundary(
                              key: _contentKey,
                              child: WidgetsToImage(
                                controller: _widgetsToImageController,
                                child: Material(
                                  color: context.primaryBackground,
                                  child: Container(
                                    width: screenWidth,
                                    constraints: BoxConstraints(
                                      minWidth: screenWidth,
                                      maxWidth: screenWidth,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: context.responsiveSpacing16,
                                      vertical: context.responsiveSpacing16,
                                    ),
                                    child: SizedBox(
                                      width: contentWidth,
                                      child: _buildContent(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }

  // 会话信息卡片
  Widget _buildSessionInfoCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.session.name,
                style: context.responsiveHeadlineMedium.copyWith(
                  color: Colors.green,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveSpacing8,
                  vertical: context.responsiveSpacing4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 14),
                    SizedBox(width: context.responsiveSpacing4),
                    const Text(
                      '已完成',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.responsiveSpacing8),
          Text(
            widget.session.periodDescription,
            style: context.responsiveBodyMedium.copyWith(
              color: Colors.grey,
            ),
          ),
          SizedBox(height: context.responsiveSpacing8),
          Text(
            '生成时间: ${DateFormat('yyyy-MM-dd HH:mm').format(_summary!.generatedDate)}',
            style: context.responsiveBodySmall.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // 财务概览卡片
  Widget _buildFinancialOverviewCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '财务概览',
            style: context.responsiveHeadlineMedium,
          ),
          SizedBox(height: context.responsiveSpacing16),
          
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  '总收入',
                  context.formatAmount(_summary!.totalIncome),
                  Colors.green,
                  Icons.trending_up,
                ),
              ),
              Expanded(
                child: _buildOverviewItem(
                  '总支出',
                  context.formatAmount(_summary!.totalExpense),
                  Colors.red,
                  Icons.trending_down,
                ),
              ),
              Expanded(
                child: _buildOverviewItem(
                  '净变化',
                  context.formatAmount(_summary!.netChange),
                  _summary!.netChange >= 0 ? Colors.green : Colors.red,
                  _summary!.netChange >= 0 ? Icons.add_circle : Icons.remove_circle,
                ),
              ),
            ],
          ),
          
          SizedBox(height: context.responsiveSpacing16),
          
          // 净变化百分比
          if (_summary!.totalIncome > 0) ...[
            Container(
              padding: EdgeInsets.all(context.responsiveSpacing12),
              decoration: BoxDecoration(
                color: (_summary!.netChange >= 0 ? Colors.green : Colors.red).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (_summary!.netChange >= 0 ? Colors.green : Colors.red).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _summary!.netChange >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: _summary!.netChange >= 0 ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  SizedBox(width: context.responsiveSpacing8),
                  Text(
                    _summary!.netChange >= 0 ? '本期盈余' : '本期亏损',
                    style: context.responsiveBodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: _summary!.netChange >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${((_summary!.netChange / _summary!.totalIncome) * 100).toStringAsFixed(1)}%',
                    style: context.responsiveBodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _summary!.netChange >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 收支分析卡片
  Widget _buildIncomeExpenseAnalysisCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '收支分析',
            style: context.responsiveHeadlineMedium,
          ),
          SizedBox(height: context.responsiveSpacing16),
          
          // 收支对比图表（简化版）
          Container(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _buildBarChart(
                    '收入',
                    _summary!.totalIncome,
                    Colors.green,
                    _summary!.totalIncome > _summary!.totalExpense
                        ? 1.0
                        : _summary!.totalIncome / _summary!.totalExpense,
                  ),
                ),
                SizedBox(width: context.responsiveSpacing16),
                Expanded(
                  child: _buildBarChart(
                    '支出',
                    _summary!.totalExpense,
                    Colors.red,
                    _summary!.totalExpense > _summary!.totalIncome
                        ? 1.0
                        : _summary!.totalExpense / _summary!.totalIncome,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: context.responsiveSpacing16),
          
          // 收支比例
          Row(
            children: [
              Expanded(
                child: _buildRatioInfo(
                  '收入占比',
                  _summary!.totalIncome + _summary!.totalExpense > 0
                      ? (_summary!.totalIncome / (_summary!.totalIncome + _summary!.totalExpense))
                      : 0.0,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildRatioInfo(
                  '支出占比',
                  _summary!.totalIncome + _summary!.totalExpense > 0
                      ? (_summary!.totalExpense / (_summary!.totalIncome + _summary!.totalExpense))
                      : 0.0,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 分类支出分析卡片
  Widget _buildCategoryAnalysisCard() {
    if (_summary!.categoryBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    // 按金额排序分类
    final sortedCategories = _summary!.categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '分类分析',
            style: context.responsiveHeadlineMedium,
          ),
          SizedBox(height: context.responsiveSpacing16),
          
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedCategories.length,
            separatorBuilder: (context, index) => SizedBox(height: context.responsiveSpacing8),
            itemBuilder: (context, index) {
              final entry = sortedCategories[index];
              final percentage = _summary!.totalExpense > 0
                  ? (entry.value / _summary!.totalExpense)
                  : 0.0;
              
              return _buildCategoryItem(
                entry.key,
                entry.value,
                percentage,
                _getCategoryColor(entry.key),
              );
            },
          ),
        ],
      ),
    );
  }

  // 主要交易列表卡片
  Widget _buildTopTransactionsCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '主要交易',
                style: context.responsiveHeadlineMedium,
              ),
              Text(
                '按金额排序',
                style: context.responsiveBodySmall.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          SizedBox(height: context.responsiveSpacing16),
          
          if (_summary!.topTransactions.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(context.responsiveSpacing24),
                child: Text(
                  '本期无交易记录',
                  style: context.responsiveBodyMedium.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _summary!.topTransactions.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey[300],
              ),
              itemBuilder: (context, index) {
                final transaction = _summary!.topTransactions[index];
                return _buildTransactionItem(transaction);
              },
            ),
        ],
      ),
    );
  }

  // 构建完整内容（用于显示和截图）
  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 会话信息卡片
        _buildSessionInfoCard(),
        SizedBox(height: context.responsiveSpacing16),

        // 财务概览卡片
        _buildFinancialOverviewCard(),
        SizedBox(height: context.responsiveSpacing16),

        // 收支分析卡片
        _buildIncomeExpenseAnalysisCard(),
        SizedBox(height: context.responsiveSpacing16),

        // 分类支出分析
        _buildCategoryAnalysisCard(),
        SizedBox(height: context.responsiveSpacing16),

        // 主要交易列表
        _buildTopTransactionsCard(),
      ],
    );
  }

  // 错误状态
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.responsiveSpacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: context.responsiveSpacing16),
            Text(
              '生成总结失败',
              style: context.responsiveHeadlineMedium.copyWith(
                color: Colors.grey,
              ),
            ),
            SizedBox(height: context.responsiveSpacing8),
            Text(
              '请检查数据完整性后重试',
              style: context.responsiveBodyMedium.copyWith(
                color: Colors.grey,
              ),
            ),
            SizedBox(height: context.responsiveSpacing16),
            ElevatedButton(
              onPressed: _loadSummary,
              child: const Text('重新生成'),
            ),
          ],
        ),
      ),
    );
  }

  // 辅助UI组件
  Widget _buildOverviewItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: context.responsiveSpacing8),
        Text(
          label,
          style: context.responsiveBodySmall.copyWith(
            color: Colors.grey,
          ),
        ),
        SizedBox(height: context.responsiveSpacing4),
        Text(
          value,
          style: context.responsiveBodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(String label, double amount, Color color, double ratio) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.formatAmount(amount),
          style: context.responsiveBodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
            fontSize: 11,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxHeight = constraints.maxHeight;
              final barHeight = (maxHeight * ratio).clamp(0.0, maxHeight);
              return Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: context.responsiveBodySmall.copyWith(
            color: Colors.grey,
            fontSize: 11,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildRatioInfo(String label, double ratio, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: context.responsiveBodyMedium,
            ),
            Text(
              '${(ratio * 100).toStringAsFixed(1)}%',
              style: context.responsiveBodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: context.responsiveSpacing4),
        LinearProgressIndicator(
          value: ratio,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(String categoryName, double amount, double percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        SizedBox(width: context.responsiveSpacing8),
        Expanded(
          child: Text(
            categoryName,
            style: context.responsiveBodyMedium,
          ),
        ),
        Text(
          '${(percentage * 100).toStringAsFixed(1)}%',
          style: context.responsiveBodySmall.copyWith(
            color: Colors.grey,
          ),
        ),
        SizedBox(width: context.responsiveSpacing8),
        Text(
          context.formatAmount(amount),
          style: context.responsiveBodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(ManualTransaction transaction) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getCategoryColor(transaction.category.displayName).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getCategoryIcon(transaction.category),
          color: _getCategoryColor(transaction.category.displayName),
          size: 20,
        ),
      ),
      title: Text(
        transaction.description,
        style: context.responsiveBodyLarge,
      ),
      subtitle: Text(
        '${transaction.category.displayName} • ${DateFormat('MM-dd').format(transaction.date)}',
        style: context.responsiveBodySmall.copyWith(
          color: Colors.grey,
        ),
      ),
      trailing: Text(
        context.formatAmount(
          transaction.category.isIncome ? transaction.amount : -transaction.amount,
        ),
        style: context.amountStyle(
          isPositive: transaction.category.isIncome,
        ),
      ),
    );
  }

  // 业务逻辑方法
  Color _getCategoryColor(String categoryName) {
    // 为不同分类分配颜色
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.lime,
    ];
    
    final index = categoryName.hashCode % colors.length;
    return colors[index.abs()];
  }

  IconData _getCategoryIcon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.salary:
        return Icons.work;
      case TransactionCategory.food:
        return Icons.restaurant;
      case TransactionCategory.transport:
        return Icons.directions_car;
      case TransactionCategory.shopping:
        return Icons.shopping_bag;
      case TransactionCategory.entertainment:
        return Icons.movie;
      case TransactionCategory.healthcare:
        return Icons.local_hospital;
      case TransactionCategory.education:
        return Icons.school;
      case TransactionCategory.housing:
        return Icons.home;
      case TransactionCategory.utilities:
        return Icons.electrical_services;
      case TransactionCategory.investment:
        return Icons.trending_up;
      case TransactionCategory.otherIncome:
      case TransactionCategory.otherExpense:
        return Icons.more_horiz;
      default:
        return Icons.attach_money;
    }
  }

  // 事件处理方法
  void _shareReport() {
    if (_summary == null) {
      GlassNotification.show(
        context,
        message: '请等待总结生成完成',
        icon: Icons.info_outline,
        backgroundColor: Colors.orange.withOpacity(0.2),
        textColor: Colors.orange,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '分享财务总结',
                style: context.responsiveHeadlineMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.blue),
              title: const Text('分享为图片'),
              subtitle: const Text('将财务总结截图并分享'),
              onTap: () {
                Navigator.of(context).pop();
                _shareAsImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_fields, color: Colors.green),
              title: const Text('分享为文本'),
              subtitle: const Text('生成文本格式的财务总结'),
              onTap: () {
                Navigator.of(context).pop();
                _shareAsText();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // 分享为图片
  Future<void> _shareAsImage() async {
    if (_summary == null) return;

    try {
      GlassNotification.show(
        context,
        message: '正在生成图片...',
        icon: Icons.image,
        backgroundColor: Colors.blue.withOpacity(0.2),
        textColor: Colors.blue,
        duration: const Duration(seconds: 1),
      );

      // 等待一下确保隐藏的widget完全渲染
      await Future<void>.delayed(const Duration(milliseconds: 800));

      // 获取设备像素密度和屏幕宽度，确保截图质量
      final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      final screenWidth = MediaQuery.of(context).size.width;

      // 截图隐藏的完整内容，指定像素密度以确保正确的宽度
      final imageBytes = await _widgetsToImageController.capture(
        pixelRatio: devicePixelRatio,
      );
      
      // 打印调试信息
      print('[PeriodSummaryScreen._shareAsImage] 📐 屏幕宽度: $screenWidth, 像素密度: $devicePixelRatio');
      
      if (imageBytes == null) {
        throw Exception('截图失败，请重试');
      }

      // 保存到临时文件
      final tempDir = await getTemporaryDirectory();
      final fileName = '财务总结_${widget.session.name}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      // 打印保存路径（方便调试）
      print('[PeriodSummaryScreen._shareAsImage] 📸 图片已保存到: ${file.path}');

      // 分享图片
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${widget.session.name} - 财务总结',
        subject: widget.session.name,
      );

      GlassNotification.show(
        context,
        message: '图片分享成功',
        icon: Icons.check_circle,
        backgroundColor: Colors.green.withOpacity(0.2),
        textColor: Colors.green,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Logger.debug('分享图片失败: $e');
      GlassNotification.show(
        context,
        message: '分享失败: $e',
        icon: Icons.error_outline,
        backgroundColor: Colors.red.withOpacity(0.2),
        textColor: Colors.red,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // 分享为文本
  Future<void> _shareAsText() async {
    if (_summary == null) return;

    try {
      final buffer = StringBuffer();
      
      // 标题
      buffer.writeln('${widget.session.name}');
      buffer.writeln('=' * 40);
      buffer.writeln();
      
      // 周期信息
      buffer.writeln('周期: ${widget.session.periodDescription}');
      buffer.writeln('生成时间: ${DateFormat('yyyy-MM-dd HH:mm').format(_summary!.generatedDate)}');
      buffer.writeln();
      
      // 财务概览
      buffer.writeln('财务概览');
      buffer.writeln('-' * 40);
      buffer.writeln('总收入: ${context.formatAmount(_summary!.totalIncome)}');
      buffer.writeln('总支出: ${context.formatAmount(_summary!.totalExpense)}');
      buffer.writeln('净变化: ${context.formatAmount(_summary!.netChange)}');
      if (_summary!.totalIncome > 0) {
        final percentage = ((_summary!.netChange / _summary!.totalIncome) * 100).toStringAsFixed(1);
        buffer.writeln('${_summary!.netChange >= 0 ? "盈余" : "亏损"}率: $percentage%');
      }
      buffer.writeln();
      
      // 收支分析
      if (_summary!.totalIncome + _summary!.totalExpense > 0) {
        final incomeRatio = (_summary!.totalIncome / (_summary!.totalIncome + _summary!.totalExpense) * 100).toStringAsFixed(1);
        final expenseRatio = (_summary!.totalExpense / (_summary!.totalIncome + _summary!.totalExpense) * 100).toStringAsFixed(1);
        buffer.writeln('收支分析');
        buffer.writeln('-' * 40);
        buffer.writeln('收入占比: $incomeRatio%');
        buffer.writeln('支出占比: $expenseRatio%');
        buffer.writeln();
      }
      
      // 分类分析
      if (_summary!.categoryBreakdown.isNotEmpty) {
        buffer.writeln('分类分析');
        buffer.writeln('-' * 40);
        final sortedCategories = _summary!.categoryBreakdown.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        
        for (final entry in sortedCategories) {
          final percentage = _summary!.totalExpense > 0
              ? (entry.value / _summary!.totalExpense * 100).toStringAsFixed(1)
              : '0.0';
          buffer.writeln('${entry.key}: ${context.formatAmount(entry.value)} ($percentage%)');
        }
        buffer.writeln();
      }
      
      // 主要交易
      if (_summary!.topTransactions.isNotEmpty) {
        buffer.writeln('主要交易');
        buffer.writeln('-' * 40);
        for (final transaction in _summary!.topTransactions) {
          final sign = transaction.category.isIncome ? '+' : '-';
          buffer.writeln('${sign}${context.formatAmount(transaction.amount)} - ${transaction.description}');
          buffer.writeln('  ${transaction.category.displayName} • ${DateFormat('MM-dd').format(transaction.date)}');
        }
        buffer.writeln();
      }
      
      buffer.writeln('=' * 40);
      buffer.writeln('来自：家庭资产记账应用');

      // 分享文本
      await Share.share(
        buffer.toString(),
        subject: '${widget.session.name} - 财务总结',
      );

      GlassNotification.show(
        context,
        message: '文本分享成功',
        icon: Icons.check_circle,
        backgroundColor: Colors.green.withOpacity(0.2),
        textColor: Colors.green,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Logger.debug('分享文本失败: $e');
      GlassNotification.show(
        context,
        message: '分享失败: $e',
        icon: Icons.error_outline,
        backgroundColor: Colors.red.withOpacity(0.2),
        textColor: Colors.red,
        duration: const Duration(seconds: 3),
      );
    }
  }

}
