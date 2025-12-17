import 'dart:convert';
import 'dart:io';

import 'package:your_finance_flutter/core/models/asset_item.dart';

/// Parses legacy assets JSON and maps it to current AssetItem models.
///
/// This adapter is tolerant to missing/extra fields and performs simple
/// enum/value migrations where necessary.
class LegacyAssetsAdapter {
  /// Reads a legacy JSON file and returns a list of AssetItem.
  static Future<List<AssetItem>> parse(File file) async {
    final content = await file.readAsString();
    final dynamic jsonData = jsonDecode(content);
    if (jsonData is List) {
      return jsonData.map<AssetItem>(_mapAsset).toList();
    }
    if (jsonData is Map<String, dynamic> && jsonData['assets'] is List) {
      return (jsonData['assets'] as List).map<AssetItem>(_mapAsset).toList();
    }
    return <AssetItem>[];
  }

  /// Parses SharedPreferences assets_data (current app format)
  static Future<List<AssetItem>> parseSharedPreferences(
    String jsonString,
  ) async {
    try {
      final dynamic jsonData = jsonDecode(jsonString);
      if (jsonData is List) {
        return jsonData.map<AssetItem>(_mapAsset).toList();
      }
    } catch (e) {
      print('Error parsing SharedPreferences assets data: $e');
    }
    return <AssetItem>[];
  }

  static AssetItem _mapAsset(Object? raw) {
    final m = (raw is Map<String, dynamic>) ? raw : <String, dynamic>{};

    final id = (m['id']?.toString().trim().isNotEmpty ?? false)
        ? m['id'].toString()
        : DateTime.now().millisecondsSinceEpoch.toString();
    final name = (m['name'] ?? m['title'] ?? '未命名资产').toString();
    final amount = _toDouble(m['amount'] ?? m['value'] ?? 0);

    // Map legacy category strings to current enum names when possible
    final legacyCategory = (m['category'] ?? 'liquidAssets').toString();
    final category = _mapCategory(legacyCategory);

    final subCategory =
        (m['subCategory'] ?? m['sub_category'] ?? '').toString();

    final creationDate = _parseDate(
      m['creationDate'] ?? m['created_at'] ?? DateTime.now().toIso8601String(),
    );
    final updateDate = _parseDate(
      m['updateDate'] ?? m['updated_at'] ?? creationDate.toIso8601String(),
    );

    return AssetItem(
      id: id,
      name: name,
      amount: amount,
      category: category,
      subCategory: subCategory,
      creationDate: creationDate,
      updateDate: updateDate,
    );
  }

  static double _toDouble(Object? v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  static DateTime _parseDate(Object? v) {
    if (v is DateTime) return v;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) {
      return DateTime.tryParse(v) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static AssetCategory _mapCategory(String legacy) {
    switch (legacy) {
      case 'cash':
      case 'bank':
      case 'liquid':
      case 'liquidAssets':
        return AssetCategory.liquidAssets;
      case 'real_estate':
      case 'property':
      case 'realEstate':
        return AssetCategory.realEstate;
      case 'investment':
      case 'investments':
        return AssetCategory.investments;
      case 'consumption':
      case 'consumptionAssets':
        return AssetCategory.consumptionAssets;
      case 'receivable':
      case 'receivables':
        return AssetCategory.receivables;
      case 'liability':
      case 'liabilities':
        return AssetCategory.liabilities;
      default:
        return AssetCategory.liquidAssets;
    }
  }
}
