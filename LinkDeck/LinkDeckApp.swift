import SwiftUI
import FirebaseCore

@main
struct LinkDeckApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var categoryViewModel = CategoryViewModel()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if !hasSeenOnboarding {
                OnboardingView()
                    .environmentObject(authViewModel)
                    .environmentObject(categoryViewModel)
            } else if authViewModel.currentUser != nil {
                HomeView()
                    .environmentObject(authViewModel)
                    .environmentObject(categoryViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
