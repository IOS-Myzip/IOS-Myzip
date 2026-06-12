import SwiftUI
import FirebaseAuth

struct OnboardingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    @State private var currentPage = 0
    @State private var selectedInterests: Set<String> = []

    let allInterests = ["테크", "개발", "AI", "비즈니스", "디자인", "트렌드", "마케팅", "스타트업", "금융", "교육"]

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            TabView(selection: $currentPage) {
                welcomePage.tag(0)
                interestPage.tag(1)
                tutorialPage.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            VStack {
                Spacer()
                VStack(spacing: 16) {
                    pageIndicator
                    nextButton
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }

    private var welcomePage: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 28) {
                ZStack {
                    Circle().fill(Color.appTeal.opacity(0.12)).frame(width: 120, height: 120)
                    Image(systemName: "rectangle.stack.fill")
                        .font(.system(size: 52)).foregroundColor(Color.appTeal)
                }

                VStack(spacing: 12) {
                    Text("my.zip")
                        .font(.title.bold()).multilineTextAlignment(.center)
                    Text("저장한 링크를 카드 뉴스로 빠르게 파악하고\n나만의 인사이트를 쌓아 보세요")
                        .font(.subheadline).multilineTextAlignment(.center)
                        .foregroundColor(.secondary).lineSpacing(4)
                }

                VStack(spacing: 12) {
                    valueRow(icon: "bolt.fill", color: .orange, title: "핵심만 빠르게", desc: "긴 아티클을 3장의 카드로 즉시 파악")
                    valueRow(icon: "square.grid.2x2.fill", color: Color.appTeal, title: "시각적 라이브러리", desc: "지루한 북마크를 카드 뉴스 컬렉션으로")
                    valueRow(icon: "arrow.counterclockwise", color: .purple, title: "잊지 않는 링크", desc: "방치되는 링크 없이 재발견 시스템 제공")
                }
                .padding(20)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
            }
            .padding(.horizontal, 28)
            Spacer()
            Spacer()
        }
    }

    @ViewBuilder
    private func valueRow(icon: String, color: Color, title: String, desc: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(color.opacity(0.12)).frame(width: 38, height: 38)
                Image(systemName: icon).font(.subheadline).foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.bold())
                Text(desc).font(.caption).foregroundColor(.secondary)
            }
            Spacer()
        }
    }

    private var interestPage: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 28) {
                VStack(spacing: 10) {
                    Text("관심 분야를 선택하세요")
                        .font(.title2.bold())
                    Text("선택한 카테고리로 링크를 분류합니다\n최소 1개 이상 선택해주세요")
                        .font(.subheadline).multilineTextAlignment(.center)
                        .foregroundColor(.secondary).lineSpacing(3)
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(allInterests, id: \.self) { item in
                        Button {
                            if selectedInterests.contains(item) {
                                selectedInterests.remove(item)
                            } else {
                                selectedInterests.insert(item)
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: iconFor(item))
                                    .font(.subheadline)
                                    .foregroundColor(selectedInterests.contains(item) ? .white : Color.appTeal)
                                Text(item)
                                    .font(.subheadline.bold())
                                    .foregroundColor(selectedInterests.contains(item) ? .white : .primary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(selectedInterests.contains(item) ? Color.appTeal : Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }

                if !selectedInterests.isEmpty {
                    Text("\(selectedInterests.count)개 선택됨")
                        .font(.caption.bold()).foregroundColor(Color.appTeal)
                }
            }
            .padding(.horizontal, 24)
            Spacer()
            Spacer()
        }
    }

    private func iconFor(_ interest: String) -> String {
        switch interest {
        case "테크": return "cpu"
        case "개발": return "chevron.left.forwardslash.chevron.right"
        case "AI": return "sparkles"
        case "비즈니스": return "briefcase.fill"
        case "디자인": return "paintbrush.fill"
        case "트렌드": return "chart.line.uptrend.xyaxis"
        case "마케팅": return "megaphone.fill"
        case "스타트업": return "rocket.fill"
        case "금융": return "wonsign.circle.fill"
        case "교육": return "book.fill"
        default: return "tag.fill"
        }
    }

    private var tutorialPage: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 28) {
                VStack(spacing: 10) {
                    Text("이렇게 사용하세요").font(.title2.bold())
                    Text("링크를 저장하고 카드 뉴스로 소비하세요")
                        .font(.subheadline).foregroundColor(.secondary)
                }

                VStack(spacing: 14) {
                    tutorialStep(icon: "plus.circle.fill", color: Color.appTeal,
                                 title: "링크 추가",
                                 desc: "홈 화면 하단 + 버튼을 눌러\nURL을 붙여넣어 저장하세요")
                    tutorialStep(icon: "rectangle.stack.fill", color: .indigo,
                                 title: "카드 뉴스로 확인",
                                 desc: "저장된 링크를 탭하면\n3장의 카드로 핵심 내용을 확인할 수 있어요")
                    tutorialStep(icon: "arrow.up.right.square.fill", color: .orange,
                                 title: "원문 이동",
                                 desc: "더 자세히 읽고 싶다면\n인사이트 카드에서 원문으로 이동하세요")
                }
                .padding(20)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
            }
            .padding(.horizontal, 24)
            Spacer()
            Spacer()
        }
    }

    @ViewBuilder
    private func tutorialStep(icon: String, color: Color, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle().fill(color.opacity(0.12)).frame(width: 44, height: 44)
                Image(systemName: icon).font(.title3).foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.subheadline.bold())
                Text(desc).font(.caption).foregroundColor(.secondary).lineSpacing(3)
            }
            Spacer()
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { i in
                Capsule()
                    .fill(currentPage == i ? Color.appTeal : Color(.systemGray4))
                    .frame(width: currentPage == i ? 24 : 8, height: 8)
                    .animation(.spring(duration: 0.3), value: currentPage)
            }
        }
    }

    private var nextButton: some View {
        Button {
            if currentPage < 2 {
                currentPage += 1
            } else {
                Task {
                    let chosen = selectedInterests.isEmpty
                        ? ["테크", "개발", "트렌드"]
                        : Array(selectedInterests).sorted()
                    categoryViewModel.categories = chosen
                    if let uid = AuthService.shared.currentUser?.uid {
                        try? await CategoryService.shared.saveCategories(chosen, userId: uid)
                    }
                }
                hasSeenOnboarding = true
            }
        } label: {
            Text(currentPage == 0 ? "시작하기 →" : currentPage == 1 ? "다음 →" : "my.zip 시작하기")
                .font(.body.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isNextEnabled ? Color.appTeal : Color.appTeal.opacity(0.35))
                .foregroundColor(.white)
                .cornerRadius(14)
        }
        .disabled(!isNextEnabled)
    }

    private var isNextEnabled: Bool {
        currentPage == 1 ? !selectedInterests.isEmpty : true
    }
}
