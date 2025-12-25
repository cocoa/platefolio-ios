import SwiftUI

struct SettingsView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = true

    var body: some View {
        NavigationStack {
            List {
                Button("Log out") { isLoggedIn = false }
                    .foregroundStyle(.red)
            }
            .navigationTitle("Settings")
        }
    }
}
