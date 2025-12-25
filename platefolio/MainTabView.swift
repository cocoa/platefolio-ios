import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            CaptureView()
                .tabItem { Label("Add", systemImage: "camera") }

            GarageView()
                .tabItem { Label("Garage", systemImage: "square.grid.2x2") }

            CommunityView()
                .tabItem { Label("Community", systemImage: "globe") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}
