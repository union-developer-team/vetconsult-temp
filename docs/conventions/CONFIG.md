# VetConsult 설정 컨벤션

**단일 레포 · 모놀리식 앱** 기준이다.
상세 인프라 참고: `수의사_반려동물_프로젝트/INFRA.md` (포트·Eureka/Gateway는 공용 인프라)

## YAML 프로필 (앱 하나)

| 파일 | 역할 |
|------|------|
| `application.yaml` | 공통 (앱명, JPA, Kafka, springdoc 등) |
| `application-local.yaml` | 로컬 (필요 시) |
| `application-dev.yaml` | DEV 노트북·통합 |
| `application-prod.yaml` | EC2 운영 |

```yaml
spring.profiles.active: ${SPRING_PROFILES_ACTIVE:local}
```

| 환경 | 활성화 |
|------|--------|
| 개인 PC | 기본 `local` |
| DEV 노트북 | `SPRING_PROFILES_ACTIVE=dev` |
| EC2 | `SPRING_PROFILES_ACTIVE=prod` |

## 포트 (로컬)

| 구성 | 포트 | 비고 |
|------|------|------|
| 모놀리식 앱 | 합의된 `SERVER_PORT` (예: `8080`) | **배포·기동 단위는 앱 하나** |
| Eureka | `8761` | 공용 인프라 (사용 시) |
| Gateway | `8000` | 공용 인프라 (사용 시) |
| MySQL | `3316` | 공용 |
| Kafka | `9092` | 공용 |
| MongoDB | `27017` | 공용 |

MSA처럼 clinic/matching을 **서로 다른 포트의 별도 프로세스**로 올리지 않는다.
(기존 멀티 레포 실험 포트 8081/8082는 이행 전 참고용일 뿐, 목표 구조는 단일 앱이다.)

## MySQL

같은 MySQL 인스턴스를 쓰고, 도메인별로 **스키마(또는 테이블 prefix)를 논리 분리**할 수 있다.

| 도메인 모듈 | 스키마 예 |
|-------------|-----------|
| matching | `svc_matching` |
| clinic | `svc_clinic` |

모놀리식 앱이 필요한 스키마에 접속한다. (스키마마다 마이크로서비스를 두지 않음)

로컬 JDBC 예:

```text
jdbc:mysql://127.0.0.1:3316/svc_matching?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Seoul
```

여러 스키마가 필요하면 multi-datasource 또는 스키마 지정 방식을 팀에서 합의한다. **프로세스 분리가 아니다.**

## Kafka / MongoDB

| 항목 | 로컬 기본 |
|------|-----------|
| Kafka | `localhost:9092` (`KAFKA_BOOTSTRAP_SERVERS`) |
| Mongo | `mongodb://127.0.0.1:27017/vetconsult` (`MONGODB_URI`) |

모놀리식 앱(및 워커가 같은 앱/모듈에 있으면 그 프로세스)이 공용 브로커·Mongo를 본다.

## Eureka / Gateway (선택)

공용 인프라에 Eureka·Gateway가 있으면 모놀리식 앱을 **인스턴스 하나**로 등록·라우팅할 수 있다.
서비스마다 레지스트리 항목을 늘리는 MSA 운영을 전제로 하지 않는다.

```bash
EUREKA_CLIENT_SERVICEURL_DEFAULTZONE=http://localhost:8761/eureka/
```

## Secret 관리

**YAML에 비밀번호·운영 URI를 하드코딩하지 않는다.**

| 항목 | local | dev / prod |
|------|-------|------------|
| DB / Kafka / Mongo | 로컬 기본값 또는 `.env` | GitHub Secrets → 배포 env |
| Eureka 등 | `localhost` 또는 compose 호스트 | env |

예시 변수: `MYSQL_URL`, `MYSQL_USERNAME`, `MYSQL_PASSWORD`, `KAFKA_BOOTSTRAP_SERVERS`, `MONGODB_URI`, `SERVER_PORT`, `SPRING_PROFILES_ACTIVE`, `EUREKA_CLIENT_SERVICEURL_DEFAULTZONE`

## 로컬 기동 요약

```bash
# 공용 인프라 (필요 시)
cd 수의사_반려동물_프로젝트
docker compose -f docker-compose.infra.yml -p vetconsult-infra up --build -d

# 모놀리식 앱 (단일 레포 루트에서)
./gradlew bootRun
```

## 패키지

`CODE_CONVENTIONS.md` §5 — 단일 앱 아래 도메인 모듈 + 헥사.
