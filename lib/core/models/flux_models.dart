import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// 🌊 Flux Ledger (流式记账) - 核心数据模型
///
/// 重新定义财务数据模型，从静态实体到动态流转
/// 核心理念：一切都是资金的流动过程

// ==================== 核心流实体 ====================

/// 资金流 (Flow) - Flux Ledger的核心实体
/// 代表一次完整的资金流动事件
class Flow extends Equatable {
  const Flow({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.source,
    required this.destination,
    required this.category,
    required this.tags,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 创建新的资金流
  factory Flow.create({
    required String userId,
    required FlowType type,
    required double amount,
    required String currency,
    required FlowSource source,
    required FlowDestination destination,
    required FlowCategory category,
    List<FlowTag> tags = const [],
    FlowMetadata? metadata,
  }) {
    final now = DateTime.now();
    return Flow(
      id: const Uuid().v4(),
      userId: userId,
      type: type,
      amount: FlowAmount(value: amount, currency: currency),
      source: source,
      destination: destination,
      category: category,
      tags: tags,
      metadata: metadata ?? FlowMetadata.empty(),
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 流ID
  final String id;

  /// 用户ID
  final String userId;

  /// 流类型
  final FlowType type;

  /// 流金额
  final FlowAmount amount;

  /// 流来源
  final FlowSource source;

  /// 流去向
  final FlowDestination destination;

  /// 流分类
  final FlowCategory category;

  /// 流标签
  final List<FlowTag> tags;

  /// 流元数据
  final FlowMetadata metadata;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  /// 复制并修改资金流对象
  Flow copyWith({
    String? id,
    String? userId,
    FlowType? type,
    FlowAmount? amount,
    FlowSource? source,
    FlowDestination? destination,
    FlowCategory? category,
    List<FlowTag>? tags,
    FlowMetadata? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Flow(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        source: source ?? this.source,
        destination: destination ?? this.destination,
        category: category ?? this.category,
        tags: tags ?? this.tags,
        metadata: metadata ?? this.metadata,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        amount,
        source,
        destination,
        category,
        tags,
        metadata,
        createdAt,
        updatedAt,
      ];
}

/// 流类型枚举
enum FlowType {
  /// 收入流 - 资金流入
  income,

  /// 支出流 - 资金流出
  expense,

  /// 转账流 - 资金在账户间转移
  transfer,

  /// 投资流 - 资金投入投资
  investment,

  /// 还款流 - 债务偿还
  repayment,

  /// 调整流 - 系统自动调整或手动修正
  adjustment,
}

/// 流金额 - 支持多币种和金额范围
class FlowAmount extends Equatable {
  const FlowAmount({
    required this.value,
    required this.currency,
    this.minValue,
    this.maxValue,
    this.isApproximate = false,
  });

  factory FlowAmount.range({
    required double minValue,
    required double maxValue,
    required String currency,
    bool isApproximate = false,
  }) =>
      FlowAmount(
        value: (minValue + maxValue) / 2, // 取中间值作为主值
        currency: currency,
        minValue: minValue,
        maxValue: maxValue,
        isApproximate: isApproximate,
      );

  /// 金额数值
  final double value;

  /// 货币代码
  final String currency;

  /// 最小金额（用于范围金额）
  final double? minValue;

  /// 最大金额（用于范围金额）
  final double? maxValue;

  /// 是否为估算金额
  final bool isApproximate;

  bool get isRange => minValue != null && maxValue != null;

  @override
  List<Object?> get props =>
      [value, currency, minValue, maxValue, isApproximate];
}

/// 流来源 - 资金的来源定义
class FlowSource extends Equatable {
  const FlowSource({
    required this.id,
    required this.type,
    required this.name,
    this.description,
    this.properties = const {},
  });

  factory FlowSource.account({
    required String accountId,
    required String accountName,
  }) =>
      FlowSource(
        id: accountId,
        type: FlowSourceType.account,
        name: accountName,
        properties: {'accountId': accountId},
      );

  factory FlowSource.income({
    required String sourceId,
    required String sourceName,
  }) =>
      FlowSource(
        id: sourceId,
        type: FlowSourceType.income,
        name: sourceName,
        properties: {'sourceId': sourceId},
      );
  final String id;
  final FlowSourceType type;
  final String name;
  final String? description;
  final Map<String, dynamic> properties;

  @override
  List<Object?> get props => [id, type, name, description, properties];
}

/// 流来源类型
enum FlowSourceType {
  /// 银行账户
  account,

  /// 收入来源
  income,

  /// 投资账户
  investment,

  /// 现金
  cash,

  /// 其他来源
  other,
}

/// 流去向 - 资金的去向定义
class FlowDestination extends Equatable {
  const FlowDestination({
    required this.id,
    required this.type,
    required this.name,
    this.description,
    this.properties = const {},
  });

  factory FlowDestination.account({
    required String accountId,
    required String accountName,
  }) =>
      FlowDestination(
        id: accountId,
        type: FlowDestinationType.account,
        name: accountName,
        properties: {'accountId': accountId},
      );

  factory FlowDestination.expense({
    required String categoryId,
    required String categoryName,
  }) =>
      FlowDestination(
        id: categoryId,
        type: FlowDestinationType.expense,
        name: categoryName,
        properties: {'categoryId': categoryId},
      );
  final String id;
  final FlowDestinationType type;
  final String name;
  final String? description;
  final Map<String, dynamic> properties;

  @override
  List<Object?> get props => [id, type, name, description, properties];
}

/// 流去向类型
enum FlowDestinationType {
  /// 银行账户
  account,

  /// 支出类别
  expense,

  /// 投资标的
  investment,

  /// 储蓄目标
  savings,

  /// 其他去向
  other,
}

/// 流类别 - 更细粒度的分类系统
class FlowCategory extends Equatable {
  const FlowCategory({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    this.parentId,
    this.description,
  });
  final String id;
  final String name;
  final String? parentId;
  final FlowCategoryType type;
  final String icon;
  final String color;
  final String? description;

  bool get isSubcategory => parentId != null;

  @override
  List<Object?> get props =>
      [id, name, parentId, type, icon, color, description];
}

/// 流类别类型
enum FlowCategoryType {
  /// 收入类别
  income,

  /// 支出类别
  expense,

  /// 转账类别
  transfer,

  /// 投资类别
  investment,
}

/// 流标签 - 灵活的标记系统
class FlowTag extends Equatable {
  const FlowTag({
    required this.id,
    required this.name,
    required this.color,
    required this.type,
    this.description,
  });
  final String id;
  final String name;
  final String color;
  final String? description;
  final FlowTagType type;

  @override
  List<Object?> get props => [id, name, color, description, type];
}

/// 流标签类型
enum FlowTagType {
  /// 场景标签 (如: 旅行, 聚餐, 购物)
  scenario,

  /// 情感标签 (如: 必要, 冲动, 快乐)
  emotion,

  /// 频率标签 (如: 一次性, 定期, 季节性)
  frequency,

  /// 优先级标签 (如: 高, 中, 低)
  priority,

  /// 自定义标签
  custom,
}

/// 流元数据 - 扩展信息存储
class FlowMetadata extends Equatable {
  const FlowMetadata({
    this.notes,
    this.attachments = const [],
    this.customFields = const {},
    this.recurrence,
    this.location,
    this.relatedFlowIds = const [],
  });

  factory FlowMetadata.empty() => const FlowMetadata();
  final String? notes;
  final List<String> attachments;
  final Map<String, dynamic> customFields;
  final FlowRecurrence? recurrence;
  final String? location;
  final List<String> relatedFlowIds;

  @override
  List<Object?> get props => [
        notes,
        attachments,
        customFields,
        recurrence,
        location,
        relatedFlowIds,
      ];
}

/// 流重复规则
class FlowRecurrence extends Equatable {
  const FlowRecurrence({
    required this.type,
    required this.interval,
    this.daysOfWeek,
    this.daysOfMonth,
    this.endDate,
  });
  final RecurrenceType type;
  final int interval;
  final List<int>? daysOfWeek; // 1-7 (周一到周日)
  final List<int>? daysOfMonth; // 1-31
  final DateTime? endDate;

  @override
  List<Object?> get props => [type, interval, daysOfWeek, daysOfMonth, endDate];
}

/// 重复类型
enum RecurrenceType {
  /// 每天
  daily,

  /// 每周
  weekly,

  /// 每月
  monthly,

  /// 每年
  yearly,

  /// 自定义间隔
  custom,
}

/// 流健康状态 - 财务健康状况评估
enum FlowHealthStatus {
  /// 优秀
  excellent,

  /// 良好
  good,

  /// 健康
  healthy,

  /// 中性/正常
  neutral,

  /// 警告/需要关注
  warning,

  /// 危险/需要立即行动
  danger,

  /// 危险/需要立即行动
  critical,
}

// ==================== 流管道系统 ====================

/// 流管道 (FlowStream) - 持续的资金流动渠道
/// 代表长期的收入来源、支出项目或转账规则
class FlowStream extends Equatable {
  const FlowStream({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.amount,
    required this.config,
    required this.createdAt,
    required this.updatedAt,
    this.lastExecutionAt,
  });

  factory FlowStream.create({
    required String userId,
    required String name,
    required String description,
    required FlowStreamType type,
    required FlowAmount amount,
    required FlowStreamConfig config,
  }) {
    final now = DateTime.now();
    return FlowStream(
      id: const Uuid().v4(),
      userId: userId,
      name: name,
      description: description,
      type: type,
      status: FlowStreamStatus.active,
      amount: amount,
      config: config,
      createdAt: now,
      updatedAt: now,
    );
  }
  final String id;
  final String userId;
  final String name;
  final String description;
  final FlowStreamType type;
  final FlowStreamStatus status;
  final FlowAmount amount;
  final FlowStreamConfig config;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastExecutionAt;

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        type,
        status,
        amount,
        config,
        createdAt,
        updatedAt,
        lastExecutionAt,
      ];
}

/// 流管道类型
enum FlowStreamType {
  /// 收入管道 (如: 工资, 投资收益)
  income,

  /// 支出管道 (如: 房贷, 保险, 订阅服务)
  expense,

  /// 转账管道 (如: 定期储蓄转账)
  transfer,

  /// 投资管道 (如: 定投计划)
  investment,
}

/// 流管道状态
enum FlowStreamStatus {
  /// 活跃
  active,

  /// 暂停
  paused,

  /// 已完成
  completed,

  /// 已取消
  cancelled,
}

/// 流管道配置
class FlowStreamConfig extends Equatable {
  // 执行金额容差

  const FlowStreamConfig({
    required this.recurrence,
    required this.source,
    required this.destination,
    required this.category,
    required this.trigger,
    this.tags = const [],
    this.autoExecute = false,
    this.tolerance,
  });
  final FlowRecurrence recurrence;
  final FlowSource source;
  final FlowDestination destination;
  final FlowCategory category;
  final List<FlowTag> tags;
  final StreamTrigger trigger;
  final bool autoExecute;
  final double? tolerance;

  @override
  List<Object?> get props => [
        recurrence,
        source,
        destination,
        category,
        tags,
        trigger,
        autoExecute,
        tolerance,
      ];
}

/// 流触发器
class StreamTrigger extends Equatable {
  const StreamTrigger({
    required this.type,
    required this.conditions,
  });
  final TriggerType type;
  final Map<String, dynamic> conditions;

  @override
  List<Object?> get props => [type, conditions];
}

/// 触发器类型
enum TriggerType {
  /// 时间触发 (定时执行)
  time,

  /// 条件触发 (满足条件时执行)
  condition,

  /// 手动触发
  manual,

  /// 事件触发 (特定事件发生时)
  event,
}

// ==================== 流模式识别 ====================

/// 流模式 (FlowPattern) - AI识别的资金流动模式
class FlowPattern extends Equatable {
  const FlowPattern({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.data,
    required this.confidence,
    required this.firstDetected,
    required this.lastUpdated,
    required this.isActive,
  });
  final String id;
  final String userId;
  final String name;
  final PatternType type;
  final FlowPatternData data;
  final PatternConfidence confidence;
  final DateTime firstDetected;
  final DateTime lastUpdated;
  final bool isActive;

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        type,
        data,
        confidence,
        firstDetected,
        lastUpdated,
        isActive,
      ];
}

/// 模式类型
enum PatternType {
  /// 周期性模式 (如: 月薪, 月租)
  periodic,

  /// 趋势性模式 (如: 消费逐渐增加)
  trending,

  /// 事件性模式 (如: 购物节消费高峰)
  event,

  /// 季节性模式 (如: 夏季空调费增加)
  seasonal,

  /// 异常模式 (如: 异常大额支出)
  anomaly,
}

/// 模式数据
class FlowPatternData extends Equatable {
  const FlowPatternData({
    required this.dataPoints,
    required this.metrics,
    required this.attributes,
  });
  final List<FlowDataPoint> dataPoints;
  final PatternMetrics metrics;
  final Map<String, dynamic> attributes;

  @override
  List<Object?> get props => [dataPoints, metrics, attributes];
}

/// 模式数据点
class FlowDataPoint extends Equatable {
  const FlowDataPoint({
    required this.timestamp,
    required this.value,
    required this.metadata,
  });
  final DateTime timestamp;
  final double value;
  final Map<String, dynamic> metadata;

  @override
  List<Object?> get props => [timestamp, value, metadata];
}

/// 模式指标
class PatternMetrics extends Equatable {
  // 对财务的影响程度

  const PatternMetrics({
    required this.frequency,
    required this.regularity,
    required this.predictability,
    required this.impact,
  });
  final double frequency; // 发生频率
  final double regularity; // 规律性 (0-1)
  final double predictability; // 可预测性 (0-1)
  final double impact;

  @override
  List<Object?> get props => [frequency, regularity, predictability, impact];
}

/// 模式置信度
class PatternConfidence extends Equatable {
  // 各影响因素的置信度

  const PatternConfidence({
    required this.overall,
    required this.factors,
  });
  final double overall; // 总体置信度 (0-1)
  final Map<String, double> factors;

  @override
  List<Object?> get props => [overall, factors];
}

// ==================== 流洞察系统 ====================

/// 流洞察 (FlowInsight) - AI生成的财务洞察
class FlowInsight extends Equatable {
  const FlowInsight({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.severity,
    required this.data,
    required this.relatedFlowIds,
    required this.generatedAt,
    this.expiresAt,
    this.isRead = false,
    this.isActioned = false,
  });
  final String id;
  final String userId;
  final InsightType type;
  final String title;
  final String description;
  final InsightSeverity severity;
  final InsightData data;
  final List<String> relatedFlowIds;
  final DateTime generatedAt;
  final DateTime? expiresAt;
  final bool isRead;
  final bool isActioned;

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        title,
        description,
        severity,
        data,
        relatedFlowIds,
        generatedAt,
        expiresAt,
        isRead,
        isActioned,
      ];
}

/// 洞察类型
enum InsightType {
  /// 机会洞察 (如: 可以投资的机会)
  opportunity,

  /// 风险洞察 (如: 支出超预算风险)
  risk,

  /// 模式洞察 (如: 发现消费模式)
  pattern,

  /// 优化洞察 (如: 预算优化建议)
  optimization,

  /// 预测洞察 (如: 未来现金流预测)
  prediction,
}

/// 洞察严重程度
enum InsightSeverity {
  /// 低优先级
  low,

  /// 中等优先级
  medium,

  /// 高优先级
  high,

  /// 紧急
  urgent,
}

/// 洞察数据
class InsightData extends Equatable {
  const InsightData({
    required this.metrics,
    required this.recommendations,
    required this.visualizationData,
  });
  final Map<String, dynamic> metrics;
  final List<InsightRecommendation> recommendations;
  final Map<String, dynamic> visualizationData;

  @override
  List<Object?> get props => [metrics, recommendations, visualizationData];
}

/// 洞察建议
class InsightRecommendation extends Equatable {
  const InsightRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.action,
    required this.parameters,
    required this.expectedImpact,
  });
  final String id;
  final String title;
  final String description;
  final RecommendationAction action;
  final Map<String, dynamic> parameters;
  final double expectedImpact;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        action,
        parameters,
        expectedImpact,
      ];
}

/// 建议行动类型
enum RecommendationAction {
  /// 创建新流
  createFlow,

  /// 修改现有流
  modifyFlow,

  /// 暂停流
  pauseFlow,

  /// 停止流
  stopFlow,

  /// 调整预算
  adjustBudget,

  /// 查看详情
  viewDetails,
}
