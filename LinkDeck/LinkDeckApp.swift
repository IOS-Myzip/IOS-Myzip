import SwiftUI
import FirebaseCore

@main
struct LinkDeckApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var categoryViewModel = CategoryViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if authViewModel.currentUser != nil {
                MainTabView()
                    .environmentObject(authViewModel)
                    .environmentObject(categoryViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
