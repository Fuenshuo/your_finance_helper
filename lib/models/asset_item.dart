// 折旧方式枚举
enum DepreciationMethod {
  smartEstimate('智能估算'),
  manualUpdate('手动更新'),
  none('无折旧');

  const DepreciationMethod(this.displayName);
  final String displayName;
}

// 定义资产/负债的大分类
enum AssetCategory {
  liquidAssets('流动资金'),
  fixedAssets('固定资产'),
  investments('投资理财'),
  receivables('应收款'),
  liabilities('负债');

  const AssetCategory(this.displayName);
  final String displayName;

  String get description {
    switch (this) {
      case AssetCategory.liquidAssets:
        return '可随时随取、即时变现的钱';
      case AssetCategory.fixedAssets:
        return '用于投资或自用的、流动性低的实物类资产';
      case AssetCategory.investments:
        return '以增值为目的的金融资产';
      case AssetCategory.receivables:
        return '他人欠自己的钱';
      case AssetCategory.liabilities:
        return '自己欠他人的钱';
    }
  }

  List<String> get subCategories {
    switch (this) {
      case AssetCategory.liquidAssets:
        return ['银行活期', '支付宝', '微信', '货币基金'];
      case AssetCategory.fixedAssets:
        return ['房产 (自住)', '房产 (投资)', '汽车', '车位', '金银珠宝', '收藏品'];
      case AssetCategory.investments:
        return ['银行理财', '定期存款/大额存单', '基金', '股票', '黄金', 'P2P'];
      case AssetCategory.receivables:
        return ['借给他人的钱', '押金', '报销款'];
      case AssetCategory.liabilities:
        return ['信用卡', '个人借款', '房屋贷款', '车辆贷款', '花呗/白条'];
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
        category: AssetCategory.values.firstWhere(
          (e) => e.name == json['category'] as String,
        ),
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

  // 获取默认折旧率（根据资产类型）
  double getDefaultDepreciationRate() {
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
      default:
        return 0.1; // 默认10% 年折旧率
    }
  }

  // 判断是否为固定资产
  bool get isFixedAsset => category == AssetCategory.fixedAssets;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AssetItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
