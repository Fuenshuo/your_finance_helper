
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
  final String id;
  final String name;
  final double amount;
  final AssetCategory category;
  final String subCategory;
  final DateTime creationDate;
  final DateTime updateDate;

  AssetItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.subCategory,
    required this.creationDate,
    required this.updateDate,
  });

  AssetItem copyWith({
    String? id,
    String? name,
    double? amount,
    AssetCategory? category,
    String? subCategory,
    DateTime? creationDate,
    DateTime? updateDate,
  }) {
    return AssetItem(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      creationDate: creationDate ?? this.creationDate,
      updateDate: updateDate ?? this.updateDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category.name,
      'subCategory': subCategory,
      'creationDate': creationDate.toIso8601String(),
      'updateDate': updateDate.toIso8601String(),
    };
  }

  factory AssetItem.fromJson(Map<String, dynamic> json) {
    return AssetItem(
      id: json['id'],
      name: json['name'],
      amount: json['amount'].toDouble(),
      category: AssetCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      subCategory: json['subCategory'],
      creationDate: DateTime.parse(json['creationDate']),
      updateDate: DateTime.parse(json['updateDate']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AssetItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
