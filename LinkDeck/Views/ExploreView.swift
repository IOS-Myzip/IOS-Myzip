import SwiftUI
import FirebaseCore

struct ExploreView: View {
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    @StateObject private var viewModel = LibraryViewModel()

    @State private var sortNewest = true
    @State private var selectedCategory: String? = nil
    @State private var selectedLink: LinkItem? = nil

    var sorted: [LinkItem] {
        var list = selectedCategory != nil
            ? viewModel.links.filter { $0.category == selectedCategory! }
            : viewModel.links
        list.sort {
            sortNewest
                ? $0.createdAt.dateValue() > $1.createdAt.dateValue()
                : $0.createdAt.dateValue() < $1.createdAt.dateValue()
        }
        return list
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar
                Divider()

                if viewModel.isLoading {
                    ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if sorted.isEmpty {
                    VStack(spacing: 14) {
                        Image(systemName: "tray")
                            .font(.system(size: 44)).foregroundColor(.secondary.opacity(0.4))
                        Text("해당하는 링크가 없습니다")
                            .font(.subheadline).foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(sorted) { link in
                            LinkRowView(link: link)
                                .contentShape(Rectangle())
                                .onTapGesture { selectedLink = link }
                                .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("탐색")
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.fetchLinks() }
            .fullScreenCover(item: $selectedLink) { link in
                CardViewerView(link: link, viewModel: viewModel)
            }
        }
    }

    private var filterBar: some View {
        HStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterChip("전체", isSelected: selectedCategory == nil) {
                        selectedCategory = nil
                    }
                    ForEach(categoryViewModel.categories, id: \.self) { cat in
                        filterChip(cat, isSelected: selectedCategory == cat) {
                            selectedCategory = selectedCategory == cat ? nil : cat
                        }
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
            }

            Divider().frame(height: 32)

            Button {
                sortNewest.toggle()
            } label: {
                HStack(spacing: 3) {
                    Image(systemName: sortNewest ? "arrow.down" : "arrow.up")
                        .font(.caption.bold())
                    Text(sortNewest ? "최신순" : "오래된순")
                        .font(.caption.bold())
                }
                .foregroundColor(Color.appTeal)
                .padding(.horizontal, 14)
            }
            .buttonStyle(.plain)
        }
        .background(Color(.systemBackground))
    }

    @ViewBuilder
    private func filterChip(_ label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .padding(.horizontal, 14).padding(.vertical, 7)
                .background(isSelected ? Color.appTeal : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .secondary)
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}
