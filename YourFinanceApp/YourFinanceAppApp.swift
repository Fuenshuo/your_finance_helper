import SwiftUI
import SwiftData

@main
struct YourFinanceAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: AssetItem.self)
    }
}
