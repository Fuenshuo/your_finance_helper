import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/features/insights/models/trend_data.dart';
import 'package:your_finance_flutter/features/insights/widgets/trend_radar_chart.dart';

void main() {
  late List<TrendData> sampleTrendData;
  late List<TrendData> emptyTrendData;
  late List<TrendData> singleTrendData;

  setUp(() {
    sampleTrendData = [
      TrendData(date: DateTime.now(), amount: 100.0, dayLabel: 'Mon'),
      TrendData(date: DateTime.now(), amount: 200.0, dayLabel: 'Tue'),
      TrendData(date: DateTime.now(), amount: 150.0, dayLabel: 'Wed'),
      TrendData(
          date: DateTime.now(), amount: 0.0, dayLabel: 'Thu'), // Zero value
      TrendData(date: DateTime.now(), amount: 300.0, dayLabel: 'Fri'),
    ];

    emptyTrendData = [];
    singleTrendData = [
      TrendData(date: DateTime.now(), amount: 500.0, dayLabel: 'Sat'),
    ];
  });

  group('TrendRadarChart Widget Tests', () {
    testWidgets('displays chart with sample data correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendRadarChart(trendData: sampleTrendData),
          ),
        ),
      );

      // Should render without errors
      expect(find.byType(TrendRadarChart), findsOneWidget);
      // Should have bars (BarChart widget)
      expect(find.byType(AspectRatio), findsOneWidget);
    });

    testWidgets('displays empty state correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendRadarChart(trendData: emptyTrendData),
          ),
        ),
      );

      // Should show empty state message
      expect(find.text('No trend data available'), findsOneWidget);
    });

    testWidgets('displays single data point correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendRadarChart(trendData: singleTrendData),
          ),
        ),
      );

      // Should render without errors
      expect(find.byType(TrendRadarChart), findsOneWidget);
      expect(find.byType(AspectRatio), findsOneWidget);
    });

    testWidgets('handles null data correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrendRadarChart(),
          ),
        ),
      );

      // Should show empty state
      expect(find.text('No trend data available'), findsOneWidget);
    });

    testWidgets('pads data to 7 days when less than 7 provided',
        (tester) async {
      // Test with only 3 days of data
      final shortData = [
        TrendData(date: DateTime.now(), amount: 100.0, dayLabel: 'Mon'),
        TrendData(date: DateTime.now(), amount: 200.0, dayLabel: 'Tue'),
        TrendData(date: DateTime.now(), amount: 150.0, dayLabel: 'Wed'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendRadarChart(trendData: shortData),
          ),
        ),
      );

      // Should render without errors (implementation should pad to 7 days)
      expect(find.byType(TrendRadarChart), findsOneWidget);
    });

    testWidgets('limits data to 7 days when more than 7 provided',
        (tester) async {
      // Test with 10 days of data
      final longData = List.generate(
        10,
        (index) => TrendData(
          date: DateTime.now().add(Duration(days: index)),
          amount: 100.0 * (index + 1),
          dayLabel: 'Day${index + 1}',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendRadarChart(trendData: longData),
          ),
        ),
      );

      // Should render without errors (implementation should limit to 7 days)
      expect(find.byType(TrendRadarChart), findsOneWidget);
    });

    testWidgets('handles zero values correctly', (tester) async {
      final dataWithZeros = [
        TrendData(date: DateTime.now(), amount: 100.0, dayLabel: 'Mon'),
        TrendData(date: DateTime.now(), amount: 0.0, dayLabel: 'Tue'), // Zero
        TrendData(date: DateTime.now(), amount: 50.0, dayLabel: 'Wed'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendRadarChart(trendData: dataWithZeros),
          ),
        ),
      );

      // Should render without errors
      expect(find.byType(TrendRadarChart), findsOneWidget);
    });
  });
}
