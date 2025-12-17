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

  /// 从JSON反序列化
  factory WeeklyAnomaly.fromJson(Map<String, dynamic> json) => WeeklyAnomaly(
        id: json['id'] as String,
        weekStart: DateTime.parse(json['weekStart'] as String),
        anomalyDate: DateTime.parse(json['anomalyDate'] as String),
        expectedAmount: (json['expectedAmount'] as num).toDouble(),
        actualAmount: (json['actualAmount'] as num).toDouble(),
        deviation: (json['deviation'] as num).toDouble(),
        reason: json['reason'] as String,
        severity: AnomalySeverity.values.firstWhere(
          (e) => e.name == json['severity'],
          orElse: () => AnomalySeverity.medium,
        ),
        categories: (json['categories'] as List).cast<String>(),
      );

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
  }) =>
      WeeklyAnomaly(
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

  /// 序列化为JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'weekStart': weekStart.toIso8601String(),
        'anomalyDate': anomalyDate.toIso8601String(),
        'expectedAmount': expectedAmount,
        'actualAmount': actualAmount,
        'deviation': deviation,
        'reason': reason,
        'severity': severity.name,
        'categories': categories,
      };
}

/// Severity levels for spending anomalies
enum AnomalySeverity {
  low, // 15-25% deviation
  medium, // 25-50% deviation
  high, // >50% deviation
}
