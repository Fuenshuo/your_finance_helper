import 'package:flutter/material.dart';

/// 滚动条组件 - 时间线滚动指示器
class Scrubber extends StatefulWidget {
  final ScrollController scrollController;
  final List<DateTime> dates;

  const Scrubber({
    super.key,
    required this.scrollController,
    required this.dates,
  });

  @override
  State<Scrubber> createState() => _ScrubberState();
}

class _ScrubberState extends State<Scrubber> {
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dates.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: widget.dates.map((date) {
          final index = widget.dates.indexOf(date);
          final isSelected = _isDateVisible(index);

          return Expanded(
            child: GestureDetector(
              onTap: () => _scrollToDate(index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    '${date.month}/${date.day}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _isDateVisible(int index) {
    if (!widget.scrollController.hasClients) return false;

    final scrollPosition = widget.scrollController.position;
    final viewportHeight = scrollPosition.viewportDimension;
    final scrollOffset = scrollPosition.pixels;

    // 计算每个日期组的高度（估算）
    const estimatedGroupHeight = 200.0;
    final groupTop = index * estimatedGroupHeight;
    final groupBottom = (index + 1) * estimatedGroupHeight;

    return scrollOffset < groupBottom && (scrollOffset + viewportHeight) > groupTop;
  }

  void _scrollToDate(int index) {
    if (!widget.scrollController.hasClients) return;

    // 估算位置并滚动
    const estimatedGroupHeight = 200.0;
    final targetOffset = index * estimatedGroupHeight;

    widget.scrollController.animateTo(
      targetOffset.clamp(0.0, widget.scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

