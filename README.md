# pet-health-consult-be

반려동물 헬스 상담 **백엔드 단일 레포 · 모놀리식** 앱이다.  
도메인만 패키지로 나누고, 배포·기동 단위는 **프로세스 하나**다.

| 항목 | 값 |
|------|-----|
| 레포 | `pet-health-consult-be` |
| 패키지 루트 | `com.pethealthconsult` |
| 기본 포트 | `8080` |
| 기본 프로필 | `local` |

팀 규칙: [vetconsult-team-conventions](https://github.com/union-developer-team/vetconsult-team-conventions)

---

## 패키지 구조

```text
com.pethealthconsult/
├── PetHealthConsultApplication.java
├── matching/          # 매칭 도메인
│   ├── request/
│   ├── wave/
│   ├── offer/
│   └── worker/
├── clinic/            # (추가 예정) 클리닉
├── care/              # (추가 예정) 케어
├── shared/            # 모듈 공용 (예외 등)
└── global/            # 설정 · ApiResponse · 예외 핸들러 · BaseEntity
```

```text
com.pethealthconsult.matching
com.pethealthconsult.clinic
com.pethealthconsult.care
com.pethealthconsult.shared
com.pethealthconsult.global
```

각 도메인(또는 matching의 `request` / `wave` / `offer`) 안은 헥사:

`domain` → `application` (usecase / port) → `adapter` (in/out)

---

## 빠른 시작 (전원 동일)

### 1) 인프라 (Docker Desktop)

```bash
# 레포 루트에서
docker compose -p pet-health up -d
```

| 서비스 | 포트 | 컨테이너 |
|--------|------|----------|
| MySQL | `3316` | `pet-health-mysql` |
| Kafka | `9092` | `pet-health-kafka` |
| MongoDB | `27017` | `pet-health-mongo` |

> 예전에 `vetconsult-mysql` 등을 띄워 두었다면 포트 충돌 난다. 끄고 위 명령을 쓴다.

최초 MySQL은 `infra/mysql/init` 스크립트로 스키마·시드를 넣는다.  
볼륨이 이미 있으면 init이 다시 안 돈다 → 초기화 시:

```bash
docker compose -p pet-health down -v
docker compose -p pet-health up -d
```

### 2) 환경 변수 (선택)

```bash
cp .env.example .env
# 필요 시만 수정. .env는 커밋하지 않는다.
```

### 3) 앱 실행

```bash
./gradlew bootRun
# 또는
./gradlew bootRun --args='--spring.profiles.active=local'
```

- Swagger: http://localhost:8080/swagger-ui.html  
- OpenAPI: http://localhost:8080/v3/api-docs  

`local` 프로필은 **Eureka 비활성**이다. Docker만으로 API 검증 가능하다.

### 4) 테스트

```bash
./gradlew test
```

단위·슬라이스 테스트는 H2를 쓴다. Docker 불필요.

---

## 프로필

| 프로필 | 용도 | Eureka |
|--------|------|--------|
| `local` (기본) | 개인 PC + Docker Desktop | OFF |
| `dev` | DEV 노트북 / 통합 | ON |
| `prod` | EC2 운영 | ON |

```bash
SPRING_PROFILES_ACTIVE=dev ./gradlew bootRun
```

---

## 팀원이 알아둘 것 (사실상 전부)

단일 레포라 **각자 다른 서비스 레포를 clone하지 않는다.**

| 구분 | 내용 |
|------|------|
| 공통 | 이 레포, `docker compose`, 패키지 규칙, 이슈/PR 템플릿 |
| 개인 | `.env` (비밀값), 로컬 IDE 설정, 맡은 **도메인 모듈** 코드만 수정 |
| 브랜치 | 무조건 `dev`에서 `feat/이슈번호-작업명` |
| PR | base = `dev` (`main`은 실배포 직전만) |
| 소유 | 다른 사람 도메인·열린 PR 파일은 합의 없이 수정 금지 |

임시 API(`@Profile({"local","dev"})`)는 워커 도입 전 검증용이다. `prod`에는 안 뜬다.

---

## 디렉터리 안내

| 경로 | 설명 |
|------|------|
| `src/main/java/com/pethealthconsult/` | 앱 소스 |
| `src/main/resources/application*.yaml` | 공통 / local / dev / prod |
| `docker-compose.yml` | MySQL · Kafka · Mongo |
| `infra/` | compose용 init 스크립트 |
| `db/seed/` | 추가 시드 참고 |
| `.github/` | 이슈·PR 템플릿 |
| `.env.example` | 환경변수 샘플 |

---

## Eureka / Gateway (선택)

공용 인프라가 있을 때만:

```bash
# 예: 상위 폴더의 eureka/gateway compose
SPRING_PROFILES_ACTIVE=dev \
EUREKA_CLIENT_SERVICEURL_DEFAULTZONE=http://localhost:8761/eureka/ \
./gradlew bootRun
```

로컬 기본(`local`)은 Eureka 없이 동작한다.

---

## 주의

- `*-service` 폴더를 다시 만들지 않는다.
- YAML에 운영 비밀번호를 하드코딩하지 않는다.
- `main`에서 작업 브랜치를 따지 않는다.
