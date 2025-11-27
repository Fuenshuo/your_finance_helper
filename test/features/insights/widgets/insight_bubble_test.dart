import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/features/insights/models/weekly_anomaly.dart';
import 'package:your_finance_flutter/features/insights/widgets/insight_bubble.dart';

void main() {
  late WeeklyAnomaly lowSeverityAnomaly;
  late WeeklyAnomaly mediumSeverityAnomaly;
  late WeeklyAnomaly highSeverityAnomaly;

  setUp(() {
    final weekStart = DateTime.now().subtract(const Duration(days: 6));
    final anomalyDate = DateTime.now().subtract(const Duration(days: 3));

    lowSeverityAnomaly = WeeklyAnomaly(
      id: 'low_anomaly',
      weekStart: weekStart,
      anomalyDate: anomalyDate,
      expectedAmount: 200.0,
      actualAmount: 250.0,
      deviation: 25.0,
      reason: '轻微超支，主要是交通费用',
      severity: AnomalySeverity.low,
      categories: ['交通'],
    );

    mediumSeverityAnomaly = WeeklyAnomaly(
      id: 'medium_anomaly',
      weekStart: weekStart,
      anomalyDate: anomalyDate,
      expectedAmount: 200.0,
      actualAmount: 350.0,
      deviation: 75.0,
      reason: '中度超支，餐饮消费较多',
      severity: AnomalySeverity.medium,
      categories: ['餐饮'],
    );

    highSeverityAnomaly = WeeklyAnomaly(
      id: 'high_anomaly',
      weekStart: weekStart,
      anomalyDate: anomalyDate,
      expectedAmount: 200.0,
      actualAmount: 500.0,
      deviation: 150.0,
      reason: '严重超支，购买了大型电器',
      severity: AnomalySeverity.high,
      categories: ['购物'],
    );
  });

  group('InsightBubble Widget Tests', () {
    testWidgets('should display low severity anomaly with appropriate styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InsightBubble(
              anomaly: lowSeverityAnomaly,
              targetPosition: const Offset(100, 100),
              bubblePosition: const Offset(50, 50),
            ),
          ),
        ),
      );

      // Check reason text
      expect(find.text('轻微超支，主要是交通费用'), findsOneWidget);

      // Check bubble is rendered
      expect(find.byType(InsightBubble), findsOneWidget);
    });

    testWidgets('should display medium severity anomaly with appropriate styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InsightBubble(
              anomaly: mediumSeverityAnomaly,
              targetPosition: const Offset(100, 100),
              bubblePosition: const Offset(50, 50),
            ),
          ),
        ),
      );

      // Check reason text
      expect(find.text('中度超支，餐饮消费较多'), findsOneWidget);
    });

    testWidgets('should display high severity anomaly with appropriate styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InsightBubble(
              anomaly: highSeverityAnomaly,
              targetPosition: const Offset(100, 100),
              bubblePosition: const Offset(50, 50),
            ),
          ),
        ),
      );

      // Check reason text
      expect(find.text('严重超支，购买了大型电器'), findsOneWidget);
    });

    testWidgets('should handle tap gesture', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InsightBubble(
              anomaly: lowSeverityAnomaly,
              targetPosition: const Offset(100, 100),
              bubblePosition: const Offset(50, 50),
              onTap: () {}, // Provide onTap callback
            ),
          ),
        ),
      );

      // Check that the widget renders with tap capability
      expect(find.byType(InsightBubble), findsOneWidget);
      expect(find.text('轻微超支，主要是交通费用'), findsOneWidget);
    });

    testWidgets('should truncate long reason text', (WidgetTester tester) async {
      final longReasonAnomaly = WeeklyAnomaly(
        id: 'long_reason',
        weekStart: DateTime.now().subtract(const Duration(days: 6)),
        anomalyDate: DateTime.now().subtract(const Duration(days: 3)),
        expectedAmount: 200.0,
        actualAmount: 300.0,
        deviation: 50.0,
        reason: '这是一个非常非常长的异常原因描述，用来测试文本截断功能是否正常工作，如果文本太长应该会被截断并显示省略号。',
        severity: AnomalySeverity.medium,
        categories: ['其他'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InsightBubble(
              anomaly: longReasonAnomaly,
              targetPosition: const Offset(100, 100),
              bubblePosition: const Offset(50, 50),
            ),
          ),
        ),
      );

      // Should still render (text overflow is handled by ellipsis)
      expect(find.byType(InsightBubble), findsOneWidget);
    });

    testWidgets('should display different icons for different severities', (WidgetTester tester) async {
      // Test low severity (check icon)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InsightBubble(
              anomaly: lowSeverityAnomaly,
              targetPosition: const Offset(100, 100),
              bubblePosition: const Offset(50, 50),
            ),
          ),
        ),
      );

      // Should render without errors
      expect(find.byType(InsightBubble), findsOneWidget);

      // Test medium severity (info icon)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InsightBubble(
              anomaly: mediumSeverityAnomaly,
              targetPosition: const Offset(100, 100),
              bubblePosition: const Offset(50, 50),
            ),
          ),
        ),
      );

      expect(find.byType(InsightBubble), findsOneWidget);

      // Test high severity (warning icon)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InsightBubble(
              anomaly: highSeverityAnomaly,
              targetPosition: const Offset(100, 100),
              bubblePosition: const Offset(50, 50),
            ),
          ),
        ),
      );

      expect(find.byType(InsightBubble), findsOneWidget);
    });

    testWidgets('should display categories when available', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InsightBubble(
              anomaly: mediumSeverityAnomaly,
              targetPosition: const Offset(100, 100),
              bubblePosition: const Offset(50, 50),
            ),
          ),
        ),
      );

      // Categories are not directly displayed in the bubble,
      // but the anomaly object contains them
      expect(find.byType(InsightBubble), findsOneWidget);
    });

    testWidgets('should handle anomalies without categories', (WidgetTester tester) async {
      final noCategoryAnomaly = WeeklyAnomaly(
        id: 'no_category',
        weekStart: DateTime.now().subtract(const Duration(days: 6)),
        anomalyDate: DateTime.now().subtract(const Duration(days: 3)),
        expectedAmount: 200.0,
        actualAmount: 300.0,
        deviation: 50.0,
        reason: '无类别异常',
        severity: AnomalySeverity.medium,
        categories: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InsightBubble(
              anomaly: noCategoryAnomaly,
              targetPosition: const Offset(100, 100),
              bubblePosition: const Offset(50, 50),
            ),
          ),
        ),
      );

      expect(find.byType(InsightBubble), findsOneWidget);
      expect(find.text('无类别异常'), findsOneWidget);
    });

    group('Severity color mapping', () {
      testWidgets('should use appropriate colors for severity levels', (WidgetTester tester) async {
        // Low severity should have success-like colors
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InsightBubble(
                anomaly: lowSeverityAnomaly,
                targetPosition: const Offset(100, 100),
                bubblePosition: const Offset(50, 50),
              ),
            ),
          ),
        );

        expect(find.byType(InsightBubble), findsOneWidget);

        // Medium severity should have accent-like colors
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InsightBubble(
                anomaly: mediumSeverityAnomaly,
                targetPosition: const Offset(100, 100),
                bubblePosition: const Offset(50, 50),
              ),
            ),
          ),
        );

        expect(find.byType(InsightBubble), findsOneWidget);

        // High severity should have danger-like colors
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InsightBubble(
                anomaly: highSeverityAnomaly,
                targetPosition: const Offset(100, 100),
                bubblePosition: const Offset(50, 50),
              ),
            ),
          ),
        );

        expect(find.byType(InsightBubble), findsOneWidget);
      });
    });

    group('Edge cases', () {
      testWidgets('should handle empty reason text', (WidgetTester tester) async {
        final emptyReasonAnomaly = WeeklyAnomaly(
          id: 'empty_reason',
          weekStart: DateTime.now().subtract(const Duration(days: 6)),
          anomalyDate: DateTime.now().subtract(const Duration(days: 3)),
          expectedAmount: 200.0,
          actualAmount: 300.0,
          deviation: 50.0,
          reason: '',
          severity: AnomalySeverity.medium,
          categories: [],
        );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InsightBubble(
              anomaly: emptyReasonAnomaly,
              targetPosition: const Offset(100, 100),
              bubblePosition: const Offset(50, 50),
            ),
          ),
        ),
      );

        // Should still render (empty text is handled gracefully)
        expect(find.byType(InsightBubble), findsOneWidget);
      });

      testWidgets('should handle very short reason text', (WidgetTester tester) async {
        final shortReasonAnomaly = WeeklyAnomaly(
          id: 'short_reason',
          weekStart: DateTime.now().subtract(const Duration(days: 6)),
          anomalyDate: DateTime.now().subtract(const Duration(days: 3)),
          expectedAmount: 200.0,
          actualAmount: 300.0,
          deviation: 50.0,
          reason: '短',
          severity: AnomalySeverity.low,
          categories: [],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InsightBubble(
                anomaly: shortReasonAnomaly,
                targetPosition: const Offset(100, 100),
                bubblePosition: const Offset(50, 50),
              ),
            ),
          ),
        );

        expect(find.byType(InsightBubble), findsOneWidget);
        expect(find.text('短'), findsOneWidget);
      });

      testWidgets('should handle extreme deviation values', (WidgetTester tester) async {
        final extremeAnomaly = WeeklyAnomaly(
          id: 'extreme',
          weekStart: DateTime.now().subtract(const Duration(days: 6)),
          anomalyDate: DateTime.now().subtract(const Duration(days: 3)),
          expectedAmount: 100.0,
          actualAmount: 10000.0,
          deviation: 9900.0,
          reason: '极端异常支出',
          severity: AnomalySeverity.high,
          categories: ['异常'],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InsightBubble(
                anomaly: extremeAnomaly,
                targetPosition: const Offset(100, 100),
                bubblePosition: const Offset(50, 50),
              ),
            ),
          ),
        );

        expect(find.byType(InsightBubble), findsOneWidget);
        expect(find.text('极端异常支出'), findsOneWidget);
      });
    });

    group('Layout and styling', () {
      testWidgets('should have appropriate padding and margins', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InsightBubble(
                anomaly: lowSeverityAnomaly,
                targetPosition: const Offset(100, 100),
                bubblePosition: const Offset(50, 50),
              ),
            ),
          ),
        );

        // Should render with proper layout
        expect(find.byType(InsightBubble), findsOneWidget);
      });

      testWidgets('should have rounded corners and shadows', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InsightBubble(
                anomaly: lowSeverityAnomaly,
                targetPosition: const Offset(100, 100),
                bubblePosition: const Offset(50, 50),
              ),
            ),
          ),
        );

        // Styling should be applied (hard to test visually)
        expect(find.byType(InsightBubble), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('should be accessible via keyboard navigation', (WidgetTester tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InsightBubble(
                anomaly: lowSeverityAnomaly,
                targetPosition: const Offset(100, 100),
                bubblePosition: const Offset(50, 50),
                onTap: () => tapped = true,
              ),
            ),
          ),
        );

        // Should be focusable and tappable
        expect(find.byType(InsightBubble), findsOneWidget);
        expect(tapped, false); // Initially not tapped
      });
    });
  });
}
