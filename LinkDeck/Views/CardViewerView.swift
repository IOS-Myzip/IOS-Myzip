import SwiftUI

struct CardViewerView: View {
    let link: LinkItem
    @ObservedObject var viewModel: LibraryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    @State private var showDeleteAlert = false

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                TabView(selection: $currentPage) {
                    CoverCardView(link: link).tag(0)
                    MainCardView(link: link).tag(1)
                    InsightCardView(link: link).tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: currentPage) { _, page in
                    if page == 2 { Task { await viewModel.markAsRead(link) } }
                }
            }
        }
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left").font(.subheadline.bold())
                    Text("뒤로").font(.subheadline)
                }
                .foregroundColor(.primary)
            }

            Spacer()

            HStack(spacing: 5) {
                ForEach(0..<3) { i in
                    Capsule()
                        .fill(currentPage == i ? Color.appTeal : Color(.systemGray4))
                        .frame(width: currentPage == i ? 20 : 8, height: 8)
                        .animation(.spring(duration: 0.3), value: currentPage)
                }
            }

            Spacer()

            Button {
                showDeleteAlert = true
            } label: {
                Image(systemName: "trash")
                    .font(.subheadline)
                    .foregroundColor(.red.opacity(0.75))
            }
            .alert("링크 삭제", isPresented: $showDeleteAlert) {
                Button("삭제", role: .destructive) {
                    Task {
                        await viewModel.deleteLink(link)
                        dismiss()
                    }
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("이 링크를 삭제할까요?")
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
    }
}

struct CoverCardView: View {
    let link: LinkItem

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(
                            colors: [Color.appTeal, Color.appTeal.opacity(0.65)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(height: 220)

                    VStack(spacing: 14) {
                        Image(systemName: iconFor(link.category))
                            .font(.system(size: 54))
                            .foregroundColor(.white.opacity(0.9))
                        Text(link.source)
                            .font(.caption.bold())
                            .padding(.horizontal, 14).padding(.vertical, 5)
                            .background(.white.opacity(0.25))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                }
                .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 12) {
                    Text(link.title)
                        .font(.title3.bold())
                        .lineSpacing(2)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            Text("#\(link.category)")
                                .font(.caption.bold())
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(Color.appTeal.opacity(0.12))
                                .foregroundColor(Color.appTeal)
                                .cornerRadius(8)
                            ForEach(link.tags.prefix(2), id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption)
                                    .padding(.horizontal, 10).padding(.vertical, 5)
                                    .background(Color(.systemGray6))
                                    .foregroundColor(.secondary)
                                    .cornerRadius(8)
                            }
                        }
                    }

                    if !link.memo.isEmpty {
                        Text(link.memo)
                            .font(.subheadline).foregroundColor(.secondary).italic()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)

                Spacer(minLength: 40)

                HStack(spacing: 6) {
                    Image(systemName: "arrow.left")
                    Text("스와이프하여 다음 카드")
                    Image(systemName: "arrow.right")
                }
                .font(.caption).foregroundColor(.secondary)
                .padding(.bottom, 24)
            }
            .padding(.top, 20)
        }
    }

    private func iconFor(_ cat: String) -> String {
        switch cat {
        case "트렌드": return "play.rectangle.fill"
        case "개발": return "chevron.left.forwardslash.chevron.right"
        default: return "globe"
        }
    }
}

struct MainCardView: View {
    let link: LinkItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("핵심 메시지")
                        .font(.caption.bold())
                        .padding(.horizontal, 12).padding(.vertical, 5)
                        .background(Color.appTeal)
                        .foregroundColor(.white)
                        .cornerRadius(20)

                    Text(link.keyMessage)
                        .font(.body.bold())
                        .lineSpacing(4)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.appTeal.opacity(0.07))
                .cornerRadius(14)

                VStack(alignment: .leading, spacing: 14) {
                    Text("주요 내용")
                        .font(.footnote.bold()).foregroundColor(.secondary)

                    ForEach(link.mainPoints, id: \.self) { point in
                        HStack(alignment: .top, spacing: 10) {
                            Circle().fill(Color.appTeal)
                                .frame(width: 6, height: 6).padding(.top, 7)
                            Text(point)
                                .font(.subheadline).lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)

                HStack {
                    Spacer()
                    Text("→ 다음: AI 인사이트 보기")
                        .font(.caption).foregroundColor(Color.appTeal)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20).padding(.bottom, 40)
        }
    }
}

struct InsightCardView: View {
    let link: LinkItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 6) {
                    Text("✦").foregroundColor(Color.appTeal)
                    Text("AI 인사이트").font(.subheadline.bold())
                }
                .padding(.horizontal, 16).padding(.vertical, 11)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(LinearGradient(
                    colors: [Color.appTeal.opacity(0.12), Color.purple.opacity(0.07)],
                    startPoint: .leading, endPoint: .trailing
                ))
                .cornerRadius(12)

                Text("이 콘텐츠가 당신에게 중요한 이유")
                    .font(.footnote.bold()).foregroundColor(.secondary)

                Text(link.insight)
                    .font(.body).lineSpacing(5)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(link.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(Color(.systemGray6))
                                .foregroundColor(.secondary)
                                .cornerRadius(8)
                        }
                    }
                }

                VStack(spacing: 10) {
                    Text("원문 읽기").font(.caption).foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                    Button {
                        if let url = URL(string: link.url) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text("원문 보기").fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.appTeal)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                }
                .padding(.top, 6)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20).padding(.bottom, 40)
        }
    }
}

#Preview {
    CardViewerView(
        link: LinkItem.create(userId: "preview", url: "https://github.com/test", memo: "테스트", category: "개발"),
        viewModel: LibraryViewModel()
    )
}
