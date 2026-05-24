import Foundation
import FirebaseFirestore

class CategoryService {
    static let shared = CategoryService()
    private let db = Firestore.firestore()

    private let defaults = ["트렌드", "개발", "테크"]

    func fetchCategories(userId: String) async throws -> [String] {
        let doc = try await db.collection("users").document(userId).getDocument()
        if let cats = doc.data()?["categories"] as? [String] {
            return cats
        }
        // 처음 가입한 유저면 기본값 저장
        try await saveCategories(defaults, userId: userId)
        return defaults
    }

    func saveCategories(_ categories: [String], userId: String) async throws {
        try await db.collection("users").document(userId).setData(
            ["categories": categories], merge: true
        )
    }
}
