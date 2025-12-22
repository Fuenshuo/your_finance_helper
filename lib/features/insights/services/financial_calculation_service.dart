import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_finance_flutter/core/utils/performance_monitor.dart';
import 'package:your_finance_flutter/features/insights/models/allocation_data.dart';
import 'package:your_finance_flutter/features/insights/models/budget_data.dart';
import 'package:your_finance_flutter/features/insights/models/health_score.dart';
import 'package:your_finance_flutter/features/insights/models/trend_data.dart';

/// Service class for financial calculations with error handling and performance monitoring.
class FinancialCalculationService {
  FinancialCalculationService();
  SharedPreferences? _prefs;

  static const String _trendDataKey = 'flux_insights_trend_data';
  static const String _allocationDataKey = 'flux_insights_allocation_data';

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Save trend data to SharedPreferences
  Future<void> saveTrendData(List<TrendData> trendData) async {
    await _initPrefs();
    try {
      final jsonList = trendData
          .map(
            (data) => {
              'date': data.date.toIso8601String(),
              'amount': data.amount,
              'dayLabel': data.dayLabel,
            },
          )
          .toList();
      final jsonString = jsonEncode(jsonList);
      await _prefs!.setString(_trendDataKey, jsonString);
    } catch (e) {
      print('[FinancialCalculationService] Error saving trend data: $e');
    }
  }

  /// Load trend data from SharedPreferences
  Future<List<TrendData>> loadTrendData() async {
    await _initPrefs();
    try {
      final jsonString = _prefs!.getString(_trendDataKey);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) {
        final map = json as Map<String, dynamic>;
        return TrendData(
          date: DateTime.parse(map['date'] as String),
          amount: (map['amount'] as num).toDouble(),
          dayLabel: map['dayLabel'] as String,
        );
      }).toList();
    } catch (e) {
      print('[FinancialCalculationService] Error loading trend data: $e');
      return [];
    }
  }

  /// Save allocation data to SharedPreferences
  Future<void> saveAllocationData(AllocationData allocationData) async {
    await _initPrefs();
    try {
      final jsonData = {
        'fixedAmount': allocationData.fixedAmount,
        'flexibleAmount': allocationData.flexibleAmount,
        'period': allocationData.period.toIso8601String(),
      };
      final jsonString = jsonEncode(jsonData);
      await _prefs!.setString(_allocationDataKey, jsonString);
    } catch (e) {
      print('[FinancialCalculationService] Error saving allocation data: $e');
    }
  }

  /// Load allocation data from SharedPreferences
  Future<AllocationData?> loadAllocationData() async {
    await _initPrefs();
    try {
      final jsonString = _prefs!.getString(_allocationDataKey);
      if (jsonString == null) return null;

      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      return AllocationData(
        fixedAmount: (jsonData['fixedAmount'] as num).toDouble(),
        flexibleAmount: (jsonData['flexibleAmount'] as num).toDouble(),
        period: DateTime.parse(jsonData['period'] as String),
      );
    } catch (e) {
      print('[FinancialCalculationService] Error loading allocation data: $e');
      return null;
    }
  }

  /// Calculate financial health score based on spending allocation data
  Future<HealthScore> calculateHealthScore(AllocationData data) async {
    PerformanceMonitor.startOperation(
      'FinancialCalculationService.calculateHealthScore',
    );
    try {
      if (!data.isValid) {
        PerformanceMonitor.logError(
          'Invalid allocation data: amounts cannot be negative',
          'FinancialCalculationService.calculateHealthScore',
        );
        throw ArgumentError(
          'Invalid allocation data: amounts cannot be negative',
        );
      }

      final healthScore = HealthScore.calculate(data);
      PerformanceMonitor.endOperation(
        'FinancialCalculationService.calculateHealthScore',
      );

      return healthScore;
    } catch (e) {
      PerformanceMonitor.logError(
        e.toString(),
        'FinancialCalculationService.calculateHealthScore',
      );
      rethrow;
    }
  }

  /// Calculate budget progress
  Future<Map<String, dynamic>> calculateBudgetProgress(BudgetData data) async {
    final startTime = DateTime.now();
    try {
      if (!data.isValid) {
        throw ArgumentError('Invalid budget data: amounts cannot be negative');
      }

      final result = {
        'remainingAmount': data.remainingAmount,
        'progressRatio': data.progressRatio,
        'isOverspent': data.isOverspent,
      };

      final duration = DateTime.now().difference(startTime);
      print(
        '[FinancialCalculationService.calculateBudgetProgress] ⏱️ 执行时间: ${duration.inMilliseconds}ms',
      );

      return result;
    } catch (e) {
      print('[FinancialCalculationService.calculateBudgetProgress] ❌ 错误: $e');
      rethrow;
    }
  }

  /// Validate and normalize trend data for chart display
  Future<List<TrendData>> validateTrendData(List<TrendData> data) async {
    final startTime = DateTime.now();
    try {
      final validatedData = data.where((item) => item.isValid).toList();

      // Sort by date
      validatedData.sort((a, b) => a.date.compareTo(b.date));

      // Limit to recent data for performance
      if (validatedData.length > 7) {
        validatedData.removeRange(0, validatedData.length - 7);
      }

      final duration = DateTime.now().difference(startTime);
      print(
        '[FinancialCalculationService.validateTrendData] ⏱️ 执行时间: ${duration.inMilliseconds}ms',
      );

      return validatedData;
    } catch (e) {
      print('[FinancialCalculationService.validateTrendData] ❌ 错误: $e');
      rethrow;
    }
  }
}
