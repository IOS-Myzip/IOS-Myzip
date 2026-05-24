import SwiftUI

struct EditLinkView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var categoryViewModel: CategoryViewModel

    let link: LinkItem
    var onSave: (LinkItem) async -> Void

    @State private var memo: String
    @State private var selectedCategory: String
    @State private var isSaving = false
    @State private var isAddingCategory = false
    @State private var newCategoryName = ""

    init(link: LinkItem, onSave: @escaping (LinkItem) async -> Void) {
        self.link = link
        self.onSave = onSave
        _memo = State(initialValue: link.memo)
        _selectedCategory = State(initialValue: link.category)
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
                        Text("링크 수정")
                            .font(.title3.bold())
                            .padding(.horizontal, 20)

                        // URL (수정 불가)
                        VStack(alignment: .leading, spacing: 8) {
                            Label("URL", systemImage: "link")
                                .font(.caption.bold()).foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                            Text(link.url)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                        }

                        // 카테고리
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

                            ScrollViewReader { proxy in
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
                                        .id(cat)
                                    }

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
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation {
                                        proxy.scrollTo(selectedCategory, anchor: .center)
                                    }
                                }
                            }
                            }
                        }

                        // 메모
                        VStack(alignment: .leading, spacing: 8) {
                            Label("메모", systemImage: "note.text")
                                .font(.caption.bold()).foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                            TextField("메모를 입력하세요", text: $memo, axis: .vertical)
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
                            var updated = link
                            updated.category = selectedCategory
                            updated.memo = memo
                            await onSave(updated)
                            isSaving = false
                            dismiss()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            if isSaving { ProgressView().tint(.white) }
                            Text(isSaving ? "저장 중..." : "수정 완료").fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.appTeal)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .disabled(isSaving)
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
    }
}
