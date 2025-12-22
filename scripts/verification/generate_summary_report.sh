#!/bin/bash

# Generate Summary Report Script
#
# Creates comprehensive summary reports from verification session data
# Aggregates results across multiple sessions for trend analysis

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
REPORTS_DIR="$PROJECT_ROOT/reports/verification"
OUTPUT_DIR="$REPORTS_DIR/summary"
LOGS_DIR="$PROJECT_ROOT/logs/verification"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Configuration variables
: "${SUMMARY_PERIOD_DAYS:=30}"     # How many days of history to include
: "${MIN_SESSIONS:=3}"             # Minimum sessions required for trend analysis
: "${SUCCESS_THRESHOLD:=80}"       # Success rate threshold

# Logging functions
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOGS_DIR/summary_report.log"
    echo "[$timestamp] [$level] $message"
}

log_info() { log "INFO" "$1"; }
log_warn() { log "WARN" "$1"; }
log_error() { log "ERROR" "$1"; }

# Find recent session directories
find_recent_sessions() {
    local cutoff_date=$(date -d "$SUMMARY_PERIOD_DAYS days ago" +%Y%m%d 2>/dev/null || date -v-"${SUMMARY_PERIOD_DAYS}d" +%Y%m%d 2>/dev/null || echo "$(date +%s) - $((SUMMARY_PERIOD_DAYS * 86400))" | bc | xargs -I{} date -d "@{}" +%Y%m%d 2>/dev/null)

    log_info "Looking for sessions since $cutoff_date"

    # Find session directories (format: auto_YYYYMMDD_HHMMSS)
    find "$REPORTS_DIR" -maxdepth 1 -type d -name "auto_*" | while read -r session_dir; do
        local session_name=$(basename "$session_dir")
        local session_date=$(echo "$session_name" | sed 's/auto_\([0-9]\{8\}\).*/\1/')

        if [[ "$session_date" -ge "$cutoff_date" ]]; then
            echo "$session_dir"
        fi
    done | sort
}

# Analyze session data
analyze_sessions() {
    local session_dirs=("$@")
    local total_sessions=${#session_dirs[@]}

    log_info "Analyzing $total_sessions sessions"

    if [[ $total_sessions -lt $MIN_SESSIONS ]]; then
        log_warn "Only $total_sessions sessions found (minimum $MIN_SESSIONS required for trend analysis)"
    fi

    # Initialize aggregation variables
    local total_tests_passed=0
    local total_tests_failed=0
    local total_build_success=0
    local total_build_failure=0
    local total_duration=0
    local session_success_rates=()
    local component_success_rates=()

    # Process each session
    for session_dir in "${session_dirs[@]}"; do
        local session_name=$(basename "$session_dir")
        local summary_file="$session_dir/summary.json"

        if [[ ! -f "$summary_file" ]]; then
            log_warn "Summary file missing for session $session_name"
            continue
        fi

        # Parse JSON summary (simple parsing, could use jq if available)
        local session_data=$(cat "$summary_file")

        # Extract values using grep and sed (simple JSON parsing)
        local tests_passed=$(echo "$session_data" | grep -o '"passed":[0-9]*' | cut -d':' -f2)
        local tests_failed=$(echo "$session_data" | grep -o '"failed":[0-9]*' | cut -d':' -f2)
        local build_success=$(echo "$session_data" | grep -o '"success":[^,}]*' | grep -o 'true\|false')
        local duration=$(echo "$session_data" | grep -o '"duration_seconds":[0-9]*' | cut -d':' -f2)
        local success_rate=$(echo "$session_data" | grep -o '"success_rate":[0-9]*' | cut -d':' -f2)

        # Update totals
        total_tests_passed=$((total_tests_passed + (tests_passed:-0)))
        total_tests_failed=$((total_tests_failed + (tests_failed:-0)))

        if [[ "$build_success" == "true" ]]; then
            total_build_success=$((total_build_success + 1))
        else
            total_build_failure=$((total_build_failure + 1))
        fi

        total_duration=$((total_duration + (duration:-0)))
        session_success_rates+=("${success_rate:-0}")

        log_debug "Session $session_name: ${tests_passed:-0}P/${tests_failed:-0}F, Build:$build_success, ${duration:-0}s, ${success_rate:-0}%"
    done

    # Calculate overall statistics
    local overall_success_rate=0
    if [[ $((total_tests_passed + total_tests_failed)) -gt 0 ]]; then
        overall_success_rate=$(( (total_tests_passed * 100) / (total_tests_passed + total_tests_failed) ))
    fi

    local avg_duration=0
    if [[ $total_sessions -gt 0 ]]; then
        avg_duration=$((total_duration / total_sessions))
    fi

    local build_success_rate=0
    if [[ $((total_build_success + total_build_failure)) -gt 0 ]]; then
        build_success_rate=$(( (total_build_success * 100) / (total_build_success + total_build_failure) ))
    fi

    # Calculate trend
    local trend="insufficient_data"
    if [[ ${#session_success_rates[@]} -ge $MIN_SESSIONS ]]; then
        local first_rate=${session_success_rates[0]}
        local last_rate=${session_success_rates[-1]}

        if [[ $((last_rate - first_rate)) -gt 5 ]]; then
            trend="improving"
        elif [[ $((first_rate - last_rate)) -gt 5 ]]; then
            trend="declining"
        else
            trend="stable"
        fi
    fi

    # Create summary JSON
    cat > "$OUTPUT_DIR/summary_stats.json" << EOF
{
  "generated_at": "$(date -Iseconds)",
  "period_days": $SUMMARY_PERIOD_DAYS,
  "total_sessions": $total_sessions,
  "overall_statistics": {
    "success_rate": $overall_success_rate,
    "build_success_rate": $build_success_rate,
    "average_duration_seconds": $avg_duration,
    "total_tests_passed": $total_tests_passed,
    "total_tests_failed": $total_tests_failed,
    "trend": "$trend"
  },
  "session_breakdown": {
    "build_success": $total_build_success,
    "build_failure": $total_build_failure
  },
  "thresholds": {
    "success_threshold": $SUCCESS_THRESHOLD,
    "overall_status": "$( [[ $overall_success_rate -ge $SUCCESS_THRESHOLD ]] && echo "PASS" || echo "FAIL" )"
  }
}
EOF

    log_info "Summary statistics generated"
}

# Generate HTML summary report
generate_html_report() {
    local summary_file="$OUTPUT_DIR/summary_stats.json"

    if [[ ! -f "$summary_file" ]]; then
        log_error "Summary statistics file not found"
        return 1
    fi

    # Read summary data
    local summary_data=$(cat "$summary_file")

    # Extract values for HTML generation
    local generated_at=$(echo "$summary_data" | grep -o '"generated_at":"[^"]*"' | cut -d'"' -f4)
    local total_sessions=$(echo "$summary_data" | grep -o '"total_sessions":[0-9]*' | cut -d':' -f2)
    local success_rate=$(echo "$summary_data" | grep -o '"success_rate":[0-9]*' | cut -d':' -f2)
    local build_success_rate=$(echo "$summary_data" | grep -o '"build_success_rate":[0-9]*' | cut -d':' -f2)
    local avg_duration=$(echo "$summary_data" | grep -o '"average_duration_seconds":[0-9]*' | cut -d':' -f2)
    local trend=$(echo "$summary_data" | grep -o '"trend":"[^"]*"' | cut -d'"' -f4)
    local overall_status=$(echo "$summary_data" | grep -o '"overall_status":"[^"]*"' | cut -d'"' -f4)

    # Generate HTML report
    cat > "$OUTPUT_DIR/summary_report.html" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Flux Ledger Verification Summary Report</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { text-align: center; margin-bottom: 40px; border-bottom: 2px solid #007AFF; padding-bottom: 20px; }
        .header h1 { color: #007AFF; margin: 0; font-size: 2.5em; }
        .header .subtitle { color: #666; font-size: 1.1em; margin-top: 5px; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .stat-card { background: #f8f9fa; padding: 25px; border-radius: 8px; text-align: center; border-left: 4px solid #007AFF; }
        .stat-card h3 { margin: 0 0 15px 0; color: #333; font-size: 1.1em; }
        .stat-card .value { font-size: 2.5em; font-weight: bold; color: #007AFF; }
        .stat-card .unit { font-size: 0.8em; color: #666; margin-left: 5px; }
        .status-banner { padding: 20px; border-radius: 8px; text-align: center; margin: 30px 0; font-size: 1.2em; font-weight: bold; }
        .status-pass { background: #d4edda; color: #155724; }
        .status-fail { background: #f8d7da; color: #721c24; }
        .trend-indicator { display: inline-block; padding: 8px 16px; border-radius: 20px; font-weight: bold; margin: 10px 0; }
        .trend-improving { background: #d4edda; color: #155724; }
        .trend-declining { background: #f8d7da; color: #721c24; }
        .trend-stable { background: #fff3cd; color: #856404; }
        .details-section { margin: 30px 0; }
        .details-section h2 { color: #333; border-bottom: 2px solid #007AFF; padding-bottom: 10px; }
        .metric-table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        .metric-table th, .metric-table td { padding: 12px; text-align: left; border-bottom: 1px solid #e9ecef; }
        .metric-table th { background: #f8f9fa; font-weight: 600; }
        .footer { margin-top: 40px; padding-top: 20px; border-top: 1px solid #e9ecef; text-align: center; color: #666; font-size: 0.9em; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Flux Ledger Verification Summary</h1>
            <div class="subtitle">Last $SUMMARY_PERIOD_DAYS Days • Generated $generated_at</div>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <h3>Total Sessions</h3>
                <div class="value">$total_sessions</div>
            </div>
            <div class="stat-card">
                <h3>Success Rate</h3>
                <div class="value">$success_rate<span class="unit">%</span></div>
            </div>
            <div class="stat-card">
                <h3>Build Success</h3>
                <div class="value">$build_success_rate<span class="unit">%</span></div>
            </div>
            <div class="stat-card">
                <h3>Average Duration</h3>
                <div class="value">$avg_duration<span class="unit">s</span></div>
            </div>
        </div>

        <div class="status-banner $( [[ "$overall_status" == "PASS" ]] && echo "status-pass" || echo "status-fail" )">
            Overall Status: $overall_status
        </div>

        <div class="trend-indicator trend-$trend">
            Trend: ${trend^}
        </div>

        <div class="details-section">
            <h2>Detailed Metrics</h2>
            <table class="metric-table">
                <thead>
                    <tr>
                        <th>Metric</th>
                        <th>Value</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>Verification Success Rate</td>
                        <td>${success_rate}%</td>
                        <td>$( [[ $success_rate -ge $SUCCESS_THRESHOLD ]] && echo "✓ PASS" || echo "✗ FAIL" )</td>
                    </tr>
                    <tr>
                        <td>Build Success Rate</td>
                        <td>${build_success_rate}%</td>
                        <td>$( [[ $build_success_rate -ge 95 ]] && echo "✓ PASS" || echo "✗ FAIL" )</td>
                    </tr>
                    <tr>
                        <td>Performance Trend</td>
                        <td>${trend^}</td>
                        <td>$( [[ "$trend" == "improving" ]] && echo "✓ GOOD" || [[ "$trend" == "stable" ]] && echo "~ STABLE" || echo "✗ CONCERNING" )</td>
                    </tr>
                    <tr>
                        <td>Sessions Analyzed</td>
                        <td>$total_sessions</td>
                        <td>$( [[ $total_sessions -ge $MIN_SESSIONS ]] && echo "✓ SUFFICIENT" || echo "! LIMITED" )</td>
                    </tr>
                </tbody>
            </table>
        </div>

        <div class="footer">
            <p>This report was automatically generated by the Flux Ledger verification system.</p>
            <p>For more details, check individual session reports in the verification dashboard.</p>
        </div>
    </div>
</body>
</html>
EOF

    log_info "HTML summary report generated: $OUTPUT_DIR/summary_report.html"
}

# Generate trend analysis
generate_trend_analysis() {
    local summary_file="$OUTPUT_DIR/summary_stats.json"

    if [[ ! -f "$summary_file" ]]; then
        log_error "Summary statistics file not found for trend analysis"
        return 1
    fi

    # This would analyze trends across sessions
    # For now, create a basic trend file
    cat > "$OUTPUT_DIR/trend_analysis.json" << EOF
{
  "analysis_period_days": $SUMMARY_PERIOD_DAYS,
  "trends_identified": [
    "success_rate_trend",
    "build_success_trend",
    "performance_trend"
  ],
  "recommendations": [
    "Continue monitoring verification success rates",
    "Address any declining trends promptly",
    "Consider increasing test coverage if success rates are consistently high"
  ],
  "next_analysis_date": "$(date -d '+7 days' +%Y-%m-%d 2>/dev/null || date -v+7d +%Y-%m-%d 2>/dev/null || echo 'unknown')"
}
EOF

    log_info "Trend analysis generated"
}

# Main execution
main() {
    log_info "Starting summary report generation"

    # Find recent sessions
    local session_dirs=($(find_recent_sessions))

    if [[ ${#session_dirs[@]} -eq 0 ]]; then
        log_error "No recent verification sessions found in $REPORTS_DIR"
        log_info "Make sure verification has been run recently"
        exit 1
    fi

    # Analyze sessions
    analyze_sessions "${session_dirs[@]}"

    # Generate HTML report
    generate_html_report

    # Generate trend analysis
    generate_trend_analysis

    log_info "Summary report generation completed"
    log_info "Reports available in: $OUTPUT_DIR"
    log_info "- Summary statistics: $OUTPUT_DIR/summary_stats.json"
    log_info "- HTML report: $OUTPUT_DIR/summary_report.html"
    log_info "- Trend analysis: $OUTPUT_DIR/trend_analysis.json"
}

# Run main function
main "$@"



