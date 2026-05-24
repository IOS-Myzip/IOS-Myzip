import SwiftUI

struct AddLinkView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    @ObservedObject var viewModel: LibraryViewModel

    @State private var url = ""
    @State private var memo = ""
    @State private var selectedCategory = ""
    @State private var isSaving = false

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
                        }

                        // 카테고리 선택
                        VStack(alignment: .leading, spacing: 10) {
                            Label("카테고리", systemImage: "tag.fill")
                                .font(.caption.bold()).foregroundColor(.secondary)
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
                            await viewModel.addLink(url: url, memo: memo, category: selectedCategory)
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
    }

    private var canSave: Bool {
        !url.trimmingCharacters(in: .whitespaces).isEmpty && !selectedCategory.isEmpty
    }
}
