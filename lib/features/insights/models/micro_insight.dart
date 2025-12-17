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

  /// 从JSON反序列化
  factory MicroInsight.fromJson(Map<String, dynamic> json) => MicroInsight(
        id: json['id'] as String,
        dailyCapId: json['dailyCapId'] as String,
        generatedAt: DateTime.parse(json['generatedAt'] as String),
        sentiment: Sentiment.values.firstWhere(
          (e) => e.name == json['sentiment'],
          orElse: () => Sentiment.neutral,
        ),
        message: json['message'] as String,
        actions: (json['actions'] as List).cast<String>(),
        trigger: InsightTrigger.values.firstWhere(
          (e) => e.name == json['trigger'],
          orElse: () => InsightTrigger.transactionAdded,
        ),
      );

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
  }) =>
      MicroInsight(
        id: id ?? this.id,
        dailyCapId: dailyCapId ?? this.dailyCapId,
        generatedAt: generatedAt ?? this.generatedAt,
        sentiment: sentiment ?? this.sentiment,
        message: message ?? this.message,
        actions: actions ?? this.actions,
        trigger: trigger ?? this.trigger,
      );

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

  /// 序列化为JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'dailyCapId': dailyCapId,
        'generatedAt': generatedAt.toIso8601String(),
        'sentiment': sentiment.name,
        'message': message,
        'actions': actions,
        'trigger': trigger.name,
      };
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
