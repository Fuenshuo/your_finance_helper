import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:your_finance_flutter/features/insights/models/daily_cap.dart';
import 'package:your_finance_flutter/features/insights/models/flux_loop_job.dart';
import 'package:your_finance_flutter/features/insights/models/micro_insight.dart';
import 'package:your_finance_flutter/features/insights/services/insight_service.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/services/ai/mock_ai_service.dart';

// Mock classes
class MockTransaction extends Mock implements Transaction {}

void main() {
  late InsightService insightService;
  late MockAiService mockAiService;

  setUp(() {
    mockAiService = MockAiService();
    insightService = InsightService(aiService: mockAiService);
  });

  tearDown(() {
    insightService.dispose();
  });

  group('Flux Loop Daily Analysis Integration Tests', () {
    test('should trigger and complete daily cap analysis for new transaction', () async {
      // Arrange: Create a mock transaction
      const transactionId = 'tx_123';
      final transaction = Transaction(
        id: transactionId,
        type: TransactionType.expense,
        amount: 150.0,
        category: TransactionCategory.foodExpense,
        description: '午餐',
        date: DateTime.now(),
        accountId: 'acc_1',
        status: TransactionStatus.confirmed,
        creationDate: DateTime.now(),
        updateDate: DateTime.now(),
      );

      // Mock AI service response for daily cap analysis
      final mockInsight = MicroInsight(
        id: 'insight_123',
        type: InsightType.behavioral,
        content: '今日午餐支出 ¥150，预算控制良好',
        sentiment: InsightSentiment.positive,
        confidence: 0.85,
        createdAt: DateTime.now(),
        metadata: {
          'trigger': 'daily_cap_analysis',
          'transactionId': transactionId,
        },
      );

      when(mockAiService.analyzeDailyCap(any))
          .thenAnswer((_) async => DailyCap(
            date: DateTime.now(),
            budgetAmount: 500.0,
            spentAmount: 150.0,
            remainingAmount: 350.0,
            percentageUsed: 30.0,
            status: CapStatus.healthy,
            insights: [mockInsight],
          ));

      // Act: Trigger daily analysis
      final job = await insightService.triggerAnalysis(
        type: JobType.dailyAnalysis,
        transactionId: transactionId,
        metadata: {
          'amount': 150.0,
          'category': 'foodExpense',
          'description': '午餐',
        },
      );

      // Assert: Job should be created and queued
      expect(job.id, isNotEmpty);
      expect(job.type, JobType.dailyAnalysis);
      expect(job.status, JobStatus.queued);
      expect(job.metadata['transactionId'], transactionId);

      // Wait for job completion
      final jobStream = insightService.watchJob(job.id);
      final completedJob = await jobStream.firstWhere(
        (job) => job.isCompleted || job.isFailed,
      );

      // Assert: Job should complete successfully
      expect(completedJob.isCompleted, true);
      expect(completedJob.result, isNotNull);
      expect(completedJob.error, isNull);

      // Verify AI service was called
      verify(mockAiService.analyzeDailyCap(any)).called(1);
    });

    test('should handle daily cap analysis failure gracefully', () async {
      // Arrange: Set up AI service to fail
      when(mockAiService.analyzeDailyCap(any))
          .thenThrow(Exception('AI service unavailable'));

      // Act: Trigger analysis
      final job = await insightService.triggerAnalysis(
        type: JobType.dailyAnalysis,
        transactionId: 'tx_fail',
        metadata: {'amount': 200.0},
      );

      // Wait for job completion
      final jobStream = insightService.watchJob(job.id);
      final failedJob = await jobStream.firstWhere(
        (job) => job.isCompleted || job.isFailed,
      );

      // Assert: Job should fail gracefully
      expect(failedJob.isFailed, true);
      expect(failedJob.error, contains('AI service unavailable'));
      expect(failedJob.result, isNull);
    });

    test('should update daily cap insights in real-time as transactions are added', () async {
      // This test simulates adding multiple transactions throughout the day
      // and verifies that insights are updated progressively

      final transactions = [
        {'id': 'tx_1', 'amount': 50.0, 'description': '早餐'},
        {'id': 'tx_2', 'amount': 100.0, 'description': '午餐'},
        {'id': 'tx_3', 'amount': 200.0, 'description': '购物'},
      ];

      // Mock progressive daily cap states
      final mockCaps = [
        DailyCap(
          date: DateTime.now(),
          budgetAmount: 500.0,
          spentAmount: 50.0,
          remainingAmount: 450.0,
          percentageUsed: 10.0,
          status: CapStatus.healthy,
          insights: [
            MicroInsight(
              id: 'insight_1',
              type: InsightType.behavioral,
              content: '早餐支出合理，预算剩余充足',
              sentiment: InsightSentiment.positive,
              confidence: 0.9,
              createdAt: DateTime.now(),
              metadata: {'transactionId': 'tx_1'},
            ),
          ],
        ),
        DailyCap(
          date: DateTime.now(),
          budgetAmount: 500.0,
          spentAmount: 150.0,
          remainingAmount: 350.0,
          percentageUsed: 30.0,
          status: CapStatus.healthy,
          insights: [
            MicroInsight(
              id: 'insight_2',
              type: InsightType.behavioral,
              content: '午餐后预算剩余 ¥350，控制良好',
              sentiment: InsightSentiment.positive,
              confidence: 0.85,
              createdAt: DateTime.now(),
              metadata: {'transactionId': 'tx_2'},
            ),
          ],
        ),
        DailyCap(
          date: DateTime.now(),
          budgetAmount: 500.0,
          spentAmount: 350.0,
          remainingAmount: 150.0,
          percentageUsed: 70.0,
          status: CapStatus.warning,
          insights: [
            MicroInsight(
              id: 'insight_3',
              type: InsightType.behavioral,
              content: '购物后支出已达70%，建议控制剩余预算',
              sentiment: InsightSentiment.neutral,
              confidence: 0.8,
              createdAt: DateTime.now(),
              metadata: {'transactionId': 'tx_3'},
            ),
          ],
        ),
      ];

      // Set up mock responses for each transaction
      var callCount = 0;
      when(mockAiService.analyzeDailyCap(any)).thenAnswer((_) async {
        return mockCaps[callCount++ % mockCaps.length];
      });

      // Act: Trigger analysis for each transaction
      final jobs = <FluxLoopJob>[];
      for (final tx in transactions) {
        final job = await insightService.triggerAnalysis(
          type: JobType.dailyAnalysis,
          transactionId: tx['id'] as String,
          metadata: {
            'amount': tx['amount'],
            'description': tx['description'],
          },
        );
        jobs.add(job);
      }

      // Assert: All jobs should complete successfully
      for (final job in jobs) {
        final jobStream = insightService.watchJob(job.id);
        final completedJob = await jobStream.firstWhere(
          (job) => job.isCompleted || job.isFailed,
        );
        expect(completedJob.isCompleted, true);
        expect(completedJob.result, isNotNull);
      }

      // Verify AI service was called for each transaction
      verify(mockAiService.analyzeDailyCap(any)).called(transactions.length);
    });

    test('should prioritize urgent daily cap warnings', () async {
      // Test that urgent warnings (like exceeding 80% budget) are processed immediately

      // Mock an urgent situation
      when(mockAiService.analyzeDailyCap(any))
          .thenAnswer((_) async => DailyCap(
            date: DateTime.now(),
            budgetAmount: 500.0,
            spentAmount: 450.0, // 90% used
            remainingAmount: 50.0,
            percentageUsed: 90.0,
            status: CapStatus.danger,
            insights: [
              MicroInsight(
                id: 'urgent_insight',
                type: InsightType.warning,
                content: '⚠️ 今日支出已达90%，仅剩 ¥50 预算！',
                sentiment: InsightSentiment.negative,
                confidence: 0.95,
                createdAt: DateTime.now(),
                metadata: {'urgent': true},
              ),
            ],
          ));

      // Act: Trigger urgent analysis
      final job = await insightService.triggerAnalysis(
        type: JobType.dailyAnalysis,
        transactionId: 'tx_urgent',
        metadata: {
          'amount': 400.0,
          'urgent': true,
          'percentageUsed': 90.0,
        },
      );

      // Wait for completion
      final jobStream = insightService.watchJob(job.id);
      final completedJob = await jobStream.firstWhere(
        (job) => job.isCompleted || job.isFailed,
      );

      // Assert: Urgent job should complete and contain warning
      expect(completedJob.isCompleted, true);
      final result = completedJob.result;
      expect(result, isNotNull);
      expect(result!.contains('90%'), true);
      expect(result.contains('⚠️'), true);
    });

    test('should handle concurrent daily analyses without conflicts', () async {
      // Test that multiple daily analyses can run concurrently without interfering

      final transactionIds = ['tx_a', 'tx_b', 'tx_c'];
      final jobs = <FluxLoopJob>[];

      // Mock different responses for each transaction
      var responseIndex = 0;
      final responses = [
        '分析A完成',
        '分析B完成',
        '分析C完成',
      ];

      when(mockAiService.analyzeDailyCap(any))
          .thenAnswer((_) async {
            // Simulate different processing times
            await Future.delayed(Duration(milliseconds: 10 * responseIndex));
            return DailyCap(
              date: DateTime.now(),
              budgetAmount: 500.0,
              spentAmount: 100.0 + (responseIndex * 50.0),
              remainingAmount: 400.0 - (responseIndex * 50.0),
              percentageUsed: 20.0 + (responseIndex * 10.0),
              status: CapStatus.healthy,
              insights: [
                MicroInsight(
                  id: 'insight_${responseIndex}',
                  type: InsightType.behavioral,
                  content: responses[responseIndex],
                  sentiment: InsightSentiment.positive,
                  confidence: 0.8,
                  createdAt: DateTime.now(),
                  metadata: {'transactionId': transactionIds[responseIndex]},
                ),
              ],
            );
          });

      // Act: Trigger multiple analyses concurrently
      for (var i = 0; i < transactionIds.length; i++) {
        final job = await insightService.triggerAnalysis(
          type: JobType.dailyAnalysis,
          transactionId: transactionIds[i],
          metadata: {'index': i},
        );
        jobs.add(job);
        responseIndex++;
      }

      // Wait for all jobs to complete
      final completionFutures = jobs.map((job) async {
        final jobStream = insightService.watchJob(job.id);
        return await jobStream.firstWhere(
          (job) => job.isCompleted || job.isFailed,
        );
      });

      final completedJobs = await Future.wait(completionFutures);

      // Assert: All jobs should complete successfully
      for (final job in completedJobs) {
        expect(job.isCompleted, true);
        expect(job.result, isNotNull);
      }

      // Verify AI service was called for each job
      verify(mockAiService.analyzeDailyCap(any)).called(transactionIds.length);
    });

    test('should maintain job history and provide analysis trends', () async {
      // Test that the system maintains analysis history for trend detection

      final transactions = [
        {'id': 'tx_morning', 'amount': 30.0, 'time': '09:00'},
        {'id': 'tx_afternoon', 'amount': 80.0, 'time': '14:00'},
        {'id': 'tx_evening', 'amount': 120.0, 'time': '19:00'},
      ];

      // Mock analysis responses that show spending pattern evolution
      final mockAnalyses = [
        '早上支出温和，预算控制良好',
        '下午支出适中，注意节奏控制',
        '晚上支出偏高，今日预算即将用尽',
      ];

      var analysisIndex = 0;
      when(mockAiService.analyzeDailyCap(any))
          .thenAnswer((_) async => DailyCap(
            date: DateTime.now(),
            budgetAmount: 500.0,
            spentAmount: transactions.sublist(0, analysisIndex + 1)
                .fold(0.0, (sum, tx) => sum + (tx['amount'] as double)),
            remainingAmount: 500.0 - transactions.sublist(0, analysisIndex + 1)
                .fold(0.0, (sum, tx) => sum + (tx['amount'] as double)),
            percentageUsed: (transactions.sublist(0, analysisIndex + 1)
                    .fold(0.0, (sum, tx) => sum + (tx['amount'] as double)) /
                500.0) *
                100,
            status: analysisIndex < 2 ? CapStatus.healthy : CapStatus.warning,
            insights: [
              MicroInsight(
                id: 'trend_insight_${analysisIndex}',
                type: InsightType.trend,
                content: mockAnalyses[analysisIndex],
                sentiment: analysisIndex < 2 ? InsightSentiment.positive : InsightSentiment.neutral,
                confidence: 0.85,
                createdAt: DateTime.now(),
                metadata: {
                  'transactionId': transactions[analysisIndex]['id'],
                  'analysisSequence': analysisIndex,
                },
              ),
            ],
          ));

      // Act: Process transactions sequentially to build analysis history
      final completedJobs = <FluxLoopJob>[];
      for (final tx in transactions) {
        final job = await insightService.triggerAnalysis(
          type: JobType.dailyAnalysis,
          transactionId: tx['id'] as String,
          metadata: {
            'amount': tx['amount'],
            'time': tx['time'],
            'sequence': analysisIndex,
          },
        );

        final jobStream = insightService.watchJob(job.id);
        final completedJob = await jobStream.firstWhere(
          (job) => job.isCompleted || job.isFailed,
        );

        completedJobs.add(completedJob);
        analysisIndex++;
      }

      // Assert: All jobs completed and analysis shows spending progression
      expect(completedJobs.length, 3);
      for (var i = 0; i < completedJobs.length; i++) {
        final job = completedJobs[i];
        expect(job.isCompleted, true);
        expect(job.result, contains(mockAnalyses[i]));
        expect(job.metadata['sequence'], i);
      }

      // Verify the system can track spending progression
      final firstJob = completedJobs[0];
      final lastJob = completedJobs[2];
      expect(lastJob.metadata['analysisSequence'], greaterThan(firstJob.metadata['analysisSequence']));
    });
  });
}
