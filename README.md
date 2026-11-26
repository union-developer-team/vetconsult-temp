# vetconsult-temp (임시 · 단일 레포 모놀리식)

팀장님 **공식 레포** 전까지 쓰는 임시 저장소다.

## 구조

MSA처럼 `SHG-matching-service/` 하위 프로젝트를 두지 않는다.  
**루트 하나 = Spring Boot 앱 하나**, 내부는 헥사 도메인 모듈이다.

```text
src/main/java/com/louiekury/
└── matching/                 # matching 도메인 모듈
    ├── request/
    │   ├── domain/
    │   ├── application/
    │   └── adapter/
    ├── wave/
    ├── offer/
    ├── worker/
    ├── shared/
    └── global/
```

이후 `clinic`, `care` 등 도메인 모듈을 **같은 앱 패키지** 아래에 추가한다.

## 규칙

https://github.com/union-developer-team/vetconsult-team-conventions

## 실행

```bash
./gradlew bootRun
# profile: local (필요 시)
```

## 이전 계획

공식 단일 레포가 생기면 이 내용을 옮기고 본 레포는 archive 한다.
