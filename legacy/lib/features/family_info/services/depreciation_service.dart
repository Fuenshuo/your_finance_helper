import 'package:your_finance_flutter/core/models/asset_item.dart';

/// 折旧计算服务
class DepreciationService {
  factory DepreciationService() => _instance;
  DepreciationService._internal();
  static final DepreciationService _instance = DepreciationService._internal();

  /// 计算资产的折旧价值
  ///
  /// [asset] 要计算的资产
  /// [asOfDate] 计算截止日期，默认为当前日期
  ///
  /// 返回计算后的折旧价值
  double calculateDepreciatedValue(AssetItem asset, {DateTime? asOfDate}) {
    if (asset.depreciationMethod == DepreciationMethod.none) {
      return asset.amount;
    }

    if (asset.purchaseDate == null) {
      return asset.amount;
    }

    final calculationDate = asOfDate ?? DateTime.now();
    final yearsUsed =
        calculationDate.difference(asset.purchaseDate!).inDays / 365.25;

    // 获取折旧率
    final depreciationRate =
        asset.depreciationRate ?? asset.getDefaultDepreciationRate();

    // 计算折旧金额
    final depreciationAmount = asset.amount * depreciationRate * yearsUsed;
    final depreciatedValue = asset.amount - depreciationAmount;

    // 确保价值不为负数
    return depreciatedValue > 0 ? depreciatedValue : 0;
  }

  /// 计算资产的年折旧额
  ///
  /// [asset] 要计算的资产
  ///
  /// 返回年折旧额
  double calculateAnnualDepreciation(AssetItem asset) {
    if (asset.depreciationMethod == DepreciationMethod.none) {
      return 0;
    }

    final depreciationRate =
        asset.depreciationRate ?? asset.getDefaultDepreciationRate();
    return asset.amount * depreciationRate;
  }

  /// 计算资产的月折旧额
  ///
  /// [asset] 要计算的资产
  ///
  /// 返回月折旧额
  double calculateMonthlyDepreciation(AssetItem asset) =>
      calculateAnnualDepreciation(asset) / 12;

  /// 获取资产的剩余使用年限
  ///
  /// [asset] 要计算的资产
  /// [asOfDate] 计算截止日期，默认为当前日期
  ///
  /// 返回剩余使用年限（年）
  double getRemainingUsefulLife(AssetItem asset, {DateTime? asOfDate}) {
    if (asset.purchaseDate == null) {
      return 0;
    }

    final calculationDate = asOfDate ?? DateTime.now();
    final yearsUsed =
        calculationDate.difference(asset.purchaseDate!).inDays / 365.25;

    // 获取折旧率
    final depreciationRate =
        asset.depreciationRate ?? asset.getDefaultDepreciationRate();

    if (depreciationRate == 0) {
      return double.infinity; // 不折旧的资产
    }

    // 计算总使用年限（当价值为0时的年限）
    final totalUsefulLife = 1 / depreciationRate;
    final remainingLife = totalUsefulLife - yearsUsed;

    return remainingLife > 0 ? remainingLife : 0;
  }

  /// 批量计算多个资产的折旧价值
  ///
  /// [assets] 要计算的资产列表
  /// [asOfDate] 计算截止日期，默认为当前日期
  ///
  /// 返回资产ID到折旧价值的映射
  Map<String, double> calculateBatchDepreciatedValues(
    List<AssetItem> assets, {
    DateTime? asOfDate,
  }) {
    final result = <String, double>{};

    for (final asset in assets) {
      result[asset.id] = calculateDepreciatedValue(asset, asOfDate: asOfDate);
    }

    return result;
  }

  /// 获取资产的折旧历史
  ///
  /// [asset] 要计算的资产
  /// [startDate] 开始日期
  /// [endDate] 结束日期
  /// [interval] 计算间隔（月）
  ///
  /// 返回日期到价值的映射
  Map<DateTime, double> getDepreciationHistory(
    AssetItem asset, {
    required DateTime startDate,
    required DateTime endDate,
    int interval = 1, // 月
  }) {
    final history = <DateTime, double>{};

    var currentDate = startDate;
    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      history[currentDate] =
          calculateDepreciatedValue(asset, asOfDate: currentDate);
      currentDate = DateTime(
        currentDate.year,
        currentDate.month + interval,
        currentDate.day,
      );
    }

    return history;
  }

  /// 建议折旧率
  ///
  /// [subCategory] 资产子分类
  /// [assetType] 资产类型（可选）
  ///
  /// 返回建议的折旧率
  double suggestDepreciationRate(String subCategory, {String? assetType}) {
    switch (subCategory) {
      case '汽车':
        return 0.15; // 15% 年折旧率
      case '房产 (自住)':
      case '房产 (投资)':
        return 0.02; // 2% 年折旧率
      case '车位':
        return 0.05; // 5% 年折旧率
      case '金银珠宝':
      case '收藏品':
        return 0.0; // 通常不折旧
      case '电子产品':
        return 0.25; // 25% 年折旧率
      case '家具':
        return 0.1; // 10% 年折旧率
      case '家电':
        return 0.2; // 20% 年折旧率
      default:
        return 0.1; // 默认10% 年折旧率
    }
  }

  /// 验证折旧设置
  ///
  /// [asset] 要验证的资产
  ///
  /// 返回验证结果和错误信息
  DepreciationValidationResult validateDepreciationSettings(AssetItem asset) {
    final errors = <String>[];

    if (asset.depreciationMethod == DepreciationMethod.smartEstimate) {
      if (asset.purchaseDate == null) {
        errors.add('智能估算需要设置购入日期');
      }
      if (asset.depreciationRate == null) {
        errors.add('智能估算需要设置折旧率');
      }
    }

    if (asset.depreciationMethod == DepreciationMethod.manualUpdate) {
      if (asset.currentValue == null) {
        errors.add('手动更新需要设置当前价值');
      }
    }

    if (asset.isIdle && asset.idleValue == null) {
      errors.add('闲置资产需要设置闲置价值');
    }

    return DepreciationValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

/// 折旧验证结果
class DepreciationValidationResult {
  DepreciationValidationResult({
    required this.isValid,
    required this.errors,
  });
  final bool isValid;
  final List<String> errors;
}
