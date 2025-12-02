import 'package:equatable/equatable.dart';

/// Comprehensive financial health assessment
class MonthlyHealthScore extends Equatable {
  const MonthlyHealthScore({
    required this.id,
    required this.month,
    required this.grade,
    required this.score,
    required this.diagnosis,
    required this.factors,
    required this.recommendations,
    required this.metrics,
  });

  final String id;
  final DateTime month;
  final LetterGrade grade;
  final double score; // 0.0 - 100.0
  final String diagnosis; // AI health assessment
  final List<HealthFactor> factors; // Contributing elements
  final List<String> recommendations; // Actionable advice
  final Map<String, double> metrics; // Structured data points

  @override
  List<Object?> get props => [
        id,
        month,
        grade,
        score,
        diagnosis,
        factors,
        recommendations,
        metrics,
      ];
}

/// Letter grades for financial health
enum LetterGrade {
  A, // Excellent (90-100)
  B, // Good (80-89)
  C, // Fair (70-79)
  D, // Poor (60-69)
  F, // Critical (0-59)
}

/// Contributing factors to health score
class HealthFactor extends Equatable {
  const HealthFactor({
    required this.name,
    required this.impact, // -1.0 to 1.0
    required this.description,
  });

  final String name;
  final double impact;
  final String description;

  @override
  List<Object?> get props => [name, impact, description];
}

