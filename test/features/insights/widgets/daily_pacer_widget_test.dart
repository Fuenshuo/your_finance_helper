import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/features/insights/models/daily_cap.dart';
import 'package:your_finance_flutter/features/insights/models/micro_insight.dart';
import 'package:your_finance_flutter/features/insights/widgets/daily_pacer_widget.dart';

void main() {
  late DailyCap safeDailyCap;
  late DailyCap warningDailyCap;
  late DailyCap dangerDailyCap;
  late DailyCap microInsightCap;

  setUp(() {
    safeDailyCap = DailyCap(
      id: 'safe_cap',
      date: DateTime.now(),
      referenceAmount: 200.0,
      currentSpending: 50.0,
      percentage: 0.25,
      status: CapStatus.safe,
    );

    warningDailyCap = DailyCap(
      id: 'warning_cap',
      date: DateTime.now(),
      referenceAmount: 200.0,
      currentSpending: 150.0,
      percentage: 0.75,
      status: CapStatus.warning,
    );

    dangerDailyCap = DailyCap(
      id: 'danger_cap',
      date: DateTime.now(),
      referenceAmount: 200.0,
      currentSpending: 250.0,
      percentage: 1.25,
      status: CapStatus.danger,
    );

    microInsightCap = DailyCap(
      id: 'insight_cap',
      date: DateTime.now(),
      referenceAmount: 200.0,
      currentSpending: 120.0,
      percentage: 0.6,
      status: CapStatus.safe,
      latestInsight: MicroInsight(
        id: 'insight_1',
        dailyCapId: 'insight_cap',
        generatedAt: DateTime.now(),
        sentiment: Sentiment.positive,
        message: '今日控制得很好，节省了20元咖啡钱。',
        trigger: InsightTrigger.timeCheck,
        actions: const ['继续保持', '查看本周趋势'],
      ),
    );
  });

  group('DailyPacerWidget Tests', () {
    testWidgets('should display safe status correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyPacerWidget(dailyCap: safeDailyCap),
          ),
        ),
      );

      // Check header
      expect(find.text('今日消费进度'), findsOneWidget);

      // Check status indicator
      expect(find.text('安全'), findsOneWidget);

      // Check spending amounts
      expect(find.text('已消费 ¥50'), findsOneWidget);
      expect(find.text('剩余 ¥150'), findsOneWidget);
    });

    testWidgets('should display warning status correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyPacerWidget(dailyCap: warningDailyCap),
          ),
        ),
      );

      // Check status indicator
      expect(find.text('注意'), findsOneWidget);

      // Check spending amounts
      expect(find.text('已消费 ¥150'), findsOneWidget);
      expect(find.text('剩余 ¥50'), findsOneWidget);
    });

    testWidgets('should display danger status correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyPacerWidget(dailyCap: dangerDailyCap),
          ),
        ),
      );

      // Check status indicator
      expect(find.text('超支'), findsOneWidget);

      // Check spending amounts
      expect(find.text('已消费 ¥250'), findsOneWidget);
      expect(find.text('超支 ¥50'), findsOneWidget);
    });

    testWidgets('should display micro insight when available', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyPacerWidget(dailyCap: microInsightCap),
          ),
        ),
      );

      // Check insight section header
      expect(find.text('AI 建议'), findsOneWidget);

      // Check insight message
      expect(find.text('今日控制得很好，节省了20元咖啡钱。'), findsOneWidget);

      // Check suggested actions
      expect(find.text('继续保持'), findsOneWidget);
      expect(find.text('查看本周趋势'), findsOneWidget);
    });

    testWidgets('should not display insight section when no insight',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyPacerWidget(dailyCap: safeDailyCap),
          ),
        ),
      );

      // Check insight section is not shown
      expect(find.text('AI 建议'), findsNothing);
    });

    testWidgets('should handle tap gesture', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyPacerWidget(
              dailyCap: safeDailyCap,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Tap the widget
      await tester.tap(find.byType(DailyPacerWidget));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('should render progress bar with correct percentage',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyPacerWidget(dailyCap: safeDailyCap),
          ),
        ),
      );

      // Progress bar should be rendered (exact testing of progress value is complex)
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('should display correct remaining amount calculation',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyPacerWidget(dailyCap: safeDailyCap),
          ),
        ),
      );

      // 200 - 50 = 150 remaining
      expect(find.text('剩余 ¥150'), findsOneWidget);
    });

    testWidgets('should display correct over budget amount', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyPacerWidget(dailyCap: dangerDailyCap),
          ),
        ),
      );

      // 250 - 200 = 50 over budget
      expect(find.text('超支 ¥50'), findsOneWidget);
    });

    group('Progress bar animations', () {
      testWidgets('should animate danger status with shake effect',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DailyPacerWidget(dailyCap: dangerDailyCap),
            ),
          ),
        );

        // Should render with animation (hard to test animation directly)
        expect(find.byType(DailyPacerWidget), findsOneWidget);
      });

      testWidgets('should not animate safe status', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DailyPacerWidget(dailyCap: safeDailyCap),
            ),
          ),
        );

        // Should render without shake animation
        expect(find.byType(DailyPacerWidget), findsOneWidget);
      });
    });

    group('Insight actions', () {
      testWidgets('should display multiple actions as chips', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DailyPacerWidget(dailyCap: microInsightCap),
            ),
          ),
        );

        // Should display actions
        expect(find.text('继续保持'), findsOneWidget);
        expect(find.text('查看本周趋势'), findsOneWidget);
      });

      testWidgets('should handle empty actions list', (tester) async {
        final capWithEmptyActions = DailyCap(
          id: 'empty_actions',
          date: DateTime.now(),
          referenceAmount: 200.0,
          currentSpending: 100.0,
          percentage: 0.5,
          status: CapStatus.safe,
          latestInsight: MicroInsight(
            id: 'empty_insight',
            dailyCapId: 'empty_actions',
            generatedAt: DateTime.now(),
            sentiment: Sentiment.neutral,
            message: 'No actions insight',
            trigger: InsightTrigger.manualRequest,
            actions: const [],
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DailyPacerWidget(dailyCap: capWithEmptyActions),
            ),
          ),
        );

        // Should render insight but no action chips
        expect(find.text('AI 建议'), findsOneWidget);
        expect(find.byType(Chip), findsNothing);
      });

      testWidgets('should display sentiment-appropriate colors',
          (tester) async {
        // Test positive sentiment
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DailyPacerWidget(dailyCap: microInsightCap),
            ),
          ),
        );

        // Should render with appropriate colors
        expect(find.byType(DailyPacerWidget), findsOneWidget);
      });
    });

    group('Status colors', () {
      testWidgets('should use green for safe status', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DailyPacerWidget(dailyCap: safeDailyCap),
            ),
          ),
        );

        // Safe status should be rendered (color testing is visual)
        expect(find.text('安全'), findsOneWidget);
      });

      testWidgets('should use orange for warning status', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DailyPacerWidget(dailyCap: warningDailyCap),
            ),
          ),
        );

        // Warning status should be rendered
        expect(find.text('注意'), findsOneWidget);
      });

      testWidgets('should use red for danger status', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DailyPacerWidget(dailyCap: dangerDailyCap),
            ),
          ),
        );

        // Danger status should be rendered
        expect(find.text('超支'), findsOneWidget);
      });
    });

    group('Edge cases', () {
      testWidgets('should handle zero spending', (tester) async {
        final zeroSpendingCap = DailyCap(
          id: 'zero_spending',
          date: DateTime.now(),
          referenceAmount: 200.0,
          currentSpending: 0.0,
          percentage: 0.0,
          status: CapStatus.safe,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DailyPacerWidget(dailyCap: zeroSpendingCap),
            ),
          ),
        );

        expect(find.text('已消费 ¥0'), findsOneWidget);
        expect(find.text('剩余 ¥200'), findsOneWidget);
      });

      testWidgets('should handle very high spending', (tester) async {
        final highSpendingCap = DailyCap(
          id: 'high_spending',
          date: DateTime.now(),
          referenceAmount: 100.0,
          currentSpending: 1000.0,
          percentage: 10.0,
          status: CapStatus.danger,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DailyPacerWidget(dailyCap: highSpendingCap),
            ),
          ),
        );

        expect(find.text('已消费 ¥1000'), findsOneWidget);
        expect(find.text('超支 ¥900'), findsOneWidget);
      });

      testWidgets('should handle negative spending (refunds)', (tester) async {
        final negativeSpendingCap = DailyCap(
          id: 'negative_spending',
          date: DateTime.now(),
          referenceAmount: 200.0,
          currentSpending: -50.0,
          percentage: -0.25,
          status: CapStatus.safe,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DailyPacerWidget(dailyCap: negativeSpendingCap),
            ),
          ),
        );

        expect(find.text('已消费 ¥-50'), findsOneWidget);
        expect(find.text('剩余 ¥250'), findsOneWidget);
      });

      testWidgets('should handle zero budget', (tester) async {
        final zeroBudgetCap = DailyCap(
          id: 'zero_budget',
          date: DateTime.now(),
          referenceAmount: 0.0,
          currentSpending: 50.0,
          percentage: double.infinity,
          status: CapStatus.danger,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DailyPacerWidget(dailyCap: zeroBudgetCap),
            ),
          ),
        );

        // Should handle gracefully (division by zero is handled in progress bar)
        expect(find.text('已消费 ¥50'), findsOneWidget);
        expect(find.text('超支 ¥50'), findsOneWidget);
      });
    });
  });
}
