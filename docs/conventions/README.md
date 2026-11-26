# VetConsult 팀 컨벤션 (공유용)

**단일 레포 · 모놀리식(헥사 모듈)** 기준으로 맞춘다.
팀원이 같은 규칙을 쓰도록 이 폴더를 공유한다.

- 레포(예): `pet-health-consult-be`
- 패키지 루트(예): `com.pethealthconsult`

## 구성

| 경로 | 용도 |
|------|------|
| [`CODE_CONVENTIONS.md`](CODE_CONVENTIONS.md) | 코드 작성·리뷰 · **패키지 구조** |
| [`GIT_CONVENTIONS.md`](GIT_CONVENTIONS.md) | 커밋·브랜치·PR (`dev`에서만 작업) |
| [`CONFIG.md`](CONFIG.md) | local / dev / prod 설정 |
| [`pull_request_template.md`](pull_request_template.md) | PR 본문 |
| [`.github/ISSUE_TEMPLATE/`](.github/ISSUE_TEMPLATE/) | 이슈 폼 |
| [`.cursor/rules/`](.cursor/rules/) | Cursor `.mdc` |
| [`docs/`](docs/) | 설계·소유권·DDL·API 명세 |

## 패키지 구조 (모놀리식)

```text
com.{서비스명}/
├── matching/          # 도메인 모듈 (매칭 담당)
│   ├── request/
│   ├── wave/
│   ├── offer/
│   └── …
├── clinic/            # 다른 도메인 (다른 담당)
├── care/              # …
├── shared/
└── global/
```

```text
com.{서비스명}.matching   ← 매칭 담당
com.{서비스명}.clinic     ← 클리닉 담당
com.{서비스명}.care       ← 케어 담당
com.{서비스명}.shared
com.{서비스명}.global
```

상세·헥사 레이어: [`CODE_CONVENTIONS.md`](CODE_CONVENTIONS.md) §5.

## 팀원 설치

1. 이 폴더 전체를 받는다. (또는 `vetconsult-rules-pack.zip` + `WHERE_TO_PUT.md`)
2. Cursor: `.cursor/rules/*.mdc` → **백엔드 레포 루트** `.cursor/rules/`
3. GitHub: **단일 레포 루트**에
   - `.github/pull_request_template.md`
   - `.github/ISSUE_TEMPLATE/*.yml`

## 아키텍처 한 줄

- **레포 1개** / **배포 단위 1개(모놀리식 앱)**
- 내부는 **도메인 모듈 + 헥사고날** (`matching`, `clinic`, `care` …)
- MSA처럼 서비스마다 레포·프로세스·`*-service` 폴더를 나누지 않는다.
- 작업 브랜치·PR은 **`dev`만**. `main`은 실배포 직전.
