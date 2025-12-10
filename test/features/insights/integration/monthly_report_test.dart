import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:your_finance_flutter/features/insights/services/insight_service.dart';
import 'package:your_finance_flutter/features/insights/services/health_analysis_service.dart';
import 'package:your_finance_flutter/features/insights/models/flux_loop_job.dart';
import 'package:your_finance_flutter/features/insights/models/monthly_health.dart';
import 'package:your_finance_flutter/core/services/ai/mock_ai_service.dart';

void main() {
  late InsightService insightService;
  late HealthAnalysisService healthAnalysisService;
  late MockAiService mockAiService;

  setUp(() {
    mockAiService = MockAiService();
    insightService = InsightService(aiService: mockAiService);
    healthAnalysisService = HealthAnalysisService();
  });

  tearDown(() {
    insightService.dispose();
  });

  group('Monthly Report Generation Integration Tests', () {
    test('should generate comprehensive monthly CFO report', () async {
      // Arrange: Create comprehensive monthly data
      final monthlyData = {
        'month': DateTime(2024, 1, 1),
        'totalIncome': 15000.0,
        'totalExpenses': 12000.0,
        'categories': {
          'survival': 5400.0, // Housing, utilities, groceries (36%)
          'lifestyle': 4200.0, // Dining, entertainment, shopping (28%)
          'savings': 1800.0, // Emergency fund, investments (12%)
          'discretionary': 1600.0, // Travel, hobbies (11%)
        },
        'weeklyBreakdown': [
          {'week': 1, 'spent': 2800.0, 'income': 3750.0},
          {'week': 2, 'spent': 3100.0, 'income': 3750.0},
          {'week': 3, 'spent': 2900.0, 'income': 3750.0},
          {'week': 4, 'spent': 3200.0, 'income': 3750.0},
        ],
        'anomalies': [
          {
            'date': DateTime(2024, 1, 15),
            'amount': 800.0,
            'category': '购物',
            'reason': '大型购物支出',
          },
        ],
        'trends': {
          'vsLastMonth': 8.5, // 8.5% increase in spending
          'savingRate': 20.0,
          'budgetCompliance': 85.0,
        },
      };

      // Mock comprehensive monthly health analysis
      final mockMonthlyHealth = MonthlyHealthScore(
        id: 'monthly_health_jan_2024',
        month: DateTime(2024, 1, 1),
        grade: LetterGrade.A,
        score: 92.0,
        diagnosis: '财务状况优秀，支出结构合理，储蓄目标达成。建议继续优化投资配置。',
        factors: [
          HealthFactor(
            name: '支出控制',
            value: 88.0,
            impact: FactorImpact.positive,
            category: '预算管理',
          ),
          HealthFactor(
            name: '储蓄效率',
            value: 95.0,
            impact: FactorImpact.positive,
            category: '储蓄投资',
          ),
          HealthFactor(
            name: '现金流稳定',
            value: 90.0,
            impact: FactorImpact.positive,
            category: '流动性',
          ),
          HealthFactor(
            name: '异常支出',
            value: 75.0,
            impact: FactorImpact.neutral,
            category: '支出管理',
          ),
        ],
        recommendations: [
          '继续保持20%的储蓄率，考虑增加投资额度',
          '关注1月15日的异常购物支出，建立更好的消费预警机制',
          '优化餐饮支出占比，从28%降至25%以内',
          '建立季度投资复盘机制，跟踪资产配置效果',
        ],
        metrics: {
          'survivalRatio': 36.0,
          'lifestyleRatio': 28.0,
          'savingsRatio': 12.0,
          'discretionaryRatio': 11.0,
          'debtToIncomeRatio': 0.0,
          'emergencyFundMonths': 6.0,
          'budgetVariance': -8.5,
          'spendingTrend': 2.1,
        },
      );

      when(mockAiService.analyzeMonthlyHealth(any))
          .thenAnswer((_) async => mockMonthlyHealth);

      // Act: Trigger monthly report generation
      final job = await insightService.triggerAnalysis(
        type: JobType.monthlyHealth,
        transactionId: 'monthly_report_jan_2024',
        metadata: monthlyData,
      );

      // Assert: Job should be created and processed
      expect(job.id, isNotEmpty);
      expect(job.type, JobType.monthlyHealth);
      expect(job.status, JobStatus.queued);

      // Wait for job completion
      final jobStream = insightService.watchJob(job.id);
      final completedJob = await jobStream.firstWhere(
        (job) => job.isCompleted || job.isFailed,
      );

      // Assert: Monthly report should be generated successfully
      expect(completedJob.isCompleted, true);
      expect(completedJob.result, isNotNull);

      // Verify comprehensive report content
      final report = completedJob.result!;

      // Executive Summary
      expect(report.contains('财务状况优秀'), true);
      expect(report.contains('92'), true); // Score
      expect(report.contains('A'), true); // Grade

      // Financial Structure Analysis
      expect(report.contains('生存支出'), true);
      expect(report.contains('36%'), true);
      expect(report.contains('生活支出'), true);
      expect(report.contains('28%'), true);
      expect(report.contains('储蓄投资'), true);
      expect(report.contains('12%'), true);

      // Key Metrics
      expect(report.contains('总收入'), true);
      expect(report.contains('¥15,000'), true);
      expect(report.contains('总支出'), true);
      expect(report.contains('¥12,000'), true);
      expect(report.contains('净储蓄'), true);
      expect(report.contains('¥3,000'), true);

      // Recommendations
      expect(report.contains('继续保持20%的储蓄率'), true);
      expect(report.contains('建立更好的消费预警机制'), true);
      expect(report.contains('优化餐饮支出占比'), true);

      verify(mockAiService.analyzeMonthlyHealth(any)).called(1);
    });

    test('should handle months with concerning financial health', () async {
      // Arrange: Create concerning monthly data (poor financial health)
      final concerningData = {
        'month': DateTime(2024, 2, 1),
        'totalIncome': 8000.0,
        'totalExpenses': 8500.0,
        'categories': {
          'survival': 6800.0, // 80% on survival needs
          'lifestyle': 1200.0, // 14% on lifestyle
          'savings': -500.0, // Negative savings (debt)
          'discretionary': 0.0,
        },
        'weeklyBreakdown': [
          {'week': 1, 'spent': 2200.0, 'income': 2000.0},
          {'week': 2, 'spent': 2100.0, 'income': 2000.0},
          {'week': 3, 'spent': 2300.0, 'income': 2000.0},
          {'week': 4, 'spent': 1900.0, 'income': 2000.0},
        ],
        'anomalies': [
          {
            'date': DateTime(2024, 2, 10),
            'amount': 1200.0,
            'category': '债务',
            'reason': '信用卡还款',
          },
        ],
        'trends': {
          'vsLastMonth': 25.0, // 25% spending increase
          'savingRate': -6.25, // Negative savings rate
          'budgetCompliance': 45.0, // Poor budget compliance
        },
      };

      // Mock concerning health analysis
      final concerningHealth = MonthlyHealthScore(
        id: 'monthly_health_feb_2024_concerning',
        month: DateTime(2024, 2, 1),
        grade: LetterGrade.D,
        score: 42.0,
        diagnosis: '财务状况堪忧，支出严重超预算，存在债务风险。需要立即采取纠正措施。',
        factors: [
          HealthFactor(
            name: '预算严重超支',
            value: 15.0,
            impact: FactorImpact.negative,
            category: '预算管理',
          ),
          HealthFactor(
            name: '债务负担',
            value: 20.0,
            impact: FactorImpact.negative,
            category: '负债管理',
          ),
          HealthFactor(
            name: '生存支出过高',
            value: 25.0,
            impact: FactorImpact.negative,
            category: '支出结构',
          ),
        ],
        recommendations: [
          '立即停止非必要支出，建立严格的预算限制',
          '制定债务清偿计划，优先处理高息债务',
          '寻求额外的收入来源以改善现金流',
          '咨询专业财务顾问获取个性化建议',
          '建立应急基金，避免进一步债务累积',
        ],
        metrics: {
          'survivalRatio': 80.0,
          'lifestyleRatio': 14.0,
          'savingsRatio': -6.25,
          'discretionaryRatio': 0.0,
          'debtToIncomeRatio': 12.5,
          'emergencyFundMonths': 0.0,
          'budgetVariance': 25.0,
          'spendingTrend': 15.2,
        },
      );

      when(mockAiService.analyzeMonthlyHealth(any))
          .thenAnswer((_) async => concerningHealth);

      // Act: Generate concerning monthly report
      final job = await insightService.triggerAnalysis(
        type: JobType.monthlyHealth,
        transactionId: 'monthly_report_feb_2024_concerning',
        metadata: concerningData,
      );

      final jobStream = insightService.watchJob(job.id);
      final completedJob = await jobStream.firstWhere(
        (job) => job.isCompleted || job.isFailed,
      );

      // Assert: Critical warnings should be included
      expect(completedJob.isCompleted, true);
      final report = completedJob.result!;

      // Critical health indicators
      expect(report.contains('财务状况堪忧'), true);
      expect(report.contains('42'), true); // Low score
      expect(report.contains('D'), true); // Poor grade

      // Negative factors highlighted
      expect(report.contains('预算严重超支'), true);
      expect(report.contains('债务负担'), true);
      expect(report.contains('生存支出过高'), true);

      // Urgent recommendations
      expect(report.contains('立即停止非必要支出'), true);
      expect(report.contains('寻求额外的收入来源'), true);
      expect(report.contains('咨询专业财务顾问'), true);

      // Negative metrics
      expect(report.contains('-¥500'), true); // Negative savings
      expect(report.contains('12.5%'), true); // Debt-to-income ratio
    });

    test('should generate trend analysis across multiple months', () async {
      // Test month-over-month comparison and trend identification

      final monthsData = [
        {
          'month': DateTime(2023, 12, 1),
          'totalIncome': 12000.0,
          'totalExpenses': 11000.0,
          'score': 75.0,
          'grade': 'C',
        },
        {
          'month': DateTime(2024, 1, 1),
          'totalIncome': 13000.0,
          'totalExpenses': 10500.0,
          'score': 82.0,
          'grade': 'B',
        },
        {
          'month': DateTime(2024, 2, 1),
          'totalIncome': 14000.0,
          'totalExpenses': 11200.0,
          'score': 78.0,
          'grade': 'C',
        },
      ];

      // Mock trend-aware analysis
      var analysisIndex = 0;
      when(mockAiService.analyzeMonthlyHealth(any)).thenAnswer((_) async {
        final monthData = monthsData[analysisIndex % monthsData.length];
        analysisIndex++;

        return MonthlyHealthScore(
          id: 'trend_analysis_${monthData['month'].toString()}',
          month: monthData['month'] as DateTime,
          grade: monthData['grade'] == 'A' ? LetterGrade.A :
                 monthData['grade'] == 'B' ? LetterGrade.B : LetterGrade.C,
          score: monthData['score'] as double,
          diagnosis: '趋势分析：财务状况逐步改善，但仍需关注支出控制。',
          factors: [
            HealthFactor(
              name: '收入增长',
              value: 85.0,
              impact: FactorImpact.positive,
              category: '收入管理',
            ),
            HealthFactor(
              name: '支出波动',
              value: 65.0,
              impact: FactorImpact.neutral,
              category: '支出管理',
            ),
          ],
          recommendations: [
            '继续提升收入来源的稳定性',
            '建立更精确的支出预测模型',
            '关注季节性消费模式变化',
          ],
          metrics: {
            'survivalRatio': 50.0,
            'lifestyleRatio': 30.0,
            'savingsRatio': 20.0,
            'discretionaryRatio': 10.0,
            'monthOverMonthGrowth': 8.5,
            'trendDirection': 1.0, // Positive trend
            'volatilityIndex': 12.3,
          },
        );
      });

      // Act: Generate reports for multiple months
      final jobs = <FluxLoopJob>[];
      for (var i = 0; i < monthsData.length; i++) {
        final job = await insightService.triggerAnalysis(
          type: JobType.monthlyHealth,
          transactionId: 'trend_month_${i + 1}',
          metadata: monthsData[i],
        );
        jobs.add(job);
      }

      // Wait for all reports to complete
      final completionFutures = jobs.map((job) async {
        final jobStream = insightService.watchJob(job.id);
        return await jobStream.firstWhere(
          (job) => job.isCompleted || job.isFailed,
        );
      });

      final completedJobs = await Future.wait(completionFutures);

      // Assert: All reports completed and show trend progression
      expect(completedJobs.length, 3);
      for (final job in completedJobs) {
        expect(job.isCompleted, true);
        expect(job.result, isNotNull);
      }

      // Verify trend analysis is included
      final firstReport = completedJobs[0].result!;
      final lastReport = completedJobs[2].result!;

      expect(firstReport.contains('趋势分析'), true);
      expect(lastReport.contains('趋势分析'), true);
      expect(lastReport.contains('财务状况逐步改善'), true);
    });

    test('should handle report generation failures gracefully', () async {
      // Arrange: AI service fails during monthly analysis
      when(mockAiService.analyzeMonthlyHealth(any))
          .thenThrow(Exception('Monthly health analysis service unavailable'));

      // Act: Attempt to generate monthly report
      final job = await insightService.triggerAnalysis(
        type: JobType.monthlyHealth,
        transactionId: 'monthly_report_failure_test',
        metadata: {'month': DateTime(2024, 3, 1)},
      );

      final jobStream = insightService.watchJob(job.id);
      final failedJob = await jobStream.firstWhere(
        (job) => job.isCompleted || job.isFailed,
      );

      // Assert: Failure is handled gracefully with appropriate error reporting
      expect(failedJob.isFailed, true);
      expect(failedJob.error, contains('Monthly health analysis service unavailable'));
      expect(failedJob.result, isNull);
    });

    test('should generate actionable insights for different financial profiles', () async {
      // Test reports for different financial archetypes

      final archetypes = [
        {
          'name': 'Budget Conscious Saver',
          'income': 18000.0,
          'expenses': 13500.0,
          'expectedGrade': LetterGrade.A,
          'expectedFocus': '储蓄优化',
        },
        {
          'name': 'Lifestyle Enthusiast',
          'income': 25000.0,
          'expenses': 22000.0,
          'expectedGrade': LetterGrade.B,
          'expectedFocus': '支出平衡',
        },
        {
          'name': 'Debt Management Focus',
          'income': 12000.0,
          'expenses': 14000.0,
          'expectedGrade': LetterGrade.D,
          'expectedFocus': '债务清偿',
        },
      ];

      for (final archetype in archetypes) {
        when(mockAiService.analyzeMonthlyHealth(any)).thenAnswer((_) async {
          final income = archetype['income'] as double;
          final expenses = archetype['expenses'] as double;
          final savings = income - expenses;
          final savingsRate = (savings / income) * 100;

          return MonthlyHealthScore(
            id: 'archetype_${archetype['name']}',
            month: DateTime(2024, 4, 1),
            grade: archetype['expectedGrade'] as LetterGrade,
            score: savingsRate > 20 ? 90.0 : savingsRate > 0 ? 70.0 : 40.0,
            diagnosis: '${archetype['name']}的财务分析报告',
            factors: [
              HealthFactor(
                name: archetype['expectedFocus'] as String,
                value: savingsRate > 20 ? 95.0 : savingsRate > 0 ? 75.0 : 45.0,
                impact: savingsRate > 20 ? FactorImpact.positive :
                       savingsRate > 0 ? FactorImpact.neutral : FactorImpact.negative,
                category: '个性化分析',
              ),
            ],
            recommendations: [
              '根据${archetype['name']}的消费模式定制建议',
              '重点关注${archetype['expectedFocus']}',
              '建立适合的财务目标和跟踪机制',
            ],
            metrics: {
              'survivalRatio': 45.0,
              'lifestyleRatio': 35.0,
              'savingsRatio': savingsRate,
              'personalizationScore': 85.0,
            },
          );
        });

        final job = await insightService.triggerAnalysis(
          type: JobType.monthlyHealth,
          transactionId: 'archetype_${archetype['name']}',
          metadata: {
            'archetype': archetype['name'],
            'totalIncome': archetype['income'],
            'totalExpenses': archetype['expenses'],
          },
        );

        final jobStream = insightService.watchJob(job.id);
        final completedJob = await jobStream.firstWhere(
          (job) => job.isCompleted || job.isFailed,
        );

        expect(completedJob.isCompleted, true);
        final report = completedJob.result!;

        // Verify archetype-specific insights
        expect(report.contains(archetype['name'] as String), true);
        expect(report.contains(archetype['expectedFocus'] as String), true);
        expect(report.contains('个性化分析'), true);
      }
    });

    test('should integrate with health analysis service for comprehensive assessment', () async {
      // Test integration between insight service and health analysis service

      final comprehensiveData = {
        'month': DateTime(2024, 5, 1),
        'transactions': [
          {'amount': 5000.0, 'category': '工资', 'type': 'income'},
          {'amount': 2000.0, 'category': '房租', 'type': 'expense'},
          {'amount': 1500.0, 'category': '餐饮', 'type': 'expense'},
          {'amount': 1000.0, 'category': '交通', 'type': 'expense'},
          {'amount': 800.0, 'category': '娱乐', 'type': 'expense'},
          {'amount': 3000.0, 'category': '储蓄', 'type': 'savings'},
        ],
        'goals': {
          'emergencyFund': 50000.0,
          'currentEmergencyFund': 15000.0,
          'monthlySavingsTarget': 4000.0,
        },
        'debts': [
          {'type': '信用卡', 'amount': 5000.0, 'interestRate': 0.18},
        ],
      };

      // Mock comprehensive analysis
      when(mockAiService.analyzeMonthlyHealth(any))
          .thenAnswer((_) async => MonthlyHealthScore(
            id: 'comprehensive_health_may_2024',
            month: DateTime(2024, 5, 1),
            grade: LetterGrade.B,
            score: 78.0,
            diagnosis: '综合财务健康评估：收入稳定，支出合理，储蓄目标基本达成。',
            factors: [
              HealthFactor(
                name: '收入稳定性',
                value: 92.0,
                impact: FactorImpact.positive,
                category: '收入分析',
              ),
              HealthFactor(
                name: '支出合理性',
                value: 78.0,
                impact: FactorImpact.neutral,
                category: '支出管理',
              ),
              HealthFactor(
                name: '储蓄目标达成',
                value: 75.0,
                impact: FactorImpact.neutral,
                category: '储蓄投资',
              ),
              HealthFactor(
                name: '债务管理',
                value: 65.0,
                impact: FactorImpact.neutral,
                category: '负债管理',
              ),
            ],
            recommendations: [
              '继续保持稳定的收入来源',
              '优化娱乐支出占比，从16%降至12%',
              '加速应急基金积累，目标6个月生活费',
              '关注信用卡债务，按时还款避免利息支出',
              '建立季度财务回顾机制',
            ],
            metrics: {
              'survivalRatio': 40.0,
              'lifestyleRatio': 30.0,
              'savingsRatio': 25.0,
              'discretionaryRatio': 5.0,
              'debtToIncomeRatio': 8.3,
              'emergencyFundCoverage': 3.0, // 3 months
              'budgetCompliance': 78.0,
              'goalAchievement': 85.0,
            },
          ));

      // Act: Generate comprehensive monthly report
      final job = await insightService.triggerAnalysis(
        type: JobType.monthlyHealth,
        transactionId: 'comprehensive_monthly_report',
        metadata: comprehensiveData,
      );

      final jobStream = insightService.watchJob(job.id);
      final completedJob = await jobStream.firstWhere(
        (job) => job.isCompleted || job.isFailed,
      );

      // Assert: Comprehensive report includes all aspects
      expect(completedJob.isCompleted, true);
      final report = completedJob.result!;

      // Verify comprehensive analysis coverage
      expect(report.contains('收入稳定性'), true);
      expect(report.contains('支出合理性'), true);
      expect(report.contains('储蓄目标达成'), true);
      expect(report.contains('债务管理'), true);

      // Verify goal tracking
      expect(report.contains('应急基金'), true);
      expect(report.contains('3.0'), true); // 3 months coverage

      // Verify actionable recommendations
      expect(report.contains('优化娱乐支出占比'), true);
      expect(report.contains('加速应急基金积累'), true);
      expect(report.contains('建立季度财务回顾机制'), true);
    });
  });
}
