import Foundation
import Combine
import FirebaseAuth

@MainActor
class LibraryViewModel: ObservableObject {
    @Published var links: [LinkItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var searchText = ""
    @Published var selectedCategory: String? = nil

    var filteredLinks: [LinkItem] {
        var result = links

        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.url.localizedCaseInsensitiveContains(searchText) ||
                $0.memo.localizedCaseInsensitiveContains(searchText)
            }
        }

        if let cat = selectedCategory {
            result = result.filter { $0.category == cat }
        }

        return result
    }

    func fetchLinks() async {
        guard let uid = AuthService.shared.currentUser?.uid else { return }
        isLoading = true
        do {
            links = try await LinkService.shared.fetchLinks(userId: uid)
        } catch {
            print("링크 불러오기 실패: \(error)")
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func addLink(url: String, memo: String, category: String) async {
        guard let uid = AuthService.shared.currentUser?.uid else { return }
        let newLink = LinkItem.create(userId: uid, url: url, memo: memo, category: category)
        do {
            try await LinkService.shared.addLink(newLink)
            await fetchLinks()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteLink(_ link: LinkItem) async {
        do {
            try await LinkService.shared.deleteLink(link)
            links.removeAll { $0.id == link.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateLink(_ link: LinkItem) async {
        do {
            try await LinkService.shared.updateLink(link)
            if let idx = links.firstIndex(where: { $0.id == link.id }) {
                links[idx] = link
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markAsRead(_ link: LinkItem) async {
        do {
            try await LinkService.shared.markAsRead(link)
            if let idx = links.firstIndex(where: { $0.id == link.id }) {
                links[idx].isRead = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
