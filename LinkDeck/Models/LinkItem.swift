import Foundation
import FirebaseFirestore

struct LinkItem: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var url: String
    var memo: String
    var title: String
    var source: String
    var category: String
    var tags: [String]
    var isRead: Bool
    var keyMessage: String
    var mainPoints: [String]
    var insight: String
    var createdAt: Timestamp

    static func create(userId: String, url: String, memo: String, category: String) -> LinkItem {
        let lowercased = url.lowercased()

        let title: String
        let source: String
        let tags: [String]
        let keyMessage: String
        let mainPoints: [String]
        let insight: String

        if lowercased.contains("youtube.com") || lowercased.contains("youtu.be") {
            title = "YouTube 트렌드 영상"
            source = "YouTube"
            tags = ["영상", "트렌드", "YouTube"]
            keyMessage = "이 영상은 최신 트렌드를 생생하게 담고 있습니다."
            mainPoints = [
                "트렌드를 빠르게 파악할 수 있는 시각적 콘텐츠",
                "전문가의 관점에서 분석한 핵심 인사이트",
                "실생활에 바로 적용 가능한 실용적 팁 제공"
            ]
            insight = "영상 콘텐츠는 복잡한 개념을 직관적으로 전달하는 데 탁월합니다. 이 트렌드를 업무나 프로젝트에 연결해 새로운 아이디어를 발견해보세요."

        } else if lowercased.contains("github.com") {
            title = "GitHub 오픈소스 프로젝트"
            source = "GitHub"
            tags = ["오픈소스", "GitHub", "개발"]
            keyMessage = "커뮤니티가 검증한 오픈소스 프로젝트입니다."
            mainPoints = [
                "활발한 커뮤니티 기여로 지속적으로 개선되는 코드베이스",
                "프로덕션 환경에서 검증된 안정적인 구현체",
                "풍부한 문서와 예제로 빠른 온보딩 가능"
            ]
            insight = "오픈소스 프로젝트에 기여하거나 직접 활용하면 실전 개발 역량을 크게 키울 수 있습니다. 먼저 이슈 트래커를 살펴보고 기여할 수 있는 부분을 찾아보세요."

        } else if lowercased.contains("medium.com") || lowercased.contains("velog.io") || lowercased.contains("tistory.com") {
            let src: String
            if lowercased.contains("medium.com") { src = "Medium" }
            else if lowercased.contains("velog.io") { src = "Velog" }
            else { src = "Tistory" }

            title = "개발 기술 블로그 포스트"
            source = src
            tags = ["블로그", "기술", "개발"]
            keyMessage = "개발자의 실전 경험이 녹아든 기술 포스트입니다."
            mainPoints = [
                "실무에서 직접 검증된 기술 노하우와 Best Practice",
                "단계별 구현 가이드와 함께 제공되는 코드 예제",
                "흔히 마주치는 문제와 그 해결 방법의 명쾌한 설명"
            ]
            insight = "블로그 포스트는 같은 문제를 먼저 겪은 개발자의 경험을 압축한 지식입니다. 읽는 데 그치지 말고 직접 구현하며 내 것으로 만들어보세요."

        } else {
            title = "아티클"
            source = URL(string: url)?.host ?? "Unknown"
            tags = ["아티클", "IT"]
            keyMessage = "최신 기술 동향과 인사이트를 담은 아티클입니다."
            mainPoints = [
                "현재 기술 업계의 주요 이슈를 심층 분석",
                "전문가 관점에서 바라본 기술의 현재와 미래",
                "실제 비즈니스와 개발에 미치는 영향 전망"
            ]
            insight = "테크 트렌드를 꾸준히 파악하는 것은 개발자 경쟁력의 핵심입니다. 아티클의 핵심 개념을 정리하고 현재 프로젝트에 적용할 수 있는 부분을 찾아보세요."
        }

        return LinkItem(
            userId: userId,
            url: url,
            memo: memo,
            title: title,
            source: source,
            category: category,
            tags: tags,
            isRead: false,
            keyMessage: keyMessage,
            mainPoints: mainPoints,
            insight: insight,
            createdAt: Timestamp(date: Date())
        )
    }
}
