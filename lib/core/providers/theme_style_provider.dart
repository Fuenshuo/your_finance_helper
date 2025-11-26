import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_design_tokens.dart';

/// 主题和风格管理Provider
/// 管理应用的4套主题和2种风格的切换
class ThemeStyleProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme';
  static const String _styleKey = 'app_style';
  static const String _moneyThemeKey = 'money_theme';

  AppTheme _currentTheme = AppTheme.modernForestGreen;
  AppStyle _currentStyle = AppStyle.iOSFintech;
  MoneyTheme _currentMoneyTheme = MoneyTheme.fluxBlue;
  bool _isInitialized = false;

  AppTheme get currentTheme => _currentTheme;
  AppStyle get currentStyle => _currentStyle;
  MoneyTheme get currentMoneyTheme => _currentMoneyTheme;
  bool get isInitialized => _isInitialized;

  /// 初始化：从持久化存储加载主题和风格
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // 加载主题
      final themeIndex = prefs.getInt(_themeKey);
      if (themeIndex != null &&
          themeIndex >= 0 &&
          themeIndex < AppTheme.values.length) {
        _currentTheme = AppTheme.values[themeIndex];
      }

      // 加载风格
      final styleIndex = prefs.getInt(_styleKey);
      if (styleIndex != null &&
          styleIndex >= 0 &&
          styleIndex < AppStyle.values.length) {
        _currentStyle = AppStyle.values[styleIndex];
      }

      final moneyThemeIndex = prefs.getInt(_moneyThemeKey);
      if (moneyThemeIndex != null &&
          moneyThemeIndex >= 0 &&
          moneyThemeIndex < MoneyTheme.values.length) {
        _currentMoneyTheme = MoneyTheme.values[moneyThemeIndex];
      }

      // 同步到 AppDesignTokens
      AppDesignTokens.setTheme(_currentTheme);
      AppDesignTokens.setStyle(_currentStyle);
      AppDesignTokens.setMoneyTheme(_currentMoneyTheme);

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // 如果加载失败，使用默认值
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// 设置主题
  Future<void> setTheme(AppTheme theme) async {
    if (_currentTheme == theme) return;

    _currentTheme = theme;
    AppDesignTokens.setTheme(theme);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, theme.index);
    } catch (e) {
      // 持久化失败不影响主题切换
    }

    notifyListeners();
  }

  /// 设置风格
  Future<void> setStyle(AppStyle style) async {
    if (_currentStyle == style) return;

    _currentStyle = style;
    AppDesignTokens.setStyle(style);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_styleKey, style.index);
    } catch (e) {
      // 持久化失败不影响风格切换
    }

    notifyListeners();
  }

  /// 设置金额主题
  Future<void> setMoneyTheme(MoneyTheme theme) async {
    if (_currentMoneyTheme == theme) return;

    _currentMoneyTheme = theme;
    AppDesignTokens.setMoneyTheme(theme);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_moneyThemeKey, theme.index);
    } catch (_) {}

    notifyListeners();
  }

  /// 获取主题显示名称
  String getThemeDisplayName(AppTheme theme) {
    switch (theme) {
      case AppTheme.modernForestGreen:
        return '森绿主题';
      case AppTheme.eleganceDeepBlue:
        return '藏青主题';
      case AppTheme.premiumGraphite:
        return '石墨主题';
      case AppTheme.classicBurgundy:
        return '紫红主题';
    }
  }

  /// 获取风格显示名称
  String getStyleDisplayName(AppStyle style) {
    switch (style) {
      case AppStyle.iOSFintech:
        return 'iOS Fintech';
      case AppStyle.SharpProfessional:
        return 'Sharp Professional';
    }
  }

  String getMoneyThemeDisplayName(MoneyTheme theme) {
    switch (theme) {
      case MoneyTheme.fluxBlue:
        return 'Flux Blue';
      case MoneyTheme.forestEmerald:
        return 'Forest Emerald';
      case MoneyTheme.graphiteMono:
        return 'Graphite Mono';
    }
  }
}
