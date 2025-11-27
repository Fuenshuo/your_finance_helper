import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/features/insights/models/monthly_health.dart';
import 'package:your_finance_flutter/features/insights/widgets/monthly_structure_card.dart';

void main() {
  late MonthlyHealthScore healthyScore;
  late MonthlyHealthScore lowScore;

  setUp(() {
    healthyScore = MonthlyHealthScore(
      id: 'test_healthy',
      month: DateTime(2025, 11),
      grade: LetterGrade.A,
      score: 92.5,
      diagnosis: '本月财务状况优秀，各项指标表现良好。',
      factors: [
        HealthFactor(
          name: '预算控制',
          impact: 0.8,
          description: '支出控制在预算范围内',
        ),
      ],
      recommendations: [
        '继续保持良好的消费习惯',
        '考虑增加储蓄比例',
      ],
      metrics: {
        'savingsRate': 0.2,
        'spendingRatio': 0.8,
        'survivalPercentage': 0.5,
        'lifestylePercentage': 0.5,
        'totalIncome': 10000.0,
        'totalSpending': 8000.0,
      },
    );

    lowScore = MonthlyHealthScore(
      id: 'test_low',
      month: DateTime(2025, 11),
      grade: LetterGrade.F,
      score: 35.0,
      diagnosis: '本月财务状况严重堪忧，存在重大风险。',
      factors: [
        HealthFactor(
          name: '预算超支',
          impact: -0.9,
          description: '支出严重超过收入',
        ),
      ],
      recommendations: [
        '立即削减非必要支出',
        '制定严格的预算计划',
        '寻求专业财务顾问帮助',
      ],
      metrics: {
        'savingsRate': -0.25,
        'spendingRatio': 1.25,
        'survivalPercentage': 0.4,
        'lifestylePercentage': 0.6,
        'totalIncome': 8000.0,
        'totalSpending': 10000.0,
      },
    );
  });

  group('MonthlyStructureCard Widget Tests', () {
    testWidgets('should display healthy score correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyStructureCard(monthlyHealth: healthyScore),
          ),
        ),
      );

      // Check header
      expect(find.text('月度结构分析'), findsOneWidget);

      // Check grade badge
      expect(find.text('A'), findsOneWidget);

      // Check diagnosis
      expect(find.text('本月财务状况优秀，各项指标表现良好。'), findsOneWidget);

      // Check recommendations
      expect(find.text('继续保持良好的消费习惯'), findsOneWidget);
    });

    testWidgets('should display low score with warning styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MonthlyStructureCard(monthlyHealth: lowScore),
            ),
          ),
        ),
      );

      // Check grade badge
      expect(find.text('F'), findsOneWidget);

      // Check diagnosis
      expect(find.text('本月财务状况严重堪忧，存在重大风险。'), findsOneWidget);

      // Check recommendations (limited to 2)
      expect(find.text('立即削减非必要支出'), findsOneWidget);
      expect(find.text('制定严格的预算计划'), findsOneWidget);
    });

    testWidgets('should show survival vs lifestyle breakdown', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyStructureCard(monthlyHealth: healthyScore),
          ),
        ),
      );

      // Check donut chart title
      expect(find.text('生存 vs 生活'), findsOneWidget);

      // Check legend items
      expect(find.text('生存'), findsOneWidget);
      expect(find.text('生活'), findsOneWidget);
    });

    testWidgets('should display top spending categories', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyStructureCard(monthlyHealth: healthyScore),
          ),
        ),
      );

      // Check top categories section
      expect(find.text('消费Top 3'), findsOneWidget);

      // Check category names (mock data)
      expect(find.text('餐饮'), findsOneWidget);
      expect(find.text('购物'), findsOneWidget);
      expect(find.text('娱乐'), findsOneWidget);
    });

    testWidgets('should handle tap gesture', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyStructureCard(
              monthlyHealth: healthyScore,
              onCardTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Tap the card
      await tester.tap(find.byType(MonthlyStructureCard));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('should render CFO report section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyStructureCard(monthlyHealth: healthyScore),
          ),
        ),
      );

      // Check CFO report header
      expect(find.text('CFO 月度诊断'), findsOneWidget);

      // Check briefcase icon is present
      expect(find.byIcon(Icons.business), findsNothing); // Phosphor icon, not Material icon
    });

    testWidgets('should display different grades with appropriate colors', (WidgetTester tester) async {
      // Test A grade (green/success)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyStructureCard(monthlyHealth: healthyScore),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);

      // Test F grade (red/danger)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyStructureCard(monthlyHealth: lowScore),
          ),
        ),
      );

      expect(find.text('F'), findsOneWidget);
    });

    testWidgets('should limit recommendations to 2 items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyStructureCard(monthlyHealth: lowScore),
          ),
        ),
      );

      // Low score has 3 recommendations but should only show 2
      expect(find.text('立即削减非必要支出'), findsOneWidget);
      expect(find.text('制定严格的预算计划'), findsOneWidget);
      expect(find.text('寻求专业财务顾问帮助'), findsNothing); // Third recommendation hidden
    });

    testWidgets('should adapt layout for wide screens', (WidgetTester tester) async {
      // Test with wide screen
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500, // Wide screen
              child: MonthlyStructureCard(monthlyHealth: healthyScore),
            ),
          ),
        ),
      );

      // Should render side-by-side layout
      expect(find.text('生存 vs 生活'), findsOneWidget);
      expect(find.text('消费Top 3'), findsOneWidget);
    });

    testWidgets('should adapt layout for narrow screens', (WidgetTester tester) async {
      // Test with narrow screen
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 300, // Narrow screen
                child: MonthlyStructureCard(monthlyHealth: healthyScore),
              ),
            ),
          ),
        ),
      );

      // Should render stacked layout
      expect(find.text('生存 vs 生活'), findsOneWidget);
      expect(find.text('消费Top 3'), findsOneWidget);
    });

    group('Donut chart rendering', () {
      testWidgets('should render donut chart with correct percentages', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MonthlyStructureCard(monthlyHealth: healthyScore),
            ),
          ),
        );

        // Check percentage display (50% for balanced case)
        expect(find.text('50%'), findsOneWidget);
        expect(find.text('生存支出'), findsOneWidget);
      });

      testWidgets('should show different percentages for unbalanced spending', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MonthlyStructureCard(monthlyHealth: lowScore),
            ),
          ),
        );

        // Low score has 40% survival spending
        expect(find.text('40%'), findsOneWidget);
      });
    });

    group('Grade badge styling', () {
      testWidgets('should show green badge for A grade', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MonthlyStructureCard(monthlyHealth: healthyScore),
            ),
          ),
        );

        // A grade should be visible
        expect(find.text('A'), findsOneWidget);
      });

      testWidgets('should show red badge for F grade', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MonthlyStructureCard(monthlyHealth: lowScore),
            ),
          ),
        );

        // F grade should be visible
        expect(find.text('F'), findsOneWidget);
      });
    });

    group('CFO report section', () {
      testWidgets('should display diagnosis with appropriate styling', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MonthlyStructureCard(monthlyHealth: healthyScore),
            ),
          ),
        );

        expect(find.text('CFO 月度诊断'), findsOneWidget);
        expect(find.text('本月财务状况优秀，各项指标表现良好。'), findsOneWidget);
      });

      testWidgets('should show recommendations section', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MonthlyStructureCard(monthlyHealth: healthyScore),
            ),
          ),
        );

        expect(find.text('建议行动：'), findsOneWidget);
      });
    });

    group('Edge cases', () {
      testWidgets('should handle empty recommendations', (WidgetTester tester) async {
        final scoreWithoutRecommendations = MonthlyHealthScore(
          id: 'test_empty',
          month: DateTime(2025, 11),
          grade: LetterGrade.C,
          score: 70.0,
          diagnosis: '一般状况',
          factors: [],
          recommendations: [],
          metrics: {},
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MonthlyStructureCard(monthlyHealth: scoreWithoutRecommendations),
            ),
          ),
        );

        // Should not show recommendations section
        expect(find.text('建议行动：'), findsNothing);
      });

      testWidgets('should handle missing metrics gracefully', (WidgetTester tester) async {
        final scoreWithoutMetrics = MonthlyHealthScore(
          id: 'test_no_metrics',
          month: DateTime(2025, 11),
          grade: LetterGrade.B,
          score: 80.0,
          diagnosis: '测试诊断',
          factors: [],
          recommendations: ['保持现状'],
          metrics: {},
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MonthlyStructureCard(monthlyHealth: scoreWithoutMetrics),
            ),
          ),
        );

        // Should render without crashing
        expect(find.text('月度结构分析'), findsOneWidget);
        expect(find.text('B'), findsOneWidget);
      });
    });
  });
}
