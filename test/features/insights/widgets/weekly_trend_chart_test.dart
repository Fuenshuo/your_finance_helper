import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/features/insights/models/weekly_anomaly.dart';
import 'package:your_finance_flutter/features/insights/widgets/weekly_trend_chart.dart';

void main() {
  late List<double> normalWeeklyData;
  late List<WeeklyAnomaly> normalAnomalies;
  late List<double> anomalousWeeklyData;
  late List<WeeklyAnomaly> anomalousAnomalies;

  setUp(() {
    // Normal week with no anomalies
    normalWeeklyData = [200.0, 180.0, 220.0, 190.0, 210.0, 200.0, 200.0];
    normalAnomalies = [];

    // Week with anomalies
    anomalousWeeklyData = [200.0, 180.0, 400.0, 190.0, 210.0, 200.0, 200.0];
    final anomalyDate = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 3)); // Wednesday
    anomalousAnomalies = [
      WeeklyAnomaly(
        id: 'anomaly_1',
        weekStart: anomalyDate.subtract(Duration(days: 2)),
        anomalyDate: anomalyDate,
        expectedAmount: 200.0,
        actualAmount: 400.0,
        deviation: 100.0,
        reason: '周三支出异常高，主要是餐饮消费',
        severity: AnomalySeverity.medium,
        categories: ['餐饮'],
      ),
    ];
  });

  group('WeeklyTrendChart Widget Tests', () {
    testWidgets('should display weekly trend chart', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyTrendChart(
              weeklyData: normalWeeklyData,
              anomalies: normalAnomalies,
            ),
          ),
        ),
      );

      // Check chart renders
      expect(find.byType(WeeklyTrendChart), findsOneWidget);
    });

    testWidgets('should display chart with anomaly highlighting', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyTrendChart(
              weeklyData: anomalousWeeklyData,
              anomalies: anomalousAnomalies,
            ),
          ),
        ),
      );

      // Check chart renders with anomalies
      expect(find.byType(WeeklyTrendChart), findsOneWidget);
    });

    testWidgets('should handle empty anomalies list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyTrendChart(
              weeklyData: normalWeeklyData,
              anomalies: normalAnomalies,
            ),
          ),
        ),
      );

      // Should render without errors
      expect(find.byType(WeeklyTrendChart), findsOneWidget);
    });

    testWidgets('should handle single anomaly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyTrendChart(
              weeklyData: anomalousWeeklyData,
              anomalies: anomalousAnomalies,
            ),
          ),
        ),
      );

      // Should render without errors
      expect(find.byType(WeeklyTrendChart), findsOneWidget);
    });

    testWidgets('should handle multiple anomalies', (WidgetTester tester) async {
      final multiAnomalies = [
        WeeklyAnomaly(
          id: 'anomaly_1',
          weekStart: DateTime.now().subtract(const Duration(days: 6)),
          anomalyDate: DateTime.now().subtract(const Duration(days: 4)),
          expectedAmount: 200.0,
          actualAmount: 300.0,
          deviation: 50.0,
          reason: '周四支出较高',
          severity: AnomalySeverity.low,
          categories: ['购物'],
        ),
        WeeklyAnomaly(
          id: 'anomaly_2',
          weekStart: DateTime.now().subtract(const Duration(days: 6)),
          anomalyDate: DateTime.now().subtract(const Duration(days: 1)),
          expectedAmount: 200.0,
          actualAmount: 500.0,
          deviation: 150.0,
          reason: '周日支出异常高',
          severity: AnomalySeverity.high,
          categories: ['娱乐'],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyTrendChart(
              weeklyData: [200.0, 180.0, 300.0, 190.0, 210.0, 500.0, 200.0],
              anomalies: multiAnomalies,
            ),
          ),
        ),
      );

      // Should render without errors
      expect(find.byType(WeeklyTrendChart), findsOneWidget);
    });

    group('Edge cases', () {
      testWidgets('should handle zero spending', (WidgetTester tester) async {
        final zeroData = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WeeklyTrendChart(
                weeklyData: zeroData,
                anomalies: [],
              ),
            ),
          ),
        );

        // Should render without errors
        expect(find.byType(WeeklyTrendChart), findsOneWidget);
      });

      testWidgets('should handle very high spending', (WidgetTester tester) async {
        final highData = [1000.0, 1200.0, 800.0, 1500.0, 900.0, 1100.0, 1300.0];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WeeklyTrendChart(
                weeklyData: highData,
                anomalies: [],
              ),
            ),
          ),
        );

        // Should render without errors
        expect(find.byType(WeeklyTrendChart), findsOneWidget);
      });
    });
  });
}
