import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var categoryViewModel: CategoryViewModel

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("홈", systemImage: "house.fill") }

            SettingsView()
                .tabItem { Label("설정", systemImage: "gearshape.fill") }
        }
        .tint(Color.appTeal)
        .task { await categoryViewModel.fetch() }
    }
}
