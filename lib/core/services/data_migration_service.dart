import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:your_finance_flutter/core/models/asset_item.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';

/// 数据迁移服务
/// 负责处理应用架构重构时的向后兼容性和数据迁移
class DataMigrationService {
  DataMigrationService._();
  static const String _migrationVersionKey = 'data_migration_version';
  static const String _migrationHistoryKey = 'migration_history';

  static const int _currentVersion = 3; // 当前数据版本

  static DataMigrationService? _instance;
  static SharedPreferences? _prefs;

  static Future<DataMigrationService> getInstance() async {
    _instance ??= DataMigrationService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  /// 检查并执行数据迁移
  Future<void> checkAndMigrateData() async {
    final currentVersion = _prefs!.getInt(_migrationVersionKey) ?? 0;

    if (currentVersion < _currentVersion) {
      print('🔄 开始数据迁移: v$currentVersion -> v$_currentVersion');

      // 执行迁移步骤
      for (var version = currentVersion + 1;
          version <= _currentVersion;
          version++) {
        await _migrateToVersion(version);
      }

      // 更新版本号
      await _prefs!.setInt(_migrationVersionKey, _currentVersion);
      print('✅ 数据迁移完成');
    } else {
      print('ℹ️ 数据已是最新版本 v$_currentVersion');
      // 即使版本是最新的，也检查工资数据
      await _checkExistingSalaryData();
    }
  }

  /// 强制重新执行数据迁移（用于数据恢复）
  Future<void> forceReMigration() async {
    print('🔄 强制重新执行数据迁移...');

    // 重置迁移版本
    await _prefs!.setInt(_migrationVersionKey, 0);

    // 清除迁移历史
    await _prefs!.remove(_migrationHistoryKey);

    // 重新执行迁移
    await checkAndMigrateData();

    print('✅ 强制重新迁移完成');
  }

  /// 执行特定版本的迁移
  Future<void> _migrateToVersion(int targetVersion) async {
    print('🔄 执行迁移到版本 $targetVersion');

    switch (targetVersion) {
      case 1:
        await _migrateV1AssetCategories();
      case 2:
        await _migrateV2TransactionTypes();
      case 3:
        await _migrateV3SalaryDataCompatibility();
      default:
        print('⚠️ 未知的迁移版本: $targetVersion');
    }

    // 记录迁移历史
    await _recordMigration(targetVersion);
  }

  /// 版本1迁移：修复资产分类
  Future<void> _migrateV1AssetCategories() async {
    print('🔄 迁移V1: 修复资产分类映射');

    const assetsKey = 'assets_data';
    final jsonString = _prefs!.getString(assetsKey);

    if (jsonString == null) {
      print('ℹ️ 没有资产数据需要迁移');
      return;
    }

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      var hasChanges = false;

      // 检查并修复每个资产的分类
      for (var i = 0; i < jsonList.length; i++) {
        final assetJson = jsonList[i] as Map<String, dynamic>;
        final categoryName = assetJson['category'] as String?;

        if (categoryName == 'fixedAssets') {
          assetJson['category'] = 'realEstate';
          hasChanges = true;
          print('🔄 迁移资产: ${assetJson['name']} 的分类从 fixedAssets -> realEstate');
        }
      }

      // 如果有更改，保存回存储
      if (hasChanges) {
        final newJsonString = jsonEncode(jsonList);
        await _prefs!.setString(assetsKey, newJsonString);
        print('💾 已保存迁移后的资产数据');
      } else {
        print('ℹ️ 没有资产需要分类迁移');
      }
    } catch (e) {
      print('❌ 资产分类迁移失败: $e');
      // 不抛出异常，继续其他迁移
    }
  }

  /// 版本2迁移：修复交易类型兼容性
  Future<void> _migrateV2TransactionTypes() async {
    print('🔄 迁移V2: 确保交易类型兼容性');

    const transactionsKey = 'transactions_data';
    const draftsKey = 'draft_transactions_data';

    // 迁移正式交易
    await _migrateTransactionTypes(transactionsKey, '正式交易');
    // 迁移草稿交易
    await _migrateTransactionTypes(draftsKey, '草稿交易');
  }

  /// 版本3迁移：工资数据兼容性处理
  Future<void> _migrateV3SalaryDataCompatibility() async {
    print('🔄 迁移V3: 工资数据兼容性处理');

    // 首先检查现有的工资数据
    await _checkExistingSalaryData();

    // 检查并迁移可能的旧工资数据存储位置
    await _migrateLegacySalaryData();

    // 确保工资数据格式正确
    await _validateAndRepairSalaryData();

    print('✅ 工资数据兼容性迁移完成');
  }

  /// 检查现有的工资数据
  Future<void> _checkExistingSalaryData() async {
    print('🔍 检查现有的工资数据...');

    const salaryKey = 'salary_incomes_data';
    final jsonString = _prefs!.getString(salaryKey);

    if (jsonString != null) {
      print('✅ 找到现有的工资数据');
      print('📊 数据长度: ${jsonString.length} 字符');

      try {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        print('📋 现有工资记录数量: ${jsonList.length}');

        if (jsonList.isNotEmpty) {
          final firstRecord = jsonList[0] as Map<String, dynamic>;
          print('👤 第一条工资记录:');
          print('   - 名称: ${firstRecord['name'] ?? '未设置'}');
          print('   - 基本工资: ¥${firstRecord['basicSalary'] ?? 0}');
          print('   - 薪资日: ${firstRecord['salaryDay'] ?? '未设置'}');
          print('   - 奖金数量: ${(firstRecord['bonuses'] as List?)?.length ?? 0}');
        }
      } catch (e) {
        print('❌ 解析现有工资数据失败: $e');
      }
    } else {
      print('❌ 未找到现有的工资数据');
    }
  }

  /// 迁移遗留的工资数据
  Future<void> _migrateLegacySalaryData() async {
    print('🔄 检查遗留工资数据...');

    // 可能的旧键名
    const legacyKeys = [
      'salary_income_data', // 旧格式
      'salary_data', // 更旧的格式
      'income_data', // 收入数据
      'salary_incomes', // 复数形式
    ];

    for (final key in legacyKeys) {
      final jsonString = _prefs!.getString(key);
      if (jsonString != null) {
        print('📄 发现遗留工资数据在键: $key');

        try {
          // 尝试解析数据
          final jsonData = jsonDecode(jsonString);

          if (jsonData is List) {
            // 如果是数组，尝试迁移
            await _migrateSalaryListData(jsonData, key);
          } else if (jsonData is Map) {
            // 如果是单个对象，转换为数组
            await _migrateSalarySingleData(
              jsonData as Map<String, dynamic>,
              key,
            );
          } else {
            print('⚠️ 未知的数据格式: $key');
          }
        } catch (e) {
          print('❌ 解析遗留数据失败: $key, 错误: $e');
        }
      }
    }
  }

  /// 迁移工资列表数据
  Future<void> _migrateSalaryListData(
    List<dynamic> dataList,
    String oldKey,
  ) async {
    print('🔄 迁移工资列表数据: ${dataList.length} 条记录');

    final migratedData = <Map<String, dynamic>>[];

    for (final item in dataList) {
      try {
        final migratedItem =
            await _migrateSingleSalaryItem(item as Map<String, dynamic>);
        if (migratedItem != null) {
          migratedData.add(migratedItem);
        }
      } catch (e) {
        print('❌ 迁移工资项目失败: $e, 数据: $item');
      }
    }

    if (migratedData.isNotEmpty) {
      // 保存到新的键
      const newKey = 'salary_incomes_data';
      final jsonString = jsonEncode(migratedData);
      await _prefs!.setString(newKey, jsonString);
      print('💾 已迁移 ${migratedData.length} 条工资记录到新格式');

      // 删除旧数据
      await _prefs!.remove(oldKey);
      print('🗑️ 已删除旧工资数据键: $oldKey');
    }
  }

  /// 迁移单个工资数据
  Future<void> _migrateSalarySingleData(
    Map<String, dynamic> data,
    String oldKey,
  ) async {
    print('🔄 迁移单个工资数据');

    try {
      final migratedItem = await _migrateSingleSalaryItem(data);
      if (migratedItem != null) {
        // 保存到新的键
        const newKey = 'salary_incomes_data';
        final jsonString = jsonEncode([migratedItem]);
        await _prefs!.setString(newKey, jsonString);
        print('💾 已迁移单个工资记录到新格式');

        // 删除旧数据
        await _prefs!.remove(oldKey);
        print('🗑️ 已删除旧工资数据键: $oldKey');
      }
    } catch (e) {
      print('❌ 迁移单个工资数据失败: $e');
    }
  }

  /// 迁移单个工资项目
  Future<Map<String, dynamic>?> _migrateSingleSalaryItem(
    Map<String, dynamic> item,
  ) async {
    print('🔄 迁移工资项目: ${item['name'] ?? '未知名称'}');

    // 标准化字段名
    final normalizedItem = <String, dynamic>{};

    // 基本字段映射
    normalizedItem['id'] = item['id'] ?? item['salaryId'] ?? const Uuid().v4();
    normalizedItem['name'] = item['name'] ?? item['salaryName'] ?? '默认工资';

    // 工资构成字段
    normalizedItem['basicSalary'] =
        item['basicSalary'] ?? item['baseSalary'] ?? item['salary'] ?? 0.0;
    normalizedItem['housingAllowance'] =
        item['housingAllowance'] ?? item['housingSubsidy'] ?? 0.0;
    normalizedItem['mealAllowance'] =
        item['mealAllowance'] ?? item['mealSubsidy'] ?? 0.0;
    normalizedItem['transportationAllowance'] =
        item['transportationAllowance'] ?? item['transportSubsidy'] ?? 0.0;
    normalizedItem['otherAllowance'] =
        item['otherAllowance'] ?? item['otherSubsidy'] ?? 0.0;

    // 时间信息
    normalizedItem['salaryDay'] = item['salaryDay'] ?? item['payDay'] ?? 1;
    normalizedItem['period'] = item['period'] ?? 'monthly';

    // 奖金处理
    if (item['bonuses'] != null) {
      normalizedItem['bonuses'] = item['bonuses'];
    } else {
      // 从旧格式转换奖金
      final bonuses = <Map<String, dynamic>>[];

      // 年终奖
      if (item['yearEndBonus'] != null && item['yearEndBonus'] > 0) {
        bonuses.add({
          'id': const Uuid().v4(),
          'name': '年终奖',
          'type': 'yearEndBonus',
          'amount': item['yearEndBonus'],
          'frequency': 'annual',
          'paymentCount': 1,
          'startDate': DateTime(DateTime.now().year, 12, 31).toIso8601String(),
          'creationDate': DateTime.now().toIso8601String(),
          'updateDate': DateTime.now().toIso8601String(),
        });
      }

      // 季度奖
      if (item['quarterlyBonus'] != null && item['quarterlyBonus'] > 0) {
        bonuses.add({
          'id': const Uuid().v4(),
          'name': '季度奖',
          'type': 'quarterly',
          'amount': item['quarterlyBonus'],
          'frequency': 'quarterly',
          'paymentCount': item['quarterlyBonusPaymentCount'] ?? 4,
          'startDate': DateTime(DateTime.now().year).toIso8601String(),
          'creationDate': DateTime.now().toIso8601String(),
          'updateDate': DateTime.now().toIso8601String(),
        });
      }

      // 其他奖金
      if (item['otherBonuses'] != null && item['otherBonuses'] > 0) {
        bonuses.add({
          'id': const Uuid().v4(),
          'name': '其他奖金',
          'type': 'other',
          'amount': item['otherBonuses'],
          'frequency': 'monthly',
          'paymentCount': 12,
          'startDate': DateTime.now().toIso8601String(),
          'creationDate': DateTime.now().toIso8601String(),
          'updateDate': DateTime.now().toIso8601String(),
        });
      }

      if (bonuses.isNotEmpty) {
        normalizedItem['bonuses'] = bonuses;
      }
    }

    // 扣除项
    normalizedItem['personalIncomeTax'] =
        item['personalIncomeTax'] ?? item['incomeTax'] ?? 0.0;
    normalizedItem['socialInsurance'] =
        item['socialInsurance'] ?? item['socialSecurity'] ?? 0.0;
    normalizedItem['housingFund'] =
        item['housingFund'] ?? item['housingProvidentFund'] ?? 0.0;
    normalizedItem['otherDeductions'] = item['otherDeductions'] ?? 0.0;
    normalizedItem['specialDeductionMonthly'] =
        item['specialDeductionMonthly'] ?? item['specialDeductions'] ?? 0.0;

    // 时间戳
    normalizedItem['creationDate'] =
        item['creationDate'] ?? DateTime.now().toIso8601String();
    normalizedItem['updateDate'] =
        item['updateDate'] ?? DateTime.now().toIso8601String();

    print('✅ 工资项目迁移完成: ${normalizedItem['name']}');
    return normalizedItem;
  }

  /// 验证并修复工资数据
  Future<void> _validateAndRepairSalaryData() async {
    print('🔄 验证工资数据完整性...');

    const salaryKey = 'salary_incomes_data';
    final jsonString = _prefs!.getString(salaryKey);

    if (jsonString == null) {
      print('ℹ️ 没有工资数据需要验证');
      return;
    }

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      var hasChanges = false;
      final validItems = <Map<String, dynamic>>[];

      for (final item in jsonList) {
        try {
          final validatedItem =
              _validateSalaryItem(item as Map<String, dynamic>);
          if (validatedItem != null) {
            validItems.add(validatedItem);
            if (validatedItem != item) {
              hasChanges = true;
            }
          }
        } catch (e) {
          print('❌ 工资项目验证失败，跳过: $e');
        }
      }

      if (hasChanges && validItems.isNotEmpty) {
        final newJsonString = jsonEncode(validItems);
        await _prefs!.setString(salaryKey, newJsonString);
        print('💾 已修复工资数据格式');
      }

      print('✅ 工资数据验证完成，共 ${validItems.length} 条有效记录');
    } catch (e) {
      print('❌ 工资数据验证失败: $e');
    }
  }

  /// 验证单个工资项目
  Map<String, dynamic>? _validateSalaryItem(Map<String, dynamic> item) {
    // 确保必需字段存在
    if (item['id'] == null) {
      item['id'] = const Uuid().v4();
    }

    if (item['name'] == null) {
      item['name'] = '未命名工资';
    }

    // 确保数值字段是数字类型
    final numericFields = [
      'basicSalary',
      'housingAllowance',
      'mealAllowance',
      'transportationAllowance',
      'otherAllowance',
      'personalIncomeTax',
      'socialInsurance',
      'housingFund',
      'otherDeductions',
      'specialDeductionMonthly',
    ];

    for (final field in numericFields) {
      if (item[field] != null) {
        final value = item[field];
        if (value is String) {
          item[field] = double.tryParse(value) ?? 0.0;
        } else if (value is! num) {
          item[field] = 0.0;
        }
      } else {
        item[field] = 0.0;
      }
    }

    // 确保薪资日是有效的
    if (item['salaryDay'] == null ||
        item['salaryDay'] is! int ||
        item['salaryDay'] < 1 ||
        item['salaryDay'] > 31) {
      item['salaryDay'] = 1;
    }

    // 确保奖金列表格式正确
    if (item['bonuses'] != null && item['bonuses'] is List) {
      final bonuses = item['bonuses'] as List<dynamic>;
      final validBonuses = <Map<String, dynamic>>[];

      for (final bonus in bonuses) {
        if (bonus is Map<String, dynamic>) {
          // 验证奖金项目
          final validBonus = _validateBonusItem(bonus);
          if (validBonus != null) {
            validBonuses.add(validBonus);
          }
        }
      }

      item['bonuses'] = validBonuses;
    } else {
      item['bonuses'] = <Map<String, dynamic>>[];
    }

    return item;
  }

  /// 验证奖金项目
  Map<String, dynamic>? _validateBonusItem(Map<String, dynamic> bonus) {
    if (bonus['id'] == null) {
      bonus['id'] = const Uuid().v4();
    }

    if (bonus['name'] == null) {
      bonus['name'] = '未命名奖金';
    }

    if (bonus['amount'] != null) {
      final amount = bonus['amount'];
      if (amount is String) {
        bonus['amount'] = double.tryParse(amount) ?? 0.0;
      } else if (amount is! num) {
        bonus['amount'] = 0.0;
      }
    } else {
      bonus['amount'] = 0.0;
    }

    if (bonus['paymentCount'] == null || bonus['paymentCount'] is! int) {
      bonus['paymentCount'] = 1;
    }

    if (bonus['startDate'] == null) {
      bonus['startDate'] = DateTime.now().toIso8601String();
    }

    if (bonus['creationDate'] == null) {
      bonus['creationDate'] = DateTime.now().toIso8601String();
    }

    if (bonus['updateDate'] == null) {
      bonus['updateDate'] = DateTime.now().toIso8601String();
    }

    return bonus;
  }

  /// 迁移交易类型数据
  Future<void> _migrateTransactionTypes(String key, String typeDesc) async {
    final jsonString = _prefs!.getString(key);

    if (jsonString == null) {
      print('ℹ️ 没有$typeDesc数据需要迁移');
      return;
    }

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      var hasChanges = false;

      // 检查并修复每个交易的类型兼容性
      for (var i = 0; i < jsonList.length; i++) {
        final transactionJson = jsonList[i] as Map<String, dynamic>;
        final typeName = transactionJson['type'] as String?;

        // 如果没有flow字段但有type字段，尝试推断flow
        if (transactionJson['flow'] == null && typeName != null) {
          final flow = _inferTransactionFlow(typeName, transactionJson);
          if (flow != null) {
            transactionJson['flow'] = flow.name;
            hasChanges = true;
            print('🔄 推断交易流向: ${transactionJson['description']} -> $flow');
          }
        }
      }

      // 如果有更改，保存回存储
      if (hasChanges) {
        final newJsonString = jsonEncode(jsonList);
        await _prefs!.setString(key, newJsonString);
        print('💾 已保存迁移后的$typeDesc数据');
      } else {
        print('ℹ️ 没有$typeDesc需要类型迁移');
      }
    } catch (e) {
      print('❌ $typeDesc类型迁移失败: $e');
      // 不抛出异常，继续其他迁移
    }
  }

  /// 从旧的交易类型推断新的交易流向
  TransactionFlow? _inferTransactionFlow(
    String typeName,
    Map<String, dynamic> transactionJson,
  ) {
    try {
      final legacyType = TransactionType.values.firstWhere(
        (e) => e.name == typeName,
      );

      // 根据交易类型推断流向
      switch (legacyType) {
        case TransactionType.income:
          return TransactionFlow.externalToWallet;
        case TransactionType.expense:
          return TransactionFlow.walletToExternal;
        case TransactionType.transfer:
          return TransactionFlow.walletToWallet;
      }
    } catch (e) {
      // 如果无法推断，返回null
      return null;
    }
  }

  /// 记录迁移历史
  Future<void> _recordMigration(int version) async {
    final history = _prefs!.getStringList(_migrationHistoryKey) ?? [];
    final timestamp = DateTime.now().toIso8601String();
    history.add('$timestamp: Migrated to version $version');
    await _prefs!.setStringList(_migrationHistoryKey, history);
  }

  /// 获取迁移历史
  List<String> getMigrationHistory() =>
      _prefs!.getStringList(_migrationHistoryKey) ?? [];

  /// 获取当前数据版本
  int getCurrentVersion() => _prefs!.getInt(_migrationVersionKey) ?? 0;

  /// 重置数据版本（用于测试）
  Future<void> resetMigrationVersion() async {
    await _prefs!.remove(_migrationVersionKey);
    await _prefs!.remove(_migrationHistoryKey);
    print('🔄 已重置数据迁移版本');
  }

  /// 验证数据完整性
  Future<bool> validateDataIntegrity() async {
    try {
      // 验证资产数据
      final assetsJson = _prefs!.getString('assets_data');
      if (assetsJson != null) {
        final assets = jsonDecode(assetsJson) as List<dynamic>;
        for (final assetJson in assets) {
          final asset = AssetItem.fromJson(assetJson as Map<String, dynamic>);
          if (asset.category.name == 'unknown') {
            print('❌ 发现无效资产分类: ${asset.name}');
            return false;
          }
        }
      }

      // 验证交易数据
      final transactionsJson = _prefs!.getString('transactions_data');
      if (transactionsJson != null) {
        final transactions = jsonDecode(transactionsJson) as List<dynamic>;
        for (final transactionJson in transactions) {
          final transaction =
              Transaction.fromJson(transactionJson as Map<String, dynamic>);
          // 验证交易基本字段
          if (transaction.description.isEmpty) {
            print('❌ 发现无效交易描述');
            return false;
          }
        }
      }

      print('✅ 数据完整性验证通过');
      return true;
    } catch (e) {
      print('❌ 数据完整性验证失败: $e');
      return false;
    }
  }

  /// 强制迁移所有数据（紧急修复）
  Future<void> forceMigrateAllData() async {
    print('🚨 开始强制迁移所有数据...');

    // 清除版本号，重新执行完整迁移
    await resetMigrationVersion();
    await checkAndMigrateData();

    print('✅ 强制迁移完成');
  }
}
