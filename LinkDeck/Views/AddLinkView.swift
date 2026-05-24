import SwiftUI

struct AddLinkView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    @ObservedObject var viewModel: LibraryViewModel

    @State private var url = ""
    @State private var memo = ""
    @State private var selectedCategory = ""
    @State private var isSaving = false
    @State private var isAddingCategory = false
    @State private var newCategoryName = ""

    // 메타데이터 미리보기
    @State private var fetchedTitle: String? = nil
    @State private var fetchedSource: String? = nil
    @State private var isFetchingPreview = false
    @State private var fetchTask: Task<Void, Never>? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Capsule()
                    .fill(Color(.systemGray4))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 20)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("링크 추가")
                            .font(.title3.bold())
                            .padding(.horizontal, 20)

                        // URL 입력
                        VStack(alignment: .leading, spacing: 8) {
                            Label("URL", systemImage: "link")
                                .font(.caption.bold()).foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                            TextField("https://", text: $url)
                                .textContentType(.URL)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .padding(14)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .padding(.horizontal, 20)

                            if !url.isEmpty && !isValidURL(url) {
                                Text("올바른 URL을 입력해주세요 (http:// 또는 https://)")
                                    .font(.caption).foregroundColor(.red.opacity(0.7))
                                    .padding(.horizontal, 20)
                            }

                            // 실시간 미리보기
                            if isFetchingPreview {
                                HStack(spacing: 6) {
                                    ProgressView().scaleEffect(0.75)
                                    Text("제목 가져오는 중...")
                                        .font(.caption).foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 20)
                            } else if let title = fetchedTitle {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.caption).foregroundColor(Color.appTeal)
                                    Text(title)
                                        .font(.caption).foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                .padding(.horizontal, 20)
                            }
                        }

                        // 카테고리 선택
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                Label("카테고리", systemImage: "tag.fill")
                                    .font(.caption.bold()).foregroundColor(.secondary)
                                if !selectedCategory.isEmpty {
                                    Text(selectedCategory)
                                        .font(.caption.bold())
                                        .foregroundColor(Color.appTeal)
                                        .padding(.horizontal, 8).padding(.vertical, 3)
                                        .background(Color.appTeal.opacity(0.12))
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal, 20)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(categoryViewModel.categories, id: \.self) { cat in
                                        Button {
                                            selectedCategory = cat
                                        } label: {
                                            Text(cat)
                                                .font(.subheadline)
                                                .fontWeight(selectedCategory == cat ? .semibold : .regular)
                                                .padding(.horizontal, 16).padding(.vertical, 9)
                                                .background(selectedCategory == cat ? Color.appTeal : Color(.systemGray6))
                                                .foregroundColor(selectedCategory == cat ? .white : .secondary)
                                                .cornerRadius(20)
                                        }
                                        .buttonStyle(.plain)
                                    }

                                    // 새 카테고리 인라인 추가
                                    if isAddingCategory {
                                        HStack(spacing: 4) {
                                            TextField("카테고리명", text: $newCategoryName)
                                                .font(.subheadline)
                                                .frame(width: 90)
                                                .onSubmit { submitNewCategory() }
                                            Button { submitNewCategory() } label: {
                                                Image(systemName: "checkmark")
                                                    .font(.caption.bold())
                                                    .foregroundColor(Color.appTeal)
                                            }
                                            Button {
                                                isAddingCategory = false
                                                newCategoryName = ""
                                            } label: {
                                                Image(systemName: "xmark")
                                                    .font(.caption.bold())
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding(.horizontal, 12).padding(.vertical, 9)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(20)
                                    } else {
                                        Button {
                                            isAddingCategory = true
                                        } label: {
                                            Image(systemName: "plus")
                                                .font(.subheadline.bold())
                                                .foregroundColor(Color.appTeal)
                                                .frame(width: 36, height: 36)
                                                .background(Color.appTeal.opacity(0.1))
                                                .cornerRadius(20)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }

                            if selectedCategory.isEmpty {
                                Text("카테고리를 선택해주세요")
                                    .font(.caption).foregroundColor(.red.opacity(0.7))
                                    .padding(.horizontal, 20)
                            }
                        }

                        // 메모
                        VStack(alignment: .leading, spacing: 8) {
                            Label("메모 (선택)", systemImage: "note.text")
                                .font(.caption.bold()).foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                            TextField("이 링크에 대한 메모를 입력하세요", text: $memo, axis: .vertical)
                                .lineLimit(3...5)
                                .padding(14)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 120)
                }

                VStack {
                    Button {
                        Task {
                            isSaving = true
                            fetchTask?.cancel()
                            await viewModel.addLink(
                                url: url, memo: memo, category: selectedCategory,
                                fetchedTitle: fetchedTitle, fetchedSource: fetchedSource
                            )
                            isSaving = false
                            dismiss()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            if isSaving { ProgressView().tint(.white) }
                            Text(isSaving ? "저장 중..." : "저장하기").fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(canSave ? Color.appTeal : Color.appTeal.opacity(0.35))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .disabled(!canSave || isSaving)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32).padding(.top, 12)
                }
                .background(Color(.systemBackground))
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }.foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            if selectedCategory.isEmpty, let first = categoryViewModel.categories.first {
                selectedCategory = first
            }
        }
        .onChange(of: url) { newValue in
            // URL 바뀔 때마다 이전 fetch 취소하고 새로 시작
            fetchTask?.cancel()
            fetchedTitle = nil
            fetchedSource = nil

            guard isValidURL(newValue) else {
                isFetchingPreview = false
                return
            }

            isFetchingPreview = true
            fetchTask = Task {
                // 0.7초 debounce (타이핑 멈출 때까지 기다림)
                try? await Task.sleep(nanoseconds: 700_000_000)
                guard !Task.isCancelled else { return }

                let result = await MetadataService.shared.fetch(urlString: newValue)
                guard !Task.isCancelled else { return }

                fetchedTitle = result.title
                fetchedSource = result.source
                isFetchingPreview = false
            }
        }
    }

    private func submitNewCategory() {
        let name = newCategoryName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        Task {
            await categoryViewModel.addCategory(name)
            selectedCategory = name
        }
        newCategoryName = ""
        isAddingCategory = false
    }

    private var canSave: Bool {
        isValidURL(url) && !selectedCategory.isEmpty
    }

    private func isValidURL(_ string: String) -> Bool {
        guard let url = URL(string: string.trimmingCharacters(in: .whitespaces)),
              let scheme = url.scheme,
              ["http", "https"].contains(scheme),
              url.host != nil else { return false }
        return true
    }
}
