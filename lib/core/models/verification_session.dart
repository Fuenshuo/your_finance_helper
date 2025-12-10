/// Verification Session - Groups verification results from a single verification run
///
/// Manages a collection of verification results from a complete verification
/// session, providing aggregate statistics and session-level status.

import 'verification_result.dart';

class VerificationSession {
  final String sessionId;
  final DateTime startTime;
  DateTime? endTime;
  final List<VerificationResult> _results = [];

  VerificationSession({
    required this.sessionId,
    DateTime? startTime,
  }) : startTime = startTime ?? DateTime.now();

  /// Add a verification result to this session
  void addResult(VerificationResult result) {
    _results.add(result);
  }

  /// Get all verification results
  List<VerificationResult> get results => List.unmodifiable(_results);

  /// Get total number of checks performed
  int get totalChecks => _results.length;

  /// Get number of passed checks
  int get passedChecks => _results.where((r) => r.status == VerificationStatus.pass).length;

  /// Get number of failed checks
  int get failedChecks => _results.where((r) => r.status == VerificationStatus.fail).length;

  /// Get number of warning checks
  int get warningChecks => _results.where((r) => r.status == VerificationStatus.warning).length;

  /// Get overall session status
  VerificationStatus get overallStatus {
    if (failedChecks > 0) return VerificationStatus.fail;
    if (warningChecks > 0) return VerificationStatus.warning;
    if (passedChecks > 0) return VerificationStatus.pass;
    return VerificationStatus.pending;
  }

  /// Check if session is completed
  bool get isCompleted => endTime != null;

  /// Get session duration
  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  /// Get results for a specific component
  VerificationResult? getResultForComponent(String componentName) {
    return _results.cast<VerificationResult?>().firstWhere(
      (result) => result?.componentName == componentName,
      orElse: () => null,
    );
  }

  /// Get all failed results
  List<VerificationResult> get failedResults =>
    _results.where((r) => r.status == VerificationStatus.fail).toList();

  /// Get all warning results
  List<VerificationResult> get warningResults =>
    _results.where((r) => r.status == VerificationStatus.warning).toList();

  /// Get success rate as percentage
  double get successRate {
    if (totalChecks == 0) return 0.0;
    return (passedChecks / totalChecks) * 100.0;
  }

  /// Generate session summary
  String generateSummary() {
    final buffer = StringBuffer();
    buffer.writeln('Verification Session: $sessionId');
    buffer.writeln('Started: ${startTime.toIso8601String()}');
    if (endTime != null) {
      buffer.writeln('Completed: ${endTime!.toIso8601String()}');
      buffer.writeln('Duration: ${duration!.inSeconds}s');
    }
    buffer.writeln('Total Checks: $totalChecks');
    buffer.writeln('Passed: $passedChecks');
    buffer.writeln('Failed: $failedChecks');
    buffer.writeln('Warnings: $warningChecks');
    buffer.writeln('Success Rate: ${successRate.toStringAsFixed(1)}%');
    buffer.writeln('Overall Status: ${overallStatus.value.toUpperCase()}');

    if (failedResults.isNotEmpty) {
      buffer.writeln('\nFailed Components:');
      for (final result in failedResults) {
        buffer.writeln('  - ${result.componentName}: ${result.details}');
        if (result.errorMessage != null) {
          buffer.writeln('    Error: ${result.errorMessage}');
        }
      }
    }

    return buffer.toString();
  }

  @override
  String toString() {
    return 'VerificationSession(id: $sessionId, checks: $totalChecks, '
           'passed: $passedChecks, failed: $failedChecks, '
           'status: ${overallStatus.value})';
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'results': _results.map((r) => r.toJson()).toList(),
    };
  }

  /// Create from JSON
  factory VerificationSession.fromJson(Map<String, dynamic> json) {
    final session = VerificationSession(
      sessionId: json['sessionId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
    );

    if (json['endTime'] != null) {
      session.endTime = DateTime.parse(json['endTime'] as String);
    }

    final resultsJson = json['results'] as List<dynamic>;
    for (final resultJson in resultsJson) {
      session.addResult(VerificationResult.fromJson(resultJson as Map<String, dynamic>));
    }

    return session;
  }
}
