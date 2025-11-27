import 'dart:math';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:your_finance_flutter/core/services/insight_service.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart'
    hide AppTheme;
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/core/widgets/app_selection_controls.dart';
import 'package:your_finance_flutter/core/widgets/app_shimmer.dart';

/// Segmented视图模式，对应日/周/月洞察。
enum InsightViewMode { day, week, month }

/// Flux Insights 2.0 - AI CFO 控制台
class FlowInsightsScreen extends StatefulWidget {
  const FlowInsightsScreen({super.key, InsightService? service})
      : _overrideService = service;

  final InsightService? _overrideService;

  @override
  State<FlowInsightsScreen> createState() => _FlowInsightsScreenState();
}

class _FlowInsightsScreenState extends State<FlowInsightsScreen> {
  late final InsightService _service;
  late final Stream<InsightSnapshot<DailyInsight>> _dailyStream;
  late final Stream<InsightSnapshot<WeeklyInsight>> _weeklyStream;
  late final Stream<InsightSnapshot<MonthlyInsight>> _monthlyStream;

  InsightViewMode _viewMode = InsightViewMode.day;

  @override
  void initState() {
    super.initState();
    _service = widget._overrideService ?? MockInsightService();
    _dailyStream = _service.dailyInsights();
    _weeklyStream = _service.weeklyInsights();
    _monthlyStream = _service.monthlyInsights();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() {
    switch (_viewMode) {
      case InsightViewMode.day:
        return _service.refreshDay();
      case InsightViewMode.week:
        return _service.refreshWeek();
      case InsightViewMode.month:
        return _service.refreshMonth();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.primaryBackground,
      appBar: AppBar(
        backgroundColor: context.surfaceWhite,
        elevation: 0,
        title: const Text('Flux Insights 2.0'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: '刷新洞察',
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesignTokens.globalHorizontalPadding,
            vertical: AppDesignTokens.spacing24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSegmentedHeader(context),
              const SizedBox(height: AppDesignTokens.spacing24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _buildViewBody(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          switch (_viewMode) {
            InsightViewMode.day => '每日控速',
            InsightViewMode.week => '趋势雷达',
            InsightViewMode.month => '结构体检',
          },
          style: AppDesignTokens.title1(context),
        ),
        AppSegmentedControl<InsightViewMode>(
          groupValue: _viewMode,
          onValueChanged: (value) {
            if (value != null) {
              setState(() => _viewMode = value);
            }
          },
          children: const {
            InsightViewMode.day: Text('Day'),
            InsightViewMode.week: Text('Week'),
            InsightViewMode.month: Text('Month'),
          },
        ),
      ],
    );
  }

  Widget _buildViewBody(BuildContext context) {
    return switch (_viewMode) {
      InsightViewMode.day => StreamBuilder<InsightSnapshot<DailyInsight>>(
          stream: _dailyStream,
          builder: (context, snapshot) => _DayViewWidget(
            snapshot: snapshot.data,
            isWaiting: snapshot.connectionState == ConnectionState.waiting,
          ),
        ),
      InsightViewMode.week => StreamBuilder<InsightSnapshot<WeeklyInsight>>(
          stream: _weeklyStream,
          builder: (context, snapshot) => _WeekViewWidget(
            snapshot: snapshot.data,
            isWaiting: snapshot.connectionState == ConnectionState.waiting,
          ),
        ),
      InsightViewMode.month => StreamBuilder<InsightSnapshot<MonthlyInsight>>(
          stream: _monthlyStream,
          builder: (context, snapshot) => _MonthViewWidget(
            snapshot: snapshot.data,
            isWaiting: snapshot.connectionState == ConnectionState.waiting,
          ),
        ),
    };
  }
}

class _DayViewWidget extends StatelessWidget {
  const _DayViewWidget({
    required this.snapshot,
    required this.isWaiting,
  });

  final InsightSnapshot<DailyInsight>? snapshot;
  final bool isWaiting;

  @override
  Widget build(BuildContext context) {
    final insight = snapshot?.data;
    final isThinking = (snapshot?.isLoading ?? true) || isWaiting;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Budget Pacer',
            style: AppDesignTokens.headline(context),
          ),
          const SizedBox(height: AppDesignTokens.spacing16),
          if (insight == null)
            const _PacerSkeleton()
          else
            _DailyPacerBar(insight: insight),
          const SizedBox(height: AppDesignTokens.spacing16),
          if (insight == null)
            const _InsightCommentSkeleton()
          else
            _MicroInsightCard(
              comment: insight.aiComment,
              sentiment: insight.sentiment,
            ),
          if (isThinking) ...[
            const Padding(
              padding: EdgeInsets.only(top: AppDesignTokens.spacing16),
              child: _ThinkingBanner(message: 'AI CFO 正在分析今日行为...'),
            ),
          ] else ...[
            const SizedBox(height: AppDesignTokens.spacing16),
            Text(
              '最后更新 · ${_formatTime(snapshot?.generatedAt)}',
              style: AppDesignTokens.caption(context),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatTime(DateTime? timestamp) {
    if (timestamp == null) return '--:--';
    final hours = timestamp.hour.toString().padLeft(2, '0');
    final minutes = timestamp.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}

class _DailyPacerBar extends StatelessWidget {
  const _DailyPacerBar({required this.insight});

  final DailyInsight insight;

  @override
  Widget build(BuildContext context) {
    final utilization = insight.utilization.clamp(0.0, 1.0);
    final color = insight.utilization < 0.8
        ? context.primaryAction
        : (insight.utilization < 1
            ? AppTheme.warningColor
            : AppTheme.expenseRed);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius:
              BorderRadius.circular(AppDesignTokens.radiusLarge(context)),
          child: SizedBox(
            height: 24,
            child: LinearProgressIndicator(
              value: utilization,
              backgroundColor: context.dividerColor.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 24,
            ),
          ),
        ),
        const SizedBox(height: AppDesignTokens.spacing8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '已花 ${context.formatAmount(insight.spent)}',
              style: AppDesignTokens.body(context),
            ),
            Text(
              '预算 ${context.formatAmount(insight.dailyBudget)}',
              style: AppDesignTokens.caption(context),
            ),
          ],
        ),
      ],
    );
  }
}

class _MicroInsightCard extends StatelessWidget {
  const _MicroInsightCard({
    required this.comment,
    required this.sentiment,
  });

  final String comment;
  final InsightSentiment sentiment;

  @override
  Widget build(BuildContext context) {
    final Color badgeColor = switch (sentiment) {
      InsightSentiment.safe => context.incomeGreen,
      InsightSentiment.warning => AppTheme.warningColor,
      InsightSentiment.overload => context.expenseRed,
    };

    return Container(
      padding: const EdgeInsets.all(AppDesignTokens.spacing16),
      decoration: BoxDecoration(
        color: context.appAccentBackground,
        borderRadius:
            BorderRadius.circular(AppDesignTokens.radiusMedium(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: PhosphorIcon(
                PhosphorIcons.sparkle(),
                color: badgeColor,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: AppDesignTokens.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Insight',
                  style: AppDesignTokens.caption(context),
                ),
                const SizedBox(height: 4),
                Text(
                  comment,
                  style: AppDesignTokens.body(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekViewWidget extends StatelessWidget {
  const _WeekViewWidget({
    required this.snapshot,
    required this.isWaiting,
  });

  final InsightSnapshot<WeeklyInsight>? snapshot;
  final bool isWaiting;

  @override
  Widget build(BuildContext context) {
    final insight = snapshot?.data;
    final isThinking = (snapshot?.isLoading ?? true) || isWaiting;

    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Week Pulse',
                style: AppDesignTokens.headline(context),
              ),
              const SizedBox(height: AppDesignTokens.spacing16),
              if (insight == null)
                const _WeekSkeleton()
              else
                _WeeklyBars(
                  insight: insight,
                  showThinking: isThinking,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeeklyBars extends StatelessWidget {
  const _WeeklyBars({
    required this.insight,
    required this.showThinking,
  });

  final WeeklyInsight insight;
  final bool showThinking;

  @override
  Widget build(BuildContext context) {
    final maxAmount = insight.data.fold<double>(
      0,
      (value, point) => max(value, point.amount),
    );
    final highestIndex = insight.data.indexWhere(
      (point) =>
          point.amount ==
          insight.data.map((p) => p.amount).reduce((a, b) => a > b ? a : b),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        const chartHeight = 180.0;
        final bubbleWidth = min(220.0, constraints.maxWidth);
        final step = constraints.maxWidth / insight.data.length;
        final bubbleCenter =
            (highestIndex + 0.5).clamp(0.0, insight.data.length.toDouble()) *
                step;
        final bubbleLeft = (bubbleCenter - bubbleWidth / 2)
            .clamp(0.0, constraints.maxWidth - bubbleWidth);

        return SizedBox(
          height: chartHeight + 120,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 70,
                left: 0,
                right: 0,
                child: _AverageLine(
                  height: chartHeight - 40,
                  normalizedY: insight.averageSpend / maxAmount,
                ),
              ),
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                height: chartHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: insight.data.map((point) {
                    final isAboveAverage = point.amount >= insight.averageSpend;
                    final barHeight =
                        (point.amount / maxAmount).clamp(0.08, 1.0) *
                            (chartHeight - 40);
                    final color = isAboveAverage
                        ? context.expenseRed
                        : context.incomeGreen.withValues(alpha: 0.7);

                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                            height: barHeight,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            point.label,
                            style: AppDesignTokens.caption(context),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              Positioned(
                top: 0,
                left: bubbleLeft,
                width: bubbleWidth,
                child: _DetectiveBubble(
                  insight: insight,
                  isThinking: showThinking,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AverageLine extends StatelessWidget {
  const _AverageLine({
    required this.height,
    required this.normalizedY,
  });

  final double height;
  final double normalizedY;

  @override
  Widget build(BuildContext context) {
    final clamped = (1 - normalizedY).clamp(0.0, 1.0);
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned(
            top: height * clamped,
            left: 0,
            right: 0,
            child: CustomPaint(
              painter: _DashedLinePainter(color: context.dividerColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double startX = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DetectiveBubble extends StatelessWidget {
  const _DetectiveBubble({
    required this.insight,
    required this.isThinking,
  });

  final WeeklyInsight insight;
  final bool isThinking;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDesignTokens.spacing16),
          decoration: BoxDecoration(
            color: context.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PhosphorIcon(
                    PhosphorIcons.detective(),
                    color: context.warningColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Detective',
                    style: AppDesignTokens.caption(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (isThinking)
                AppShimmer.text(height: 14)
              else
                Text(
                  insight.anomalyReason,
                  style: AppDesignTokens.body(context),
                ),
            ],
          ),
        ),
        CustomPaint(
          painter: _PointerPainter(color: context.surfaceWhite),
          child: const SizedBox(height: 12, width: 24),
        ),
      ],
    );
  }
}

class _PointerPainter extends CustomPainter {
  const _PointerPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MonthViewWidget extends StatelessWidget {
  const _MonthViewWidget({
    required this.snapshot,
    required this.isWaiting,
  });

  final InsightSnapshot<MonthlyInsight>? snapshot;
  final bool isWaiting;

  @override
  Widget build(BuildContext context) {
    final insight = snapshot?.data;
    final isThinking = (snapshot?.isLoading ?? true) || isWaiting;

    return Column(
      children: [
        _BentoRow(
          children: [
            AppCard(
              child: insight == null
                  ? const _StructureSkeleton()
                  : _StructureCard(
                      insight: insight,
                      isThinking: isThinking && !isWaiting,
                    ),
            ),
            AppCard(
              child: insight == null
                  ? const _ReportSkeleton()
                  : _ReportCard(
                      insight: insight,
                      isThinking: isThinking,
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BentoRow extends StatelessWidget {
  const _BentoRow({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.length != 2) return Column(children: children);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        if (isNarrow) {
          return Column(
            children: [
              children.first,
              const SizedBox(height: AppDesignTokens.spacing24),
              children.last,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: children.first),
            const SizedBox(width: AppDesignTokens.spacing24),
            Expanded(child: children.last),
          ],
        );
      },
    );
  }
}

class _StructureCard extends StatelessWidget {
  const _StructureCard({
    required this.insight,
    required this.isThinking,
  });

  final MonthlyInsight insight;
  final bool isThinking;

  @override
  Widget build(BuildContext context) {
    final total = insight.total;
    final fixedRatio = insight.fixedRatio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '支出结构',
          style: AppDesignTokens.headline(context),
        ),
        const SizedBox(height: AppDesignTokens.spacing16),
        SizedBox(
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: fixedRatio),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  builder: (context, value, _) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 16,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(context.expenseRed),
                      backgroundColor:
                          context.incomeGreen.withValues(alpha: 0.15),
                    );
                  },
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(fixedRatio * 100).toStringAsFixed(0)}%',
                    style: AppDesignTokens.title1(context),
                  ),
                  const SizedBox(height: 4),
                  const Text('固定占比'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDesignTokens.spacing16),
        _StructureRow(
          label: 'Fixed · Living & Bills',
          amount: insight.fixedCost,
          color: context.expenseRed,
          isThinking: isThinking,
        ),
        const SizedBox(height: 12),
        _StructureRow(
          label: 'Flexible · Food & Fun',
          amount: insight.flexibleCost,
          color: context.incomeGreen,
          isThinking: isThinking,
        ),
        const SizedBox(height: 12),
        Text(
          'Total ${context.formatAmount(total)}',
          style: AppDesignTokens.caption(context),
        ),
      ],
    );
  }
}

class _StructureRow extends StatelessWidget {
  const _StructureRow({
    required this.label,
    required this.amount,
    required this.color,
    required this.isThinking,
  });

  final String label;
  final double amount;
  final Color color;
  final bool isThinking;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppDesignTokens.body(context),
          ),
        ),
        const SizedBox(width: 12),
        if (isThinking)
          SizedBox(width: 80, child: AppShimmer.text(height: 14))
        else
          Text(
            context.formatAmount(amount),
            style: AppDesignTokens.body(context),
          ),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.insight,
    required this.isThinking,
  });

  final MonthlyInsight insight;
  final bool isThinking;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financial Health Score',
          style: AppDesignTokens.headline(context),
        ),
        const SizedBox(height: AppDesignTokens.spacing8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _scoreLetter(insight.score),
              style: AppDesignTokens.largeTitle(context),
            ),
            const SizedBox(width: 8),
            Text(
              insight.score.toStringAsFixed(1),
              style: AppDesignTokens.title1(context).copyWith(
                color: context.secondaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDesignTokens.spacing16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: isThinking
              ? KeyedSubtree(
                  key: const ValueKey('report_shimmer'),
                  child: AppShimmer.text(height: 18),
                )
              : KeyedSubtree(
                  key: const ValueKey('report_text'),
                  child: Text(
                    insight.cfoReport,
                    style: AppDesignTokens.body(context),
                  ),
                ),
        ),
      ],
    );
  }

  static String _scoreLetter(double score) {
    if (score >= 90) return 'A';
    if (score >= 85) return 'B+';
    if (score >= 80) return 'B';
    return 'C';
  }
}

class _ThinkingBanner extends StatelessWidget {
  const _ThinkingBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDesignTokens.spacing12),
      decoration: BoxDecoration(
        color: context.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppDesignTokens.caption(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _PacerSkeleton extends StatelessWidget {
  const _PacerSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppShimmer(width: double.infinity, height: 24, radius: 12),
        const SizedBox(height: AppDesignTokens.spacing8),
        AppShimmer.text(width: 200),
      ],
    );
  }
}

class _InsightCommentSkeleton extends StatelessWidget {
  const _InsightCommentSkeleton();

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppShimmer.text(),
          const SizedBox(height: AppDesignTokens.spacing8),
          AppShimmer.text(width: 220),
        ],
      );
}

class _WeekSkeleton extends StatelessWidget {
  const _WeekSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: AppShimmer(width: double.infinity, height: 14),
        ),
      ),
    );
  }
}

class _StructureSkeleton extends StatelessWidget {
  const _StructureSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppShimmer.text(width: 120),
        const SizedBox(height: AppDesignTokens.spacing16),
        Row(
          children: const [
            Expanded(child: AppShimmer(width: double.infinity, height: 120)),
            SizedBox(width: AppDesignTokens.spacing16),
            Expanded(child: AppShimmer(width: double.infinity, height: 120)),
          ],
        ),
      ],
    );
  }
}

class _ReportSkeleton extends StatelessWidget {
  const _ReportSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        4,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: AppShimmer.text(
            width: index.isEven ? double.infinity : 200,
          ),
        ),
      ),
    );
  }
}
