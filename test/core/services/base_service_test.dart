import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/core/services/base_service.dart';

/// 测试用的具体服务实现
class TestService extends StatefulService {
  TestService(this.testData);
  final String testData;

  @override
  String get serviceName => 'TestService';

  @override
  Future<void> initialize() async {
    if (isInitialized) return;

    await executeOperation('initialize', () async {
      // 模拟初始化逻辑
      await Future.delayed(const Duration(milliseconds: 10));
      setState(ServiceState.initialized);
    });
  }

  // 测试用的业务方法
  Future<String> processData(String input) async {
    return executeOperation('processData', () async {
      await Future.delayed(const Duration(milliseconds: 5));
      return '$testData-$input';
    });
  }

  // 测试用的同步方法
  String syncProcess(String input) {
    return executeSyncOperation('syncProcess', () {
      return '$testData-$input-sync';
    });
  }

  @override
  Map<String, dynamic> getStats() {
    return {
      ...super.getStats(),
      'serviceName': serviceName,
    };
  }
}

void main() {
  group('BaseService Tests', () {
    late TestService service;

    setUp(() {
      service = TestService('test');
    });

    test('should have correct service name', () {
      expect(service.serviceName, 'TestService');
    });

    test('should not be initialized initially', () {
      expect(service.isInitialized, false);
      expect(service.isLoading, false);
      expect(service.state, ServiceState.uninitialized);
    });

    test('should initialize correctly', () async {
      await service.initialize();

      expect(service.isInitialized, true);
      expect(service.isLoading, false);
      expect(service.state, ServiceState.initialized);
      expect(service.lastError, null);
    });

    test('should handle initialization errors', () async {
      final errorService = TestService('error');

      // 模拟初始化错误
      await expectLater(
        () async {
          await (errorService as dynamic).executeOperation('test', () async {
            throw Exception('Test error');
          });
        },
        throwsA(isA<Exception>()),
      );

      expect(errorService.lastError, isNotNull);
      expect(errorService.state, ServiceState.error);
    });

    test('should execute operations correctly', () async {
      await service.initialize();
      final result = await service.processData('input');

      expect(result, 'test-input');
    });

    test('should execute sync operations correctly', () async {
      await service.initialize();
      final result = service.syncProcess('input');

      expect(result, 'test-input-sync');
    });

    test('should provide stats', () async {
      await service.initialize();
      final stats = service.getStats();

      expect(stats, isA<Map<String, dynamic>>());
      expect(stats['serviceName'], 'TestService');
      expect(stats['state'], ServiceState.initialized.name);
    });

    test('should reset service', () async {
      await service.initialize();
      expect(service.isInitialized, true);

      await service.reset();
      expect(service.isInitialized, false);
      expect(service.state, ServiceState.uninitialized);
      expect(service.lastError, null);
    });

    test('should dispose service', () async {
      await service.initialize();
      expect(service.isInitialized, true);

      await service.dispose();
      expect(service.state, ServiceState.disposed);
    });

    test('should perform health check', () async {
      await service.initialize();
      final healthy = await service.healthCheck();

      expect(healthy, true);
    });
  });

  group('ServiceState Tests', () {
    test('should have correct enum values', () {
      expect(ServiceState.uninitialized, ServiceState.uninitialized);
      expect(ServiceState.initializing, ServiceState.initializing);
      expect(ServiceState.initialized, ServiceState.initialized);
      expect(ServiceState.error, ServiceState.error);
      expect(ServiceState.disposed, ServiceState.disposed);
    });
  });

  group('ServiceOperationException Tests', () {
    test('should create exception correctly', () {
      final exception = ServiceOperationException(
        'Test error',
        operation: 'testOperation',
        cause: Exception('Original error'),
      );

      expect(exception.message, 'Test error');
      expect(exception.operation, 'testOperation');
      expect(exception.cause, isA<Exception>());
    });

    test('should convert to string correctly', () {
      final exception = ServiceOperationException('Test error');
      expect(exception.toString(), 'ServiceOperationException: Test error');
    });

    test('should handle null operation', () {
      final exception = ServiceOperationException('Test error');
      expect(exception.operation, null);
    });
  });

  group('ServiceInitializationException Tests', () {
    test('should create exception correctly', () {
      final exception = ServiceInitializationException(
        'Init error',
        cause: Exception('Original error'),
      );

      expect(exception.message, 'Init error');
      expect(exception.cause, isA<Exception>());
    });

    test('should convert to string correctly', () {
      final exception = ServiceInitializationException('Init error');
      expect(exception.toString(), 'ServiceInitializationException: Init error');
    });
  });
}
