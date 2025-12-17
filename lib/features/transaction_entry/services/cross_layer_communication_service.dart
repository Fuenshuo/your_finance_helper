import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/draft_transaction.dart';
import '../models/input_validation.dart';

/// 跨层通信事件类型
enum CommunicationEvent {
  /// 草稿更新
  draftUpdated,

  /// 验证状态变更
  validationChanged,

  /// 解析完成
  parsingCompleted,

  /// 保存成功
  saveCompleted,

  /// 错误发生
  errorOccurred,

  /// UI状态变更
  uiStateChanged,
}

/// 通信事件数据
class CommunicationEventData {
  final CommunicationEvent type;
  final dynamic data;
  final DateTime timestamp;
  final String? source;

  CommunicationEventData({
    required this.type,
    this.data,
    DateTime? timestamp,
    this.source,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// 跨层通信服务接口
abstract class CrossLayerCommunicationService {
  /// 发送事件
  void sendEvent(CommunicationEvent event, dynamic data, {String? source});

  /// 监听事件
  Stream<CommunicationEventData> listenEvents([CommunicationEvent? filterType]);

  /// 监听特定类型的事件
  Stream<CommunicationEventData> listenTo(CommunicationEvent eventType);

  /// 移除监听器
  void removeListener(Function listener);

  /// 清空所有监听器
  void clearListeners();
}

/// 默认跨层通信服务实现
class DefaultCrossLayerCommunicationService
    implements CrossLayerCommunicationService {
  final StreamController<CommunicationEventData> _controller =
      StreamController.broadcast();

  @override
  void sendEvent(CommunicationEvent event, dynamic data, {String? source}) {
    final eventData = CommunicationEventData(
      type: event,
      data: data,
      source: source,
    );

    _controller.add(eventData);
  }

  @override
  Stream<CommunicationEventData> listenEvents(
      [CommunicationEvent? filterType]) {
    if (filterType == null) {
      return _controller.stream;
    }

    return _controller.stream.where((event) => event.type == filterType);
  }

  @override
  Stream<CommunicationEventData> listenTo(CommunicationEvent eventType) {
    return listenEvents(eventType);
  }

  @override
  void removeListener(Function listener) {
    // StreamController 不支持直接移除监听器
    // 这个方法为了接口兼容性而保留
  }

  @override
  void clearListeners() {
    // 广播流不支持清空监听器
    // 这个方法为了接口兼容性而保留
  }

  /// 关闭通信服务
  void dispose() {
    _controller.close();
  }
}

/// 跨层通信服务Provider
final crossLayerCommunicationServiceProvider =
    Provider<CrossLayerCommunicationService>((ref) {
  return DefaultCrossLayerCommunicationService();
});

/// 扩展方法：用于在UI层发送事件
extension CrossLayerCommunicationExtensions on WidgetRef {
  /// 发送草稿更新事件
  void sendDraftUpdated(DraftTransaction draft, {String? source}) {
    final service = read(crossLayerCommunicationServiceProvider);
    service.sendEvent(CommunicationEvent.draftUpdated, draft, source: source);
  }

  /// 发送验证状态变更事件
  void sendValidationChanged(InputValidation validation, {String? source}) {
    final service = read(crossLayerCommunicationServiceProvider);
    service.sendEvent(CommunicationEvent.validationChanged, validation,
        source: source);
  }

  /// 发送解析完成事件
  void sendParsingCompleted(DraftTransaction draft, {String? source}) {
    final service = read(crossLayerCommunicationServiceProvider);
    service.sendEvent(CommunicationEvent.parsingCompleted, draft,
        source: source);
  }

  /// 发送保存成功事件
  void sendSaveCompleted(dynamic transaction, {String? source}) {
    final service = read(crossLayerCommunicationServiceProvider);
    service.sendEvent(CommunicationEvent.saveCompleted, transaction,
        source: source);
  }

  /// 发送错误事件
  void sendErrorOccurred(String error, {String? source}) {
    final service = read(crossLayerCommunicationServiceProvider);
    service.sendEvent(CommunicationEvent.errorOccurred, error, source: source);
  }

  /// 监听草稿更新事件
  Stream<DraftTransaction> listenDraftUpdates() {
    final service = read(crossLayerCommunicationServiceProvider);
    return service
        .listenTo(CommunicationEvent.draftUpdated)
        .map((event) => event.data as DraftTransaction);
  }

  /// 监听验证状态变更事件
  Stream<InputValidation> listenValidationChanges() {
    final service = read(crossLayerCommunicationServiceProvider);
    return service
        .listenTo(CommunicationEvent.validationChanged)
        .map((event) => event.data as InputValidation);
  }

  /// 监听错误事件
  Stream<String> listenErrors() {
    final service = read(crossLayerCommunicationServiceProvider);
    return service
        .listenTo(CommunicationEvent.errorOccurred)
        .map((event) => event.data as String);
  }
}
