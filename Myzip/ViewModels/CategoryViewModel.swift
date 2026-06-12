import Foundation
import Combine
import SwiftUI
import FirebaseAuth

@MainActor
class CategoryViewModel: ObservableObject {
    @Published var categories: [String] = ["트렌드", "개발", "테크"]

    func fetch() async {
        guard let uid = AuthService.shared.currentUser?.uid else { return }
        do {
            categories = try await CategoryService.shared.fetchCategories(userId: uid)
        } catch {
            print("카테고리 로드 실패: \(error)")
        }
    }

    func addCategory(_ name: String) async {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !categories.contains(trimmed) else { return }
        categories.append(trimmed)
        await save()
    }

    func deleteCategory(at offsets: IndexSet) async {
        categories.remove(atOffsets: offsets)
        await save()
    }

    private func save() async {
        guard let uid = AuthService.shared.currentUser?.uid else { return }
        try? await CategoryService.shared.saveCategories(categories, userId: uid)
    }
}
