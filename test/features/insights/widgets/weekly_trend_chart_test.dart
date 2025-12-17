import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/core/services/insight_service.dart';
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
    final anomalyDate = DateTime.now()
        .subtract(Duration(days: DateTime.now().weekday - 3)); // Wednesday
    anomalousAnomalies = [
      WeeklyAnomaly(
        id: 'anomaly_1',
        weekStart: anomalyDate.subtract(const Duration(days: 2)),
        anomalyDate: anomalyDate,
        expectedAmount: 200.0,
        actualAmount: 400.0,
        deviation: 100.0,
        reason: '周三支出异常高，主要是餐饮消费',
        severity: AnomalySeverity.medium,
        categories: const ['餐饮'],
      ),
    ];
  });

  group('WeeklyTrendChart Widget Tests', () {
    testWidgets('should display weekly trend chart', (tester) async {
      final insight = _buildWeeklyInsight(normalWeeklyData, normalAnomalies);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyTrendChart(weeklyInsight: insight),
          ),
        ),
      );

      // Check chart renders
      expect(find.byType(WeeklyTrendChart), findsOneWidget);
    });

    testWidgets('should display chart with anomaly highlighting',
        (tester) async {
      final insight =
          _buildWeeklyInsight(anomalousWeeklyData, anomalousAnomalies);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyTrendChart(weeklyInsight: insight),
          ),
        ),
      );

      // Check chart renders with anomalies
      expect(find.byType(WeeklyTrendChart), findsOneWidget);
    });

    testWidgets('should handle empty anomalies list', (tester) async {
      final insight = _buildWeeklyInsight(normalWeeklyData, normalAnomalies);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyTrendChart(weeklyInsight: insight),
          ),
        ),
      );

      // Should render without errors
      expect(find.byType(WeeklyTrendChart), findsOneWidget);
    });

    testWidgets('should handle single anomaly', (tester) async {
      final insight =
          _buildWeeklyInsight(anomalousWeeklyData, anomalousAnomalies);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyTrendChart(weeklyInsight: insight),
          ),
        ),
      );

      // Should render without errors
      expect(find.byType(WeeklyTrendChart), findsOneWidget);
    });

    testWidgets('should handle multiple anomalies', (tester) async {
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
          categories: const ['购物'],
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
          categories: const ['娱乐'],
        ),
      ];

      final insight = _buildWeeklyInsight(
        [200.0, 180.0, 300.0, 190.0, 210.0, 500.0, 200.0],
        multiAnomalies,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyTrendChart(weeklyInsight: insight),
          ),
        ),
      );

      // Should render without errors
      expect(find.byType(WeeklyTrendChart), findsOneWidget);
    });

    group('Edge cases', () {
      testWidgets('should handle zero spending', (tester) async {
        final zeroData = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];

        final insight = _buildWeeklyInsight(zeroData, []);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WeeklyTrendChart(weeklyInsight: insight),
            ),
          ),
        );

        // Should render without errors
        expect(find.byType(WeeklyTrendChart), findsOneWidget);
      });

      testWidgets('should handle very high spending', (tester) async {
        final highData = [1000.0, 1200.0, 800.0, 1500.0, 900.0, 1100.0, 1300.0];

        final insight = _buildWeeklyInsight(highData, []);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WeeklyTrendChart(weeklyInsight: insight),
            ),
          ),
        );

        // Should render without errors
        expect(find.byType(WeeklyTrendChart), findsOneWidget);
      });
    });
  });
}

WeeklyInsight _buildWeeklyInsight(
  List<double> weeklyData,
  List<WeeklyAnomaly> anomalies,
) {
  assert(weeklyData.length == 7, 'Weekly data must contain 7 entries');
  final total =
      weeklyData.fold<double>(0, (previous, value) => previous + value);
  final average = weeklyData.isEmpty ? 0.0 : total / weeklyData.length;

  return WeeklyInsight(
    totalSpent: total,
    averageSpent: average,
    anomalies: anomalies,
    monday: weeklyData[0],
    tuesday: weeklyData[1],
    wednesday: weeklyData[2],
    thursday: weeklyData[3],
    friday: weeklyData[4],
    saturday: weeklyData[5],
    sunday: weeklyData[6],
  );
}
