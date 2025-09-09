import SwiftUI

struct AddAssetSheetView: View {
    let category: AssetCategory
    let onSave: (AssetItem) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSubCategory = ""
    @State private var customName = ""
    @State private var amount = ""
    @State private var showingCustomInput = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 分类标题
                Text("添加\(category.rawValue)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // 子分类选择
                VStack(alignment: .leading, spacing: 12) {
                    Text("选择类型")
                        .font(.headline)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(category.subCategories, id: \.self) { subCategory in
                            Button(action: {
                                selectedSubCategory = subCategory
                                showingCustomInput = false
                            }) {
                                Text(subCategory)
                                    .font(.subheadline)
                                    .foregroundColor(selectedSubCategory == subCategory ? .white : .blue)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        selectedSubCategory == subCategory ? Color.blue : Color.blue.opacity(0.1)
                                    )
                                    .cornerRadius(8)
                            }
                        }
                        
                        // 自定义选项
                        Button(action: {
                            showingCustomInput = true
                            selectedSubCategory = ""
                        }) {
                            Text("自定义")
                                .font(.subheadline)
                                .foregroundColor(showingCustomInput ? .white : .blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    showingCustomInput ? Color.blue : Color.blue.opacity(0.1)
                                )
                                .cornerRadius(8)
                        }
                    }
                }
                
                // 自定义输入
                if showingCustomInput {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("自定义名称")
                            .font(.headline)
                        
                        TextField("请输入名称", text: $customName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                // 金额输入
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
                        saveAsset()
                    }
                    .disabled(!isValidInput)
                }
            }
        }
    }
    
    private var isValidInput: Bool {
        let hasValidSubCategory = !selectedSubCategory.isEmpty || (!customName.isEmpty && showingCustomInput)
        let hasValidAmount = !amount.isEmpty && Double(amount) != nil && Double(amount)! > 0
        
        return hasValidSubCategory && hasValidAmount
    }
    
    private func saveAsset() {
        guard let amountValue = Double(amount) else { return }
        
        let name = showingCustomInput ? customName : selectedSubCategory
        let subCategory = showingCustomInput ? "自定义" : selectedSubCategory
        
        let asset = AssetItem(
            name: name,
            amount: amountValue,
            category: category,
            subCategory: subCategory
        )
        
        onSave(asset)
        dismiss()
    }
}

#Preview {
    AddAssetSheetView(category: .liquidAssets) { _ in }
}
