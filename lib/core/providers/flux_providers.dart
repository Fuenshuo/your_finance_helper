/// [FLUX] Flux Ledger 核心提供者
///
/// 基于Riverpod + Provider的混合状态管理架构
/// 支持流式数据和实时响应
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_finance_flutter/core/models/flux_models.dart'
    as flux_models;
import 'package:your_finance_flutter/core/providers/stream_insights_flag_provider.dart';
import 'package:your_finance_flutter/core/services/ai/ai_config_service.dart';
import 'package:your_finance_flutter/core/services/ai/ai_service_factory.dart'
    as ai_factory;
import 'package:your_finance_flutter/core/services/ai/ai_service_factory.dart';
import 'package:your_finance_flutter/core/services/ai/prompts/prompt_loader.dart';
import 'package:your_finance_flutter/core/services/dio_http_service.dart';
import 'package:your_finance_flutter/core/services/flux_services.dart';
import 'package:your_finance_flutter/core/utils/performance_monitor.dart';
import 'package:your_finance_flutter/features/insights/services/analysis_data_source.dart';
import 'package:your_finance_flutter/features/insights/services/serverless_ai_data_source.dart';
import 'package:your_finance_flutter/features/insights/services/stream_insights_analysis_service.dart';

/// Feature flag identifiers (Flux Stream + Insights merge rollout).
const String streamInsightsFeatureFlag = 'stream_insights';

/// Default state now keeps the merged UI enabled unless explicitly disabled.
bool get streamInsightsFlagDefaultValue => true;

/// 流仪表板提供者 - 核心数据概览
class FlowDashboardProvider extends ChangeNotifier {
  FlowDashboardData _dashboardData = FlowDashboardData.empty();
  flux_models.FlowHealthStatus _overallHealth =
      flux_models.FlowHealthStatus.neutral;
  bool _isLoading = false;
  String? _error;

  FlowDashboardData get dashboardData => _dashboardData;
  flux_models.FlowHealthStatus get overallHealth => _overallHealth;
  bool get isLoading => _isLoading;
  String? get error => _error;

  StreamSubscription<dynamic>? _analyticsSubscription;

  Future<void> initialize() async {
    await loadDashboard();
    _setupRealtimeUpdates();
  }

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 获取最近30天的资金流数据
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));

      final flows = await FlowStorageService().getFlows(
        period: DateTimeRange(start: startDate, end: endDate),
      );

      // 分析资金流数据
      final analytics = await FlowAnalysisService().analyzeFlows(
        flows: flows,
        period: DateTimeRange(start: startDate, end: endDate),
      );

      // 计算整体健康度
      _overallHealth = _calculateOverallHealth(analytics);

      // 构建仪表板数据
      _dashboardData = FlowDashboardData(
        period: DateTimeRange(start: startDate, end: endDate),
        totalFlows: flows.length,
        totalInflow: analytics.basicStats.totalInflow,
        totalOutflow: analytics.basicStats.totalOutflow,
        netFlow: analytics.basicStats.netFlow,
        topCategories: await _getTopCategories(flows),
        recentFlows: flows.take(5).toList(),
        healthScore: _calculateHealthScore(analytics),
        insights: await _getRecentInsights(),
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupRealtimeUpdates() {
    // 订阅实时分析数据更新
    _analyticsSubscription = FlowAnalysisService().analyticsStream.listen(
      (analytics) {
        _overallHealth = _calculateOverallHealth(analytics);
        loadDashboard(); // 重新加载仪表板数据
      },
    );
  }

  flux_models.FlowHealthStatus _calculateOverallHealth(
    FlowAnalyticsData analytics,
  ) {
    final netFlow = analytics.basicStats.netFlow;
    final anomalyCount = analytics.anomalies.length;

    if (netFlow > 0 && anomalyCount == 0) {
      return flux_models.FlowHealthStatus.healthy;
    }
    if (netFlow < -1000 || anomalyCount > 2) {
      return flux_models.FlowHealthStatus.danger;
    }
    if (netFlow < 0 || anomalyCount > 0) {
      return flux_models.FlowHealthStatus.warning;
    }

    return flux_models.FlowHealthStatus.neutral;
  }

  double _calculateHealthScore(FlowAnalyticsData analytics) {
    // 基于多种指标计算健康评分 (0-100)
    final netFlowScore =
        (analytics.basicStats.netFlow + 10000).clamp(0, 20000) / 20000 * 40;
    final anomalyScore =
        (10 - analytics.anomalies.length).clamp(0, 10) / 10 * 30;
    final regularityScore = analytics.basicStats.averageFlow > 0 ? 30 : 0;

    return (netFlowScore + anomalyScore + regularityScore).clamp(0, 100);
  }

  Future<List<CategoryFlow>> _getTopCategories(
    List<flux_models.Flow> flows,
  ) async {
    // 统计各类别资金流
    final categoryMap = <String, double>{};

    for (final flow in flows) {
      final categoryId = flow.category.id;
      final amount = flow.amount.value as num;

      categoryMap[categoryId] = (categoryMap[categoryId] ?? 0) +
          (flow.type == flux_models.FlowType.income ? amount : -amount);
    }

    // 转换为CategoryFlow列表
    return categoryMap.entries
        .map(
          (entry) => CategoryFlow(
            categoryId: entry.key,
            categoryName: entry.key, // 临时使用ID作为名称
            amount: entry.value,
            flowCount: flows.where((f) => f.category.id == entry.key).length,
          ),
        )
        .toList()
      ..sort((a, b) => b.amount.abs().compareTo(a.amount.abs()));
  }

  Future<List<flux_models.FlowInsight>> _getRecentInsights() async {
    // 获取最近的洞察
    final insights = await FlowInsightService().insightsStream.first;
    return insights
        .where(
          (insight) => insight.generatedAt.isAfter(
            DateTime.now().subtract(const Duration(days: 7)),
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    _analyticsSubscription?.cancel();
    super.dispose();
  }
}

/// 流管道提供者 - 管理持续性资金流
class FlowStreamsProvider extends ChangeNotifier {
  List<flux_models.FlowStream> _streams = [];
  bool _isLoading = false;
  String? _error;

  List<flux_models.FlowStream> get streams => _streams;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    await loadStreams();
  }

  Future<void> loadStreams() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: 实现从存储服务获取流管道数据
      _streams = [];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addStream(flux_models.FlowStream stream) async {
    // TODO: 实现添加流管道
    await loadStreams();
  }

  Future<void> updateStream(
    String streamId,
    flux_models.FlowStream updatedStream,
  ) async {
    // TODO: 实现更新流管道
    await loadStreams();
  }

  Future<void> pauseStream(String streamId) async {
    // TODO: 实现暂停流管道
    await loadStreams();
  }

  Future<void> resumeStream(String streamId) async {
    // TODO: 实现恢复流管道
    await loadStreams();
  }

  Future<void> deleteStream(String streamId) async {
    // TODO: 实现删除流管道
    await loadStreams();
  }
}

/// 流洞察提供者 - 管理AI洞察
class FlowInsightsProvider extends ChangeNotifier {
  List<flux_models.FlowInsight> _insights = [];
  bool _isLoading = false;
  String? _error;

  List<flux_models.FlowInsight> get insights => _insights;
  bool get isLoading => _isLoading;
  String? get error => _error;

  StreamSubscription<dynamic>? _insightsSubscription;

  Future<void> initialize() async {
    await loadInsights();
    _setupRealtimeUpdates();
  }

  Future<void> loadInsights() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _insights = await FlowInsightService().insightsStream.first;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupRealtimeUpdates() {
    _insightsSubscription = FlowInsightService().insightsStream.listen(
      (insights) {
        _insights = insights;
        notifyListeners();
      },
    );
  }

  Future<void> markInsightAsRead(String insightId) async {
    // TODO: 更新洞察状态 - insightId: $insightId
    await loadInsights();
  }

  Future<void> markInsightAsActioned(String insightId) async {
    // TODO: 更新洞察状态 - insightId: $insightId
    await loadInsights();
  }

  @override
  void dispose() {
    _insightsSubscription?.cancel();
    super.dispose();
  }
}

/// 流分析提供者 - 数据分析和可视化
class FlowAnalyticsProvider extends ChangeNotifier {
  FlowAnalyticsData _analyticsData = FlowAnalyticsData.empty();
  bool _isLoading = false;
  String? _error;

  FlowAnalyticsData get analyticsData => _analyticsData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  StreamSubscription<dynamic>? _analyticsSubscription;

  Future<void> initialize() async {
    await loadAnalytics();
    _setupRealtimeUpdates();
  }

  Future<void> loadAnalytics({
    DateTimeRange? period,
    List<flux_models.FlowType>? flowTypes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final analysisPeriod = period ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          );

      final flows = await FlowStorageService().getFlows(
        period: analysisPeriod,
      );

      _analyticsData = await FlowAnalysisService().analyzeFlows(
        flows: flows,
        period: analysisPeriod,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupRealtimeUpdates() {
    _analyticsSubscription = FlowAnalysisService().analyticsStream.listen(
      (analytics) {
        _analyticsData = analytics;
        notifyListeners();
      },
    );
  }

  Future<void> refreshAnalytics() async {
    await loadAnalytics();
  }

  @override
  void dispose() {
    _analyticsSubscription?.cancel();
    super.dispose();
  }
}

/// Flux主题提供者 - 主题和样式管理
class FluxThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _useDynamicColors = false;

  ThemeMode get themeMode => _themeMode;
  bool get useDynamicColors => _useDynamicColors;

  Future<void> initialize() async {
    // TODO: 从存储加载主题设置
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    // TODO: 持久化设置
  }

  void toggleDynamicColors() {
    _useDynamicColors = !_useDynamicColors;
    notifyListeners();
    // TODO: 持久化设置
  }
}

/// 遗留数据提供者 - 兼容性过渡
class LegacyDataProvider extends ChangeNotifier {
  bool _isMigrating = false;
  double _migrationProgress = 0.0;
  String? _migrationError;

  bool get isMigrating => _isMigrating;
  double get migrationProgress => _migrationProgress;
  String? get migrationError => _migrationError;

  Future<void> initialize() async {
    // 检查是否需要数据迁移
    await checkMigrationStatus();
  }

  Future<void> checkMigrationStatus() async {
    // TODO: 检查遗留数据是否存在
    // 如果存在，启动迁移流程
  }

  Future<void> startMigration() async {
    _isMigrating = true;
    _migrationProgress = 0.0;
    _migrationError = null;
    notifyListeners();

    try {
      // TODO: 实现数据迁移逻辑
      // 1. 读取遗留数据
      // 2. 转换为Flux模型
      // 3. 保存到新存储
      // 4. 更新进度

      _migrationProgress = 1.0;
    } catch (e) {
      _migrationError = e.toString();
    } finally {
      _isMigrating = false;
      notifyListeners();
    }
  }
}

// ==================== 数据模型 ====================

/// 仪表板数据
class FlowDashboardData {
  const FlowDashboardData({
    required this.period,
    required this.totalFlows,
    required this.totalInflow,
    required this.totalOutflow,
    required this.netFlow,
    required this.topCategories,
    required this.recentFlows,
    required this.healthScore,
    required this.insights,
    required this.lastUpdated,
  });

  factory FlowDashboardData.empty() => FlowDashboardData(
        period: DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        ),
        totalFlows: 0,
        totalInflow: 0,
        totalOutflow: 0,
        netFlow: 0,
        topCategories: [],
        recentFlows: [],
        healthScore: 0,
        insights: [],
        lastUpdated: DateTime.now(),
      );
  final DateTimeRange period;
  final int totalFlows;
  final double totalInflow;
  final double totalOutflow;
  final double netFlow;
  final List<CategoryFlow> topCategories;
  final List<flux_models.Flow> recentFlows;
  final double healthScore;
  final List<flux_models.FlowInsight> insights;
  final DateTime lastUpdated;
}

/// 类别资金流
class CategoryFlow {
  const CategoryFlow({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.flowCount,
  });
  final String categoryId;
  final String categoryName;
  final double amount;
  final int flowCount;
}

// ==================== Riverpod提供者 ====================

/// 流引擎提供者
final flowEngineProvider = Provider<FlowEngine>((ref) => FlowEngine());

/// 流分析服务提供者
final flowAnalysisServiceProvider =
    Provider<FlowAnalysisService>((ref) => FlowAnalysisService());

/// 流洞察服务提供者
final flowInsightServiceProvider =
    Provider<FlowInsightService>((ref) => FlowInsightService());

/// 实时流服务提供者
final realtimeFlowServiceProvider =
    Provider<RealtimeFlowService>((ref) => RealtimeFlowService());

/// 流仪表板状态提供者
final flowDashboardStateProvider =
    StateNotifierProvider<FlowDashboardNotifier, AsyncValue<FlowDashboardData>>(
  FlowDashboardNotifier.new,
);

class FlowDashboardNotifier
    extends StateNotifier<AsyncValue<FlowDashboardData>> {
  FlowDashboardNotifier(this.ref) : super(const AsyncValue.loading()) {
    initialize();
  }
  final Ref ref;

  Future<void> initialize() async {
    state = const AsyncValue.loading();

    try {
      // TODO: 实现仪表板数据加载
      final dashboardData = FlowDashboardData.empty();
      state = AsyncValue.data(dashboardData);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await initialize();
  }
}

/// Stream + Insights merge feature flag provider.
final streamInsightsFlagStateProvider =
    ChangeNotifierProvider<StreamInsightsFlagProvider>((ref) {
  final provider = StreamInsightsFlagProvider(
    flagKey: streamInsightsFeatureFlag,
    defaultValue: streamInsightsFlagDefaultValue,
  );
  unawaited(provider.initialize());
  ref.onDispose(provider.dispose);
  return provider;
});

/// HTTP service provider
final dioHttpServiceProvider = Provider<DioHttpService>((ref) {
  throw UnimplementedError('Use DioHttpService.getInstance() instead');
});

/// Performance monitor provider
final performanceMonitorProvider =
    Provider<PerformanceMonitor>((ref) => PerformanceMonitor());

/// Prompt loader provider
final promptLoaderProvider = Provider<PromptLoader>((ref) => PromptLoader());

/// AI service factory provider
final aiServiceFactoryProvider =
    Provider<AiServiceFactoryImpl>((ref) => ai_factory.aiServiceFactory);

/// AI config service provider
final aiConfigServiceProvider = FutureProvider<AiConfigService>(
    (ref) async => AiConfigService.getInstance());

/// Analysis data source provider - fixed to Serverless AI
final analysisDataSourceProvider =
    FutureProvider<AnalysisDataSource>((ref) async {
  final aiFactory = ref.watch(aiServiceFactoryProvider);
  final aiConfigService = await ref.watch(aiConfigServiceProvider.future);
  return ServerlessAiDataSource(aiFactory, aiConfigService);
});

/// Stream insights analysis service provider (facade pattern)
final streamInsightsAnalysisServiceProvider =
    FutureProvider<StreamInsightsAnalysisService>((ref) async {
  final dataSource = await ref.watch(analysisDataSourceProvider.future);
  return StreamInsightsAnalysisService(dataSource);
});
