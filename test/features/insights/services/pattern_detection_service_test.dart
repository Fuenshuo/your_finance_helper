import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/features/insights/models/weekly_anomaly.dart';
import 'package:your_finance_flutter/features/insights/services/pattern_detection_service.dart';

void main() {
  late PatternDetectionService service;
  late DateTime testWeekStart;
  late List<double> normalWeek;
  late List<double> anomalousWeek;
  late List<String> categoryBreakdown;

  setUp(() {
    service = PatternDetectionService.instance;
    testWeekStart = DateTime(2025, 11, 25); // Monday

    // Normal week with consistent spending
    normalWeek = [150.0, 140.0, 160.0, 155.0, 145.0, 200.0, 180.0];

    // Week with anomalies (Wednesday spike, Friday low)
    anomalousWeek = [150.0, 140.0, 320.0, 155.0, 60.0, 200.0, 180.0];

    // Category breakdown for each day
    categoryBreakdown = [
      '餐饮:80,购物:70',
      '交通:50,餐饮:90',
      '餐饮:150,娱乐:170', // Wednesday anomaly
      '餐饮:100,购物:55',
      '餐饮:60', // Friday low spending
      '餐饮:120,娱乐:80',
      '餐饮:100,购物:80'
    ];
  });

  group('PatternDetectionService Tests', () {
    test('should detect no anomalies in normal spending week', () async {
      final anomalies = await service.detectWeeklyAnomalies(
        normalWeek,
        testWeekStart,
        categoryBreakdown,
      );

      expect(anomalies, isEmpty);
    });

    test('should detect anomalies in week with irregular spending', () async {
      final anomalies = await service.detectWeeklyAnomalies(
        anomalousWeek,
        testWeekStart,
        categoryBreakdown,
      );

      expect(anomalies.length, greaterThanOrEqualTo(2)); // Wednesday high + Friday low
    });

    test('should correctly identify high spending anomaly', () async {
      final anomalies = await service.detectWeeklyAnomalies(
        anomalousWeek,
        testWeekStart,
        categoryBreakdown,
      );

      expect(anomalies.length, greaterThan(0));

      // Find Wednesday anomaly (Day 2)
      final wednesdayAnomaly = anomalies.firstWhere(
        (a) => a.anomalyDate.difference(testWeekStart).inDays == 2,
        orElse: () => throw StateError('Wednesday anomaly not found'),
      );

      expect(wednesdayAnomaly.actualAmount, 320.0);
      expect(wednesdayAnomaly.expectedAmount, closeTo(137.0, 1.0)); // Baseline calculation
      expect(wednesdayAnomaly.deviation, greaterThan(1.0)); // Significant deviation
      expect(wednesdayAnomaly.severity, equals(AnomalySeverity.high));
      expect(wednesdayAnomaly.reason, contains('激增'));
      expect(wednesdayAnomaly.categories, contains('餐饮'));
      expect(wednesdayAnomaly.categories, contains('娱乐'));
    });

    test('should correctly identify low spending anomaly', () async {
      final anomalies = await service.detectWeeklyAnomalies(
        anomalousWeek,
        testWeekStart,
        categoryBreakdown,
      );

      final fridayAnomaly = anomalies.firstWhere(
        (a) => a.anomalyDate.difference(testWeekStart).inDays == 4, // Friday (Day 4)
      );

      expect(fridayAnomaly.actualAmount, 60.0);
      expect(fridayAnomaly.expectedAmount, closeTo(137.0, 1.0)); // Baseline calculation
      expect(fridayAnomaly.deviation, lessThan(-0.5)); // Significant negative deviation
      expect(fridayAnomaly.reason, contains('偏低'));
    });

    test('should throw error for invalid input length', () async {
      final invalidData = [100.0, 200.0]; // Only 2 days

      expect(
        () => service.detectWeeklyAnomalies(invalidData, testWeekStart, []),
        throwsArgumentError,
      );
    });

    test('should calculate weekly statistics correctly', () {
      final stats = service.calculateWeeklyStats(normalWeek);

      expect(stats['total'], closeTo(1130.0, 0.1));
      expect(stats['average'], closeTo(161.43, 1.0));
      expect(stats['max'], 200.0);
      expect(stats['min'], 140.0);
      expect(stats.containsKey('variance'), true);
      expect(stats.containsKey('standardDeviation'), true);
    });

    test('should identify weekend spending patterns', () {
      final patterns = service.identifyPatterns(normalWeek);

      expect(patterns['weekendMultiplier'], greaterThan(1.0)); // Weekend spending higher
      expect(patterns['peakDay'], isA<int>()); // Should identify peak day
      expect(patterns['spendingTrend'], isA<double>()); // Should calculate trend
    });

    test('should handle empty category breakdown', () async {
      final anomalies = await service.detectWeeklyAnomalies(
        anomalousWeek,
        testWeekStart,
        [], // Empty categories
      );

      expect(anomalies, hasLength(2));
      expect(anomalies.first.categories, contains('未知分类'));
    });

    test('should calculate different severity levels', () async {
      // Create week with various deviation levels
      final testWeek = [100.0, 100.0, 100.0, 100.0, 100.0, 260.0, 100.0]; // 160% deviation
      final anomalies = await service.detectWeeklyAnomalies(
        testWeek,
        testWeekStart,
        [],
      );

      expect(anomalies, hasLength(1));
      expect(anomalies.first.severity, equals(AnomalySeverity.high));
    });

    test('should generate appropriate anomaly explanations', () async {
      final anomalies = await service.detectWeeklyAnomalies(
        anomalousWeek,
        testWeekStart,
        categoryBreakdown,
      );

      for (final anomaly in anomalies) {
        expect(anomaly.reason, isNotEmpty);
        expect(anomaly.reason, contains('¥')); // Should include amount
        expect(anomaly.reason, contains('%')); // Should include percentage
      }
    });

    group('Edge cases', () {
      test('should handle all zero spending', () async {
        final zeroWeek = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
        final anomalies = await service.detectWeeklyAnomalies(
          zeroWeek,
          testWeekStart,
          [],
        );

        expect(anomalies, isEmpty); // No anomalies when everything is zero
      });

      test('should handle very high variance', () async {
        final highVarianceWeek = [10.0, 20.0, 30.0, 40.0, 50.0, 500.0, 60.0];
        final stats = service.calculateWeeklyStats(highVarianceWeek);

        expect(stats['variance'], greaterThan(10000)); // High variance
        expect(stats['standardDeviation'], greaterThan(100)); // High std dev
      });

      test('should handle decreasing trend', () async {
        final decreasingWeek = [200.0, 180.0, 160.0, 140.0, 120.0, 100.0, 80.0];
        final patterns = service.identifyPatterns(decreasingWeek);

        expect(patterns['spendingTrend'], lessThan(0)); // Negative trend
      });
    });
  });
}
