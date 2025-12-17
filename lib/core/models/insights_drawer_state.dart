import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_finance_flutter/core/models/flux_view_state.dart';
import 'package:your_finance_flutter/core/providers/flux_providers.dart';
import 'package:your_finance_flutter/core/utils/performance_monitor.dart';

const Duration _defaultCollapseDuration = Duration(seconds: 3);

/// Represents the inline Insights drawer UI state.
class InsightsDrawerState extends Equatable {
  const InsightsDrawerState({
    required this.isVisible,
    required this.isExpanded,
    required this.message,
    required this.improvementCount,
    required this.collapseTimer,
  }) : assert(improvementCount >= 0, 'improvementCount cannot be negative');

  factory InsightsDrawerState.hidden() {
    return const InsightsDrawerState(
      isVisible: false,
      isExpanded: false,
      message: null,
      improvementCount: 0,
      collapseTimer: _defaultCollapseDuration,
    );
  }

  final bool isVisible;
  final bool isExpanded;
  final String? message;
  final int improvementCount;
  final Duration collapseTimer;

  InsightsDrawerState copyWith({
    bool? isVisible,
    bool? isExpanded,
    String? message,
    bool clearMessage = false,
    int? improvementCount,
    Duration? collapseTimer,
  }) {
    final bool resolvedVisibility = isVisible ?? this.isVisible;
    return InsightsDrawerState(
      isVisible: resolvedVisibility,
      isExpanded: resolvedVisibility ? (isExpanded ?? this.isExpanded) : false,
      message: clearMessage ? null : (message ?? this.message),
      improvementCount: improvementCount ?? this.improvementCount,
      collapseTimer: collapseTimer ?? this.collapseTimer,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'isVisible': isVisible,
      'isExpanded': isExpanded,
      'message': message,
      'improvementCount': improvementCount,
      'collapseTimer': collapseTimer.inMilliseconds,
    };
  }

  factory InsightsDrawerState.fromJson(Map<String, dynamic> json) {
    return InsightsDrawerState(
      isVisible: json['isVisible'] as bool? ?? false,
      isExpanded: json['isExpanded'] as bool? ?? false,
      message: json['message'] as String?,
      improvementCount:
          (json['improvementCount'] as int?)?.clamp(0, 1 << 31) ?? 0,
      collapseTimer: Duration(
        milliseconds: json['collapseTimer'] as int? ??
            _defaultCollapseDuration.inMilliseconds,
      ),
    );
  }

  bool get hasMessage => (message ?? '').isNotEmpty;

  @override
  List<Object?> get props => <Object?>[
        isVisible,
        isExpanded,
        message,
        improvementCount,
        collapseTimer,
      ];
}

/// Riverpod provider for the drawer controller.
final insightsDrawerControllerProvider =
    StateNotifierProvider<InsightsDrawerController, InsightsDrawerState>(
  (ref) => InsightsDrawerController(ref: ref),
);

/// Controls drawer visibility, timers, and aggregation of incoming analysis results.
class InsightsDrawerController extends StateNotifier<InsightsDrawerState> {
  InsightsDrawerController({Ref? ref})
      : _ref = ref,
        super(InsightsDrawerState.hidden());

  Timer? _collapseTimer;
  Timer? _deferredExpansionTimer;
  final Ref? _ref;

  void handleAnalysisSummary({
    required String summaryText,
    int improvementDelta = 1,
    Duration? collapseAfter,
    Duration? deferExpansionBy,
  }) {
    final int safeDelta = improvementDelta < 0 ? 0 : improvementDelta;
    final bool shouldDefer =
        deferExpansionBy != null && deferExpansionBy > Duration.zero;

    _cancelTimers();
    state = state.copyWith(
      isVisible: true,
      isExpanded: !shouldDefer,
      message: summaryText,
      improvementCount:
          (state.isVisible ? state.improvementCount : 0) + safeDelta,
      collapseTimer: collapseAfter ?? _defaultCollapseDuration,
    );

    if (shouldDefer) {
      _deferredExpansionTimer = Timer(deferExpansionBy, () {
        state = state.copyWith(isExpanded: true);
        _logDrawerTelemetry(
          expanded: true,
          reason: 'analysis_deferred_expand',
        );
        _startCollapseTimer(state.collapseTimer);
      });
    } else {
      _startCollapseTimer(state.collapseTimer);
      _logDrawerTelemetry(
        expanded: true,
        reason: 'analysis_summary',
      );
    }
  }

  void pulseVisibility({
    required Duration visibleFor,
    bool resetCounter = true,
  }) {
    _cancelTimers();
    state = state.copyWith(
      isVisible: true,
      isExpanded: false,
      improvementCount: resetCounter ? 0 : state.improvementCount,
      collapseTimer: visibleFor,
      clearMessage: true,
    );
    _startCollapseTimer(visibleFor);
    _logDrawerTelemetry(expanded: false, reason: 'pulse_visibility');
  }

  void incrementCounter({int delta = 1}) {
    if (delta <= 0) {
      return;
    }
    state = state.copyWith(improvementCount: state.improvementCount + delta);
  }

  void collapseNow({String reason = 'auto_collapse'}) {
    _cancelTimers();
    final wasVisible = state.isVisible;
    state = InsightsDrawerState.hidden();
    if (wasVisible) {
      _logDrawerTelemetry(expanded: false, reason: reason);
    }
  }

  void setExpanded(bool expanded) {
    if (!state.isVisible || state.isExpanded == expanded) {
      return;
    }
    state = state.copyWith(isExpanded: expanded);
    if (expanded) {
      _startCollapseTimer(state.collapseTimer);
    }
    _logDrawerTelemetry(
      expanded: expanded,
      reason: expanded ? 'manual_expand' : 'manual_minimize',
    );
  }

  void _startCollapseTimer(Duration duration) {
    _collapseTimer = Timer(duration, () {
      collapseNow();
    });
  }

  void _cancelTimers() {
    _collapseTimer?.cancel();
    _collapseTimer = null;
    _deferredExpansionTimer?.cancel();
    _deferredExpansionTimer = null;
  }

  void _logDrawerTelemetry({
    required bool expanded,
    required String reason,
  }) {
    final ref = _ref;
    if (ref == null) {
      return;
    }
    final viewState = ref.read(fluxViewStateProvider);
    final flagEnabled = ref.read(streamInsightsFlagStateProvider).isEnabled;
    PerformanceMonitor.logDrawerTelemetry(
      expanded: expanded,
      pane: viewState.pane,
      timeframe: viewState.timeframe,
      flagEnabled: flagEnabled,
      metadata: <String, Object?>{'reason': reason},
    );
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}
