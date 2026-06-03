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

    static func create(userId: String, url: String, memo: String, category: String,
                       fetchedTitle: String? = nil, fetchedSource: String? = nil) -> LinkItem {
        let lower = url.lowercased()

        var title = ""
        var source = ""
        var tags: [String] = []
        var keyMessage = ""
        var mainPoints: [String] = []
        var insight = ""

        if lower.contains("youtube.com") || lower.contains("youtu.be") {
            title = "YouTube 영상"
            source = "YouTube"
            tags = ["영상", "YouTube"]
            keyMessage = "영상 콘텐츠입니다. 재생하며 내용을 확인해 보세요."
            mainPoints = [
                "영상 길이와 구성을 먼저 확인하면 핵심을 빠르게 파악할 수 있어요",
                "자막이나 속도 조절 기능을 활용하면 효율적으로 볼 수 있어요",
                "인상적인 구간은 타임 스탬프를 메모하면 나중에 찾기 편해요"
            ]
            insight = "나중에 다시 보고 싶은 부분이 있다면 타임 스탬프를 메모에 남겨 두세요."

        } else if lower.contains("github.com") {
            title = "GitHub 저장소"
            source = "GitHub"
            tags = ["GitHub", "오픈소스"]
            keyMessage = "README와 이슈 트래커를 먼저 살펴 보면 프로젝트 방향을 빠르게 파악할 수 있어요."
            mainPoints = [
                "README에서 사용 목적과 설치 방법을 확인할 수 있어요",
                "이슈와 PR 히스토리에서 활발히 유지보수되고 있는지 파악할 수 있어요",
                "최근 커밋 날짜가 실제 활성도를 잘 보여 줘요"
            ]
            insight = "clone 후 직접 실행해 보면 문서만 읽을 때보다 훨씬 빨리 파악돼요."

        } else if lower.contains("medium.com") || lower.contains("velog.io") || lower.contains("tistory.com") {
            let src = lower.contains("medium.com") ? "Medium" : (lower.contains("velog.io") ? "Velog" : "Tistory")
            title = "블로그 포스트"
            source = src
            tags = ["블로그", src]
            keyMessage = "개발자가 직접 경험하고 정리한 내용을 담고 있어요."
            mainPoints = [
                "글쓴이가 어떤 문제를 풀고자 했는지 먼저 파악하면 읽기 수월해요",
                "코드 예제가 있다면 직접 따라 해 보는 게 이해에 훨씬 도움이 돼요",
                "댓글이나 반응을 보면 실제로 유용했는지 가늠할 수 있어요"
            ]
            insight = "읽는 데서 끝내지 말고 핵심 내용 한 줄 요약을 메모에 남겨 보세요."

        } else {
            title = "아티클"
            source = URL(string: url)?.host?
                .replacingOccurrences(of: "www.", with: "")
                .replacingOccurrences(of: "m.", with: "") ?? "Unknown"
            tags = ["아티클"]
            keyMessage = "저장한 링크입니다. 읽고 나서 핵심 내용을 메모에 남겨 보세요."
            mainPoints = [
                "제목과 소제목을 먼저 훑어 보면 전체 구조를 파악하기 쉬워요",
                "모든 내용을 읽는 것이 아닌 필요한 부분만 골라 읽어도 충분해요",
                "나중에 다시 찾을 것 같다면 핵심 문장을 메모에 복사해 두세요"
            ]
            insight = "나중에 왜 저장했는지 기억나지 않는 경우가 많아요. 지금 간단히 이유를 적으면 도움이 돼요."
        }

        let finalTitle = (fetchedTitle != nil && !fetchedTitle!.isEmpty) ? fetchedTitle! : title
        let finalSource = (fetchedSource != nil && !fetchedSource!.isEmpty) ? fetchedSource! : source

        return LinkItem(
            userId: userId,
            url: url,
            memo: memo,
            title: finalTitle,
            source: finalSource,
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
