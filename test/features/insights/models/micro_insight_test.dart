import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/features/insights/models/micro_insight.dart';

void main() {
  group('MicroInsight Model Tests', () {
    late MicroInsight microInsight;

    setUp(() {
      microInsight = MicroInsight(
        id: 'test_micro_insight',
        dailyCapId: 'test_daily_cap',
        generatedAt: DateTime(2025, 11, 27, 10, 30),
        sentiment: Sentiment.neutral,
        message: '今日消费适中，还有 ¥150 的预算空间。',
        actions: const ['合理安排剩余预算'],
        trigger: InsightTrigger.transactionAdded,
      );
    });

    test('should identify positive sentiment', () {
      final positiveInsight =
          microInsight.copyWith(sentiment: Sentiment.positive);
      expect(positiveInsight.isPositive, true);

      final neutralInsight =
          microInsight.copyWith(sentiment: Sentiment.neutral);
      expect(neutralInsight.isPositive, false);

      final negativeInsight =
          microInsight.copyWith(sentiment: Sentiment.negative);
      expect(negativeInsight.isPositive, false);
    });

    test('should identify when actions are required', () {
      expect(microInsight.requiresAction, true);

      final noActionInsight = microInsight.copyWith(actions: []);
      expect(noActionInsight.requiresAction, false);
    });

    test('should have correct props for equality', () {
      final identicalInsight = MicroInsight(
        id: 'test_micro_insight',
        dailyCapId: 'test_daily_cap',
        generatedAt: DateTime(2025, 11, 27, 10, 30),
        sentiment: Sentiment.neutral,
        message: '今日消费适中，还有 ¥150 的预算空间。',
        actions: const ['合理安排剩余预算'],
        trigger: InsightTrigger.transactionAdded,
      );

      expect(microInsight, equals(identicalInsight));
    });

    test('should be different when properties change', () {
      final differentInsight =
          microInsight.copyWith(message: 'Different message');
      expect(microInsight, isNot(equals(differentInsight)));
    });

    group('Sentiment enum values', () {
      test('positive sentiment', () {
        expect(Sentiment.positive, equals(Sentiment.positive));
      });

      test('neutral sentiment', () {
        expect(Sentiment.neutral, equals(Sentiment.neutral));
      });

      test('negative sentiment', () {
        expect(Sentiment.negative, equals(Sentiment.negative));
      });
    });

    group('InsightTrigger enum values', () {
      test('transactionAdded trigger', () {
        expect(InsightTrigger.transactionAdded,
            equals(InsightTrigger.transactionAdded));
      });

      test('budgetExceeded trigger', () {
        expect(InsightTrigger.budgetExceeded,
            equals(InsightTrigger.budgetExceeded));
      });

      test('timeCheck trigger', () {
        expect(InsightTrigger.timeCheck, equals(InsightTrigger.timeCheck));
      });

      test('manualRequest trigger', () {
        expect(
            InsightTrigger.manualRequest, equals(InsightTrigger.manualRequest));
      });
    });

    group('Message validation', () {
      test('should handle empty message', () {
        final emptyMessageInsight = microInsight.copyWith(message: '');
        expect(emptyMessageInsight.message, '');
        expect(emptyMessageInsight.requiresAction, true);
      });

      test('should handle long messages', () {
        final longMessage = 'A' * 500;
        final longMessageInsight = microInsight.copyWith(message: longMessage);
        expect(longMessageInsight.message, longMessage);
      });

      test('should handle messages with special characters', () {
        const specialMessage = '今日消费 ¥150.50，还剩 25% 预算！';
        final specialInsight = microInsight.copyWith(message: specialMessage);
        expect(specialInsight.message, specialMessage);
      });
    });

    group('Actions validation', () {
      test('should handle empty actions list', () {
        final noActionsInsight = microInsight.copyWith(actions: []);
        expect(noActionsInsight.actions, isEmpty);
        expect(noActionsInsight.requiresAction, false);
      });

      test('should handle multiple actions', () {
        final multipleActions = [
          '合理安排剩余预算',
          '查看大额消费明细',
          '设置消费提醒',
        ];
        final multiActionInsight =
            microInsight.copyWith(actions: multipleActions);
        expect(multiActionInsight.actions, hasLength(3));
        expect(multiActionInsight.requiresAction, true);
      });
    });

    group('GeneratedAt timestamp', () {
      test('should preserve timestamp', () {
        final testTime = DateTime(2025, 11, 27, 15, 45, 30);
        final timestampInsight = microInsight.copyWith(generatedAt: testTime);
        expect(timestampInsight.generatedAt, testTime);
      });

      test('should handle future timestamps', () {
        final futureTime = DateTime(2025, 12, 31, 23, 59, 59);
        final futureInsight = microInsight.copyWith(generatedAt: futureTime);
        expect(futureInsight.generatedAt, futureTime);
      });
    });
  });
}
