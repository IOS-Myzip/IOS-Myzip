import SwiftUI

struct CategoryManageView: View {
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    @State private var newCategory = ""
    @State private var showAddField = false

    var body: some View {
        List {
            Section {
                ForEach(categoryViewModel.categories, id: \.self) { cat in
                    HStack {
                        Circle()
                            .fill(Color.appTeal.opacity(0.2))
                            .frame(width: 8, height: 8)
                        Text(cat)
                            .font(.subheadline)
                    }
                    .padding(.vertical, 2)
                }
                .onDelete { offsets in
                    Task { await categoryViewModel.deleteCategory(at: offsets) }
                }
            } header: {
                Text("카테고리 목록")
            } footer: {
                Text("왼쪽으로 스와이프하면 삭제할 수 있습니다.")
                    .font(.caption)
            }

            Section {
                if showAddField {
                    HStack {
                        TextField("새 카테고리 이름", text: $newCategory)
                            .autocorrectionDisabled()
                        Button("추가") {
                            Task {
                                await categoryViewModel.addCategory(newCategory)
                                newCategory = ""
                                showAddField = false
                            }
                        }
                        .disabled(newCategory.trimmingCharacters(in: .whitespaces).isEmpty)
                        .foregroundColor(Color.appTeal)
                        .fontWeight(.semibold)
                    }
                } else {
                    Button {
                        showAddField = true
                    } label: {
                        Label("새 카테고리 추가", systemImage: "plus.circle.fill")
                            .foregroundColor(Color.appTeal)
                    }
                }
            }
        }
        .navigationTitle("카테고리 관리")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            EditButton()
        }
    }
}
