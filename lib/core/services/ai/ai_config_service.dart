import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_finance_flutter/core/models/ai_config.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';

/// AI配置服务 - 管理AI配置的持久化存储
class AiConfigService {
  AiConfigService._();
  static AiConfigService? _instance;

  static Future<AiConfigService> getInstance() async {
    if (_instance == null) {
      _instance = AiConfigService._();
      await _instance!._initialize();
    }
    return _instance!;
  }

  SharedPreferences? _prefs;
  static const String _configKey = 'ai_config';

  Future<void> _initialize() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
      Log.business('AiConfigService', 'AI配置服务初始化完成');
    }
  }

  /// 保存AI配置
  Future<void> saveConfig(AiConfig config) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final json = config.toJson();
      final jsonString = jsonEncode(json);
      await prefs.setString(_configKey, jsonString);
      Log.business('AiConfigService', 'AI配置已保存', {
        'provider': config.provider.name,
        'enabled': config.enabled,
      });
    } catch (e) {
      Log.error('AiConfigService', '保存AI配置失败', {'error': e.toString()});
      rethrow;
    }
  }

  /// 加载AI配置
  Future<AiConfig?> loadConfig() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_configKey);
      if (jsonString == null) {
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return AiConfig.fromJson(json);
    } catch (e) {
      Log.error('AiConfigService', '加载AI配置失败', {'error': e.toString()});
      return null;
    }
  }

  /// 删除AI配置
  Future<void> deleteConfig() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.remove(_configKey);
      Log.business('AiConfigService', 'AI配置已删除');
    } catch (e) {
      Log.error('AiConfigService', '删除AI配置失败', {'error': e.toString()});
      rethrow;
    }
  }

  /// 检查是否有配置
  Future<bool> hasConfig() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.containsKey(_configKey);
  }
}
