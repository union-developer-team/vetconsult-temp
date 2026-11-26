# 로컬 · DEV · EC2 인프라 (Eureka / Gateway / 데이터)

## 포트

| 구성 | 포트 |
| --- | --- |
| Eureka | `8761` |
| Gateway | `8000` |
| **pet-health-consult-be** (모놀리식 앱) | `8080` |
| 로컬 MySQL | `3316` |
| Kafka | `9092` |
| MongoDB | `27017` |

## 로컬 데이터 (권장)

백엔드 레포 루트:

```bash
cd pet-health-consult-be
docker compose -p pet-health up -d
```

| 컨테이너 | 포트 |
| --- | --- |
| `pet-health-mysql` | `3316` |
| `pet-health-kafka` | `9092` |
| `pet-health-mongo` | `27017` |

## 환경별 Eureka 주소

| 환경 | Gateway `defaultZone` | 앱 `defaultZone` | 비고 |
| --- | --- | --- | --- |
| **로컬 Docker** (`docker-compose.infra.yml`) | `http://eureka:8761/eureka/` | 호스트 앱: `http://localhost:8761/eureka/` | compose가 Gateway에 env 주입 |
| **로컬 Gradle** | `application-local` / `--spring.profiles.active=local` | **Eureka 기본 OFF** | Docker 데이터만으로 API 검증 |
| **DEV** | env `EUREKA_CLIENT_SERVICEURL_DEFAULTZONE` | 동일 | MySQL `3316` |
| **EC2** | `http://eureka:8761/eureka/` 또는 내부 DNS | env로 덮어쓰기 | Secrets |

```bash
EUREKA_CLIENT_SERVICEURL_DEFAULTZONE=http://localhost:8761/eureka/
```

## Eureka + Gateway Docker (선택)

```bash
cd 수의사_반려동물_프로젝트
docker compose -f docker-compose.infra.yml -p vetconsult-infra up --build -d
```

- Eureka UI: http://localhost:8761  
- Gateway: http://localhost:8000  
- 통합 Swagger: http://localhost:8000/swagger-ui/index.html  

## Mac에서 Gradle로 앱 기동

```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 17 || /usr/libexec/java_home -v 21)
cd pet-health-consult-be
./gradlew bootRun
```

- 앱 Swagger: http://localhost:8080/swagger-ui.html  
- `local` 프로필: Eureka 등록 안 함  

## Gateway 라우팅 (Eureka 사용 시)

- `discovery.locator` → `/{eureka-service-id-lowercase}/**`  
- 앱 id: `pet-health-consult-be`  
  예: `http://localhost:8000/pet-health-consult-be/api/matching/...`  
- OpenAPI: `http://localhost:8000/pet-health-consult-be/v3/api-docs`

## 참고

- 모놀리식: clinic / matching 을 **별도 포트 프로세스로 나누지 않는다.**  
- EC2는 하드코딩 프로필 대신 **같은 이미지 + env**로 맞춘다.  
- DEV DB: `~/.config/vetconsult/dev-notebook.env` (`EC2_SSH.md` 참고)
