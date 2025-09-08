import SwiftUI

struct AssetCategoryView: View {
    let category: AssetCategory
    @Binding var tempAssets: [AssetItem]
    @State private var showingAddSheet = false
    
    private var categoryAssets: [AssetItem] {
        tempAssets.filter { $0.category == category }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 分类说明
                VStack(alignment: .leading, spacing: 8) {
                    Text(category.rawValue)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(category.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // 已添加的资产列表
                if !categoryAssets.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("已添加的\(category.rawValue)")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVStack(spacing: 8) {
                            ForEach(categoryAssets, id: \.id) { asset in
                                AssetRowView(asset: asset) {
                                    removeAsset(asset)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // 添加按钮
                Button(action: {
                    showingAddSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("添加\(category.rawValue)")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddAssetSheetView(category: category) { asset in
                tempAssets.append(asset)
            }
        }
    }
    
    private func removeAsset(_ asset: AssetItem) {
        tempAssets.removeAll { $0.id == asset.id }
    }
}

struct AssetRowView: View {
    let asset: AssetItem
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(asset.name)
                    .font(.headline)
                Text(asset.subCategory)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(formatAmount(asset.amount))
                .font(.headline)
                .foregroundColor(asset.category == .liabilities ? .red : .green)
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
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
    AssetCategoryView(category: .liquidAssets, tempAssets: .constant([]))
}
