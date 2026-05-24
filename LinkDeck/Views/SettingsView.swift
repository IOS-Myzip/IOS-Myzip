import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showLogoutAlert = false

    var body: some View {
        NavigationStack {
            List {
                Section("계정") {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle().fill(Color.appTeal.opacity(0.15)).frame(width: 52, height: 52)
                            Image(systemName: "person.fill").font(.title3).foregroundColor(Color.appTeal)
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(authViewModel.currentUser?.email ?? "")
                                .font(.subheadline.bold())
                            Text("LinkDeck 사용자")
                                .font(.caption).foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }

                Section("콘텐츠") {
                    NavigationLink {
                        CategoryManageView()
                    } label: {
                        Label("카테고리 관리", systemImage: "tag.fill")
                    }
                }

                Section("정보") {
                    HStack {
                        Label("앱 버전", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0").foregroundColor(.secondary).font(.subheadline)
                    }
                    HStack {
                        Label("개발자", systemImage: "hammer")
                        Spacer()
                        Text("김예나").foregroundColor(.secondary).font(.subheadline)
                    }
                }

                Section {
                    Button { showLogoutAlert = true } label: {
                        Label("로그아웃", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .alert("로그아웃", isPresented: $showLogoutAlert) {
                Button("취소", role: .cancel) {}
                Button("로그아웃", role: .destructive) { authViewModel.signOut() }
            } message: {
                Text("로그아웃 하시겠습니까?")
            }
        }
    }
}
