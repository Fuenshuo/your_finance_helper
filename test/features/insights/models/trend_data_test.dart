import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/features/insights/models/trend_data.dart';

void main() {
  group('TrendData Model', () {
    test('TrendData validates correctly', () {
      // Valid data
      final validTrend = TrendData(
        date: DateTime.now(),
        amount: 1250.0,
        dayLabel: 'Mon',
      );
      expect(validTrend.isValid, isTrue);

      // Invalid: negative amount
      final invalidTrend1 = TrendData(
        date: DateTime.now(),
        amount: -100.0,
        dayLabel: 'Tue',
      );
      expect(invalidTrend1.isValid, isFalse);

      // Invalid: empty day label
      final invalidTrend2 = TrendData(
        date: DateTime.now(),
        amount: 500.0,
        dayLabel: '',
      );
      expect(invalidTrend2.isValid, isFalse);
    });

    test('TrendData handles zero amounts correctly', () {
      final zeroTrend = TrendData(
        date: DateTime.now(),
        amount: 0.0,
        dayLabel: 'Wed',
      );
      expect(zeroTrend.isValid, isTrue);
      expect(zeroTrend.amount, 0.0);
    });

    test('TrendData handles large amounts correctly', () {
      final largeTrend = TrendData(
        date: DateTime.now(),
        amount: 999999.99,
        dayLabel: 'Thu',
      );
      expect(largeTrend.isValid, isTrue);
      expect(largeTrend.amount, 999999.99);
    });

    test('TrendData handles various day labels', () {
      final monday = TrendData(
        date: DateTime.now(),
        amount: 100.0,
        dayLabel: 'Mon',
      );
      expect(monday.isValid, isTrue);

      final sunday = TrendData(
        date: DateTime.now(),
        amount: 200.0,
        dayLabel: 'Sun',
      );
      expect(sunday.isValid, isTrue);

      // Single character (should be valid)
      final singleChar = TrendData(
        date: DateTime.now(),
        amount: 50.0,
        dayLabel: 'M',
      );
      expect(singleChar.isValid, isTrue);
    });

    test('TrendData constructor creates object correctly', () {
      final date = DateTime(2024, 1, 15);
      final trend = TrendData(
        date: date,
        amount: 750.0,
        dayLabel: 'Fri',
      );

      expect(trend.date, date);
      expect(trend.amount, 750.0);
      expect(trend.dayLabel, 'Fri');
      expect(trend.isValid, isTrue);
    });

    test('TrendData handles decimal amounts correctly', () {
      final decimalTrend = TrendData(
        date: DateTime.now(),
        amount: 123.45,
        dayLabel: 'Sat',
      );
      expect(decimalTrend.isValid, isTrue);
      expect(decimalTrend.amount, 123.45);
    });
  });
}
