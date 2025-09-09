import Foundation
import SwiftData

@Observable
class DashboardViewModel {
    var isAmountHidden = false
    var excludeFixedAssets = false
    
    func calculateTotalAssets(from assetItems: [AssetItem]) -> Double {
        let filteredItems = assetItems.filter { item in
            if excludeFixedAssets && item.category == .fixedAssets {
                return false
            }
            return item.category != .liabilities
        }
        return filteredItems.reduce(0) { $0 + $1.amount }
    }
    
    func calculateTotalLiabilities(from assetItems: [AssetItem]) -> Double {
        return assetItems
            .filter { $0.category == .liabilities }
            .reduce(0) { $0 + $1.amount }
    }
    
    func calculateNetAssets(from assetItems: [AssetItem]) -> Double {
        return calculateTotalAssets(from: assetItems) - calculateTotalLiabilities(from: assetItems)
    }
    
    func calculateDebtRatio(from assetItems: [AssetItem]) -> Double {
        let totalAssets = calculateTotalAssets(from: assetItems)
        let totalLiabilities = calculateTotalLiabilities(from: assetItems)
        
        guard totalAssets > 0 else { return 0 }
        return (totalLiabilities / totalAssets) * 100
    }
    
    func getAssetsByCategory(from assetItems: [AssetItem]) -> [AssetCategory: Double] {
        var categoryTotals: [AssetCategory: Double] = [:]
        
        for category in AssetCategory.allCases {
            let total = assetItems
                .filter { $0.category == category }
                .reduce(0) { $0 + $1.amount }
            categoryTotals[category] = total
        }
        
        return categoryTotals
    }
    
    func getLastUpdateDate(from assetItems: [AssetItem]) -> Date? {
        return assetItems.map { $0.updateDate }.max()
    }
    
    func formatAmount(_ amount: Double) -> String {
        if isAmountHidden {
            return "****"
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.currencyCode = "CNY"
        return formatter.string(from: NSNumber(value: amount)) ?? "¥0"
    }
}
