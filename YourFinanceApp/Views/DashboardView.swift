import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(DashboardViewModel.self) private var viewModel
    @Query private var assetItems: [AssetItem]
    @State private var showingAddAssetFlow = false
    @State private var showingAssetManagement = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 资产总览卡片
                    AssetOverviewCard()
                    
                    // 资产月度变化
                    MonthlyChangeCard()
                    
                    // 各类资产分布
                    AssetDistributionCard()
                    
                    // 资产组成图表
                    AssetCompositionChart()
                    
                    // 更新资产按钮
                    Button(action: {
                        showingAddAssetFlow = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("更新资产")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("家庭资产")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAssetManagement = true
                    }) {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddAssetFlow) {
            AddAssetFlowView()
        }
        .sheet(isPresented: $showingAssetManagement) {
            AssetManagementView()
        }
    }
}

struct AssetOverviewCard: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(DashboardViewModel.self) private var viewModel
    @Query private var assetItems: [AssetItem]
    
    var body: some View {
        VStack(spacing: 16) {
            // 总资产
            VStack(spacing: 8) {
                HStack {
                    Text("总资产")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.isAmountHidden.toggle()
                    }) {
                        Image(systemName: viewModel.isAmountHidden ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.blue)
                    }
                }
                
                Text(viewModel.formatAmount(viewModel.calculateTotalAssets(from: assetItems)))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                // 排除固定资产开关
                HStack {
                    Toggle("排除固定资产", isOn: $viewModel.excludeFixedAssets)
                        .font(.caption)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
            }
            
            Divider()
            
            // 净资产和负债率
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("净资产")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(viewModel.formatAmount(viewModel.calculateNetAssets(from: assetItems)))
                        .font(.headline)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("负债率")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(String(format: "%.1f", viewModel.calculateDebtRatio(from: assetItems)))%")
                        .font(.headline)
                        .foregroundColor(.red)
                }
            }
            
            // 更新日期
            if let lastUpdate = viewModel.getLastUpdateDate(from: assetItems) {
                HStack {
                    Text("最近更新")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(lastUpdate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct MonthlyChangeCard: View {
    @Environment(DashboardViewModel.self) private var viewModel
    @Query private var assetItems: [AssetItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("本月变化")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 16) {
                // 总资产变化
                VStack(alignment: .leading, spacing: 4) {
                    Text("总资产")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Text(viewModel.formatAmount(viewModel.calculateTotalAssets(from: assetItems)))
                            .font(.headline)
                        
                        // 这里可以添加与上月的比较
                        Text("+¥0")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
                
                // 总负债变化
                VStack(alignment: .trailing, spacing: 4) {
                    Text("总负债")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Text("+¥0")
                            .font(.caption)
                            .foregroundColor(.red)
                        
                        Text(viewModel.formatAmount(viewModel.calculateTotalLiabilities(from: assetItems)))
                            .font(.headline)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}

struct AssetDistributionCard: View {
    @Environment(DashboardViewModel.self) private var viewModel
    @Query private var assetItems: [AssetItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("资产分布")
                .font(.headline)
                .padding(.horizontal)
            
            let categoryTotals = viewModel.getAssetsByCategory(from: assetItems)
            let totalAssets = viewModel.calculateTotalAssets(from: assetItems)
            
            VStack(spacing: 8) {
                ForEach(AssetCategory.allCases, id: \.self) { category in
                    if let amount = categoryTotals[category], amount > 0 {
                        AssetDistributionRow(
                            category: category,
                            amount: amount,
                            total: totalAssets,
                            isHidden: viewModel.isAmountHidden
                        )
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}

struct AssetDistributionRow: View {
    let category: AssetCategory
    let amount: Double
    let total: Double
    let isHidden: Bool
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return (amount / total) * 100
    }
    
    var body: some View {
        HStack {
            Text(category.rawValue)
                .font(.subheadline)
                .frame(width: 80, alignment: .leading)
            
            // 进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(colorForCategory(category))
                        .frame(width: geometry.size.width * (percentage / 100), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
            
            Text(isHidden ? "****" : formatAmount(amount))
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .trailing)
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
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.currencyCode = "CNY"
        return formatter.string(from: NSNumber(value: amount)) ?? "¥0"
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: AssetItem.self, inMemory: true)
        .environment(DashboardViewModel())
}
