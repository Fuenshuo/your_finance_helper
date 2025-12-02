import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Supported timeline scopes for the merged Stream experience.
enum FluxTimeframe {
  day,
  week,
  month,
}

/// Available panes rendered by the unified Stream + Insights surface.
enum FluxPane {
  timeline,
  insights,
}

/// Aggregates UI state shared between the Stream timeline and Insights panes.
class FluxViewState extends Equatable {
  const FluxViewState({
    required this.timeframe,
    required this.pane,
    required this.isFlagEnabled,
    this.lastDrawerUpdate,
  });

  factory FluxViewState.initial({
    bool isFlagEnabled = true,
  }) {
    return FluxViewState(
      timeframe: FluxTimeframe.day,
      pane: FluxPane.timeline,
      isFlagEnabled: isFlagEnabled,
      lastDrawerUpdate: null,
    );
  }

  final FluxTimeframe timeframe;
  final FluxPane pane;
  final bool isFlagEnabled;
  final DateTime? lastDrawerUpdate;

  FluxViewState copyWith({
    FluxTimeframe? timeframe,
    FluxPane? pane,
    bool? isFlagEnabled,
    DateTime? lastDrawerUpdate,
    bool clearDrawerTimestamp = false,
  }) {
    return FluxViewState(
      timeframe: timeframe ?? this.timeframe,
      pane: pane ?? this.pane,
      isFlagEnabled: isFlagEnabled ?? this.isFlagEnabled,
      lastDrawerUpdate: clearDrawerTimestamp
          ? null
          : (lastDrawerUpdate ?? this.lastDrawerUpdate),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'timeframe': timeframe.name,
      'pane': pane.name,
      'isFlagEnabled': isFlagEnabled,
      'lastDrawerUpdate': lastDrawerUpdate?.toIso8601String(),
    };
  }

  factory FluxViewState.fromJson(Map<String, dynamic> json) {
    return FluxViewState(
      timeframe: FluxTimeframe.values.firstWhere(
        (value) => value.name == json['timeframe'],
        orElse: () => FluxTimeframe.day,
      ),
      pane: FluxPane.values.firstWhere(
        (value) => value.name == json['pane'],
        orElse: () => FluxPane.timeline,
      ),
      isFlagEnabled: json['isFlagEnabled'] as bool? ?? false,
      lastDrawerUpdate: json['lastDrawerUpdate'] != null
          ? DateTime.tryParse(json['lastDrawerUpdate'] as String)
          : null,
    );
  }

  bool get isShowingInsights => pane == FluxPane.insights;

  @override
  List<Object?> get props => <Object?>[
        timeframe,
        pane,
        isFlagEnabled,
        lastDrawerUpdate,
      ];
}

/// Riverpod provider that exposes the current [FluxViewState].
final fluxViewStateProvider =
    StateNotifierProvider<FluxViewStateNotifier, FluxViewState>(
  (ref) => FluxViewStateNotifier(),
);

class FluxViewStateNotifier extends StateNotifier<FluxViewState> {
  FluxViewStateNotifier({FluxViewState? initialState})
      : super(initialState ?? FluxViewState.initial());

  void setTimeframe(FluxTimeframe timeframe) {
    if (state.timeframe == timeframe) {
      return;
    }
    state = state.copyWith(timeframe: timeframe);
  }

  void setPane(FluxPane pane) {
    if (!state.isFlagEnabled) {
      state = state.copyWith(pane: FluxPane.timeline);
      return;
    }
    if (pane == state.pane) {
      return;
    }
    state = state.copyWith(pane: pane);
  }

  void syncFlag({required bool isEnabled}) {
    if (state.isFlagEnabled == isEnabled) {
      return;
    }

    state = state.copyWith(
      isFlagEnabled: isEnabled,
      pane: isEnabled ? state.pane : FluxPane.timeline,
    );
  }

  void markDrawerUpdated(DateTime timestamp) {
    final DateTime? lastUpdate = state.lastDrawerUpdate;
    if (lastUpdate == null || timestamp.isAfter(lastUpdate)) {
      state = state.copyWith(lastDrawerUpdate: timestamp);
    }
  }

  void clearDrawerTimestamp() {
    if (state.lastDrawerUpdate == null) {
      return;
    }
    state = state.copyWith(clearDrawerTimestamp: true);
  }

  void reset({bool isFlagEnabled = false}) {
    state = FluxViewState.initial(isFlagEnabled: isFlagEnabled);
  }
}
