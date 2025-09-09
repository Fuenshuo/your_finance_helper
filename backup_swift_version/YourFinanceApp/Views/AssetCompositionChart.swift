import SwiftUI
import Charts

struct AssetCompositionChart: View {
    @Environment(DashboardViewModel.self) private var viewModel
    @Query private var assetItems: [AssetItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("资产组成")
                .font(.headline)
                .padding(.horizontal)
            
            let categoryTotals = viewModel.getAssetsByCategory(from: assetItems)
            let chartData = createChartData(from: categoryTotals)
            
            Chart(chartData, id: \.category) { item in
                BarMark(
                    x: .value("类型", item.category.rawValue),
                    y: .value("金额", item.amount)
                )
                .foregroundStyle(colorForCategory(item.category))
            }
            .frame(height: 200)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    private func createChartData(from categoryTotals: [AssetCategory: Double]) -> [ChartDataItem] {
        return categoryTotals.compactMap { (category, amount) in
            guard amount > 0 else { return nil }
            return ChartDataItem(category: category, amount: amount)
        }
    }
    
    private func colorForCategory(_ category: AssetCategory) -> Color {
        switch category {
        case .liquidAssets: return .blue
        case .fixedAssets: return .green
        case .investments: return .orange
        case .receivables: return .purple
        case .liabilities: return .red
        }
    }
}

struct ChartDataItem {
    let category: AssetCategory
    let amount: Double
}

#Preview {
    AssetCompositionChart()
        .modelContainer(for: AssetItem.self, inMemory: true)
        .environment(DashboardViewModel())
}
