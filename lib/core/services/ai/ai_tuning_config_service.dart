import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_finance_flutter/core/models/ai_nlp_tuning_config.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';

/// 管理自然语言解析的调参配置
class AiTuningConfigService {
  AiTuningConfigService._();
  static AiTuningConfigService? _instance;

  static Future<AiTuningConfigService> getInstance() async {
    if (_instance == null) {
      _instance = AiTuningConfigService._();
      await _instance!._initialize();
    }
    return _instance!;
  }

  static const _prefsKey = 'ai_nlp_tuning_config';
  SharedPreferences? _prefs;

  Future<void> _initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<AiNlpTuningConfig> loadConfig() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString == null) {
      return const AiNlpTuningConfig();
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return AiNlpTuningConfig.fromJson(json);
    } catch (e) {
      Log.warning(
        'AiTuningConfigService',
        '解析 AI 调参配置失败，使用默认值: $e',
      );
      return const AiNlpTuningConfig();
    }
  }

  Future<void> saveConfig(AiNlpTuningConfig config) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(config.toJson()));
    Log.business(
      'AiTuningConfigService',
      'AI调参配置已保存',
      config.toJson(),
    );
  }

  Future<void> resetConfig() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    Log.business('AiTuningConfigService', 'AI调参配置已重置');
  }
}
