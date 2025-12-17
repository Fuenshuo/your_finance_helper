import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';

/// 可展开的计算项组件
/// 用于显示薪资计算的详细展开信息
class ExpandableCalculationItem extends StatefulWidget {
  const ExpandableCalculationItem({
    required this.title,
    required this.amount,
    required this.amountColor,
    required this.icon,
    required this.monthlyDetails,
    required this.calculationFormula,
    this.initiallyExpanded = false,
    super.key,
  });

  final String title;
  final String amount;
  final Color amountColor;
  final IconData icon;
  final List<MonthlyDetailItem> monthlyDetails;
  final String calculationFormula;
  final bool initiallyExpanded;

  @override
  State<ExpandableCalculationItem> createState() =>
      _ExpandableCalculationItemState();
}

class _ExpandableCalculationItemState extends State<ExpandableCalculationItem>
    with TickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _iconTurns;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _iconTurns = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _heightFactor = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          // 可点击的标题栏
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.all(context.spacing12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // 图标
                  Icon(widget.icon, color: widget.amountColor, size: 20),
                  SizedBox(width: context.spacing8),

                  // 标题
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),

                  // 金额
                  Text(
                    widget.amount,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: widget.amountColor,
                        ),
                  ),

                  // 箭头图标
                  RotationTransition(
                    turns: _iconTurns,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 可展开的内容
          ClipRect(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Align(
                alignment: Alignment.centerLeft,
                heightFactor: _heightFactor.value,
                child: child,
              ),
              child: Container(
                margin: EdgeInsets.only(top: context.spacing8),
                padding: EdgeInsets.all(context.spacing16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 计算公式
                    Container(
                      padding: EdgeInsets.all(context.spacing8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '计算公式',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                          ),
                          SizedBox(height: context.spacing4),
                          Text(
                            widget.calculationFormula,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontFamily: 'monospace',
                                      color: Colors.blue.shade700,
                                    ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: context.spacing16),

                    // 每月详情
                    Text(
                      '每月详情',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: context.spacing8),

                    // 每月详情列表
                    ...widget.monthlyDetails.map(
                      (detail) => Container(
                        margin: EdgeInsets.only(bottom: context.spacing8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 月份和总金额标题栏
                            Container(
                              padding: EdgeInsets.all(context.spacing12),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.03),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    detail.month,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Text(
                                    detail.amount,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: widget.amountColor,
                                        ),
                                  ),
                                ],
                              ),
                            ),

                            // 金额组成部分详情
                            if (detail.components.isNotEmpty) ...[
                              Padding(
                                padding: EdgeInsets.all(context.spacing12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '组成明细',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: context.secondaryText,
                                          ),
                                    ),
                                    SizedBox(height: context.spacing8),
                                    ...detail.components.map(
                                      (component) => Container(
                                        margin: EdgeInsets.only(
                                          bottom: context.spacing4,
                                        ),
                                        padding:
                                            EdgeInsets.all(context.spacing8),
                                        decoration: BoxDecoration(
                                          color: component.color
                                                  ?.withValues(alpha: 0.05) ??
                                              Colors.grey
                                                  .withValues(alpha: 0.02),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                            color: component.color
                                                    ?.withValues(alpha: 0.2) ??
                                                Colors.grey
                                                    .withValues(alpha: 0.1),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            // 组件图标或颜色指示器
                                            if (component.color != null)
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: component.color,
                                                  shape: BoxShape.circle,
                                                ),
                                              )
                                            else
                                              const SizedBox(width: 8),
                                            SizedBox(width: context.spacing8),

                                            // 组件标签和描述
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    component.label,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: component
                                                                  .color ??
                                                              context
                                                                  .primaryText,
                                                        ),
                                                  ),
                                                  if (component.description !=
                                                      null)
                                                    Text(
                                                      component.description!,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color: context
                                                                .secondaryText,
                                                            fontSize: 10,
                                                          ),
                                                    ),
                                                ],
                                              ),
                                            ),

                                            // 组件金额
                                            Text(
                                              component.value,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: component.color ??
                                                        widget.amountColor,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // 计算等式
                                    if (detail.components.isNotEmpty) ...[
                                      SizedBox(height: context.spacing8),
                                      Container(
                                        padding:
                                            EdgeInsets.all(context.spacing8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue
                                              .withValues(alpha: 0.05),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                            color: Colors.blue
                                                .withValues(alpha: 0.2),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.functions,
                                              size: 14,
                                              color: Colors.blue.shade600,
                                            ),
                                            SizedBox(width: context.spacing4),
                                            Expanded(
                                              child: Text(
                                                '计算等式: ${detail.components.map((c) => c.value).join(' + ')} = ${detail.amount}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color:
                                                          Colors.blue.shade700,
                                                      fontFamily: 'monospace',
                                                      fontSize: 11,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
}

/// 每月详情项
class MonthlyDetailItem {
  const MonthlyDetailItem({
    required this.month,
    required this.amount,
    this.components = const [], // 金额组成部分
  }); // 金额组成部分

  // 创建带组成部分的详情项
  factory MonthlyDetailItem.withComponents({
    required String month,
    required String amount,
    required List<ComponentItem> components,
  }) =>
      MonthlyDetailItem(
        month: month,
        amount: amount,
        components: components,
      );

  final String month;
  final String amount;
  final List<ComponentItem> components;
}

/// 金额组成部分项
class ComponentItem {
  const ComponentItem({
    required this.label,
    required this.value,
    this.description,
    this.color,
  });

  final String label;
  final String value;
  final String? description;
  final Color? color;
}
