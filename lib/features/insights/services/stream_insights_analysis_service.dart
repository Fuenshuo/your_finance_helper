import 'package:dio/dio.dart';
import 'package:your_finance_flutter/core/models/analysis_summary.dart';
import 'package:your_finance_flutter/core/models/flux_view_state.dart';
import 'package:your_finance_flutter/core/services/dio_http_service.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';

/// Lightweight client that talks to the Stream Insights analysis + telemetry API.
class StreamInsightsAnalysisService {
  StreamInsightsAnalysisService._(this._http);

  final DioHttpService _http;

  static StreamInsightsAnalysisService? _instance;

  /// Returns the shared instance backed by a lazily initialized [DioHttpService].
  static Future<StreamInsightsAnalysisService> getInstance() async {
    if (_instance != null) {
      return _instance!;
    }
    final http = await DioHttpService.getInstance();
    _instance = StreamInsightsAnalysisService._(http);
    return _instance!;
  }

  /// Calls `/insights/analysis` and returns the generated [AnalysisSummary].
  Future<AnalysisSummary> requestAnalysis({
    required List<String> transactionIds,
    required FluxTimeframe timeframe,
    required FluxPane pane,
    required bool flagEnabled,
  }) async {
    final response = await _http.post<Map<String, dynamic>>(
      '/insights/analysis',
      data: <String, dynamic>{
        'transactionIds': transactionIds,
        'timeframe': timeframe.name,
        'pane': pane.name,
        'flagEnabled': flagEnabled,
      },
    );
    final data = response.data;
    if (data == null) {
      throw const FormatException('Empty analysis summary response');
    }
    return AnalysisSummary.fromJson(data);
  }

  /// Sends `/telemetry/stream-insights` events. Failures are logged and ignored.
  Future<void> logTelemetry(StreamInsightsTelemetryEvent event) async {
    try {
      await _http.post<void>(
        '/telemetry/stream-insights',
        data: event.toJson(),
      );
    } on DioException catch (error) {
      Logger.warning(
        'StreamInsightsAnalysisService',
        'Telemetry upload failed: ${error.message ?? error.toString()}',
      );
    }
  }
}
