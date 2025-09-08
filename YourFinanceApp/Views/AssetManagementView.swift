import SwiftUI
import SwiftData

struct AssetManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var assetItems: [AssetItem]
    @State private var showingAddAssetFlow = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(AssetCategory.allCases, id: \.self) { category in
                    let categoryAssets = assetItems.filter { $0.category == category }
                    
                    if !categoryAssets.isEmpty {
                        Section(category.rawValue) {
                            ForEach(categoryAssets, id: \.id) { asset in
                                AssetManagementRow(asset: asset)
                            }
                            .onDelete { indexSet in
                                deleteAssets(at: indexSet, in: categoryAssets)
                            }
                        }
                    }
                }
            }
            .navigationTitle("资产管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("完成") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddAssetFlow = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddAssetFlow) {
            AddAssetFlowView()
        }
    }
    
    private func deleteAssets(at offsets: IndexSet, in assets: [AssetItem]) {
        for index in offsets {
            let asset = assets[index]
            modelContext.delete(asset)
        }
        try? modelContext.save()
    }
}

struct AssetManagementRow: View {
    let asset: AssetItem
    @State private var showingEditSheet = false
    
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
            
            Button(action: {
                showingEditSheet = true
            }) {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditAssetSheetView(asset: asset)
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

struct EditAssetSheetView: View {
    let asset: AssetItem
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name: String
    @State private var amount: String
    @State private var subCategory: String
    
    init(asset: AssetItem) {
        self.asset = asset
        self._name = State(initialValue: asset.name)
        self._amount = State(initialValue: String(asset.amount))
        self._subCategory = State(initialValue: asset.subCategory)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("编辑资产")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("名称")
                        .font(.headline)
                    
                    TextField("请输入名称", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("子分类")
                        .font(.headline)
                    
                    TextField("请输入子分类", text: $subCategory)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("金额")
                        .font(.headline)
                    
                    TextField("请输入金额", text: $amount)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveChanges()
                    }
                    .disabled(!isValidInput)
                }
            }
        }
    }
    
    private var isValidInput: Bool {
        return !name.isEmpty && !subCategory.isEmpty && !amount.isEmpty && Double(amount) != nil
    }
    
    private func saveChanges() {
        guard let amountValue = Double(amount) else { return }
        
        asset.name = name
        asset.subCategory = subCategory
        asset.amount = amountValue
        asset.updateDate = Date()
        
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AssetManagementView()
        .modelContainer(for: AssetItem.self, inMemory: true)
}
