import 'package:equatable/equatable.dart';
import 'allocation_data.dart';

/// Represents calculated financial health score with grading.
enum HealthGrade { A, B, C, D, F }

class HealthScore extends Equatable {
  final double score; // Calculated score (0-100)
  final HealthGrade grade; // Letter grade
  final DateTime calculatedAt; // Calculation timestamp

  const HealthScore._({
    required this.score,
    required this.grade,
    required this.calculatedAt,
  });

  // Factory constructor for calculation
  factory HealthScore.calculate(AllocationData allocation) {
    final flexibleRatio = allocation.flexibleRatio;
    final rawScore = 100.0 - (flexibleRatio * 100.0);
    final clampedScore = rawScore.clamp(0.0, 100.0);

    final grade = _calculateGrade(clampedScore);

    return HealthScore._(
      score: clampedScore,
      grade: grade,
      calculatedAt: DateTime.now(),
    );
  }

  static HealthGrade _calculateGrade(double score) {
    if (score >= 90) return HealthGrade.A;
    if (score >= 80) return HealthGrade.B;
    if (score >= 70) return HealthGrade.C;
    if (score >= 60) return HealthGrade.D;
    return HealthGrade.F;
  }

  // Validation
  bool get isValid => score >= 0 && score <= 100;

  @override
  List<Object?> get props => [score, grade, calculatedAt];
}
