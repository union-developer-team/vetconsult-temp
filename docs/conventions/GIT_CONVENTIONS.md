# 기여 가이드 (Git)

이 프로젝트는 **단일 레포**다. 브랜치·PR·이슈는 모두 이 레포에서 진행한다.

## 커밋 메시지

```text
<타입>: <한글 설명>
```

| 타입 | 설명 |
|------|------|
| `feat` | 새 기능 |
| `fix` | 버그 수정 |
| `docs` | 문서 |
| `chore` | 빌드·설정 등 |
| `refactor` | 리팩터링 |
| `test` | 테스트 |
| `style` | UI·스타일 (해당 시) |

```text
feat: 회원 가입 API 추가
fix: JWT 검증 오류 수정
docs: README 템플릿 통일
```

## 브랜치

| 브랜치 | 역할 |
|--------|------|
| `main` | **실배포 직전** 반영용. 일상 작업·기능 통합에 쓰지 않는다. |
| `dev` | 통합 개발. 모든 작업 브랜치의 **분기 기준**이자 기능 PR의 **기본 대상** |

> 원본 가이드의 `develop`은 이 프로젝트에서 **`dev`** 로 통일한다.

### 필수 (에이전트·사람 공통)

1. **작업 브랜치는 무조건 `dev`에서 딴다.** (`git checkout dev && git pull && git checkout -b feat/...`)
2. **`main`에서 바로 `feat/`·`fix/` 등 작업 브랜치를 만들지 않는다.**
3. **기능·버그·문서·chore PR의 base는 `dev`다.** `main`을 base로 두지 않는다.
4. **`main`은 실배포 직전에만** (`dev` → `main` 등 합의된 릴리스 머지) 사용한다.
5. Cursor/에이전트가 브랜치를 만들 때도 위와 동일하다. `main` 위 작업 금지.

## 브랜치 명명

1. GitHub Issue를 먼저 만든다. (`.github/ISSUE_TEMPLATE` 폼 사용)
2. 이슈 **승인**(`approved` 라벨 또는 승인 댓글/채팅) 후 작업 브랜치를 딴다.
3. **`dev`를 최신화한 뒤** 분기한다. (`main`에서 분기 금지)
4. 이름: `{type}/{issue-number}-{short-slug}`
   예: `feat/1-login-api`, `feat/3-wave-offer-create`

## PR 제목

`.github/pull_request_template.md` 참고.

```text
[#{Issue Number}] Feature : 작업 내용
```

예: `[#12] Feature : 로그인 API 구현` / `[#25] Fix : …` / `[#31] Docs : …`

## PR 대상·머지

- 일상 PR (feat/fix/docs/chore/refactor/test/style) → **`dev`만**
- **`main` 직행 PR 금지** (실배포 직전 릴리스 머지만 예외, 팀 합의 후)
- 머지는 사람이 한다
- 이슈 전체 완료 시 본문에 `Close #번호` (또는 `Closes #번호`)

## PR 본문에 넣지 말 것

- `Made with Cursor` / `Made with [Cursor](...)` 등 **도구·에디터 광고 문구**
- AI·에이전트가 자동으로 붙이는 서명·푸터
- PR 본문은 템플릿 내용만 작성한다
