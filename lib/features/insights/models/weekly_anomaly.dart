import 'package:equatable/equatable.dart';

/// Detected abnormal spending patterns with explanations
class WeeklyAnomaly extends Equatable {
  const WeeklyAnomaly({
    required this.id,
    required this.weekStart,
    required this.anomalyDate,
    required this.expectedAmount,
    required this.actualAmount,
    required this.deviation,
    required this.reason,
    required this.severity,
    required this.categories,
  });

  final String id;
  final DateTime weekStart;
  final DateTime anomalyDate;
  final double expectedAmount;
  final double actualAmount;
  final double deviation; // percentage difference
  final String reason; // AI-generated explanation
  final AnomalySeverity severity;
  final List<String> categories; // affected spending categories

  WeeklyAnomaly copyWith({
    String? id,
    DateTime? weekStart,
    DateTime? anomalyDate,
    double? expectedAmount,
    double? actualAmount,
    double? deviation,
    String? reason,
    AnomalySeverity? severity,
    List<String>? categories,
  }) {
    return WeeklyAnomaly(
      id: id ?? this.id,
      weekStart: weekStart ?? this.weekStart,
      anomalyDate: anomalyDate ?? this.anomalyDate,
      expectedAmount: expectedAmount ?? this.expectedAmount,
      actualAmount: actualAmount ?? this.actualAmount,
      deviation: deviation ?? this.deviation,
      reason: reason ?? this.reason,
      severity: severity ?? this.severity,
      categories: categories ?? this.categories,
    );
  }

  @override
  List<Object?> get props => [
        id,
        weekStart,
        anomalyDate,
        expectedAmount,
        actualAmount,
        deviation,
        reason,
        severity,
        categories,
      ];
}

/// Severity levels for spending anomalies
enum AnomalySeverity {
  low, // 15-25% deviation
  medium, // 25-50% deviation
  high, // >50% deviation
}
