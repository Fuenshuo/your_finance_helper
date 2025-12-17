import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_finance_flutter/features/insights/models/daily_cap.dart';
import 'package:your_finance_flutter/features/insights/models/micro_insight.dart';
import 'package:your_finance_flutter/features/insights/models/monthly_health.dart';
import 'package:your_finance_flutter/features/insights/models/weekly_anomaly.dart';

/// Cache entry with metadata
class CacheEntry<T> {
  const CacheEntry({
    required this.data,
    required this.timestamp,
    required this.expiry,
    required this.key,
  });

  final T data;
  final DateTime timestamp;
  final DateTime expiry;
  final String key;

  bool get isExpired => DateTime.now().isAfter(expiry);

  CacheEntry<T> copyWith({
    T? data,
    DateTime? timestamp,
    DateTime? expiry,
    String? key,
  }) =>
      CacheEntry(
        data: data ?? this.data,
        timestamp: timestamp ?? this.timestamp,
        expiry: expiry ?? this.expiry,
        key: key ?? this.key,
      );
}

/// Insight caching service for performance optimization
class CacheService {
  CacheService._();
  static const String _cachePrefix = 'insights_cache_';
  static const Duration _defaultExpiry = Duration(hours: 24);
  static const int _maxCacheSize = 100;

  static final CacheService _instance = CacheService._();
  static CacheService get instance => _instance;

  final Map<String, CacheEntry<dynamic>> _memoryCache = {};
  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _loadPersistedCache();
  }

  Future<void> _loadPersistedCache() async {
    if (_prefs == null) return;

    final keys = _prefs!.getKeys().where((key) => key.startsWith(_cachePrefix));

    for (final key in keys) {
      try {
        final jsonString = _prefs!.getString(key);
        if (jsonString != null) {
          final entry = _deserializeCacheEntry(key, jsonString);
          if (entry != null && !entry.isExpired) {
            _memoryCache[key] = entry;
          } else {
            // Remove expired entry
            await _prefs!.remove(key);
          }
        }
      } catch (e) {
        // Remove corrupted cache entry
        await _prefs!.remove(key);
      }
    }
  }

  /// Cache daily cap data
  Future<void> cacheDailyCap(String userId, DailyCap dailyCap) async {
    await _cacheData(
      'daily_cap_$userId',
      dailyCap,
      _serializeDailyCap,
      _deserializeDailyCap,
    );
  }

  /// Get cached daily cap
  DailyCap? getCachedDailyCap(String userId) => _getCachedData(
        'daily_cap_$userId',
        _deserializeDailyCap,
      );

  /// Cache weekly insights
  Future<void> cacheWeeklyInsights(
    String userId,
    List<WeeklyAnomaly> anomalies,
  ) async {
    await _cacheData(
      'weekly_insights_$userId',
      anomalies,
      _serializeWeeklyAnomalies,
      _deserializeWeeklyAnomalies,
    );
  }

  /// Get cached weekly insights
  List<WeeklyAnomaly>? getCachedWeeklyInsights(String userId) => _getCachedData(
        'weekly_insights_$userId',
        _deserializeWeeklyAnomalies,
      );

  /// Cache monthly health score
  Future<void> cacheMonthlyHealth(
    String userId,
    MonthlyHealthScore health,
  ) async {
    await _cacheData(
      'monthly_health_$userId',
      health,
      _serializeMonthlyHealth,
      _deserializeMonthlyHealth,
    );
  }

  /// Get cached monthly health
  MonthlyHealthScore? getCachedMonthlyHealth(String userId) => _getCachedData(
        'monthly_health_$userId',
        _deserializeMonthlyHealth,
      );

  /// Cache micro insights
  Future<void> cacheMicroInsights(
    String userId,
    List<MicroInsight> insights,
  ) async {
    await _cacheData(
      'micro_insights_$userId',
      insights,
      _serializeMicroInsights,
      _deserializeMicroInsights,
    );
  }

  /// Get cached micro insights
  List<MicroInsight>? getCachedMicroInsights(String userId) => _getCachedData(
        'micro_insights_$userId',
        _deserializeMicroInsights,
      );

  /// Generic cache method
  Future<void> _cacheData<T>(
    String key,
    T data,
    String Function(T) serializer,
    T Function(String) deserializer,
  ) async {
    final cacheKey = '$_cachePrefix$key';
    final expiry = DateTime.now().add(_defaultExpiry);

    final entry = CacheEntry<T>(
      data: data,
      timestamp: DateTime.now(),
      expiry: expiry,
      key: cacheKey,
    );

    // Update memory cache
    _memoryCache[cacheKey] = entry;

    // Persist to storage
    if (_prefs != null) {
      final cacheData = {
        'data': serializer(data),
        'timestamp': entry.timestamp.toIso8601String(),
        'expiry': entry.expiry.toIso8601String(),
        'type': T.toString(),
      };

      await _prefs!.setString(cacheKey, jsonEncode(cacheData));
    }

    // Clean up old entries if cache is too large
    await _cleanupIfNeeded();
  }

  /// Generic get cached data method
  T? _getCachedData<T>(String key, T Function(String) deserializer) {
    final cacheKey = '$_cachePrefix$key';
    final entry = _memoryCache[cacheKey] as CacheEntry<T>?;

    if (entry != null && !entry.isExpired) {
      return entry.data;
    }

    // Remove expired entry
    _memoryCache.remove(cacheKey);
    if (_prefs != null) {
      _prefs!.remove(cacheKey);
    }

    return null;
  }

  /// Clean up expired and old entries
  Future<void> _cleanupIfNeeded() async {
    // Remove expired entries
    final expiredKeys = _memoryCache.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _memoryCache.remove(key);
      if (_prefs != null) {
        await _prefs!.remove(key);
      }
    }

    // If still too large, remove oldest entries
    if (_memoryCache.length > _maxCacheSize) {
      final sortedEntries = _memoryCache.entries.toList()
        ..sort((a, b) => a.value.timestamp.compareTo(b.value.timestamp));

      final toRemove =
          sortedEntries.take(_memoryCache.length - _maxCacheSize + 10);
      for (final entry in toRemove) {
        _memoryCache.remove(entry.key);
        if (_prefs != null) {
          await _prefs!.remove(entry.key);
        }
      }
    }
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    _memoryCache.clear();
    if (_prefs != null) {
      final keys =
          _prefs!.getKeys().where((key) => key.startsWith(_cachePrefix));
      for (final key in keys) {
        await _prefs!.remove(key);
      }
    }
  }

  /// Clear cache for specific user
  Future<void> clearUserCache(String userId) async {
    final userKeys =
        _memoryCache.keys.where((key) => key.contains('_${userId}_')).toList();

    for (final key in userKeys) {
      _memoryCache.remove(key);
      if (_prefs != null) {
        await _prefs!.remove(key);
      }
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    final now = DateTime.now();
    final totalEntries = _memoryCache.length;
    final expiredEntries =
        _memoryCache.values.where((entry) => entry.isExpired).length;
    final validEntries = totalEntries - expiredEntries;

    // Calculate average age of valid entries
    final validEntriesList =
        _memoryCache.values.where((entry) => !entry.isExpired).toList();
    final averageAge = validEntriesList.isEmpty
        ? 0.0
        : validEntriesList.fold<double>(
              0,
              (sum, entry) => sum + now.difference(entry.timestamp).inMinutes,
            ) /
            validEntriesList.length;

    return {
      'totalEntries': totalEntries,
      'validEntries': validEntries,
      'expiredEntries': expiredEntries,
      'averageAgeMinutes': averageAge,
      'hitRate': validEntries / totalEntries,
    };
  }

  // Serialization methods
  String _serializeDailyCap(DailyCap cap) => jsonEncode(cap.toJson());
  DailyCap _deserializeDailyCap(String json) =>
      DailyCap.fromJson(jsonDecode(json) as Map<String, dynamic>);

  String _serializeWeeklyAnomalies(List<WeeklyAnomaly> anomalies) =>
      jsonEncode(anomalies.map((a) => a.toJson()).toList());
  List<WeeklyAnomaly> _deserializeWeeklyAnomalies(String json) =>
      (jsonDecode(json) as List)
          .map((a) => WeeklyAnomaly.fromJson(a as Map<String, dynamic>))
          .toList();

  String _serializeMonthlyHealth(MonthlyHealthScore health) =>
      jsonEncode(health.toJson());
  MonthlyHealthScore _deserializeMonthlyHealth(String json) =>
      MonthlyHealthScore.fromJson(jsonDecode(json) as Map<String, dynamic>);

  String _serializeMicroInsights(List<MicroInsight> insights) =>
      jsonEncode(insights.map((i) => i.toJson()).toList());
  List<MicroInsight> _deserializeMicroInsights(String json) =>
      (jsonDecode(json) as List)
          .map((i) => MicroInsight.fromJson(i as Map<String, dynamic>))
          .toList();

  CacheEntry<dynamic>? _deserializeCacheEntry(String key, String jsonString) {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final timestamp = DateTime.parse(data['timestamp'] as String);
      final expiry = DateTime.parse(data['expiry'] as String);
      final type = data['type'] as String;

      // Deserialize based on type
      dynamic deserializedData;
      switch (type) {
        case 'DailyCap':
          deserializedData = _deserializeDailyCap(data['data'] as String);
        case 'List<WeeklyAnomaly>':
          deserializedData =
              _deserializeWeeklyAnomalies(data['data'] as String);
        case 'MonthlyHealthScore':
          deserializedData = _deserializeMonthlyHealth(data['data'] as String);
        case 'List<MicroInsight>':
          deserializedData = _deserializeMicroInsights(data['data'] as String);
        default:
          return null;
      }

      return CacheEntry(
        data: deserializedData,
        timestamp: timestamp,
        expiry: expiry,
        key: key,
      );
    } catch (e) {
      // Return null for corrupted cache entries
      return null;
    }
  }
}
