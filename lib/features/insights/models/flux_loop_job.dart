import 'package:equatable/equatable.dart';

/// Background AI analysis task tracking
class FluxLoopJob extends Equatable {
  const FluxLoopJob({
    required this.id,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.metadata,
    this.completedAt,
    this.result,
    this.error,
  });

  final String id;
  final JobType type;
  final JobStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? result; // JSON result data
  final String? error; // Error message if failed
  final Map<String, dynamic> metadata; // Job-specific data

  // Computed properties
  bool get isCompleted => status == JobStatus.completed;
  bool get isFailed => status == JobStatus.failed;
  bool get isInProgress => status == JobStatus.processing;
  Duration? get processingTime => completedAt?.difference(createdAt);

  FluxLoopJob copyWith({
    String? id,
    JobType? type,
    JobStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? result,
    String? error,
    Map<String, dynamic>? metadata,
  }) =>
      FluxLoopJob(
        id: id ?? this.id,
        type: type ?? this.type,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        completedAt: completedAt ?? this.completedAt,
        result: result ?? this.result,
        error: error ?? this.error,
        metadata: metadata ?? this.metadata,
      );

  @override
  List<Object?> get props => [
        id,
        type,
        status,
        createdAt,
        completedAt,
        result,
        error,
        metadata,
      ];
}

/// Types of background analysis jobs
enum JobType {
  dailyAnalysis, // Daily spending cap and micro-insights
  weeklyPatterns, // Weekly anomaly detection
  monthlyHealth, // Monthly financial health assessment
  microInsight, // On-demand micro-insight generation
}

/// Status of background job processing
enum JobStatus {
  queued, // Waiting to be processed
  processing, // Currently being analyzed
  completed, // Finished successfully
  failed, // Failed with error
}
