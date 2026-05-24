import Foundation
import LinkPresentation

class MetadataService {
    static let shared = MetadataService()

    // URL에서 실제 제목이랑 출처 도메인 가져오기
    func fetch(urlString: String) async -> (title: String, source: String) {
        guard let url = URL(string: urlString.trimmingCharacters(in: .whitespaces)) else {
            return ("", "")
        }

        let source = url.host?
            .replacingOccurrences(of: "www.", with: "")
            .replacingOccurrences(of: "m.", with: "") ?? "Unknown"

        let provider = LPMetadataProvider()
        provider.shouldFetchSubresources = false
        provider.timeout = 8

        do {
            let metadata = try await provider.startFetchingMetadata(for: url)
            let title = metadata.title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return (title.isEmpty ? source : title, source)
        } catch {
            // 네트워크 오류 등이면 도메인명으로 폴백
            return (source, source)
        }
    }
}
