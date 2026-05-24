import SwiftUI
import FirebaseCore

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    @StateObject private var viewModel = LibraryViewModel()

    @State private var showAddLink = false
    @State private var selectedLink: LinkItem? = nil

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                navBar
                searchBar
                categoryChips

                if viewModel.isLoading {
                    ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.filteredLinks.isEmpty {
                    emptyView
                } else {
                    linkList
                }
            }

            // 링크 추가 버튼
            Button { showAddLink = true } label: {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.appTeal)
                    .clipShape(Circle())
                    .shadow(color: Color.appTeal.opacity(0.4), radius: 10, x: 0, y: 4)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $showAddLink) {
            AddLinkView(viewModel: viewModel)
        }
        .fullScreenCover(item: $selectedLink) { link in
            CardViewerView(link: link, viewModel: viewModel)
        }
        .task { await viewModel.fetchLinks() }
    }

    private var navBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("내 라이브러리")
                    .font(.title3.bold())
                Text("저장된 링크 \(viewModel.links.count)개")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button {
                authViewModel.signOut()
            } label: {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundColor(.secondary)
            TextField("제목, URL, 메모 검색", text: $viewModel.searchText)
                .font(.subheadline)
        }
        .padding(11)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .background(Color(.systemBackground))
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ChipView(label: "전체", isSelected: viewModel.selectedCategory == nil) {
                    viewModel.selectedCategory = nil
                }
                ForEach(categoryViewModel.categories, id: \.self) { cat in
                    ChipView(label: cat, isSelected: viewModel.selectedCategory == cat) {
                        viewModel.selectedCategory = viewModel.selectedCategory == cat ? nil : cat
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .background(Color(.systemBackground))
    }

    private var linkList: some View {
        List {
            ForEach(viewModel.filteredLinks) { link in
                LinkRowView(link: link)
                    .contentShape(Rectangle())
                    .onTapGesture { selectedLink = link }
                    .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            .onDelete { indexSet in
                Task {
                    for i in indexSet {
                        await viewModel.deleteLink(viewModel.filteredLinks[i])
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .refreshable { await viewModel.fetchLinks() }
    }

    private var emptyView: some View {
        VStack(spacing: 14) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.secondary.opacity(0.4))
            Text("저장된 링크가 없습니다")
                .font(.headline).foregroundColor(.secondary)
            Text("+ 버튼을 눌러 추가해보세요")
                .font(.subheadline).foregroundColor(.secondary.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ChipView: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.appTeal : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .secondary)
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

struct LinkRowView: View {
    let link: LinkItem

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(link.category)
                    .font(.caption2.bold())
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(categoryColor(link.category).opacity(0.12))
                    .foregroundColor(categoryColor(link.category))
                    .cornerRadius(6)

                Text(link.title)
                    .font(.subheadline.bold())
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Text(link.source).font(.caption).foregroundColor(.secondary)
                    Text("·").font(.caption).foregroundColor(.secondary.opacity(0.6))
                    Text(timeAgo(link.createdAt.dateValue())).font(.caption).foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(spacing: 8) {
                ZStack {
                    Circle().fill(Color(.systemGray5)).frame(width: 34, height: 34)
                    Text(initials(link.source))
                        .font(.caption2.bold()).foregroundColor(.secondary)
                }
                Circle()
                    .fill(link.isRead ? Color(.systemGray4) : Color.appTeal)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    private func categoryColor(_ cat: String) -> Color {
        switch cat {
        case "트렌드": return .orange
        case "개발": return Color.appTeal
        default: return .purple
        }
    }

    private func initials(_ source: String) -> String {
        let words = source.split(separator: " ")
        if words.count >= 2 {
            return String(words[0].prefix(1) + words[1].prefix(1)).uppercased()
        }
        return String(source.prefix(2)).uppercased()
    }

    private func timeAgo(_ date: Date) -> String {
        let diff = Int(Date().timeIntervalSince(date))
        if diff < 60 { return "방금 전" }
        if diff < 3600 { return "\(diff/60)분 전" }
        if diff < 86400 { return "\(diff/3600)시간 전" }
        return "\(diff/86400)일 전"
    }
}
