/// Verification Report Service - Generates comprehensive reports for verification results
///
/// Creates detailed HTML/PDF reports with evidence, recommendations, and status summaries
/// for all verification sessions and individual component verifications.

import 'dart:convert';
import 'dart:io';
import '../models/verification_result.dart';
import '../models/verification_session.dart';

class VerificationReportService {

  /// Generate comprehensive HTML report for a verification session
  Future<String> generateSessionReport(VerificationSession session) async {
    final buffer = StringBuffer();

    // HTML header with styling
    buffer.writeln('''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Flux Ledger Migration Verification Report</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { text-align: center; margin-bottom: 40px; border-bottom: 2px solid #007AFF; padding-bottom: 20px; }
        .header h1 { color: #007AFF; margin: 0; font-size: 2.5em; }
        .header .subtitle { color: #666; font-size: 1.1em; margin-top: 5px; }
        .summary { display: flex; justify-content: space-around; margin-bottom: 30px; flex-wrap: wrap; }
        .summary-card { background: #f8f9fa; padding: 20px; border-radius: 8px; text-align: center; min-width: 150px; margin: 10px; }
        .summary-card h3 { margin: 0 0 10px 0; color: #333; }
        .summary-card .value { font-size: 2em; font-weight: bold; }
        .status-pass { color: #28a745; }
        .status-fail { color: #dc3545; }
        .status-partial { color: #ffc107; }
        .component { margin-bottom: 30px; border: 1px solid #e9ecef; border-radius: 8px; overflow: hidden; }
        .component-header { background: #f8f9fa; padding: 15px; border-bottom: 1px solid #e9ecef; }
        .component-header h3 { margin: 0; color: #333; }
        .component-content { padding: 20px; }
        .evidence-list { margin-top: 15px; }
        .evidence-item { background: #f8f9fa; padding: 10px; margin: 5px 0; border-radius: 4px; border-left: 4px solid #007AFF; }
        .remediation { background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 4px; margin-top: 15px; }
        .remediation h4 { color: #856404; margin: 0 0 10px 0; }
        .remediation ul { margin: 0; padding-left: 20px; }
        .timestamp { color: #666; font-size: 0.9em; margin-top: 20px; text-align: center; }
        .priority-high { border-left-color: #dc3545; }
        .priority-medium { border-left-color: #ffc107; }
        .priority-low { border-left-color: #28a745; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #e9ecef; }
        th { background: #f8f9fa; font-weight: 600; }
        .badge { padding: 4px 8px; border-radius: 4px; font-size: 0.8em; font-weight: bold; }
        .badge-pass { background: #d4edda; color: #155724; }
        .badge-fail { background: #f8d7da; color: #721c24; }
        .badge-pending { background: #fff3cd; color: #856404; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Flux Ledger Migration Verification</h1>
            <div class="subtitle">Migration Verification - Flux Ledger Capability Audit</div>
        </div>

        <div class="summary">
''');

    // Summary statistics
    final totalResults = session.results.length;
    final passedResults = session.results
        .where((r) => r.status == VerificationStatus.pass)
        .length;
    final failedResults = session.results
        .where((r) => r.status == VerificationStatus.fail)
        .length;
    final passRate =
        totalResults > 0 ? ((passedResults / totalResults) * 100).round() : 0;

    buffer.writeln('''
            <div class="summary-card">
                <h3>Total Components</h3>
                <div class="value">${totalResults}</div>
            </div>
            <div class="summary-card">
                <h3>Passed</h3>
                <div class="value status-pass">${passedResults}</div>
            </div>
            <div class="summary-card">
                <h3>Failed</h3>
                <div class="value status-fail">${failedResults}</div>
            </div>
            <div class="summary-card">
                <h3>Success Rate</h3>
                <div class="value ${passRate >= 80 ? 'status-pass' : passRate >= 60 ? 'status-partial' : 'status-fail'}">${passRate}%</div>
            </div>
        </div>

        <h2>Verification Results</h2>
        <table>
            <thead>
                <tr>
                    <th>Component</th>
                    <th>Status</th>
                    <th>Priority</th>
                    <th>Duration</th>
                    <th>Details</th>
                </tr>
            </thead>
            <tbody>
''');

    // Component results table
    for (final result in session.results) {
      final statusClass = result.status == VerificationStatus.pass
          ? 'badge-pass'
          : result.status == VerificationStatus.fail
              ? 'badge-fail'
              : 'badge-pending';
      final statusText = result.status.toString().split('.').last.toUpperCase();

      buffer.writeln('''
                <tr>
                    <td>${result.componentName}</td>
                    <td><span class="badge ${statusClass}">${statusText}</span></td>
                    <td>${result.priority}</td>
                    <td>${result.duration?.inSeconds ?? 'N/A'}s</td>
                    <td>${_truncateText(result.details, 100)}</td>
                </tr>
''');
    }

    buffer.writeln('''
            </tbody>
        </table>

        <h2>Detailed Results</h2>
''');

    // Detailed component results
    for (final result in session.results) {

      buffer.writeln('''
        <div class="component">
            <div class="component-header">
                <h3>${result.componentName} <span class="badge ${result.status == VerificationStatus.pass ? 'badge-pass' : 'badge-fail'}">${result.status.toString().split('.').last.toUpperCase()}</span></h3>
            </div>
            <div class="component-content">
                <p><strong>Details:</strong> ${result.details}</p>
                <p><strong>Priority:</strong> ${result.priority}</p>
                <p><strong>Duration:</strong> ${result.duration?.inSeconds ?? 'N/A'} seconds</p>
''');

      if (result.checkResults?.isNotEmpty == true) {
        buffer.writeln('''
                <h4>Check Results:</h4>
                <ul>
''');
        result.checkResults?.forEach((key, passed) {
          buffer.writeln(
              '                    <li class="${passed ? 'status-pass' : 'status-fail'}">${key}: ${passed ? 'PASS' : 'FAIL'}</li>');
        });
        buffer.writeln('                </ul>');
      }

      if (result.remediationSteps != null &&
          result.remediationSteps!.isNotEmpty) {
        buffer.writeln('''
                <div class="remediation">
                    <h4>Remediation Steps:</h4>
                    <ul>
''');
        for (final step in result.remediationSteps!) {
          buffer.writeln('                        <li>${step}</li>');
        }
        buffer.writeln('''
                    </ul>
                </div>
''');
      }

      buffer.writeln('''
            </div>
        </div>
''');
    }

    // Footer with timestamp
    buffer.writeln('''
        <div class="timestamp">
            <p>Report generated on ${DateTime.now().toString()}</p>
            <p>Session started: ${session.startTime.toString()}</p>
            <p>Session ended: ${session.endTime?.toString() ?? 'In progress'}</p>
        </div>
    </div>
</body>
</html>
''');

    return buffer.toString();
  }

  /// Save report to file
  Future<File> saveReport(String reportContent, String filePath) async {
    final file = File(filePath);
    await file.writeAsString(reportContent);
    return file;
  }

  /// Generate summary statistics
  Map<String, dynamic> generateSummaryStats(VerificationSession session) {
    final totalComponents = session.results.length;
    final passed = session.results
        .where((r) => r.status == VerificationStatus.pass)
        .length;
    final failed = session.results
        .where((r) => r.status == VerificationStatus.fail)
        .length;
    final pending = session.results
        .where((r) => r.status == VerificationStatus.pending)
        .length;

    final avgDuration = session.results
            .where((r) => r.duration != null)
            .map((r) => r.duration!.inSeconds)
            .fold<double>(0, (sum, duration) => sum + duration) /
        session.results.where((r) => r.duration != null).length;

    return {
      'total_components': totalComponents,
      'passed': passed,
      'failed': failed,
      'pending': pending,
      'success_rate':
          totalComponents > 0 ? (passed / totalComponents * 100).round() : 0,
      'average_duration_seconds': avgDuration.isNaN ? 0 : avgDuration.round(),
      'session_duration_seconds':
          session.endTime?.difference(session.startTime).inSeconds ?? 0,
      'high_priority_failures': session.results
          .where((r) => r.status == VerificationStatus.fail && r.priority >= 4)
          .map((r) => r.componentName)
          .toList(),
    };
  }

  /// Generate JSON report for programmatic consumption
  String generateJsonReport(VerificationSession session) {
    final summary = generateSummaryStats(session);

    final report = {
      'session': {
        'id': session.sessionId,
        'start_time': session.startTime.toIso8601String(),
        'end_time': session.endTime?.toIso8601String(),
        'overall_status': session.overallStatus.toString().split('.').last,
      },
      'summary': summary,
      'results': session.results
          .map((result) => {
                'component_name': result.componentName,
                'status': result.status.toString().split('.').last,
                'priority': result.priority,
                'duration_seconds': result.duration?.inSeconds,
                'details': result.details,
                'check_results': result.checkResults,
                'remediation_steps': result.remediationSteps,
                'error_message': result.errorMessage,
              })
          .toList(),
    };

    return JsonEncoder.withIndent('  ').convert(report);
  }

  /// Helper method to truncate text for display
  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}

