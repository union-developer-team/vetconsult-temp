# vetconsult-temp (임시)

팀장님이 **공식 단일 레포**를 만들어 주시기 전까지 쓰는 **임시 작업 레포**다.

- 목표: **모놀리식 · 단일 레포** (도메인 모듈 + 헥사). 서비스별 폴더로 쪼개지 않는다.
- 용도: 팀원 작업과 matching 등 기존 작업을 **여기에 모아 병합**
- 이후: 공식 레포가 생기면 이 내용을 이전하고, 본 레포는 archive 예정

## 규칙

팀 규칙: [vetconsult-team-conventions](https://github.com/union-developer-team/vetconsult-team-conventions)

## 현재 구성

단일 Spring Boot 앱. 패키지는 도메인 모듈로만 나눈다.

```text
src/main/java/com/pethealthconsult/matching/
├── MatchingApplication.java
├── request/     # consultation_request
├── wave/        # match_wave
├── offer/       # match_offer
├── worker/
├── shared/
└── global/
```

| 경로 | 설명 |
|------|------|
| `src/` | 모놀리식 앱 소스 (matching 모듈부터) |
| `db/` | 시드·DDL 참고 |
| `.github/` | 이슈·PR 템플릿 |

clinic 등 다른 도메인은 같은 앱 아래에 모듈 패키지로 추가한다. (`com.pethealthconsult.clinic` 등)

## 로컬 실행

```bash
./gradlew bootRun --args='--spring.profiles.active=local'
```

- 스키마: `svc_matching` (당분간 matching 전용)
- 기본 포트: `8082`
- Swagger: http://localhost:8082/swagger-ui.html

## 브랜치

- `dev` — 통합 개발. **모든 작업 브랜치는 여기서만** 딴다
- `main` — 실배포 직전 머지용. 일상 작업·기능 PR 금지
- 작업: `dev` 최신화 후 `feat/이슈번호-작업명`
- PR 대상: **`dev`만** (`main` 직행 금지)

## 주의

- 이 레포는 **임시**다. 장기 배포·운영 기준으로 쓰지 말 것.
- **`SHG-*-service` 같은 서비스 폴더를 다시 만들지 않는다.**
