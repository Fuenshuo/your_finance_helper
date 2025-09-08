import Foundation
import SwiftData

// 定义资产/负债的大分类
enum AssetCategory: String, Codable, CaseIterable {
    case liquidAssets = "流动资金"
    case fixedAssets = "固定资产"
    case investments = "投资理财"
    case receivables = "应收款"
    case liabilities = "负债"
    
    var description: String {
        switch self {
        case .liquidAssets:
            return "可随时随取、即时变现的钱"
        case .fixedAssets:
            return "用于投资或自用的、流动性低的实物类资产"
        case .investments:
            return "以增值为目的的金融资产"
        case .receivables:
            return "他人欠自己的钱"
        case .liabilities:
            return "自己欠他人的钱"
        }
    }
    
    var subCategories: [String] {
        switch self {
        case .liquidAssets:
            return ["银行活期", "支付宝", "微信", "货币基金"]
        case .fixedAssets:
            return ["房产 (自住)", "房产 (投资)", "汽车", "车位", "金银珠宝", "收藏品"]
        case .investments:
            return ["银行理财", "定期存款/大额存单", "基金", "股票", "黄金", "P2P"]
        case .receivables:
            return ["借给他人的钱", "押金", "报销款"]
        case .liabilities:
            return ["信用卡", "个人借款", "房屋贷款", "车辆贷款", "花呗/白条"]
        }
    }
}

// 主数据模型：代表每一笔资产或负债
@Model
class AssetItem {
    @Attribute(.unique) var id: UUID
    var name: String                 // 名称 (如: 支付宝, 房产(自住))
    var amount: Double               // 金额
    var category: AssetCategory      // 所属大分类
    var subCategory: String          // 子分类 (自定义或预设名称)
    var creationDate: Date           // 创建日期
    var updateDate: Date             // 最后更新日期

    init(name: String, amount: Double, category: AssetCategory, subCategory: String) {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.category = category
        self.subCategory = subCategory
        self.creationDate = Date()
        self.updateDate = Date()
    }
}
