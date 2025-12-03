import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_finance_flutter/core/services/shared_preferences_service.dart';
import 'package:your_finance_flutter/core/services/base_service.dart';

void main() {
  group('SharedPreferencesService Tests', () {
    late SharedPreferencesService service;

    setUp(() async {
      // 使用mock SharedPreferences进行测试
      SharedPreferences.setMockInitialValues({
        'test_string': 'test_value',
        'test_int': 42,
        'test_double': 3.14,
        'test_bool': true,
        'test_string_list': ['item1', 'item2'],
      });

      service = await SharedPreferencesService.getInstance();
    });

    tearDown(() async {
      // 清理测试数据，但保留一些用于统计测试
      // 注意：tearDown在每个测试后运行，所以统计测试需要特殊处理
    });

    test('should initialize correctly', () async {
      // Service should be initialized after getInstance
      expect(service.serviceName, 'SharedPreferencesService');
      expect(service.isLoading, false);

      // Health check should pass
      final healthy = await service.healthCheck();
      expect(healthy, true);
    });

    test('should get string values', () {
      final value = service.getString('test_string');
      expect(value, 'test_value');
    });

    test('should get int values', () {
      final value = service.getInt('test_int');
      expect(value, 42);
    });

    test('should get double values', () {
      final value = service.getDouble('test_double');
      expect(value, 3.14);
    });

    test('should get bool values', () {
      final value = service.getBool('test_bool');
      expect(value, true);
    });

    test('should get string list values', () {
      final value = service.getStringList('test_string_list');
      expect(value, ['item1', 'item2']);
    });

    test('should return null for non-existent keys', () {
      final value = service.getString('non_existent');
      expect(value, null);
    });

    test('should set string values', () async {
      final success = await service.setString('new_string', 'new_value');
      expect(success, true);
      expect(service.getString('new_string'), 'new_value');
    });

    test('should set int values', () async {
      final success = await service.setInt('new_int', 123);
      expect(success, true);
      expect(service.getInt('new_int'), 123);
    });

    test('should set double values', () async {
      final success = await service.setDouble('new_double', 2.71);
      expect(success, true);
      expect(service.getDouble('new_double'), 2.71);
    });

    test('should set bool values', () async {
      final success = await service.setBool('new_bool', false);
      expect(success, true);
      expect(service.getBool('new_bool'), false);
    });

    test('should set string list values', () async {
      final success = await service.setStringList('new_list', ['a', 'b', 'c']);
      expect(success, true);
      expect(service.getStringList('new_list'), ['a', 'b', 'c']);
    });

    test('should check key existence', () {
      expect(service.containsKey('test_string'), true);
      expect(service.containsKey('non_existent'), false);
    });

    test('should get all keys', () {
      final keys = service.getKeys();
      expect(keys, contains('test_string'));
      expect(keys, contains('test_int'));
      expect(keys, contains('test_double'));
      expect(keys, contains('test_bool'));
      expect(keys, contains('test_string_list'));
    });

    test('should remove keys', () async {
      expect(service.containsKey('test_string'), true);
      final success = await service.remove('test_string');
      expect(success, true);
      expect(service.containsKey('test_string'), false);
    });

    test('should clear all data', () async {
      expect(service.getKeys().isNotEmpty, true);
      final success = await service.clear();
      expect(success, true);
      expect(service.getKeys().isEmpty, true);
    });

    test('should bulk set values', () async {
      final values = {
        'bulk_string': 'bulk_value',
        'bulk_int': 999,
        'bulk_bool': false,
      };

      final results = await service.setBulk(values);

      expect(results['bulk_string'], true);
      expect(results['bulk_int'], true);
      expect(results['bulk_bool'], true);

      expect(service.getString('bulk_string'), 'bulk_value');
      expect(service.getInt('bulk_int'), 999);
      expect(service.getBool('bulk_bool'), false);
    });

    test('should bulk get values', () async {
      // 设置测试数据
      await service.setString('bulk_get_string', 'bulk_value');
      await service.setInt('bulk_get_int', 456);

      final keys = ['bulk_get_string', 'bulk_get_int', 'non_existent'];
      final results = service.getBulk(keys);

      expect(results['bulk_get_string'], 'bulk_value');
      expect(results['bulk_get_int'], 456);
      expect(results['non_existent'], null);
    });

    test('should export data', () async {
      // 设置测试数据
      await service.setString('export_test_string', 'export_value');
      await service.setInt('export_test_int', 123);

      final data = service.exportData();

      expect(data, isA<Map<String, dynamic>>());
      expect(data['export_test_string'], 'export_value');
      expect(data['export_test_int'], 123);
    });

    test('should import data', () async {
      final importData = {
        'imported_string': 'imported_value',
        'imported_int': 777,
      };

      final success = await service.importData(importData);
      expect(success, true);

      expect(service.getString('imported_string'), 'imported_value');
      expect(service.getInt('imported_int'), 777);
    });

    test('should provide storage stats', () {
      final stats = service.getStorageStats();

      expect(stats, isA<Map<String, dynamic>>());
      expect(stats['totalKeys'], isA<int>());
      expect(stats['estimatedSize'], isA<int>());
      expect(stats['keyTypes'], isA<Map<String, int>>());
    });

    test('should provide service stats', () {
      final stats = service.getStats();

      expect(stats, isA<Map<String, dynamic>>());
      expect(stats['serviceName'], 'SharedPreferencesService');
      expect(stats['state'], ServiceState.initialized.name);
      expect(stats['keysCount'], isA<int>());
    });

    test('should perform health check', () async {
      final healthy = await service.healthCheck();
      expect(healthy, true);
    });

    test('should handle operation errors gracefully', () async {
      // 模拟错误情况
      SharedPreferences.setMockInitialValues({});

      final errorService = await SharedPreferencesService.getInstance();

      // 测试在错误情况下的行为
      final stringValue = errorService.getString('non_existent');
      expect(stringValue, null);

      final success = await errorService.setString('test', 'value');
      expect(success, isA<bool>()); // 应该不会抛出异常
    });
  });
}
