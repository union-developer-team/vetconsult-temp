# SHG-matching-service

VetConsult 매칭 처리 서비스 (`svc_matching`).  
호출 request 상태 갱신, match wave/offer, 백그라운드 매칭 워커.

- Java 패키지: `com.louiekury.matching`
- 스키마: `svc_matching`
- 기본 포트: `8082`
- 컨벤션: `../louie-kury-document/docs/convension/`

## 모듈

| 모듈 | 역할 |
| --- | --- |
| `request` | `consultation_request` 상태 update |
| `wave` | `match_wave` |
| `offer` | `match_offer` |
| `worker` | 매칭 워커 (Kafka `matching.request.v1` 소비 등) |

## 로컬 실행

```bash
./gradlew bootRun
```

MySQL `svc_matching`, Eureka(`8761`), Kafka(`9092`)가 떠 있어야 한다.

### Swagger

- 서비스 직접: http://localhost:8082/swagger-ui.html  
- Gateway(Eureka 드롭다운): http://localhost:8000/swagger-ui/index.html  
  → 목록 API: http://localhost:8000/swagger-services-config

### 임시 PATCH (수동 검증)

`PATCH /api/matching/requests/{uuid}/status` 는 워커 도입 전 검증용이며  
`--spring.profiles.active=local` 또는 `dev` 일 때만 등록된다.

```bash
./gradlew bootRun --args='--spring.profiles.active=local'
```
