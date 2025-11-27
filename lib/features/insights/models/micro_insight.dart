import 'package:equatable/equatable.dart';

/// AI-generated short feedback on spending behavior
class MicroInsight extends Equatable {
  const MicroInsight({
    required this.id,
    required this.dailyCapId,
    required this.generatedAt,
    required this.sentiment,
    required this.message,
    required this.actions,
    required this.trigger,
  });

  final String id;
  final String dailyCapId;
  final DateTime generatedAt;
  final Sentiment sentiment;
  final String message;
  final List<String> actions;
  final InsightTrigger trigger;

  // Business logic
  bool get isPositive => sentiment == Sentiment.positive;
  bool get requiresAction => actions.isNotEmpty;

  MicroInsight copyWith({
    String? id,
    String? dailyCapId,
    DateTime? generatedAt,
    Sentiment? sentiment,
    String? message,
    List<String>? actions,
    InsightTrigger? trigger,
  }) {
    return MicroInsight(
      id: id ?? this.id,
      dailyCapId: dailyCapId ?? this.dailyCapId,
      generatedAt: generatedAt ?? this.generatedAt,
      sentiment: sentiment ?? this.sentiment,
      message: message ?? this.message,
      actions: actions ?? this.actions,
      trigger: trigger ?? this.trigger,
    );
  }

  @override
  List<Object?> get props => [
        id,
        dailyCapId,
        generatedAt,
        sentiment,
        message,
        actions,
        trigger,
      ];
}

/// Sentiment type for AI insights
enum Sentiment {
  positive,
  neutral,
  negative,
}

/// What triggered the insight generation
enum InsightTrigger {
  transactionAdded,
  budgetExceeded,
  timeCheck,
  manualRequest,
}
