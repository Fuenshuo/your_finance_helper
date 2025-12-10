#!/bin/bash

# Automated Verification Scheduling Script
#
# Runs comprehensive verification suite on schedule or on-demand
# Generates reports and sends notifications for failures

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
VERIFICATION_DIR="$PROJECT_ROOT/scripts/verification"
REPORTS_DIR="$PROJECT_ROOT/reports/verification"
LOGS_DIR="$PROJECT_ROOT/logs/verification"

# Create directories
mkdir -p "$REPORTS_DIR" "$LOGS_DIR"

# Configuration variables (can be overridden by environment)
: "${VERIFICATION_SCHEDULE:="daily"}"  # daily, weekly, manual
: "${NOTIFICATION_EMAIL:=""}"          # Email for notifications
: "${SLACK_WEBHOOK_URL:=""}"           # Slack webhook for notifications
: "${FAILURE_THRESHOLD:=80}"           # Minimum success rate percentage
: "${TIMEOUT_MINUTES:=30}"             # Maximum runtime in minutes
: "${LOG_LEVEL:="INFO"}"               # DEBUG, INFO, WARN, ERROR

# Logging functions
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOGS_DIR/verification.log"

    # Also print to stdout for cron jobs
    if [[ "$LOG_LEVEL" == "DEBUG" ]] || [[ "$level" != "DEBUG" ]]; then
        echo "[$timestamp] [$level] $message"
    fi
}

log_debug() { log "DEBUG" "$1"; }
log_info() { log "INFO" "$1"; }
log_warn() { log "WARN" "$1"; }
log_error() { log "ERROR" "$1"; }

# Setup function
setup() {
    log_info "Setting up automated verification environment"

    # Check if we're in the right directory
    if [[ ! -f "$PROJECT_ROOT/pubspec.yaml" ]]; then
        log_error "Not in Flutter project root. Expected pubspec.yaml at $PROJECT_ROOT"
        exit 1
    fi

    # Check Flutter installation
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter not found in PATH"
        exit 1
    fi

    # Verify Flutter setup
    log_debug "Checking Flutter doctor"
    if ! flutter doctor --quiet; then
        log_warn "Flutter doctor reported issues. Continuing anyway..."
    fi

    log_info "Setup completed successfully"
}

# Run verification tests
run_verification_tests() {
    local start_time=$(date +%s)
    local session_id="auto_$(date +%Y%m%d_%H%M%S)"

    log_info "Starting verification session: $session_id"

    # Create session directory
    local session_dir="$REPORTS_DIR/$session_id"
    mkdir -p "$session_dir"

    # Start performance monitoring
    log_debug "Starting performance monitoring"

    # Run Flutter tests with timeout
    local test_result=0
    local test_output=""

    log_info "Running integration tests"
    if timeout "${TIMEOUT_MINUTES}m" flutter test integration_test/ --verbose > "$session_dir/test_output.log" 2>&1; then
        test_result=$?
        test_output=$(cat "$session_dir/test_output.log")
        log_info "Integration tests completed"
    else
        test_result=$?
        test_output=$(cat "$session_dir/test_output.log")
        log_error "Integration tests failed or timed out (exit code: $test_result)"
    fi

    # Run build verification
    log_info "Running build verification"
    local build_result=0
    local build_output=""

    if flutter build apk --release --verbose > "$session_dir/build_output.log" 2>&1; then
        build_result=0
        build_output=$(cat "$session_dir/build_output.log")
        log_info "Build verification completed successfully"
    else
        build_result=$?
        build_output=$(cat "$session_dir/build_output.log")
        log_error "Build verification failed (exit code: $build_result)"
    fi

    # Analyze results
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    log_info "Analyzing verification results"

    # Extract test results
    local tests_passed=$(echo "$test_output" | grep -c "✓" || echo "0")
    local tests_failed=$(echo "$test_output" | grep -c "✗" || echo "0")
    local total_tests=$((tests_passed + tests_failed))

    # Calculate success rate
    local success_rate=0
    if [[ $total_tests -gt 0 ]]; then
        success_rate=$(( (tests_passed * 100) / total_tests ))
    fi

    # Generate summary report
    cat > "$session_dir/summary.json" << EOF
{
  "session_id": "$session_id",
  "timestamp": "$(date -Iseconds)",
  "duration_seconds": $duration,
  "tests": {
    "total": $total_tests,
    "passed": $tests_passed,
    "failed": $tests_failed,
    "success_rate": $success_rate
  },
  "build": {
    "success": $([ $build_result -eq 0 ] && echo "true" || echo "false")
  },
  "overall_success": $([ $success_rate -ge $FAILURE_THRESHOLD ] && [ $build_result -eq 0 ] && echo "true" || echo "false")
}
EOF

    # Generate HTML report
    generate_html_report "$session_id" "$session_dir" "$success_rate" "$duration" "$tests_passed" "$tests_failed" "$build_result"

    log_info "Verification session $session_id completed in ${duration}s"

    # Send notifications if needed
    if [[ $success_rate -lt $FAILURE_THRESHOLD ]] || [[ $build_result -ne 0 ]]; then
        log_warn "Verification failed - sending notifications"
        send_failure_notification "$session_id" "$success_rate" "$build_result"
    else
        log_info "Verification passed - no notifications needed"
    fi

    # Cleanup old reports (keep last 30)
    cleanup_old_reports

    return $test_result
}

# Generate HTML report
generate_html_report() {
    local session_id="$1"
    local session_dir="$2"
    local success_rate="$3"
    local duration="$4"
    local tests_passed="$5"
    local tests_failed="$6"
    local build_result="$7"

    cat > "$session_dir/report.html" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Flux Ledger Verification Report - $session_id</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { text-align: center; margin-bottom: 30px; }
        .header h1 { color: #007AFF; margin: 0; }
        .summary { display: flex; justify-content: space-around; margin: 30px 0; }
        .metric { text-align: center; padding: 20px; }
        .metric h3 { margin: 0 0 10px 0; color: #666; }
        .metric .value { font-size: 2em; font-weight: bold; }
        .status { padding: 20px; margin: 20px 0; border-radius: 8px; }
        .status.success { background: #d4edda; color: #155724; }
        .status.failure { background: #f8d7da; color: #721c24; }
        .details { margin: 20px 0; }
        .details h3 { color: #333; border-bottom: 2px solid #007AFF; padding-bottom: 5px; }
        .log-section { background: #f8f9fa; padding: 15px; border-radius: 4px; margin: 10px 0; }
        .log-section h4 { margin: 0 0 10px 0; color: #495057; }
        .log-content { font-family: monospace; font-size: 12px; white-space: pre-wrap; max-height: 300px; overflow-y: auto; background: white; padding: 10px; border: 1px solid #dee2e6; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Flux Ledger Verification Report</h1>
            <p>Session: $session_id</p>
            <p>Generated: $(date)</p>
        </div>

        <div class="summary">
            <div class="metric">
                <h3>Success Rate</h3>
                <div class="value" style="color: $([ $success_rate -ge $FAILURE_THRESHOLD ] && echo '#28a745' || echo '#dc3545')">$success_rate%</div>
            </div>
            <div class="metric">
                <h3>Duration</h3>
                <div class="value">${duration}s</div>
            </div>
            <div class="metric">
                <h3>Tests Passed</h3>
                <div class="value" style="color: #28a745">$tests_passed</div>
            </div>
            <div class="metric">
                <h3>Tests Failed</h3>
                <div class="value" style="color: $([ $tests_failed -eq 0 ] && echo '#28a745' || echo '#dc3545')">$tests_failed</div>
            </div>
        </div>

        <div class="status $([ $success_rate -ge $FAILURE_THRESHOLD ] && [ $build_result -eq 0 ] && echo 'success' || echo 'failure')">
            <h3>Overall Status: $([ $success_rate -ge $FAILURE_THRESHOLD ] && [ $build_result -eq 0 ] && echo 'PASSED' || echo 'FAILED')</h3>
            <p>Build Status: $([ $build_result -eq 0 ] && echo 'SUCCESS' || echo 'FAILED')</p>
        </div>

        <div class="details">
            <h3>Test Results</h3>
            <div class="log-section">
                <h4>Test Output</h4>
                <div class="log-content">$(head -50 "$session_dir/test_output.log" 2>/dev/null || echo "No test output available")</div>
            </div>

            <h3>Build Results</h3>
            <div class="log-section">
                <h4>Build Output</h4>
                <div class="log-content">$(tail -30 "$session_dir/build_output.log" 2>/dev/null || echo "No build output available")</div>
            </div>
        </div>
    </div>
</body>
</html>
EOF

    log_info "HTML report generated: $session_dir/report.html"
}

# Send failure notifications
send_failure_notification() {
    local session_id="$1"
    local success_rate="$2"
    local build_result="$3"

    local subject="Flux Ledger Verification FAILED - $session_id"
    local message="Verification session $session_id failed.

Success Rate: $success_rate%
Build Status: $([ $build_result -eq 0 ] && echo 'SUCCESS' || echo 'FAILED')
Failure Threshold: ${FAILURE_THRESHOLD}%

View full report: reports/verification/$session_id/report.html

This is an automated message from the Flux Ledger verification system."

    # Email notification
    if [[ -n "$NOTIFICATION_EMAIL" ]]; then
        log_info "Sending email notification to $NOTIFICATION_EMAIL"
        echo "$message" | mail -s "$subject" "$NOTIFICATION_EMAIL" 2>/dev/null || \
        log_warn "Failed to send email notification"
    fi

    # Slack notification
    if [[ -n "$SLACK_WEBHOOK_URL" ]]; then
        log_info "Sending Slack notification"

        local slack_payload=$(cat <<EOF
{
  "text": "*Flux Ledger Verification FAILED*",
  "attachments": [
    {
      "color": "danger",
      "fields": [
        {"title": "Session ID", "value": "$session_id", "short": true},
        {"title": "Success Rate", "value": "$success_rate%", "short": true},
        {"title": "Build Status", "value": $([ $build_result -eq 0 ] && echo '"SUCCESS"' || echo '"FAILED"'), "short": true}
      ]
    }
  ]
}
EOF
)

        curl -X POST -H 'Content-type: application/json' --data "$slack_payload" "$SLACK_WEBHOOK_URL" 2>/dev/null || \
        log_warn "Failed to send Slack notification"
    fi
}

# Cleanup old reports
cleanup_old_reports() {
    local max_reports=30

    # Count current reports
    local report_count=$(ls -1d "$REPORTS_DIR"/*/ 2>/dev/null | wc -l)

    if [[ $report_count -gt $max_reports ]]; then
        local to_delete=$((report_count - max_reports))
        log_info "Cleaning up $to_delete old reports"

        # Delete oldest reports
        ls -1td "$REPORTS_DIR"/*/ | tail -n $to_delete | xargs rm -rf
    fi
}

# Health check function
health_check() {
    log_info "Performing health check"

    # Check disk space
    local available_space=$(df "$PROJECT_ROOT" | tail -1 | awk '{print $4}')
    if [[ $available_space -lt 1000000 ]]; then  # Less than ~1GB
        log_warn "Low disk space: ${available_space}KB available"
    fi

    # Check Flutter version
    local flutter_version=$(flutter --version | head -1)
    log_debug "Flutter version: $flutter_version"

    # Check pubspec.yaml exists and is valid
    if [[ ! -f "$PROJECT_ROOT/pubspec.yaml" ]]; then
        log_error "pubspec.yaml not found"
        return 1
    fi

    # Check if any verification files exist
    if [[ ! -d "$VERIFICATION_DIR" ]]; then
        log_warn "Verification directory not found: $VERIFICATION_DIR"
    fi

    log_info "Health check completed"
}

# Main execution
main() {
    local command="${1:-run}"

    case "$command" in
        "run")
            log_info "Starting automated verification run"
            setup
            run_verification_tests
            ;;
        "health")
            health_check
            ;;
        "cleanup")
            log_info "Running cleanup only"
            cleanup_old_reports
            ;;
        "setup")
            setup
            ;;
        *)
            echo "Usage: $0 {run|health|cleanup|setup}"
            echo "  run     - Run full verification suite (default)"
            echo "  health  - Perform health check only"
            echo "  cleanup - Clean up old reports only"
            echo "  setup   - Setup verification environment only"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
