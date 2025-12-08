import 'package:equatable/equatable.dart';

/// Survival vs Lifestyle spending analysis model
class SurvivalLifestyleAnalysis extends Equatable {
  const SurvivalLifestyleAnalysis({
    required this.id,
    required this.month,
    required this.survivalExpenses,
    required this.lifestyleExpenses,
    required this.survivalRatio,
    required this.lifestyleRatio,
    required this.benchmarkComparison,
    required this.recommendations,
    required this.trendAnalysis,
  });

  final String id;
  final DateTime month;
  final double survivalExpenses; // Essential expenses (rent, utilities, groceries)
  final double lifestyleExpenses; // Discretionary expenses (dining, entertainment, shopping)
  final double survivalRatio; // Percentage of survival expenses
  final double lifestyleRatio; // Percentage of lifestyle expenses
  final Map<String, double> benchmarkComparison; // Comparison with industry benchmarks
  final List<String> recommendations; // Actionable advice
  final Map<String, dynamic> trendAnalysis; // Trend data over time

  /// Calculate total expenses
  double get totalExpenses => survivalExpenses + lifestyleExpenses;

  /// Calculate balance score (optimal ratio around 60/40)
  double get balanceScore {
    const optimalSurvivalRatio = 60.0;
    const optimalLifestyleRatio = 40.0;

    final survivalDeviation = (survivalRatio - optimalSurvivalRatio).abs();
    final lifestyleDeviation = (lifestyleRatio - optimalLifestyleRatio).abs();

    // Perfect balance = 100, maximum deviation = 0
    return 100.0 - (survivalDeviation + lifestyleDeviation) / 2;
  }

  /// Get spending category assessment
  String get spendingAssessment {
    if (survivalRatio > 80) {
      return '生存压力大，建议优化支出结构';
    } else if (lifestyleRatio > 60) {
      return '生活支出过高，建议控制非必要消费';
    } else if (balanceScore > 80) {
      return '支出结构合理，保持良好习惯';
    } else {
      return '支出结构一般，有优化空间';
    }
  }

  SurvivalLifestyleAnalysis copyWith({
    String? id,
    DateTime? month,
    double? survivalExpenses,
    double? lifestyleExpenses,
    double? survivalRatio,
    double? lifestyleRatio,
    Map<String, double>? benchmarkComparison,
    List<String>? recommendations,
    Map<String, dynamic>? trendAnalysis,
  }) {
    return SurvivalLifestyleAnalysis(
      id: id ?? this.id,
      month: month ?? this.month,
      survivalExpenses: survivalExpenses ?? this.survivalExpenses,
      lifestyleExpenses: lifestyleExpenses ?? this.lifestyleExpenses,
      survivalRatio: survivalRatio ?? this.survivalRatio,
      lifestyleRatio: lifestyleRatio ?? this.lifestyleRatio,
      benchmarkComparison: benchmarkComparison ?? this.benchmarkComparison,
      recommendations: recommendations ?? this.recommendations,
      trendAnalysis: trendAnalysis ?? this.trendAnalysis,
    );
  }

  @override
  List<Object?> get props => [
        id,
        month,
        survivalExpenses,
        lifestyleExpenses,
        survivalRatio,
        lifestyleRatio,
        benchmarkComparison,
        recommendations,
        trendAnalysis,
      ];
}

/// Spending category classification
enum SpendingCategory {
  survival('生存必需'),
  lifestyle('生活品质'),
  savings('储蓄投资'),
  discretionary('可选择');

  const SpendingCategory(this.displayName);
  final String displayName;
}

/// Category mapping for transactions
const categoryMapping = {
  // Survival categories
  'housing': SpendingCategory.survival,
  'utilities': SpendingCategory.survival,
  'groceries': SpendingCategory.survival,
  'transportation': SpendingCategory.survival,
  'insurance': SpendingCategory.survival,
  'healthcare': SpendingCategory.survival,

  // Lifestyle categories
  'dining': SpendingCategory.lifestyle,
  'entertainment': SpendingCategory.lifestyle,
  'shopping': SpendingCategory.lifestyle,
  'fitness': SpendingCategory.lifestyle,
  'education': SpendingCategory.lifestyle,

  // Discretionary categories
  'travel': SpendingCategory.discretionary,
  'hobbies': SpendingCategory.discretionary,
  'gifts': SpendingCategory.discretionary,

  // Savings categories
  'savings': SpendingCategory.savings,
  'investments': SpendingCategory.savings,
};
