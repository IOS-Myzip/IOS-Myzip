# 🔗 LinkDeck

저장하고 싶은 링크를 카드 뉴스 형태로 정리해서 볼 수 있는 iOS 링크 큐레이션 앱

![iOS](https://img.shields.io/badge/iOS-17%2B-000000?style=flat&logo=apple&logoColor=white) ![Swift](https://img.shields.io/badge/Swift-5.9-F54A2A?style=flat&logo=swift&logoColor=white) ![SwiftUI](https://img.shields.io/badge/SwiftUI-F54A2A?style=flat&logo=swift&logoColor=white) ![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat&logo=firebase&logoColor=black)

<br>

## 기능

### 링크 저장
- URL 입력 시 페이지 제목 자동 fetch (`LPMetadataProvider`)
- 카테고리 선택 및 메모 추가
- 링크 추가 화면에서 새 카테고리 인라인 생성

### 홈 화면
- 카테고리별 필터링, 미읽음 필터
- 최신순 / 오래된순 정렬 토글
- 스와이프 제스처로 수정 및 삭제

### 카드 뷰어
- 커버 → 핵심 메시지 → 인사이트 순서로 3장 스와이프
- 마지막 카드까지 읽으면 자동 읽음 처리
- 카드 내에서 수정, 삭제, 원문 이동

### 카테고리 관리
- 설정에서 카테고리 추가 및 삭제
- Firestore 동기화로 기기 변경 후에도 유지

### 온보딩
- 관심 분야 선택 → 초기 카테고리 자동 설정

<br>

## 기술 스택

| 분류 | 사용 기술 |
|---|---|
| UI | ![SwiftUI](https://img.shields.io/badge/SwiftUI-F05138?style=flat&logo=swift&logoColor=white) |
| 인증 | ![Firebase Auth](https://img.shields.io/badge/Firebase_Auth-FFCA28?style=flat&logo=firebase&logoColor=black) |
| DB | ![Firestore](https://img.shields.io/badge/Firestore-FFCA28?style=flat&logo=firebase&logoColor=black) |
| 메타데이터 | ![Apple](https://img.shields.io/badge/LinkPresentation-000000?style=flat&logo=apple&logoColor=white) |
| 아키텍처 | ![MVVM](https://img.shields.io/badge/MVVM-555555?style=flat) |

<br>

## 프로젝트 구조

```
LinkDeck/
├── Models/
│   └── LinkItem.swift
├── Services/
│   ├── AuthService.swift
│   ├── LinkService.swift
│   ├── CategoryService.swift
│   └── MetadataService.swift
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── LibraryViewModel.swift
│   └── CategoryViewModel.swift
└── Views/
    ├── HomeView.swift
    ├── CardViewerView.swift
    ├── AddLinkView.swift
    ├── EditLinkView.swift
    ├── LoginView.swift
    ├── OnboardingView.swift
    ├── SettingsView.swift
    └── CategoryManageView.swift
```

<br>

## 실행 방법

1. Firebase 프로젝트 생성 후 `GoogleService-Info.plist` 추가
   - 템플릿: `LinkDeck/GoogleService-Info.plist.template` 참고
2. Firestore 복합 인덱스 생성 (`userId` + `createdAt` desc)
3. Xcode에서 빌드 (iOS 17+)
