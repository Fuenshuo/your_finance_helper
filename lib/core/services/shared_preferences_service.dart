import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_finance_flutter/core/services/base_service.dart';

/// 统一的SharedPreferences服务
/// 避免多个服务重复初始化SharedPreferences实例
class SharedPreferencesService extends StatefulService {
  SharedPreferencesService._();
  static SharedPreferencesService? _instance;
  static SharedPreferences? _prefs;

  /// 获取单例实例
  static Future<SharedPreferencesService> getInstance() async {
    if (_instance == null) {
      _instance = SharedPreferencesService._();
      _prefs ??= await SharedPreferences.getInstance();
      // 初始化服务状态
      await _instance!.initialize();
    }
    return _instance!;
  }

  /// 获取SharedPreferences实例（仅供内部使用）
  static SharedPreferences? get _sharedPrefs => _prefs;

  /// 获取SharedPreferences实例（供其他服务使用）
  static SharedPreferences? get sharedPreferences => _prefs;

  @override
  String get serviceName => 'SharedPreferencesService';

  @override
  Future<void> initialize() async {
    if (isInitialized) return;

    await executeOperation('initialize', () async {
      _prefs ??= await SharedPreferences.getInstance();
      setState(ServiceState.initialized);
    });
  }

  @override
  Map<String, dynamic> getStats() => {
        'serviceName': serviceName,
        'state': state.name,
        'keysCount': _prefs?.getKeys().length ?? 0,
        'lastError': lastError,
      };

  // ============================================================================
  // 类型安全的读取方法
  // ============================================================================

  /// 读取String值
  String? getString(String key) {
    try {
      return _prefs?.getString(key);
    } catch (e) {
      debugPrint('SharedPreferencesService: 读取String失败 key=$key, error=$e');
      return null;
    }
  }

  /// 读取int值
  int? getInt(String key) {
    try {
      return _prefs?.getInt(key);
    } catch (e) {
      debugPrint('SharedPreferencesService: 读取int失败 key=$key, error=$e');
      return null;
    }
  }

  /// 读取double值
  double? getDouble(String key) {
    try {
      return _prefs?.getDouble(key);
    } catch (e) {
      debugPrint('SharedPreferencesService: 读取double失败 key=$key, error=$e');
      return null;
    }
  }

  /// 读取bool值
  bool? getBool(String key) {
    try {
      return _prefs?.getBool(key);
    } catch (e) {
      debugPrint('SharedPreferencesService: 读取bool失败 key=$key, error=$e');
      return null;
    }
  }

  /// 读取StringList值
  List<String>? getStringList(String key) {
    try {
      return _prefs?.getStringList(key);
    } catch (e) {
      debugPrint('SharedPreferencesService: 读取StringList失败 key=$key, error=$e');
      return null;
    }
  }

  // ============================================================================
  // 类型安全的新增方法
  // ============================================================================

  /// 设置String值
  Future<bool> setString(String key, String value) async {
    try {
      return await _prefs?.setString(key, value) ?? false;
    } catch (e) {
      debugPrint('SharedPreferencesService: 设置String失败 key=$key, error=$e');
      return false;
    }
  }

  /// 设置int值
  Future<bool> setInt(String key, int value) async {
    try {
      return await _prefs?.setInt(key, value) ?? false;
    } catch (e) {
      debugPrint('SharedPreferencesService: 设置int失败 key=$key, error=$e');
      return false;
    }
  }

  /// 设置double值
  Future<bool> setDouble(String key, double value) async {
    try {
      return await _prefs?.setDouble(key, value) ?? false;
    } catch (e) {
      debugPrint('SharedPreferencesService: 设置double失败 key=$key, error=$e');
      return false;
    }
  }

  /// 设置bool值
  Future<bool> setBool(String key, bool value) async {
    try {
      return await _prefs?.setBool(key, value) ?? false;
    } catch (e) {
      debugPrint('SharedPreferencesService: 设置bool失败 key=$key, error=$e');
      return false;
    }
  }

  /// 设置StringList值
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      return await _prefs?.setStringList(key, value) ?? false;
    } catch (e) {
      debugPrint('SharedPreferencesService: 设置StringList失败 key=$key, error=$e');
      return false;
    }
  }

  // ============================================================================
  // 批量操作方法
  // ============================================================================

  /// 批量设置值
  Future<Map<String, bool>> setBulk(Map<String, dynamic> values) async {
    final results = <String, bool>{};

    for (final entry in values.entries) {
      final key = entry.key;
      final value = entry.value;

      try {
        bool success = false;
        if (value is String) {
          success = await setString(key, value);
        } else if (value is int) {
          success = await setInt(key, value);
        } else if (value is double) {
          success = await setDouble(key, value);
        } else if (value is bool) {
          success = await setBool(key, value);
        } else if (value is List<String>) {
          success = await setStringList(key, value);
        }

        results[key] = success;
      } catch (e) {
        debugPrint('SharedPreferencesService: 批量设置失败 key=$key, error=$e');
        results[key] = false;
      }
    }

    return results;
  }

  /// 批量获取值
  Map<String, dynamic?> getBulk(List<String> keys) {
    final results = <String, dynamic?>{};

    for (final key in keys) {
      try {
        final value = _prefs?.get(key);
        results[key] = value;
      } catch (e) {
        debugPrint('SharedPreferencesService: 批量获取失败 key=$key, error=$e');
        results[key] = null;
      }
    }

    return results;
  }

  // ============================================================================
  // 管理方法
  // ============================================================================

  /// 检查key是否存在
  bool containsKey(String key) {
    try {
      return _prefs?.containsKey(key) ?? false;
    } catch (e) {
      debugPrint('SharedPreferencesService: 检查key存在失败 key=$key, error=$e');
      return false;
    }
  }

  /// 获取所有keys
  Set<String> getKeys() {
    try {
      return _prefs?.getKeys() ?? {};
    } catch (e) {
      debugPrint('SharedPreferencesService: 获取keys失败 error=$e');
      return {};
    }
  }

  /// 删除指定key
  Future<bool> remove(String key) async {
    try {
      return await _prefs?.remove(key) ?? false;
    } catch (e) {
      debugPrint('SharedPreferencesService: 删除key失败 key=$key, error=$e');
      return false;
    }
  }

  /// 清空所有数据
  Future<bool> clear() async {
    try {
      return await _prefs?.clear() ?? false;
    } catch (e) {
      debugPrint('SharedPreferencesService: 清空数据失败 error=$e');
      return false;
    }
  }

  /// 重新加载数据（用于测试）
  @visibleForTesting
  Future<bool> reload() async {
    try {
      await _prefs?.reload();
      return true;
    } catch (e) {
      debugPrint('SharedPreferencesService: 重新加载失败 error=$e');
      return false;
    }
  }

  // ============================================================================
  // 高级功能
  // ============================================================================

  /// 获取存储使用统计
  Map<String, dynamic> getStorageStats() {
    try {
      final keys = getKeys();
      final stats = <String, dynamic>{
        'totalKeys': keys.length,
        'keyTypes': <String, int>{},
        'estimatedSize': 0,
      };

      for (final key in keys) {
        final value = _prefs?.get(key);
        if (value != null) {
          final typeName = value.runtimeType.toString();
          stats['keyTypes'][typeName] = (stats['keyTypes'][typeName] ?? 0) + 1;

          // 估算大小
          if (value is String) {
            stats['estimatedSize'] += value.length * 2; // UTF-16估算
          } else if (value is List<String>) {
            stats['estimatedSize'] += value.join(',').length * 2;
          } else {
            stats['estimatedSize'] += 8; // 其他类型估算
          }
        }
      }

      return stats;
    } catch (e) {
      debugPrint('SharedPreferencesService: 获取统计失败 error=$e');
      return {};
    }
  }

  /// 导出数据（用于备份）
  Map<String, dynamic> exportData() {
    try {
      final keys = getKeys();
      final data = <String, dynamic>{};

      for (final key in keys) {
        data[key] = _prefs?.get(key);
      }

      return data;
    } catch (e) {
      debugPrint('SharedPreferencesService: 导出数据失败 error=$e');
      return {};
    }
  }

  /// 导入数据（用于恢复）
  Future<bool> importData(Map<String, dynamic> data) async {
    try {
      return (await setBulk(data)).values.every((success) => success);
    } catch (e) {
      debugPrint('SharedPreferencesService: 导入数据失败 error=$e');
      return false;
    }
  }
}
