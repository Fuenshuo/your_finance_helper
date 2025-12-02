import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the Stream + Insights feature flag backed by SharedPreferences.
class StreamInsightsFlagProvider extends ChangeNotifier {
  StreamInsightsFlagProvider({
    required this.flagKey,
    required this.defaultValue,
    SharedPreferences? sharedPreferences,
  })  : _sharedPreferences = sharedPreferences,
        _flagValue = defaultValue {
    _instances.add(this);
  }

  final String flagKey;
  final bool defaultValue;
  static const String _debugOverrideKey = 'stream_insights_debug_override';
  static const String _defaultFlagKey = 'stream_insights';
  static final Set<StreamInsightsFlagProvider> _instances =
      <StreamInsightsFlagProvider>{};
  final SharedPreferences? _sharedPreferences;

  SharedPreferences? _prefs;
  bool _isInitialized = false;
  bool _flagValue;
  static bool? _debugOverride;
  bool _isDisposed = false;

  bool get isInitialized => _isInitialized;
  bool get isEnabled => _debugOverride ?? _flagValue;
  bool get hasDebugOverride => _debugOverride != null;

  Future<void> initialize() async {
    _prefs ??= _sharedPreferences ?? await SharedPreferences.getInstance();
    _flagValue = _prefs!.getBool(flagKey) ?? defaultValue;
    _debugOverride = _prefs!.getBool(_debugOverrideKey);
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_prefs == null && _sharedPreferences == null) {
      await initialize();
      return;
    }

    await initialize();
  }

  Future<void> updateFlag(bool isEnabled) async {
    _prefs ??= _sharedPreferences ?? await SharedPreferences.getInstance();
    await _prefs!.setBool(flagKey, isEnabled);
    _flagValue = isEnabled;
    notifyListeners();
  }

  static Future<void> writeOverride({bool? value}) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_debugOverrideKey);
    } else {
      await prefs.setBool(_debugOverrideKey, value);
    }
    _debugOverride = value;
    _notifyAll();
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    final keysToRemove = _instances.isEmpty
        ? <String>{_defaultFlagKey}
        : _instances.map((instance) => instance.flagKey).toSet();
    for (final key in keysToRemove) {
      await prefs.remove(key);
    }
    await prefs.remove(_debugOverrideKey);
    _debugOverride = null;
    _notifyReset(prefs);
  }

  static bool? get debugOverride => _debugOverride;

  static set debugOverride(bool? value) {
    unawaited(writeOverride(value: value));
  }

  static void _notifyAll() {
    for (final instance in _instances) {
      instance.notifyListeners();
    }
  }

  static void _notifyReset(SharedPreferences prefs) {
    for (final instance in _instances) {
      instance._prefs = prefs;
      instance._isInitialized = true;
      instance._flagValue = instance.defaultValue;
      instance.notifyListeners();
    }
  }

  @override
  void dispose() {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    _instances.remove(this);
    super.dispose();
  }
}
