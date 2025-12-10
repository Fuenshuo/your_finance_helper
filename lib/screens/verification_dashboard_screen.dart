/// Verification Dashboard Screen - Interactive dashboard for verification results
///
/// Provides real-time monitoring, historical trends, and detailed component analysis
/// with interactive charts and actionable insights.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/verification_provider.dart';
import '../core/services/verification_runner.dart';
import '../core/services/verification_report_service.dart';
import '../core/services/verification_aggregator.dart';
import '../core/services/verification_performance_monitor.dart';
import '../models/verification_session.dart';
import '../widgets/verification_status_card.dart';
import '../widgets/verification_chart.dart';
import '../widgets/verification_details_panel.dart';

class VerificationDashboardScreen extends StatefulWidget {
  const VerificationDashboardScreen({super.key});

  @override
  State<VerificationDashboardScreen> createState() => _VerificationDashboardScreenState();
}

class _VerificationDashboardScreenState extends State<VerificationDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isRunningVerification = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flux Ledger Verification Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.history), text: 'History'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh verification data',
          ),
          IconButton(
            icon: Icon(_isRunningVerification ? Icons.stop : Icons.play_arrow),
            onPressed: _isRunningVerification ? _stopVerification : _startVerification,
            tooltip: _isRunningVerification ? 'Stop verification' : 'Start verification',
          ),
        ],
      ),
      body: Consumer<VerificationProvider>(
        builder: (context, verificationProvider, child) {
          if (verificationProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Running verification...'),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(verificationProvider),
              _buildAnalyticsTab(verificationProvider),
              _buildHistoryTab(verificationProvider),
              _buildSettingsTab(verificationProvider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generateReport,
        icon: const Icon(Icons.description),
        label: const Text('Generate Report'),
        tooltip: 'Generate detailed verification report',
      ),
    );
  }

  Widget _buildOverviewTab(VerificationProvider provider) {
    final currentSession = provider.currentSession;
    final recentResults = provider.recentResults;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Session Status
          if (currentSession != null) ...[
            Text(
              'Current Session',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            VerificationStatusCard(session: currentSession),
            const SizedBox(height: 24),
          ],

          // Quick Stats Grid
          Text(
            'Verification Overview',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildStatCard(
                'Total Components',
                recentResults.length.toString(),
                Icons.apps,
                Colors.blue,
              ),
              _buildStatCard(
                'Success Rate',
                _calculateSuccessRate(recentResults),
                Icons.check_circle,
                Colors.green,
              ),
              _buildStatCard(
                'Avg Duration',
                _calculateAverageDuration(recentResults),
                Icons.timer,
                Colors.orange,
              ),
              _buildStatCard(
                'High Priority',
                _countHighPriorityFailures(recentResults).toString(),
                Icons.warning,
                Colors.red,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Results
          Text(
            'Recent Results',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          VerificationChart(
            results: recentResults.take(10).toList(),
            chartType: ChartType.recentResults,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(VerificationProvider provider) {
    final aggregator = VerificationAggregator();
    final sessions = provider.sessionHistory;
    final aggregation = aggregator.aggregateSessions(sessions);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Analytics',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          // Trend Analysis
          _buildTrendAnalysisCard(aggregation.trendAnalysis),

          const SizedBox(height: 24),

          // Component Performance
          Text(
            'Component Performance',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          VerificationChart(
            results: aggregation.componentResults.values
                .map((c) => _componentAggregationToResult(c))
                .toList(),
            chartType: ChartType.componentPerformance,
          ),

          const SizedBox(height: 24),

          // Failure Patterns
          if (aggregation.failurePatterns.isNotEmpty) ...[
            Text(
              'Failure Patterns',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...aggregation.failurePatterns.take(5).map((pattern) =>
              _buildFailurePatternCard(pattern),
            ),
          ],

          const SizedBox(height: 24),

          // Recommendations
          if (aggregation.recommendations.isNotEmpty) ...[
            Text(
              'Recommendations',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...aggregation.recommendations.map((recommendation) =>
              _buildRecommendationCard(recommendation),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryTab(VerificationProvider provider) {
    final sessions = provider.sessionHistory;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text('Session ${session.sessionId}'),
            subtitle: Text(
              '${session.startTime.toString().split('.')[0]} - '
              '${session.endTime?.toString().split('.')[0] ?? 'In progress'}',
            ),
            trailing: Chip(
              label: Text(session.overallStatus.toString().split('.').last.toUpperCase()),
              backgroundColor: session.overallStatus == VerificationStatus.pass
                  ? Colors.green.shade100
                  : Colors.red.shade100,
            ),
            onTap: () => _showSessionDetails(session),
          ),
        );
      },
    );
  }

  Widget _buildSettingsTab(VerificationProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verification Settings',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          // Auto-run settings
          SwitchListTile(
            title: const Text('Auto-run verification on app start'),
            subtitle: const Text('Automatically run verification when the app launches'),
            value: provider.autoRunEnabled,
            onChanged: (value) => provider.setAutoRunEnabled(value),
          ),

          const Divider(),

          // Performance monitoring
          SwitchListTile(
            title: const Text('Performance monitoring'),
            subtitle: const Text('Track execution times and resource usage'),
            value: provider.performanceMonitoringEnabled,
            onChanged: (value) => provider.setPerformanceMonitoringEnabled(value),
          ),

          const Divider(),

          // Notification settings
          SwitchListTile(
            title: const Text('Failure notifications'),
            subtitle: const Text('Show notifications when verification fails'),
            value: provider.notificationsEnabled,
            onChanged: (value) => provider.setNotificationsEnabled(value),
          ),

          const Divider(),

          // Report settings
          ListTile(
            title: const Text('Report format'),
            subtitle: Text(provider.reportFormat),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _showReportFormatDialog,
          ),

          const Divider(),

          // Actions
          ElevatedButton.icon(
            onPressed: _clearHistory,
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear History'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade100,
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendAnalysisCard(TrendAnalysis trends) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trend Analysis',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildTrendItem('Overall Trend', trends.overallTrend.toUpperCase(), _getTrendColor(trends.overallTrend)),
            _buildTrendItem('Improving', trends.improvingComponents.length.toString(), Colors.green),
            _buildTrendItem('Declining', trends.decliningComponents.length.toString(), Colors.red),
            _buildTrendItem('Consistently Passing', trends.consistentlyPassing.length.toString(), Colors.blue),
            _buildTrendItem('Consistently Failing', trends.consistentlyFailing.length.toString(), Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailurePatternCard(FailurePattern pattern) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.error,
          color: _getSeverityColor(pattern.severity),
        ),
        title: Text(pattern.pattern),
        subtitle: Text('${pattern.frequency} occurrences • ${pattern.affectedComponents.length} components'),
        trailing: Chip(
          label: Text(pattern.severity.toUpperCase()),
          backgroundColor: _getSeverityColor(pattern.severity).withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(String recommendation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.blue.shade50,
      child: ListTile(
        leading: const Icon(Icons.lightbulb, color: Colors.blue),
        title: Text(recommendation),
      ),
    );
  }

  // Helper methods
  String _calculateSuccessRate(List<VerificationResult> results) {
    if (results.isEmpty) return '0%';
    final passed = results.where((r) => r.status == VerificationStatus.pass).length;
    return '${((passed / results.length) * 100).round()}%';
  }

  String _calculateAverageDuration(List<VerificationResult> results) {
    final durations = results.where((r) => r.duration != null).map((r) => r.duration!.inSeconds);
    if (durations.isEmpty) return '0s';
    final avg = durations.reduce((a, b) => a + b) / durations.length;
    return '${avg.round()}s';
  }

  int _countHighPriorityFailures(List<VerificationResult> results) {
    return results.where((r) => r.status == VerificationStatus.fail && r.priority >= 4).length;
  }

  VerificationResult _componentAggregationToResult(ComponentAggregation agg) {
    return VerificationResult(
      componentName: agg.componentName,
      status: agg.successRate >= 80 ? VerificationStatus.pass : VerificationStatus.fail,
      details: 'Success rate: ${agg.successRate}%',
      priority: agg.averagePriority,
      duration: Duration(seconds: agg.averageDurationSeconds),
    );
  }

  Color _getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'improving': return Colors.green;
      case 'declining': return Colors.red;
      case 'stable': return Colors.blue;
      default: return Colors.grey;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical': return Colors.red;
      case 'high': return Colors.orange;
      case 'medium': return Colors.yellow;
      case 'low': return Colors.green;
      default: return Colors.grey;
    }
  }

  // Action methods
  void _refreshData() {
    final provider = context.read<VerificationProvider>();
    provider.refreshData();
  }

  void _startVerification() async {
    setState(() => _isRunningVerification = true);

    try {
      final provider = context.read<VerificationProvider>();
      final runner = VerificationRunner();

      await runner.runVerification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification completed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRunningVerification = false);
      }
    }
  }

  void _stopVerification() {
    setState(() => _isRunningVerification = false);
    // Implementation would cancel running verification
  }

  void _generateReport() async {
    final provider = context.read<VerificationProvider>();
    final session = provider.currentSession;

    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No verification session available')),
      );
      return;
    }

    try {
      final reportService = VerificationReportService(provider.evidenceService);
      final reportHtml = await reportService.generateSessionReport(session);

      // In a real app, this would save to file or share
      // For now, just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report generated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate report: $e')),
      );
    }
  }

  void _showSessionDetails(VerificationSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Session ${session.sessionId}'),
        content: VerificationDetailsPanel(session: session),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showReportFormatDialog() {
    final provider = context.read<VerificationProvider>();
    final formats = ['HTML', 'JSON', 'PDF'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Report Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: formats.map((format) => ListTile(
            title: Text(format),
            leading: Radio<String>(
              value: format,
              groupValue: provider.reportFormat,
              onChanged: (value) {
                if (value != null) {
                  provider.setReportFormat(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          )).toList(),
        ),
      ),
    );
  }

  void _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all verification history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final provider = context.read<VerificationProvider>();
      await provider.clearHistory();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('History cleared successfully')),
      );
    }
  }
}
