import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 安全存储服务 - 处理敏感数据的安全存储
class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // iOS Keychain选项
  static const IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  // Android选项
  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  /// 存储敏感数据
  static Future<void> writeSecureData(String key, String value) async {
    try {
      await _storage.write(
        key: key,
        value: value,
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
    } on Exception catch (e) {
      throw Exception('安全存储写入失败: $e');
    }
  }

  /// 读取敏感数据
  static Future<String?> readSecureData(String key) async {
    try {
      return await _storage.read(
        key: key,
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
    } on Exception catch (e) {
      throw Exception('安全存储读取失败: $e');
    }
  }

  /// 删除敏感数据
  static Future<void> deleteSecureData(String key) async {
    try {
      await _storage.delete(
        key: key,
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
    } on Exception catch (e) {
      throw Exception('安全存储删除失败: $e');
    }
  }

  /// 检查数据是否存在
  static Future<bool> containsKey(String key) async {
    try {
      final value = await _storage.read(
        key: key,
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
      return value != null;
    } catch (e) {
      return false;
    }
  }

  /// 获取所有存储的键
  static Future<Set<String>> getAllKeys() async {
    try {
      final allData = await _storage.readAll(
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
      return allData.keys.toSet();
    } on Exception catch (e) {
      throw Exception('获取存储键失败: $e');
    }
  }

  /// 清空所有安全存储数据
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll(
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
    } on Exception catch (e) {
      throw Exception('清空安全存储失败: $e');
    }
  }

  /// 安全存储金融数据的便捷方法
  static Future<void> saveFinancialData(
    String dataId,
    String encryptedData,
  ) async {
    await writeSecureData('financial_$dataId', encryptedData);
  }

  /// 读取金融数据的便捷方法
  static Future<String?> loadFinancialData(String dataId) async =>
      readSecureData('financial_$dataId');

  /// 删除金融数据的便捷方法
  static Future<void> removeFinancialData(String dataId) async {
    await deleteSecureData('financial_$dataId');
  }
}
