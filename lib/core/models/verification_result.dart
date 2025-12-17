/// Verification Result - Records the outcome of individual verification checks
///
/// Represents the result of verifying a specific component or functionality,
/// including status, details, and any associated evidence.

enum VerificationStatus {
  pending('pending'),
  pass('pass'),
  fail('fail'),
  warning('warning');

  const VerificationStatus(this.value);
  final String value;

  static VerificationStatus fromString(String value) {
    return VerificationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => VerificationStatus.pending,
    );
  }
}

class VerificationResult {
  final String componentName;
  final VerificationStatus status;
  final String details;
  final DateTime timestamp;
  final int priority;
  final Duration? duration;
  final Map<String, bool>? checkResults;
  final List<String>? remediationSteps;
  final String? errorMessage;

  VerificationResult({
    required this.componentName,
    required this.status,
    required this.details,
    DateTime? timestamp,
    this.priority = 3,
    this.duration,
    this.checkResults,
    this.remediationSteps,
    this.errorMessage,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create a passing result
  factory VerificationResult.pass(
    String componentName,
    String details, {
    Map<String, bool>? checkResults,
    int priority = 3,
    Duration? duration,
  }) {
    return VerificationResult(
      componentName: componentName,
      status: VerificationStatus.pass,
      details: details,
      checkResults: checkResults,
      priority: priority,
      duration: duration,
    );
  }

  /// Create a failing result
  factory VerificationResult.fail(
    String componentName,
    String details, {
    String? errorMessage,
    List<String>? remediationSteps,
    Map<String, bool>? checkResults,
    int priority = 3,
    Duration? duration,
  }) {
    return VerificationResult(
      componentName: componentName,
      status: VerificationStatus.fail,
      details: details,
      errorMessage: errorMessage,
      remediationSteps: remediationSteps,
      checkResults: checkResults,
      priority: priority,
      duration: duration,
    );
  }

  /// Create a warning result
  factory VerificationResult.warning(
    String componentName,
    String details, {
    List<String>? remediationSteps,
    Map<String, bool>? checkResults,
    int priority = 3,
    Duration? duration,
  }) {
    return VerificationResult(
      componentName: componentName,
      status: VerificationStatus.warning,
      details: details,
      remediationSteps: remediationSteps,
      checkResults: checkResults,
      priority: priority,
      duration: duration,
    );
  }

  /// Check if the result is successful
  bool get isSuccessful => status == VerificationStatus.pass;

  /// Check if the result has failures
  bool get hasFailures => status == VerificationStatus.fail;

  /// Check if the result has warnings
  bool get hasWarnings => status == VerificationStatus.warning;

  /// Get summary of check results
  String getCheckSummary() {
    if (checkResults == null || checkResults!.isEmpty) {
      return 'No detailed checks performed';
    }

    final passed = checkResults!.values.where((v) => v).length;
    final total = checkResults!.length;
    return '$passed/$total checks passed';
  }

  @override
  String toString() {
    return 'VerificationResult(component: $componentName, status: ${status.value}, details: $details)';
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'componentName': componentName,
      'status': status.value,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
      'priority': priority,
      'durationMs': duration?.inMilliseconds,
      'checkResults': checkResults,
      'remediationSteps': remediationSteps,
      'errorMessage': errorMessage,
    };
  }

  /// Create from JSON
  factory VerificationResult.fromJson(Map<String, dynamic> json) {
    return VerificationResult(
      componentName: json['componentName'] as String,
      status: VerificationStatus.fromString(json['status'] as String),
      details: json['details'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      priority: json['priority'] as int? ?? 3,
      duration: json['durationMs'] != null
          ? Duration(milliseconds: json['durationMs'] as int)
          : null,
      checkResults: json['checkResults'] != null
          ? Map<String, bool>.from(json['checkResults'] as Map)
          : null,
      remediationSteps: json['remediationSteps'] != null
          ? List<String>.from(json['remediationSteps'] as List)
          : null,
      errorMessage: json['errorMessage'] as String?,
    );
  }
}
