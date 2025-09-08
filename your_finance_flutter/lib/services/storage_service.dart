import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/asset_item.dart';

class StorageService {
  static const String _assetsKey = 'assets_data';
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // 保存资产列表
  Future<void> saveAssets(List<AssetItem> assets) async {
    final jsonList = assets.map((asset) => asset.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs!.setString(_assetsKey, jsonString);
  }

  // 获取资产列表
  Future<List<AssetItem>> getAssets() async {
    final jsonString = _prefs!.getString(_assetsKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => AssetItem.fromJson(json)).toList();
  }

  // 添加资产
  Future<void> addAsset(AssetItem asset) async {
    final assets = await getAssets();
    assets.add(asset);
    await saveAssets(assets);
  }

  // 更新资产
  Future<void> updateAsset(AssetItem asset) async {
    final assets = await getAssets();
    final index = assets.indexWhere((a) => a.id == asset.id);
    if (index != -1) {
      assets[index] = asset;
      await saveAssets(assets);
    }
  }

  // 删除资产
  Future<void> deleteAsset(String assetId) async {
    final assets = await getAssets();
    assets.removeWhere((asset) => asset.id == assetId);
    await saveAssets(assets);
  }

  // 清空所有数据
  Future<void> clearAll() async {
    await _prefs!.remove(_assetsKey);
  }
}
