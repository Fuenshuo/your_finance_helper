// 折旧方式枚举
enum DepreciationMethod {
  smartEstimate('智能估算'),
  manualUpdate('手动更新'),
  none('无折旧');

  const DepreciationMethod(this.displayName);
  final String displayName;
}

// 定义资产/负债的大分类 - 重新设计以支持消费资产
enum AssetCategory {
  // 资产类
  liquidAssets('流动资产'), // 现金、存款等高流动性资产
  realEstate('不动产'), // 房产等不动产
  investments('投资理财'), // 股票、基金等投资
  consumptionAssets('消费资产'), // 电脑、家具等消费性资产
  receivables('应收款'), // 他人欠款

  // 负债类
  liabilities('债务'); // 欠他人的钱

  const AssetCategory(this.displayName);
  final String displayName;

  // 是否为资产（非负债）
  bool get isAsset => [
        AssetCategory.liquidAssets,
        AssetCategory.realEstate,
        AssetCategory.investments,
        AssetCategory.consumptionAssets,
        AssetCategory.receivables,
      ].contains(this);

  // 是否为负债
  bool get isLiability => this == AssetCategory.liabilities;

  String get description {
    switch (this) {
      case AssetCategory.liquidAssets:
        return '现金、银行存款、支付宝余额等高流动性资产';
      case AssetCategory.realEstate:
        return '房产、土地等不动产资产';
      case AssetCategory.investments:
        return '股票、基金、理财产品等投资性资产';
      case AssetCategory.consumptionAssets:
        return '电脑、家具、电器等消费性耐用品，虽然有价值但流动性较差';
      case AssetCategory.receivables:
        return '他人欠自己的钱款';
      case AssetCategory.liabilities:
        return '欠他人的债务和借款';
    }
  }

  List<String> get subCategories {
    switch (this) {
      case AssetCategory.liquidAssets:
        return ['现金', '银行活期', '支付宝', '微信', '货币基金', '定期存款'];
      case AssetCategory.realEstate:
        return ['住宅', '商铺', '写字楼', '土地', '车位'];
      case AssetCategory.investments:
        return ['股票', '基金', '债券', '理财产品', '黄金', '外汇', 'P2P', '数字货币'];
      case AssetCategory.consumptionAssets:
        return ['电子产品', '家具', '电器', '服装', '首饰', '书籍', '乐器', '运动器材', '其他耐用品'];
      case AssetCategory.receivables:
        return ['个人借款', '企业欠款', '押金', '报销款', '其他应收'];
      case AssetCategory.liabilities:
        return ['信用卡欠款', '个人借款', '房屋贷款', '车辆贷款', '消费贷', '企业借款'];
    }
  }

  // 获取消费资产的折旧年限（用于估值计算）
  int getDepreciationYears(String subCategory) {
    if (this != AssetCategory.consumptionAssets) return 0;

    switch (subCategory) {
      case '电子产品':
        return 3; // 电脑、手机等3年折旧
      case '电器':
        return 5; // 冰箱、洗衣机等5年折旧
      case '家具':
        return 8; // 家具8年折旧
      case '服装':
        return 2; // 服装2年折旧
      case '首饰':
        return 10; // 首饰10年折旧
      case '书籍':
        return 5; // 书籍5年折旧
      case '乐器':
        return 10; // 乐器10年折旧
      case '运动器材':
        return 5; // 运动器材5年折旧
      default:
        return 5; // 默认5年折旧
    }
  }
}

// 主数据模型：代表每一笔资产或负债
class AssetItem {
  // 备注

  AssetItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.subCategory,
    required this.creationDate,
    required this.updateDate,
    this.purchaseDate,
    this.depreciationMethod = DepreciationMethod.none,
    this.depreciationRate,
    this.currentValue,
    this.isIdle = false,
    this.idleValue,
    this.notes,
  });

  factory AssetItem.fromJson(Map<String, dynamic> json) => AssetItem(
        id: json['id'] as String,
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
        category: _parseAssetCategory(json['category'] as String),
        subCategory: json['subCategory'] as String,
        creationDate: DateTime.parse(json['creationDate'] as String),
        updateDate: DateTime.parse(json['updateDate'] as String),
        purchaseDate: json['purchaseDate'] != null
            ? DateTime.parse(json['purchaseDate'] as String)
            : null,
        depreciationMethod: json['depreciationMethod'] != null
            ? DepreciationMethod.values.firstWhere(
                (e) => e.name == json['depreciationMethod'] as String,
                orElse: () => DepreciationMethod.none,
              )
            : DepreciationMethod.none,
        depreciationRate: json['depreciationRate'] != null
            ? (json['depreciationRate'] as num).toDouble()
            : null,
        currentValue: json['currentValue'] != null
            ? (json['currentValue'] as num).toDouble()
            : null,
        isIdle: json['isIdle'] as bool? ?? false,
        idleValue: json['idleValue'] != null
            ? (json['idleValue'] as num).toDouble()
            : null,
        notes: json['notes'] as String?,
      );

  // 解析资产分类，支持向后兼容旧数据格式
  static AssetCategory _parseAssetCategory(String categoryName) {
    // 处理旧的分类名称映射
    switch (categoryName) {
      case 'fixedAssets':
        return AssetCategory.realEstate; // 旧的fixedAssets映射到新的realEstate
      default:
        // 尝试直接匹配新枚举值
        return AssetCategory.values.firstWhere(
          (e) => e.name == categoryName,
          orElse: () => AssetCategory.liquidAssets, // 默认值
        );
    }
  }

  final String id;
  final String name;
  final double amount;
  final AssetCategory category;
  final String subCategory;
  final DateTime creationDate;
  final DateTime updateDate;

  // 固定资产管理相关字段
  final DateTime? purchaseDate; // 购入日期
  final DepreciationMethod depreciationMethod; // 折旧方式
  final double? depreciationRate; // 年折旧率
  final double? currentValue; // 当前价值
  final bool isIdle; // 是否闲置
  final double? idleValue; // 闲置价值
  final String? notes;

  AssetItem copyWith({
    String? id,
    String? name,
    double? amount,
    AssetCategory? category,
    String? subCategory,
    DateTime? creationDate,
    DateTime? updateDate,
    DateTime? purchaseDate,
    DepreciationMethod? depreciationMethod,
    double? depreciationRate,
    double? currentValue,
    bool? isIdle,
    double? idleValue,
    String? notes,
  }) =>
      AssetItem(
        id: id ?? this.id,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        subCategory: subCategory ?? this.subCategory,
        creationDate: creationDate ?? this.creationDate,
        updateDate: updateDate ?? this.updateDate,
        purchaseDate: purchaseDate ?? this.purchaseDate,
        depreciationMethod: depreciationMethod ?? this.depreciationMethod,
        depreciationRate: depreciationRate ?? this.depreciationRate,
        currentValue: currentValue ?? this.currentValue,
        isIdle: isIdle ?? this.isIdle,
        idleValue: idleValue ?? this.idleValue,
        notes: notes ?? this.notes,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'category': category.name,
        'subCategory': subCategory,
        'creationDate': creationDate.toIso8601String(),
        'updateDate': updateDate.toIso8601String(),
        'purchaseDate': purchaseDate?.toIso8601String(),
        'depreciationMethod': depreciationMethod.name,
        'depreciationRate': depreciationRate,
        'currentValue': currentValue,
        'isIdle': isIdle,
        'idleValue': idleValue,
        'notes': notes,
      };

  // 获取实际价值（用于总资产计算）
  double get effectiveValue {
    // 如果是闲置状态，使用闲置价值
    if (isIdle && idleValue != null) {
      return idleValue!;
    }

    // 如果有当前价值，使用当前价值
    if (currentValue != null) {
      return currentValue!;
    }

    // 否则使用原始金额
    return amount;
  }

  // 计算折旧后的价值
  double calculateDepreciatedValue() {
    if (depreciationMethod == DepreciationMethod.none ||
        purchaseDate == null ||
        depreciationRate == null) {
      return amount;
    }

    final now = DateTime.now();
    final yearsUsed = now.difference(purchaseDate!).inDays / 365.25;
    final depreciationAmount = amount * depreciationRate! * yearsUsed;
    final depreciatedValue = amount - depreciationAmount;

    return depreciatedValue > 0 ? depreciatedValue : 0;
  }

  // 获取默认折旧率（根据资产类型和分类）
  double getDefaultDepreciationRate() {
    // 根据资产分类确定折旧策略
    switch (category) {
      case AssetCategory.consumptionAssets:
        // 消费资产使用年限折旧法
        final depreciationYears = category.getDepreciationYears(subCategory);
        return depreciationYears > 0 ? 1.0 / depreciationYears : 0.0;

      case AssetCategory.realEstate:
        // 不动产折旧率
        return 0.02; // 2% 年折旧率

      case AssetCategory.liquidAssets:
        // 流动资产通常不折旧
        return 0.0;

      case AssetCategory.investments:
        // 投资资产根据具体类型
        switch (subCategory) {
          case '黄金':
          case '外汇':
          case '数字货币':
            return 0.0; // 贵金属和货币通常不折旧
          default:
            return 0.05; // 其他投资5%年折旧
        }

      case AssetCategory.receivables:
        // 应收款通常不折旧
        return 0.0;

      case AssetCategory.liabilities:
        // 负债不适用折旧
        return 0.0;
    }
  }

  // 判断是否为固定资产（不动产 + 消费资产）
  bool get isFixedAsset => [
        AssetCategory.realEstate,
        AssetCategory.consumptionAssets,
      ].contains(category);

  // 判断是否为消费资产
  bool get isConsumptionAsset => category == AssetCategory.consumptionAssets;

  // 判断是否需要折旧
  bool get requiresDepreciation =>
      [
        AssetCategory.realEstate,
        AssetCategory.consumptionAssets,
      ].contains(category) &&
      depreciationMethod != DepreciationMethod.none;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AssetItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
