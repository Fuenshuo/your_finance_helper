import 'package:flutter/foundation.dart';

/// Debug模式管理器
/// 通过连续点击5次来开启/关闭debug模式
class DebugModeManager extends ChangeNotifier {
  factory DebugModeManager() => _instance;
  DebugModeManager._internal();
  static final DebugModeManager _instance = DebugModeManager._internal();

  bool _isDebugModeEnabled = false;
  int _clickCount = 0;
  DateTime? _lastClickTime;
  static const int _requiredClicks = 5;
  static const Duration _clickTimeout = Duration(seconds: 3);

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
      print('🔧 Debug模式已强制开启');
    }
  }

  /// 强制关闭debug模式
  void forceDisableDebugMode() {
    _isDebugModeEnabled = false;
    resetClickCount();
    if (kDebugMode) {
      print('🔧 Debug模式已强制关闭');
    }
  }
}
