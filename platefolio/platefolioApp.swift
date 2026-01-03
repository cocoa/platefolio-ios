import SwiftUI
import SwiftData

@main
struct PlatefolioApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: PlatePostEntity.self)
    }
}



