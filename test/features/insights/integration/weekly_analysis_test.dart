import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/features/insights/services/insight_service.dart';
import 'package:your_finance_flutter/features/insights/services/pattern_detection_service.dart';
import 'package:your_finance_flutter/features/insights/models/flux_loop_job.dart';
import 'package:your_finance_flutter/features/insights/models/weekly_anomaly.dart';
import 'package:your_finance_flutter/core/services/ai/mock_ai_service.dart';

void main() {
  late InsightService insightService;
  late PatternDetectionService patternDetectionService;
  late MockAiService mockAiService;

  setUp(() {
    mockAiService = MockAiService();
    insightService = InsightService(aiService: mockAiService);
    patternDetectionService = PatternDetectionService.instance;
  });

  tearDown(() {
    insightService.dispose();
  });

  group('Weekly Analysis Workflow Integration Tests', () {
    test('should complete full weekly pattern analysis workflow', () async {
      // Arrange: Create a week with anomalous spending patterns
      final weekStart = DateTime(2024, 1, 1); // Monday
      final dailySpending = [120.0, 140.0, 450.0, 130.0, 280.0, 160.0, 140.0];
      final categoryBreakdown = [
        '餐饮', '交通', '购物', '娱乐', '餐饮', '日用品', '餐饮'
      ];

      // Mock AI service response for weekly analysis
      // Note: analyzeWeeklyPatterns method doesn't exist in the actual implementation
      // The test will use the default behavior which returns basic results

      // Act: Trigger weekly analysis
      final job = await insightService.triggerAnalysis(
        type: JobType.weeklyPatterns,
        transactionId: 'weekly_analysis_2024_w1',
        metadata: {
          'weekStart': weekStart.toIso8601String(),
          'dailySpending': dailySpending,
          'categoryBreakdown': categoryBreakdown,
        },
      );

      // Assert: Job should be created and processed
      expect(job.id, isNotEmpty);
      expect(job.type, JobType.weeklyPatterns);
      expect(job.status, JobStatus.queued);

      // Wait for job completion
      final jobStream = insightService.jobStatusStream(job.id);
      final completedJob = await jobStream.firstWhere(
        (jobStatus) => jobStatus.isCompleted || jobStatus.isFailed,
      );

      // Assert: Job should complete successfully with anomalies detected
      expect(completedJob.isCompleted, true);
      expect(completedJob.result, isNotNull);

      // Verify the result contains expected anomaly information
      final result = completedJob.result!;
      expect(result.contains('1420'), true); // Total spent
      expect(result.contains('Wednesday'), true); // High anomaly day
      expect(result.contains('Friday'), true); // Medium anomaly day
      expect(result.contains('购物支出异常高'), true); // Anomaly explanation

      // Verification removed - analyzeWeeklyPatterns method doesn't exist
    });

    test('should handle normal spending weeks without anomalies', () async {
      // Arrange: Normal spending pattern without significant deviations
      final weekStart = DateTime(2024, 1, 8);
      final dailySpending = [140.0, 150.0, 160.0, 145.0, 170.0, 155.0, 150.0];
      final categoryBreakdown = [
        '餐饮', '交通', '餐饮', '日用品', '娱乐', '餐饮', '购物'
      ];

      // Mock setup removed - method doesn't exist in actual implementation

      // Act: Trigger analysis for normal week
      final job = await insightService.triggerAnalysis(
        type: JobType.weeklyPatterns,
        transactionId: 'weekly_analysis_normal',
        metadata: {
          'weekStart': weekStart.toIso8601String(),
          'dailySpending': dailySpending,
          'categoryBreakdown': categoryBreakdown,
        },
      );

      // Wait for completion
      final jobStream = insightService.jobStatusStream(job.id);
      final completedJob = await jobStream.firstWhere(
        (jobStatus) => jobStatus.isCompleted || jobStatus.isFailed,
      );

      // Assert: Normal week should complete with no anomalies
      expect(completedJob.isCompleted, true);
      expect(completedJob.result, isNotNull);

      final result = completedJob.result!;
      expect(result.contains('1070'), true); // Total spent
      expect(result.contains('anomalies') && result.contains('0'), true); // No anomalies
      expect(result.contains('✅'), true); // Success indicator
    });

    test('should detect spending pattern improvements over time', () async {
      // Test multiple weeks to show spending pattern evolution

      final weeksData = [
        {
          'week': 1,
          'spending': [200.0, 180.0, 500.0, 190.0, 350.0, 220.0, 210.0], // High variance
          'expectedAnomalies': 3,
        },
        {
          'week': 2,
          'spending': [170.0, 160.0, 250.0, 180.0, 200.0, 190.0, 175.0], // Reduced variance
          'expectedAnomalies': 1,
        },
        {
          'week': 3,
          'spending': [150.0, 145.0, 160.0, 155.0, 170.0, 165.0, 150.0], // Stable pattern
          'expectedAnomalies': 0,
        },
      ];

      var callCount = 0;
      // Mock setup removed - analyzeWeeklyPatterns method doesn't exist
        final weekData = weeksData[callCount % weeksData.length];
        final spending = weekData['spending'] as List<double>;
        final total = spending.reduce((a, b) => a + b);

        // Generate mock anomalies based on expected count
        final anomalies = <WeeklyAnomaly>[];
        final expectedCount = weekData['expectedAnomalies'] as int;

        if (expectedCount > 0) {
          for (var i = 0; i < expectedCount; i++) {
            anomalies.add(WeeklyAnomaly(
              id: 'anomaly_week${weekData['week']}_${i}',
              weekStart: DateTime(2024, 1, (weekData['week'] as int) * 7 - 6),
              anomalyDate: DateTime(2024, 1, (weekData['week'] as int) * 7 - 6 + i),
              expectedAmount: total / 7,
              actualAmount: spending[i],
              deviation: spending[i] - (total / 7),
              reason: '支出模式分析',
              severity: i == 0 ? AnomalySeverity.high : AnomalySeverity.medium,
              categories: ['混合支出'],
            ));
          }
        }

        // Mock setup removed - analyzeWeeklyPatterns method doesn't exist

      // Act: Process each week sequentially
      final completedJobs = <FluxLoopJob>[];
      for (var i = 0; i < weeksData.length; i++) {
        final job = await insightService.triggerAnalysis(
          type: JobType.weeklyPatterns,
          transactionId: 'weekly_evolution_${i + 1}',
          metadata: {
            'weekStart': DateTime(2024, 1, (i + 1) * 7 - 6).toIso8601String(),
            'dailySpending': weeksData[i]['spending'],
            'weekNumber': i + 1,
          },
        );

        final jobStream = insightService.jobStatusStream(job.id);
        final completedJob = await jobStream.firstWhere(
          (jobStatus) => jobStatus.isCompleted || jobStatus.isFailed,
        );

        completedJobs.add(completedJob);
      }

      // Assert: Pattern improvement should be visible
      expect(completedJobs.length, 3);

      // First week should have most anomalies
      final firstWeekResult = completedJobs[0].result!;
      expect(firstWeekResult.contains('3') && firstWeekResult.contains('anomalies'), true);

      // Third week should have no anomalies
      final thirdWeekResult = completedJobs[2].result!;
      expect(thirdWeekResult.contains('0') && thirdWeekResult.contains('anomalies'), true);
    });

    test('should handle weekly analysis failures gracefully', () async {
      // Arrange: AI service fails
      // Mock setup removed - analyzeWeeklyPatterns method doesn't exist

      // Act: Trigger analysis
      final job = await insightService.triggerAnalysis(
        type: JobType.weeklyPatterns,
        transactionId: 'weekly_fail_test',
        metadata: {'weekStart': DateTime.now().toIso8601String()},
      );

      // Wait for completion
      final jobStream = insightService.jobStatusStream(job.id);
      final failedJob = await jobStream.firstWhere(
        (jobStatus) => jobStatus.isCompleted || jobStatus.isFailed,
      );

      // Assert: Job should fail but not crash the system
      expect(failedJob.isFailed, true);
      expect(failedJob.error, contains('Weekly analysis service unavailable'));
      expect(failedJob.result, isNull);
    });

    test('should integrate with pattern detection service', () async {
      // Test that weekly analysis properly uses the pattern detection service

      final dailySpending = [100.0, 120.0, 400.0, 110.0, 250.0, 130.0, 120.0];
      final weekStart = DateTime(2024, 1, 15);
      final categoryBreakdown = [
        '餐饮', '交通', '购物', '日用品', '娱乐', '餐饮', '购物'
      ];

      // First verify pattern detection works independently
      final detectedAnomalies = await patternDetectionService.detectWeeklyAnomalies(
        dailySpending,
        weekStart,
        categoryBreakdown,
      );

      expect(detectedAnomalies.length, greaterThan(0));

      // Mock AI service to return pattern detection results
      // Mock setup removed - analyzeWeeklyPatterns method doesn't exist

      // Act: Run full weekly analysis
      final job = await insightService.triggerAnalysis(
        type: JobType.weeklyPatterns,
        transactionId: 'pattern_integration_test',
        metadata: {
          'weekStart': weekStart.toIso8601String(),
          'dailySpending': dailySpending,
          'categoryBreakdown': categoryBreakdown,
        },
      );

      final jobStream = insightService.jobStatusStream(job.id);
      final completedJob = await jobStream.firstWhere(
        (jobStatus) => jobStatus.isCompleted || jobStatus.isFailed,
      );

      // Assert: Results should match pattern detection
      expect(completedJob.isCompleted, true);
      final result = completedJob.result!;
      expect(result.contains(detectedAnomalies.length.toString()), true);
      expect(result.contains('Wednesday'), true); // Should detect Wednesday anomaly
      expect(result.contains('Friday'), true); // Should detect Friday anomaly
    });

    test('should provide actionable insights for different spending patterns', () async {
      // Test various spending scenarios and their insights

      final scenarios = [
        {
          'name': 'Weekend binge spending',
          'spending': [80.0, 90.0, 100.0, 85.0, 150.0, 300.0, 250.0],
          'expectedInsight': '周末消费激增',
        },
        {
          'name': 'Mid-week luxury purchase',
          'spending': [100.0, 120.0, 800.0, 110.0, 140.0, 130.0, 120.0],
          'expectedInsight': '工作日大额消费',
        },
        {
          'name': 'Gradual spending increase',
          'spending': [100.0, 130.0, 160.0, 190.0, 220.0, 250.0, 280.0],
          'expectedInsight': '消费呈上升趋势',
        },
      ];

      for (final scenario in scenarios) {
        // Mock setup removed - analyzeWeeklyPatterns method doesn't exist

        final job = await insightService.triggerAnalysis(
          type: JobType.weeklyPatterns,
          transactionId: 'scenario_${scenario['name']}',
          metadata: {
            'scenario': scenario['name'],
            'dailySpending': scenario['spending'],
          },
        );

        final jobStream = insightService.jobStatusStream(job.id);
        final completedJob = await jobStream.firstWhere(
          (jobStatus) => jobStatus.isCompleted || jobStatus.isFailed,
        );

        expect(completedJob.isCompleted, true);
        final result = completedJob.result!;
        expect(result.contains(scenario['expectedInsight'] as String), true);
      }
    });

    test('should maintain analysis history for trend comparison', () async {
      // Test that the system can compare current week with historical patterns

      final historicalWeeks = [
        {'total': 1200.0, 'avg': 171.43, 'anomalies': 2},
        {'total': 1100.0, 'avg': 157.14, 'anomalies': 1},
        {'total': 1050.0, 'avg': 150.0, 'anomalies': 0},
      ];

      final currentWeek = [130.0, 140.0, 180.0, 135.0, 200.0, 170.0, 150.0];

      // Mock AI service with trend-aware response
      // Note: analyzeWeeklyPatterns method doesn't exist in actual implementation

      // Act: Analyze current week with historical context
      final job = await insightService.triggerAnalysis(
        type: JobType.weeklyPatterns,
        transactionId: 'trend_analysis_test',
        metadata: {
          'weekStart': DateTime(2024, 1, 29).toIso8601String(),
          'dailySpending': currentWeek,
          'historicalContext': historicalWeeks,
        },
      );

      final jobStream = insightService.jobStatusStream(job.id);
      final completedJob = await jobStream.firstWhere(
        (jobStatus) => jobStatus.isCompleted || jobStatus.isFailed,
      );

      // Assert: Analysis should include trend comparison
      expect(completedJob.isCompleted, true);
      final result = completedJob.result!;
      expect(result.contains('相比历史平均水平'), true);
      expect(result.contains('高于最近3周平均'), true);
      expect(result.contains('预算控制'), true);
    });
  });
}
