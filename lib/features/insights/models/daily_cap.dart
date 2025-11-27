import 'package:equatable/equatable.dart';
import 'package:your_finance_flutter/features/insights/models/micro_insight.dart';

/// Represents daily spending limit tracking with AI-powered insights
class DailyCap extends Equatable {
  const DailyCap({
    required this.id,
    required this.date,
    required this.referenceAmount,
    required this.currentSpending,
    required this.percentage,
    required this.status,
    this.latestInsight,
  });

  final String id;
  final DateTime date;
  final double referenceAmount; // Calculated daily budget
  final double currentSpending; // Actual spending today
  final double percentage; // 0.0 - 1.0 (actual/cap)
  final CapStatus status;
  final MicroInsight? latestInsight;

  // Business logic
  double get remainingAmount => referenceAmount - currentSpending;
  bool get isOverBudget => currentSpending > referenceAmount;

  DailyCap copyWith({
    String? id,
    DateTime? date,
    double? referenceAmount,
    double? currentSpending,
    double? percentage,
    CapStatus? status,
    MicroInsight? latestInsight,
  }) {
    return DailyCap(
      id: id ?? this.id,
      date: date ?? this.date,
      referenceAmount: referenceAmount ?? this.referenceAmount,
      currentSpending: currentSpending ?? this.currentSpending,
      percentage: percentage ?? this.percentage,
      status: status ?? this.status,
      latestInsight: latestInsight ?? this.latestInsight,
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        referenceAmount,
        currentSpending,
        percentage,
        status,
        latestInsight,
      ];
}

/// Status of daily spending cap
enum CapStatus {
  safe, // < 50%
  warning, // > 80%
  danger, // > 100%
}
