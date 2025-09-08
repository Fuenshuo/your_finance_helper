import SwiftUI
import SwiftData

struct AddAssetFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var currentStep = 0
    @State private var tempAssets: [AssetItem] = []
    
    private let categories = AssetCategory.allCases
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 步骤指示器
                ProgressView(value: Double(currentStep + 1), total: Double(categories.count))
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding()
                
                // 分类标签页
                TabView(selection: $currentStep) {
                    ForEach(Array(categories.enumerated()), id: \.offset) { index, category in
                        AssetCategoryView(
                            category: category,
                            tempAssets: $tempAssets
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // 底部按钮
                HStack {
                    if currentStep > 0 {
                        Button("上一步") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    if currentStep < categories.count - 1 {
                        Button("下一步") {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(8)
                    } else {
                        Button("完成") {
                            saveAssets()
                            dismiss()
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("添加家庭资产")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveAssets() {
        for asset in tempAssets {
            modelContext.insert(asset)
        }
        try? modelContext.save()
    }
}

#Preview {
    AddAssetFlowView()
        .modelContainer(for: AssetItem.self, inMemory: true)
}
