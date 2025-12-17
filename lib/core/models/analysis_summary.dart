import 'package:equatable/equatable.dart';

import 'package:your_finance_flutter/core/models/flux_view_state.dart';

/// Shared summary produced by the Insights analysis endpoint.
class AnalysisSummary extends Equatable {
  const AnalysisSummary({
    required this.analysisId,
    required this.generatedAt,
    required this.improvementsFound,
    required this.topRecommendation,
    this.deepLink,
    this.score = 0, // Analysis confidence score (0-100)
  });

  factory AnalysisSummary.fromJson(Map<String, dynamic> json) =>
      AnalysisSummary(
        analysisId: json['analysisId'] as String? ??
            'local-analysis-${DateTime.now().millisecondsSinceEpoch}',
        generatedAt: json['generatedAt'] != null
            ? DateTime.parse(json['generatedAt'] as String)
            : DateTime.now(),
        improvementsFound: json['improvementsFound'] as int? ?? 0,
        topRecommendation: json['topRecommendation'] as String? ?? '',
        deepLink: json['deepLink'] != null
            ? Uri.tryParse(json['deepLink'] as String)
            : null,
        score: json['score'] as int? ?? 0,
      );

  /// Creates an empty AnalysisSummary for error cases
  factory AnalysisSummary.empty() => AnalysisSummary(
        analysisId: 'empty-analysis-${DateTime.now().millisecondsSinceEpoch}',
        generatedAt: DateTime.now(),
        improvementsFound: 0,
        topRecommendation: '',
      );

  final String analysisId;
  final DateTime generatedAt;
  final int improvementsFound;
  final String topRecommendation;
  final Uri? deepLink;
  final int score;

  AnalysisSummary copyWith({
    String? analysisId,
    DateTime? generatedAt,
    int? improvementsFound,
    String? topRecommendation,
    Uri? deepLink,
    int? score,
  }) =>
      AnalysisSummary(
        analysisId: analysisId ?? this.analysisId,
        generatedAt: generatedAt ?? this.generatedAt,
        improvementsFound: improvementsFound ?? this.improvementsFound,
        topRecommendation: topRecommendation ?? this.topRecommendation,
        deepLink: deepLink ?? this.deepLink,
        score: score ?? this.score,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'analysisId': analysisId,
        'generatedAt': generatedAt.toIso8601String(),
        'improvementsFound': improvementsFound,
        'topRecommendation': topRecommendation,
        'deepLink': deepLink?.toString(),
      };

  bool get hasDeepLink => deepLink != null;

  @override
  List<Object?> get props => <Object?>[
        analysisId,
        generatedAt,
        improvementsFound,
        topRecommendation,
        deepLink,
      ];
}

enum StreamInsightsTelemetryEventType {
  viewToggled('view_toggled'),
  drawerOpen('drawer_open'),
  drawerCollapse('drawer_collapse'),
  analysisSummary('analysis_summary'),
  flagChanged('flag_state'),
  flagExposure('flag_variant_exposed'),
  bottomTabSelect('bottom_tab_select'),
  usageReduction('insights_usage_reduction');

  const StreamInsightsTelemetryEventType(this.value);
  final String value;

  static StreamInsightsTelemetryEventType fromValue(String? value) =>
      StreamInsightsTelemetryEventType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => StreamInsightsTelemetryEventType.viewToggled,
      );
}

/// Telemetry payload describing Stream/Insights interactions.
class StreamInsightsTelemetryEvent extends Equatable {
  const StreamInsightsTelemetryEvent({
    required this.type,
    required this.pane,
    required this.timeframe,
    required this.flagEnabled,
    required this.metadata,
    required this.occurredAt,
  });

  factory StreamInsightsTelemetryEvent.viewToggle({
    required FluxPane pane,
    required FluxTimeframe timeframe,
    required bool flagEnabled,
    Map<String, Object?> metadata = const <String, Object?>{},
    DateTime? occurredAt,
  }) =>
      StreamInsightsTelemetryEvent(
        type: StreamInsightsTelemetryEventType.viewToggled,
        pane: pane,
        timeframe: timeframe,
        flagEnabled: flagEnabled,
        metadata: metadata,
        occurredAt: occurredAt ?? DateTime.now(),
      );

  factory StreamInsightsTelemetryEvent.drawer({
    required bool expanded,
    required FluxPane pane,
    required FluxTimeframe timeframe,
    required bool flagEnabled,
    Map<String, Object?> metadata = const <String, Object?>{},
    DateTime? occurredAt,
  }) =>
      StreamInsightsTelemetryEvent(
        type: expanded
            ? StreamInsightsTelemetryEventType.drawerOpen
            : StreamInsightsTelemetryEventType.drawerCollapse,
        pane: pane,
        timeframe: timeframe,
        flagEnabled: flagEnabled,
        metadata: metadata,
        occurredAt: occurredAt ?? DateTime.now(),
      );

  factory StreamInsightsTelemetryEvent.analysis({
    required AnalysisSummary summary,
    required FluxPane pane,
    required FluxTimeframe timeframe,
    required bool flagEnabled,
    DateTime? occurredAt,
  }) =>
      StreamInsightsTelemetryEvent(
        type: StreamInsightsTelemetryEventType.analysisSummary,
        pane: pane,
        timeframe: timeframe,
        flagEnabled: flagEnabled,
        metadata: <String, Object?>{
          'analysisId': summary.analysisId,
          'improvementsFound': summary.improvementsFound,
          'hasDeepLink': summary.hasDeepLink,
        },
        occurredAt: occurredAt ?? summary.generatedAt,
      );

  factory StreamInsightsTelemetryEvent.flag({
    required bool flagEnabled,
    required FluxPane pane,
    required FluxTimeframe timeframe,
    DateTime? occurredAt,
  }) =>
      StreamInsightsTelemetryEvent(
        type: StreamInsightsTelemetryEventType.flagChanged,
        pane: pane,
        timeframe: timeframe,
        flagEnabled: flagEnabled,
        metadata: const <String, Object?>{},
        occurredAt: occurredAt ?? DateTime.now(),
      );

  factory StreamInsightsTelemetryEvent.flagExposure({
    required bool flagEnabled,
    DateTime? occurredAt,
  }) =>
      StreamInsightsTelemetryEvent(
        type: StreamInsightsTelemetryEventType.flagExposure,
        pane: FluxPane.timeline,
        timeframe: FluxTimeframe.day,
        flagEnabled: flagEnabled,
        metadata: <String, Object?>{
          'variant': flagEnabled ? 'merged' : 'legacy',
        },
        occurredAt: occurredAt ?? DateTime.now(),
      );

  factory StreamInsightsTelemetryEvent.bottomTabSelection({
    required int index,
    required bool flagEnabled,
    required String label,
    Map<String, Object?> metadata = const <String, Object?>{},
    DateTime? occurredAt,
  }) =>
      StreamInsightsTelemetryEvent(
        type: StreamInsightsTelemetryEventType.bottomTabSelect,
        pane: FluxPane.timeline,
        timeframe: FluxTimeframe.day,
        flagEnabled: flagEnabled,
        metadata: <String, Object?>{
          'index': index,
          'label': label,
          ...metadata,
        },
        occurredAt: occurredAt ?? DateTime.now(),
      );

  factory StreamInsightsTelemetryEvent.usageReduction({
    required int legacySelections,
    required int mergedSelections,
    required double reductionRatio,
    DateTime? occurredAt,
  }) =>
      StreamInsightsTelemetryEvent(
        type: StreamInsightsTelemetryEventType.usageReduction,
        pane: FluxPane.timeline,
        timeframe: FluxTimeframe.day,
        flagEnabled: true,
        metadata: <String, Object?>{
          'legacySelections': legacySelections,
          'mergedSelections': mergedSelections,
          'reductionRatio': double.parse(reductionRatio.toStringAsFixed(4)),
        },
        occurredAt: occurredAt ?? DateTime.now(),
      );

  factory StreamInsightsTelemetryEvent.fromJson(Map<String, dynamic> json) =>
      StreamInsightsTelemetryEvent(
        type: StreamInsightsTelemetryEventType.fromValue(
          json['eventType'] as String?,
        ),
        pane: FluxPane.values.firstWhere(
          (pane) => pane.name == json['pane'],
          orElse: () => FluxPane.timeline,
        ),
        timeframe: FluxTimeframe.values.firstWhere(
          (value) => value.name == json['timeframe'],
          orElse: () => FluxTimeframe.day,
        ),
        flagEnabled: json['flagEnabled'] as bool? ?? false,
        metadata: Map<String, Object?>.from(
          json['metadata'] as Map? ?? <String, Object?>{},
        ),
        occurredAt: DateTime.parse(json['occurredAt'] as String),
      );

  final StreamInsightsTelemetryEventType type;
  final FluxPane pane;
  final FluxTimeframe timeframe;
  final bool flagEnabled;
  final Map<String, Object?> metadata;
  final DateTime occurredAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'eventType': type.value,
        'pane': pane.name,
        'timeframe': timeframe.name,
        'flagEnabled': flagEnabled,
        'metadata': metadata,
        'occurredAt': occurredAt.toIso8601String(),
      };

  @override
  List<Object?> get props => <Object?>[
        type,
        pane,
        timeframe,
        flagEnabled,
        metadata,
        occurredAt,
      ];
}
