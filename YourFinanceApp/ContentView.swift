import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var assetItems: [AssetItem]
    @State private var viewModel = DashboardViewModel()
    @State private var showingAddAssetFlow = false
    
    var body: some View {
        NavigationStack {
            if assetItems.isEmpty {
                // 首次使用，显示引导流程
                OnboardingView()
            } else {
                // 显示主仪表盘
                DashboardView()
            }
        }
        .environment(viewModel)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: AssetItem.self, inMemory: true)
}
