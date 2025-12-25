import SwiftUI

struct RootView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false

    var body: some View {
        if isLoggedIn {
            MainTabView()
        } else {
            LoginView()
        }
    }
}

struct LoginView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Platefolio")
                .font(.largeTitle).bold()

            Text("Sign in required")
                .foregroundStyle(.secondary)

            Button("Continue (temporary)") {
                isLoggedIn = true
            }
            .buttonStyle(.borderedProminent)

            Text("Next step: replace this with Sign in with Apple + Firebase Auth.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
        .padding()
    }
}
