# vetconsult-temp (임시)

팀장님이 **공식 단일 레포**를 만들어 주시기 전까지 쓰는 **임시 작업 레포**다.

- 목표: **모놀리식 · 단일 레포** (도메인 모듈 + 헥사)
- 용도: 팀원 작업과 matching 등 기존 작업을 **여기에 모아 병합**
- 이후: 공식 레포가 생기면 이 내용을 이전하고, 본 레포는 archive 예정

## 규칙

팀 규칙: [vetconsult-team-conventions](https://github.com/union-developer-team/vetconsult-team-conventions)

## 현재 구성

| 경로 | 설명 |
|------|------|
| `SHG-matching-service/` | 기존 matching 작업 (임시 수용). 이후 모놀리식 모듈로 흡수 예정 |
| `.github/` | 이슈·PR 템플릿 |

## 브랜치

- `main` — 임시 통합
- 작업: `feat/이슈번호-작업명` (규칙 레포 Git 컨벤션 따름)
- PR 대상: 당분간 `main` (공식 레포의 `dev` 정책은 이전 후 맞춤)

## 주의

- 이 레포는 **임시**다. 장기 배포·운영 기준으로 쓰지 말 것.
- clinic 등 미작업 레포는 넣지 않았다. 필요 시 모듈로 추가·PR.
