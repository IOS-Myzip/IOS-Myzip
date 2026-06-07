# 🔗 LinkDeck

저장하고 싶은 링크를 카드 뉴스 형태로 정리해서 볼 수 있는 iOS 링크 큐레이션 앱

![iOS](https://img.shields.io/badge/iOS-17%2B-000000?style=flat&logo=apple&logoColor=white) ![Swift](https://img.shields.io/badge/Swift-5.9-F54A2A?style=flat&logo=swift&logoColor=white) ![SwiftUI](https://img.shields.io/badge/SwiftUI-F54A2A?style=flat&logo=swift&logoColor=white) ![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat&logo=firebase&logoColor=black)

<br>

### 1. 프로젝트 수행 목적
**1-1. 프로젝트 배경**
브라우저 북마크, 카카오톡 저장 메시지, 노션 링크 모음 등 여러 곳에 분산된 링크를 한 곳에서 관리하기 어렵다는 불편함에서 출발한다. 특히 나중에 읽으려고 저장한 링크를 실제로 다시 읽는 경우는 드물며, 읽었는지 여부도 파악하기 어려워 잊히고는 한다. 이러한 문제를 해결하기 위해 링크를 저장하는 행위 자체의 마찰을 낮추고, 저장된 링크를 카드 뉴스 형식으로 소비할 수 있는 iOS 앱을 기획하였다.
**1-2. 프로젝트 목표**
URL 하나로 제목, 출처, 핵심 메시지를 자동으로 구성해 링크 저장 마찰을 최소화
카드 뷰어(커버 → 핵심 메시지 → 인사이트) 형식으로 콘텐츠를 단계적으로 소비
읽음 상태 자동 추적 및 카테고리 분류로 링크 관리 효율화
Firebase 동기화를 통해 기기가 바뀌어도 데이터 유지

<br>

### 2. 프로젝트 기능

**1) 온보딩**
- 앱 최초 실행 시 3단계 온보딩 진행 (환영 → 관심 분야 선택 → 사용법 안내)
- 테크, 개발, AI, 비즈니스 등 10개 관심 분야 중 선택 → 초기 카테고리 자동 설정
- 선택하지 않을 경우 기본 카테고리(테크, 개발, 트렌드)로 자동 설정

**2) 링크 저장**
- URL 입력 시 페이지 제목 자동 fetch (LPMetadataProvider)
- YouTube, GitHub, Medium 등 도메인별 핵심 메시지·요점·인사이트 자동 구성
- 카테고리 선택 및 메모 추가
- 링크 추가 화면에서 새 카테고리 인라인 생성

**3) 홈 화면**
- 저장된 링크 수 표시 및 검색 기능
- 카테고리별 필터링, 미읽음 필터
- 최신순 / 오래된순 정렬 토글
- 스와이프 제스처로 삭제

**4) 카드 뷰어**
- 커버 → 핵심 메시지 → 인사이트 순서로 3장 스와이프
- 마지막 카드까지 읽으면 자동 읽음 처리
- 카드 내에서 삭제, 원문 이동

**5) 카테고리 관리**
- 설정에서 카테고리 추가 및 삭제
- Firestore 동기화로 기기 변경 후에도 유지

<br>

###  3. 기대효과
| 항목 | 내용 |
|---|---|
| 링크 저장 효율화 | URL 하나만 입력하면 제목·출처·카드 내용이 자동 생성되어 저장 시간 단축 |
| 콘텐츠 소비율 향상 | 카드 슬라이드 형식으로 핵심을 압축 제공해 방치되는 링크 감소 |
| 링크 관리 체계화 | 카테고리 분류, 읽음 여부 추적, 최신순/오래된순 정렬로 링크 현황 파악 용이 |
| 기기 독립성 | Firebase 클라우드 동기화로 기기 변경 시에도 데이터 유지 |
| 맞춤형 온보딩 | 관심 분야 기반 초기 카테고리 자동 설정으로 진입 장벽 최소화 |

<br>

### 4. 관련 기술
| 분류 | 사용 기술 | 상세 |
|---|---|---|
| 언어 | ![Swift](https://img.shields.io/badge/Swift-5.9-F54A2A?style=flat&logo=swift&logoColor=white) | Swift 5.9 |
| UI | ![SwiftUI](https://img.shields.io/badge/SwiftUI-F05138?style=flat&logo=swift&logoColor=white) | iOS 17+ 전용 |
| 인증 | ![Firebase Auth](https://img.shields.io/badge/Firebase_Auth-FFCA28?style=flat&logo=firebase&logoColor=black) | 이메일·비밀번호 인증 |
| DB | ![Firestore](https://img.shields.io/badge/Firestore-FFCA28?style=flat&logo=firebase&logoColor=black) | 링크 및 카테고리 저장, 복합 인덱스(`userId` + `createdAt` desc) |
| 메타데이터 | ![Apple](https://img.shields.io/badge/LinkPresentation-000000?style=flat&logo=apple&logoColor=white) | `LPMetadataProvider`로 URL 제목 자동 fetch |
| 아키텍처 | ![MVVM](https://img.shields.io/badge/MVVM-555555?style=flat) | View ↔ ViewModel ↔ Service 3계층 분리 |

<br>

### 5. 개발 도구
| 도구 | 용도 |
|---|---|
| Xcode 15+ | iOS 앱 빌드 및 시뮬레이터 실행 |
| Firebase Console | Authentication 설정, Firestore 인덱스 생성 및 데이터 확인 |
| Git | 버전 관리 (민감 파일 `.gitignore` 처리) |
| Swift Package Manager | Firebase iOS SDK 의존성 관리 |

<br>

### 6. 프로젝트 구조

<img width="1000" alt="아키텍처 구조도" src="https://github.com/user-attachments/assets/b4ecee31-5ca7-4e1f-ad5c-1eb8eb18576b" />

<br>

### 7. 실행 방법

1. Firebase 프로젝트 생성 후 `GoogleService-Info.plist` 추가
   - 템플릿: `LinkDeck/GoogleService-Info.plist.template` 참고
2. Firestore 복합 인덱스 생성 (`userId` + `createdAt` desc)
3. Xcode에서 빌드 (iOS 17+)
