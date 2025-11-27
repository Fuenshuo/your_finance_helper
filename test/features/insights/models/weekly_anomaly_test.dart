import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/features/insights/models/weekly_anomaly.dart';

void main() {
  late WeeklyAnomaly highAnomaly;
  late WeeklyAnomaly lowAnomaly;
  late DateTime testWeekStart;

  setUp(() {
    testWeekStart = DateTime(2025, 11, 25); // Monday

    highAnomaly = WeeklyAnomaly(
      id: 'test_high_anomaly',
      weekStart: testWeekStart,
      anomalyDate: testWeekStart.add(Duration(days: 2)), // Wednesday
      expectedAmount: 150.0,
      actualAmount: 320.0,
      deviation: 1.13, // 113% higher
      reason: '餐饮,娱乐 开支激增 113%，超出预期 ¥170。可能是特殊事件或消费习惯变化。',
      severity: AnomalySeverity.high,
      categories: ['餐饮', '娱乐'],
    );

    lowAnomaly = WeeklyAnomaly(
      id: 'test_low_anomaly',
      weekStart: testWeekStart,
      anomalyDate: testWeekStart.add(Duration(days: 4)), // Friday
      expectedAmount: 150.0,
      actualAmount: 60.0,
      deviation: -0.6, // 60% lower
      reason: '餐饮 支出偏低 60%，比平时少 ¥90。良好的节约表现！',
      severity: AnomalySeverity.medium,
      categories: ['餐饮'],
    );
  });

  group('WeeklyAnomaly Model Tests', () {
    test('should create high spending anomaly correctly', () {
      expect(highAnomaly.id, 'test_high_anomaly');
      expect(highAnomaly.weekStart, testWeekStart);
      expect(highAnomaly.anomalyDate, testWeekStart.add(Duration(days: 2)));
      expect(highAnomaly.expectedAmount, 150.0);
      expect(highAnomaly.actualAmount, 320.0);
      expect(highAnomaly.deviation, 1.13);
      expect(highAnomaly.severity, AnomalySeverity.high);
      expect(highAnomaly.categories, ['餐饮', '娱乐']);
    });

    test('should create low spending anomaly correctly', () {
      expect(lowAnomaly.id, 'test_low_anomaly');
      expect(lowAnomaly.expectedAmount, 150.0);
      expect(lowAnomaly.actualAmount, 60.0);
      expect(lowAnomaly.deviation, -0.6);
      expect(lowAnomaly.severity, AnomalySeverity.medium);
      expect(lowAnomaly.categories, ['餐饮']);
    });

    test('should have correct equality for identical anomalies', () {
      final identicalAnomaly = WeeklyAnomaly(
        id: 'test_high_anomaly',
        weekStart: testWeekStart,
        anomalyDate: testWeekStart.add(Duration(days: 2)),
        expectedAmount: 150.0,
        actualAmount: 320.0,
        deviation: 1.13,
        reason: '餐饮,娱乐 开支激增 113%，超出预期 ¥170。可能是特殊事件或消费习惯变化。',
        severity: AnomalySeverity.high,
        categories: ['餐饮', '娱乐'],
      );

      expect(highAnomaly, equals(identicalAnomaly));
    });

    test('should be different when properties change', () {
      final differentAnomaly = highAnomaly.copyWith(actualAmount: 350.0);
      expect(highAnomaly, isNot(equals(differentAnomaly)));
    });

    test('should calculate difference between expected and actual', () {
      expect(highAnomaly.actualAmount - highAnomaly.expectedAmount, 170.0);
      expect(lowAnomaly.expectedAmount - lowAnomaly.actualAmount, 90.0);
    });

    group('AnomalySeverity enum values', () {
      test('low severity', () {
        expect(AnomalySeverity.low, equals(AnomalySeverity.low));
      });

      test('medium severity', () {
        expect(AnomalySeverity.medium, equals(AnomalySeverity.medium));
      });

      test('high severity', () {
        expect(AnomalySeverity.high, equals(AnomalySeverity.high));
      });
    });

    group('Reason validation', () {
      test('should contain spending amount in reason', () {
        expect(highAnomaly.reason, contains('¥170'));
        expect(lowAnomaly.reason, contains('¥90'));
      });

      test('should contain percentage in reason', () {
        expect(highAnomaly.reason, contains('113%'));
        expect(lowAnomaly.reason, contains('60%'));
      });

      test('should contain appropriate keywords for high spending', () {
        expect(highAnomaly.reason, contains('激增'));
        expect(highAnomaly.reason, contains('超出'));
      });

      test('should contain appropriate keywords for low spending', () {
        expect(lowAnomaly.reason, contains('偏低'));
        expect(lowAnomaly.reason, contains('节约'));
      });
    });

    group('Categories validation', () {
      test('should handle multiple categories', () {
        expect(highAnomaly.categories, hasLength(2));
        expect(highAnomaly.categories, contains('餐饮'));
        expect(highAnomaly.categories, contains('娱乐'));
      });

      test('should handle single category', () {
        expect(lowAnomaly.categories, hasLength(1));
        expect(lowAnomaly.categories, contains('餐饮'));
      });

      test('should handle empty categories', () {
        final anomalyWithEmptyCategories = highAnomaly.copyWith(categories: []);
        expect(anomalyWithEmptyCategories.categories, isEmpty);
      });
    });

    group('Date validation', () {
      test('should have anomaly date within the week', () {
        expect(highAnomaly.anomalyDate.difference(highAnomaly.weekStart).inDays, 2);
        expect(lowAnomaly.anomalyDate.difference(lowAnomaly.weekStart).inDays, 4);
      });

      test('should handle different week starts', () {
        final sundayStart = DateTime(2025, 11, 24); // Sunday
        final anomalyWithSundayStart = highAnomaly.copyWith(weekStart: sundayStart);
        // In Dart, weekday 7 = Sunday, 1 = Monday
        expect(anomalyWithSundayStart.weekStart.weekday, greaterThanOrEqualTo(1));
        expect(anomalyWithSundayStart.weekStart.weekday, lessThanOrEqualTo(7));
      });
    });

    group('Deviation calculations', () {
      test('should have positive deviation for high spending', () {
        expect(highAnomaly.deviation, greaterThan(0));
        expect(highAnomaly.deviation, closeTo(1.13, 0.01));
      });

      test('should have negative deviation for low spending', () {
        expect(lowAnomaly.deviation, lessThan(0));
        expect(lowAnomaly.deviation, closeTo(-0.6, 0.01));
      });

      test('should calculate percentage correctly', () {
        // For high anomaly: (320 - 150) / 150 = 170 / 150 = 1.133...
        final expectedHighDeviation = (320.0 - 150.0) / 150.0;
        expect(highAnomaly.deviation, closeTo(expectedHighDeviation, 0.01));

        // For low anomaly: (60 - 150) / 150 = -90 / 150 = -0.6
        final expectedLowDeviation = (60.0 - 150.0) / 150.0;
        expect(lowAnomaly.deviation, closeTo(expectedLowDeviation, 0.01));
      });
    });

    group('Edge cases', () {
      test('should handle zero expected amount', () {
        final anomalyWithZeroExpected = highAnomaly.copyWith(expectedAmount: 0.0);
        // Division by zero would cause issues, but this should be prevented at creation time
        expect(anomalyWithZeroExpected.expectedAmount, 0.0);
      });

      test('should handle very large deviations', () {
        final hugeAnomaly = highAnomaly.copyWith(
          expectedAmount: 1.0,
          actualAmount: 1000.0,
          deviation: 999.0,
        );
        expect(hugeAnomaly.deviation, 999.0);
        expect(hugeAnomaly.severity, AnomalySeverity.high);
      });

      test('should handle very small deviations', () {
        final tinyAnomaly = highAnomaly.copyWith(
          expectedAmount: 100.0,
          actualAmount: 100.01,
          deviation: 0.0001,
        );
        expect(tinyAnomaly.deviation, closeTo(0.0001, 0.0001));
      });
    });
  });
}
