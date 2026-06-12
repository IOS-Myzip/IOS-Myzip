import Foundation
import FirebaseFirestore

class LinkService {
    static let shared = LinkService()
    private let db = Firestore.firestore()

    func addLink(_ link: LinkItem) async throws {
        try db.collection("links").addDocument(from: link)
    }

    func fetchLinks(userId: String) async throws -> [LinkItem] {
        let snapshot = try await db.collection("links")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: LinkItem.self) }
    }

    func deleteLink(_ link: LinkItem) async throws {
        guard let id = link.id else { return }
        try await db.collection("links").document(id).delete()
    }

    func markAsRead(_ link: LinkItem) async throws {
        guard let id = link.id else { return }
        try await db.collection("links").document(id).updateData(["isRead": true])
    }
}
