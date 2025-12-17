import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/models/user_income_profile.dart';

/// 用户收入画像服务
/// 负责管理和更新用户的收入模式画像
class UserIncomeProfileService {
  UserIncomeProfileService._();
  static UserIncomeProfileService? _instance;
  static SharedPreferences? _prefs;

  static const String _profileKey = 'user_income_profile';

  static Future<UserIncomeProfileService> getInstance() async {
    _instance ??= UserIncomeProfileService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  /// 加载用户画像
  Future<UserIncomeProfile> loadProfile() async {
    final jsonString = _prefs?.getString(_profileKey);
    if (jsonString == null) {
      return const UserIncomeProfile();
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserIncomeProfile.fromJson(json);
    } catch (e) {
      print(
        '[UserIncomeProfileService.loadProfile] ❌ 加载画像失败: $e',
      );
      return const UserIncomeProfile();
    }
  }

  /// 保存用户画像
  Future<void> saveProfile(UserIncomeProfile profile) async {
    try {
      final jsonString = jsonEncode(profile.toJson());
      await _prefs?.setString(_profileKey, jsonString);
      print(
        '[UserIncomeProfileService.saveProfile] ✅ 保存画像成功',
      );
    } catch (e) {
      print(
        '[UserIncomeProfileService.saveProfile] ❌ 保存画像失败: $e',
      );
    }
  }

  /// 从交易记录更新画像
  Future<void> updateFromTransaction(Transaction transaction) async {
    print(
      '[UserIncomeProfileService.updateFromTransaction] 📊 更新画像: ${transaction.type} ${transaction.category} ${transaction.amount}',
    );

    final profile = await loadProfile();
    final updatedProfile = profile.updateFromTransaction(transaction);
    await saveProfile(updatedProfile);

    print(
      '[UserIncomeProfileService.updateFromTransaction] ✅ 画像已更新: 平均月收入=${updatedProfile.avgMonthlySalary}, 交易数=${updatedProfile.transactionCount}',
    );
  }

  /// 更新转账方向偏好
  Future<void> updateTransferDirectionPreference(String direction) async {
    print(
      '[UserIncomeProfileService.updateTransferDirectionPreference] 🔄 更新转账方向偏好: $direction',
    );

    final profile = await loadProfile();
    final updatedProfile = profile.updateTransferDirectionPreference(direction);
    await saveProfile(updatedProfile);
  }

  /// 获取置信度阈值（动态阈值，考虑冷启动）
  Future<ConfidenceThresholds> getConfidenceThresholds() async {
    final profile = await loadProfile();

    if (profile.isColdStart) {
      // 冷启动：前5笔记录使用更严格阈值
      return const ConfidenceThresholds(
        autoSave: 0.95,
        quickConfirm: 0.85,
      );
    } else {
      // 正常模式
      return const ConfidenceThresholds(
        autoSave: 0.90,
        quickConfirm: 0.70,
      );
    }
  }
}

/// 置信度阈值配置
class ConfidenceThresholds {
  const ConfidenceThresholds({
    required this.autoSave,
    required this.quickConfirm,
  });

  /// 自动保存阈值（≥此值自动保存）
  final double autoSave;

  /// 快速确认阈值（≥此值显示快速确认）
  final double quickConfirm;
}
