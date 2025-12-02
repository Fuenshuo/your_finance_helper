import '../../../core/models/analysis_summary.dart';
import '../../../core/models/transaction.dart';
import '../../../core/models/flux_view_state.dart';

/// Abstract interface for transaction analysis implementations.
/// Supports multiple strategies (HTTP, Serverless AI) through strategy pattern.
///
/// This interface allows seamless switching between different analysis
/// implementations without changing the calling code.
abstract class AnalysisDataSource {
  /// Analyzes a transaction and returns insights.
  ///
  /// This method must never throw exceptions. Implementations should handle
  /// all errors internally and return safe default values (silent failure).
  ///
  /// [transaction] The transaction to analyze
  /// [timeframe] Analysis context (daily, weekly, monthly)
  /// Returns analysis results or safe defaults on failure
  Future<AnalysisSummary> analyze(Transaction transaction, FluxTimeframe timeframe);
}
