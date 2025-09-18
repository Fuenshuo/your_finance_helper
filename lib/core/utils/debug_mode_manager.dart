import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Debug模式管理器
/// 通过连续点击5次来开启/关闭debug模式
class DebugModeManager extends ChangeNotifier {
  factory DebugModeManager() => _instance;
  DebugModeManager._internal() {
    _loadDebugModeState();
  }
  static final DebugModeManager _instance = DebugModeManager._internal();

  bool _isDebugModeEnabled = false;
  int _clickCount = 0;
  DateTime? _lastClickTime;
  static const int _requiredClicks = 5;
  static const Duration _clickTimeout = Duration(seconds: 3);
  static const String _debugModeKey = 'debug_mode_enabled';

  /// 从SharedPreferences加载debug模式状态
  Future<void> _loadDebugModeState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDebugModeEnabled = prefs.getBool(_debugModeKey) ?? false;

      if (kDebugMode) {
        print('🔧 Debug模式状态已加载: $_isDebugModeEnabled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 加载Debug模式状态失败: $e');
      }
      _isDebugModeEnabled = false;
    }
  }

  /// 保存debug模式状态到SharedPreferences
  Future<void> _saveDebugModeState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_debugModeKey, _isDebugModeEnabled);

      if (kDebugMode) {
        print('💾 Debug模式状态已保存: $_isDebugModeEnabled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 保存Debug模式状态失败: $e');
      }
    }
  }

  /// 获取debug模式状态
  bool get isDebugModeEnabled => _isDebugModeEnabled;

  /// 处理点击事件
  /// 返回true表示debug模式已开启
  bool handleClick() {
    final now = DateTime.now();

    // 如果距离上次点击超过3秒，重置计数
    if (_lastClickTime != null &&
        now.difference(_lastClickTime!) > _clickTimeout) {
      _clickCount = 0;
    }

    _clickCount++;
    _lastClickTime = now;

    if (kDebugMode) {
      print('🔧 Debug点击计数: $_clickCount/$_requiredClicks');
    }

    // 达到5次点击，切换debug模式
    if (_clickCount >= _requiredClicks) {
      _isDebugModeEnabled = !_isDebugModeEnabled;
      _clickCount = 0;

      if (kDebugMode) {
        print('🔧 Debug模式${_isDebugModeEnabled ? '已开启' : '已关闭'}');
      }

      // 保存状态到SharedPreferences
      _saveDebugModeState();

      // 通知监听器
      notifyListeners();

      return _isDebugModeEnabled;
    }

    return false;
  }

  /// 重置点击计数
  void resetClickCount() {
    _clickCount = 0;
    _lastClickTime = null;
  }

  /// 强制开启debug模式（仅用于开发）
  void forceEnableDebugMode() {
    if (kDebugMode) {
      _isDebugModeEnabled = true;
      _saveDebugModeState();
      notifyListeners();
      print('🔧 Debug模式已强制开启');
    }
  }

  /// 强制关闭debug模式
  void forceDisableDebugMode() {
    _isDebugModeEnabled = false;
    resetClickCount();
    _saveDebugModeState();
    notifyListeners();
    if (kDebugMode) {
      print('🔧 Debug模式已强制关闭');
    }
  }
}
