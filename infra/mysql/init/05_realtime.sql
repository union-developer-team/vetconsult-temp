-- 실시간 지역 매칭, 병원 관리앱, 플랫폼 운영.
-- 채팅 원문과 수의사 실시간 좌표는 MongoDB. 상태 변화는 각 스키마 outbox 를 거쳐 Kafka 로 나간다.
-- 서비스 밖 참조는 UUID 값이다.

SET NAMES utf8mb4;

-- ---------------------------------------------------------------------------
-- clinic: 병원 앱이 당장 쓰는 운영 상태
-- ---------------------------------------------------------------------------
USE svc_clinic;

ALTER TABLE hospital
  ADD COLUMN latitude DECIMAL(9,6) NULL COMMENT '위도' AFTER remark,
  ADD COLUMN longitude DECIMAL(9,6) NULL COMMENT '경도' AFTER latitude,
  ADD COLUMN geohash VARCHAR(12) NULL COMMENT '지오해시' AFTER longitude,
  ADD KEY idx_hospital_geo (latitude, longitude),
  ADD KEY idx_hospital_geohash (geohash);

UPDATE hospital
SET latitude = 37.501274, longitude = 127.026382, geohash = 'wydm8'
WHERE uuid = 'h1000000-0000-4000-8000-000000000001';

UPDATE hospital
SET latitude = 35.163112, longitude = 129.163534, geohash = 'wy6qn'
WHERE uuid = 'h1000000-0000-4000-8000-000000000002';

CREATE TABLE hospital_runtime (
  hospital_id          BIGINT       NOT NULL,
  is_accepting_visit   TINYINT(1)   NOT NULL,
  is_accepting_consult TINYINT(1)   NOT NULL,
  pause_reason         VARCHAR(200) NULL,
  updated_at           DATETIME     NOT NULL,
  PRIMARY KEY (hospital_id),
  CONSTRAINT fk_runtime_hospital FOREIGN KEY (hospital_id) REFERENCES hospital (id)
) ENGINE=InnoDB COMMENT='병원 앱의 지금 접수 상태. 요일 영업시간과 별개';

CREATE TABLE hospital_consult_policy (
  hospital_id       BIGINT   NOT NULL,
  chat_enabled      TINYINT(1) NOT NULL,
  video_enabled     TINYINT(1) NOT NULL,
  emergency_enabled TINYINT(1) NOT NULL,
  max_concurrent    INT      NOT NULL,
  service_radius_m  INT      NOT NULL,
  updated_at        DATETIME NOT NULL,
  PRIMARY KEY (hospital_id),
  CONSTRAINT fk_consult_policy_hospital FOREIGN KEY (hospital_id) REFERENCES hospital (id)
) ENGINE=InnoDB COMMENT='병원별 실시간 상담 정책';

CREATE TABLE hospital_staff (
  id           BIGINT      NOT NULL AUTO_INCREMENT,
  uuid         CHAR(36)    NOT NULL,
  hospital_id  BIGINT      NOT NULL,
  account_uuid CHAR(36)    NOT NULL,
  staff_role   VARCHAR(20) NOT NULL,
  status       VARCHAR(20) NOT NULL,
  created_at   DATETIME    NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_staff_uuid (uuid),
  UNIQUE KEY uk_staff_pair (hospital_id, account_uuid),
  KEY idx_staff_account (account_uuid, status),
  CONSTRAINT fk_staff_hospital FOREIGN KEY (hospital_id) REFERENCES hospital (id),
  CONSTRAINT chk_staff_role CHECK (staff_role IN ('OWNER', 'VET', 'NURSE', 'RECEPTION')),
  CONSTRAINT chk_staff_status CHECK (status IN ('ACTIVE', 'SUSPENDED'))
) ENGINE=InnoDB COMMENT='병원 앱 직원. account_uuid 는 identity 값';

CREATE TABLE vet_date_off (
  id      BIGINT       NOT NULL AUTO_INCREMENT,
  uuid    CHAR(36)     NOT NULL,
  vet_id  BIGINT       NOT NULL,
  off_date DATE        NOT NULL,
  reason  VARCHAR(200) NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_date_off_uuid (uuid),
  UNIQUE KEY uk_date_off (vet_id, off_date),
  CONSTRAINT fk_date_off_vet FOREIGN KEY (vet_id) REFERENCES veterinarian (id)
) ENGINE=InnoDB COMMENT='수의사 특정일 휴무. 요일 휴무와 별개';

CREATE TABLE vet_duty_session (
  id               BIGINT        NOT NULL AUTO_INCREMENT,
  uuid             CHAR(36)      NOT NULL,
  vet_id           BIGINT        NOT NULL,
  hospital_id      BIGINT        NOT NULL,
  accept_chat      TINYINT(1)    NOT NULL,
  accept_video     TINYINT(1)    NOT NULL,
  service_radius_m INT           NOT NULL,
  origin_lat       DECIMAL(9,6)  NOT NULL,
  origin_lng       DECIMAL(9,6)  NOT NULL,
  started_at       DATETIME      NOT NULL,
  ended_at         DATETIME      NULL,
  current_flag     TINYINT       AS (IF(ended_at IS NULL, 1, NULL)) STORED,
  PRIMARY KEY (id),
  UNIQUE KEY uk_duty_uuid (uuid),
  UNIQUE KEY uk_vet_one_duty (vet_id, current_flag),
  KEY idx_duty_hospital_open (hospital_id, ended_at),
  CONSTRAINT fk_duty_vet FOREIGN KEY (vet_id) REFERENCES veterinarian (id),
  CONSTRAINT fk_duty_hospital FOREIGN KEY (hospital_id) REFERENCES hospital (id)
) ENGINE=InnoDB COMMENT='출근 세션. 실시간 좌표 핑은 MongoDB vet_live_location';

CREATE TABLE visit_arrival (
  id               BIGINT      NOT NULL AUTO_INCREMENT,
  uuid             CHAR(36)    NOT NULL,
  hospital_id      BIGINT      NOT NULL,
  reservation_uuid CHAR(36)    NOT NULL,
  status           VARCHAR(20) NOT NULL,
  arrived_at       DATETIME    NOT NULL,
  called_at        DATETIME    NULL,
  completed_at     DATETIME    NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_arrival_uuid (uuid),
  UNIQUE KEY uk_arrival_reservation (reservation_uuid),
  KEY idx_arrival_queue (hospital_id, status, arrived_at),
  CONSTRAINT fk_arrival_hospital FOREIGN KEY (hospital_id) REFERENCES hospital (id),
  CONSTRAINT chk_arrival_status CHECK (status IN ('WAITING', 'CALLED', 'DONE'))
) ENGINE=InnoDB COMMENT='병원 앱 내원 대기열. 예약 uuid 는 care 값';

INSERT INTO hospital_runtime (hospital_id, is_accepting_visit, is_accepting_consult, updated_at)
SELECT id, 1, 1, '2026-11-23 09:00:00' FROM hospital;

INSERT INTO hospital_consult_policy (hospital_id, chat_enabled, video_enabled, emergency_enabled, max_concurrent, service_radius_m, updated_at)
SELECT id, 1, 1, 1, 3, 5000, '2026-11-23 09:00:00' FROM hospital WHERE uuid = 'h1000000-0000-4000-8000-000000000001';
INSERT INTO hospital_consult_policy (hospital_id, chat_enabled, video_enabled, emergency_enabled, max_concurrent, service_radius_m, updated_at)
SELECT id, 1, 1, 0, 2, 4000, '2026-11-23 09:00:00' FROM hospital WHERE uuid = 'h1000000-0000-4000-8000-000000000002';

INSERT INTO hospital_staff (uuid, hospital_id, account_uuid, staff_role, status, created_at)
SELECT 'hs000000-0000-4000-8000-000000000001', id, 'a1000000-0000-4000-8000-000000000003', 'VET', 'ACTIVE', '2026-11-01 11:00:00'
FROM hospital WHERE uuid = 'h1000000-0000-4000-8000-000000000001';
INSERT INTO hospital_staff (uuid, hospital_id, account_uuid, staff_role, status, created_at)
SELECT 'hs000000-0000-4000-8000-000000000002', id, 'a1000000-0000-4000-8000-000000000004', 'VET', 'ACTIVE', '2026-11-01 11:10:00'
FROM hospital WHERE uuid = 'h1000000-0000-4000-8000-000000000002';

INSERT INTO vet_duty_session (uuid, vet_id, hospital_id, accept_chat, accept_video, service_radius_m, origin_lat, origin_lng, started_at)
SELECT 'du000000-0000-4000-8000-000000000001', v.id, h.id, 1, 1, 5000, 37.501274, 127.026382, '2026-11-23 09:00:00'
FROM veterinarian v JOIN hospital h
WHERE v.uuid = 'v1000000-0000-4000-8000-000000000001' AND h.uuid = 'h1000000-0000-4000-8000-000000000001';
INSERT INTO vet_duty_session (uuid, vet_id, hospital_id, accept_chat, accept_video, service_radius_m, origin_lat, origin_lng, started_at)
SELECT 'du000000-0000-4000-8000-000000000002', v.id, h.id, 1, 1, 4000, 35.163112, 129.163534, '2026-11-23 09:05:00'
FROM veterinarian v JOIN hospital h
WHERE v.uuid = 'v1000000-0000-4000-8000-000000000002' AND h.uuid = 'h1000000-0000-4000-8000-000000000002';

INSERT INTO visit_arrival (uuid, hospital_id, reservation_uuid, status, arrived_at)
SELECT 'va000000-0000-4000-8000-000000000001', id, 'r1000000-0000-4000-8000-000000000001', 'WAITING', '2026-11-20 09:55:00'
FROM hospital WHERE uuid = 'h1000000-0000-4000-8000-000000000001';

INSERT INTO outbox (event_id, event_type, aggregate_uuid, payload, occurred_at) VALUES
('e1000000-0000-4000-8000-000000000210', 'VetDutyStarted', 'v1000000-0000-4000-8000-000000000001',
 JSON_OBJECT('vet_uuid', 'v1000000-0000-4000-8000-000000000001', 'hospital_uuid', 'h1000000-0000-4000-8000-000000000001', 'accept_video', 1),
 '2026-11-23 09:00:00.000000');

-- ---------------------------------------------------------------------------
-- platform
-- ---------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS svc_platform DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE svc_platform;

CREATE TABLE region (
  id         BIGINT      NOT NULL AUTO_INCREMENT,
  code       VARCHAR(20) NOT NULL,
  name       VARCHAR(50) NOT NULL,
  parent_code VARCHAR(20) NULL,
  latitude   DECIMAL(9,6) NULL,
  longitude  DECIMAL(9,6) NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_region_code (code),
  KEY idx_region_parent (parent_code, name)
) ENGINE=InnoDB COMMENT='플랫폼 권역 코드';

CREATE TABLE matching_policy (
  id                   BIGINT      NOT NULL AUTO_INCREMENT,
  uuid                 CHAR(36)    NOT NULL,
  name                 VARCHAR(50) NOT NULL,
  active               TINYINT(1)  NOT NULL,
  default_radius_m     INT         NOT NULL,
  emergency_radius_m   INT         NOT NULL,
  radius_step_m        INT         NOT NULL,
  max_waves            INT         NOT NULL,
  max_offers_per_wave  INT         NOT NULL,
  offer_ttl_sec        INT         NOT NULL,
  request_ttl_sec      INT         NOT NULL,
  updated_at           DATETIME    NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_policy_uuid (uuid),
  KEY idx_policy_active (active, updated_at)
) ENGINE=InnoDB COMMENT='호출 반경, 제안 수, 수락 제한시간. 카카오택시의 배차 정책에 해당';

CREATE TABLE platform_setting (
  setting_key   VARCHAR(80)  NOT NULL,
  setting_value JSON         NOT NULL,
  updated_at    DATETIME     NOT NULL,
  PRIMARY KEY (setting_key)
) ENGINE=InnoDB COMMENT='플랫폼 운영 설정';

CREATE TABLE admin_audit (
  id           BIGINT       NOT NULL AUTO_INCREMENT,
  uuid         CHAR(36)     NOT NULL,
  admin_uuid   CHAR(36)     NOT NULL,
  action       VARCHAR(80)  NOT NULL,
  target_type  VARCHAR(40)  NOT NULL,
  target_uuid  CHAR(36)     NOT NULL,
  detail       JSON         NULL,
  created_at   DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_audit_uuid (uuid),
  KEY idx_audit_created (created_at),
  KEY idx_audit_target (target_type, target_uuid)
) ENGINE=InnoDB COMMENT='플랫폼 관리자 감사 로그';

CREATE TABLE outbox (
  id             BIGINT       NOT NULL AUTO_INCREMENT,
  event_id       CHAR(36)     NOT NULL,
  event_type     VARCHAR(100) NOT NULL,
  aggregate_uuid CHAR(36)     NOT NULL,
  payload        JSON         NOT NULL,
  occurred_at    DATETIME(6)  NOT NULL,
  published_at   DATETIME(6)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_outbox_event (event_id),
  KEY idx_outbox_unpublished (published_at, id)
) ENGINE=InnoDB COMMENT='platform 트랜잭셔널 아웃박스. 토픽 platform.policy.v1';

INSERT INTO region (code, name, parent_code, latitude, longitude) VALUES
('11', '서울', NULL, 37.566500, 126.978000),
('11680', '강남구', '11', 37.517200, 127.047300),
('26', '부산', NULL, 35.179600, 129.075600),
('26350', '해운대구', '26', 35.163100, 129.163500);

INSERT INTO matching_policy (uuid, name, active, default_radius_m, emergency_radius_m, radius_step_m, max_waves, max_offers_per_wave, offer_ttl_sec, request_ttl_sec, updated_at)
VALUES ('mp000000-0000-4000-8000-000000000001', 'default', 1, 3000, 8000, 2000, 3, 5, 20, 180, '2026-11-23 08:00:00');

INSERT INTO platform_setting (setting_key, setting_value, updated_at) VALUES
('consult.channels', JSON_ARRAY('CHAT', 'VIDEO'), '2026-11-23 08:00:00'),
('consult.emergency.priority', JSON_OBJECT('boost_score', 30), '2026-11-23 08:00:00');

INSERT INTO admin_audit (uuid, admin_uuid, action, target_type, target_uuid, detail, created_at) VALUES
('au000000-0000-4000-8000-000000000001', 'ad000000-0000-4000-8000-000000000001', 'POLICY_ACTIVATED', 'MATCHING_POLICY', 'mp000000-0000-4000-8000-000000000001',
 JSON_OBJECT('offer_ttl_sec', 20), '2026-11-23 08:00:00');

-- ---------------------------------------------------------------------------
-- matching: 호출, 반경 확장, 수의사 제안
-- ---------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS svc_matching DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE svc_matching;

CREATE TABLE consultation_request (
  id                     BIGINT        NOT NULL AUTO_INCREMENT,
  uuid                   CHAR(36)      NOT NULL,
  caregiver_uuid         CHAR(36)      NOT NULL,
  pet_uuid               CHAR(36)      NOT NULL,
  medical_subject_uuid   CHAR(36)      NOT NULL,
  channel                VARCHAR(20)   NOT NULL,
  is_emergency           TINYINT(1)    NOT NULL,
  status                 VARCHAR(20)   NOT NULL,
  origin_lat             DECIMAL(9,6)  NOT NULL,
  origin_lng             DECIMAL(9,6)  NOT NULL,
  geohash                VARCHAR(12)   NOT NULL,
  region                 VARCHAR(50)   NOT NULL,
  si                     VARCHAR(50)   NOT NULL,
  gu                     VARCHAR(50)   NOT NULL,
  search_radius_m        INT           NOT NULL,
  symptom_memo           VARCHAR(200)  NULL,
  requested_at           DATETIME      NOT NULL,
  expire_at              DATETIME      NOT NULL,
  assigned_vet_uuid      CHAR(36)      NULL,
  assigned_hospital_uuid CHAR(36)      NULL,
  assigned_at            DATETIME      NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_request_uuid (uuid),
  KEY idx_request_status_at (status, requested_at),
  KEY idx_request_region (region, status, is_emergency, requested_at),
  KEY idx_request_caregiver (caregiver_uuid, requested_at),
  KEY idx_request_geo (origin_lat, origin_lng),
  CONSTRAINT chk_request_channel CHECK (channel IN ('CHAT', 'VIDEO', 'BOTH')),
  CONSTRAINT chk_request_status CHECK (status IN ('REQUESTED', 'MATCHING', 'ASSIGNED', 'EXPIRED', 'CANCELLED', 'NO_VET'))
) ENGINE=InnoDB COMMENT='보호자 호출. 택시 호출에 해당. 실시간 후보 검색은 Mongo 2dsphere';

CREATE TABLE request_symptom (
  request_id   BIGINT   NOT NULL,
  symptom_uuid CHAR(36) NOT NULL,
  PRIMARY KEY (request_id, symptom_uuid),
  KEY idx_request_symptom (symptom_uuid, request_id),
  CONSTRAINT fk_request_symptom_request FOREIGN KEY (request_id) REFERENCES consultation_request (id)
) ENGINE=InnoDB COMMENT='호출-증상. symptom_uuid 는 care 값';

CREATE TABLE match_wave (
  id          BIGINT   NOT NULL AUTO_INCREMENT,
  uuid        CHAR(36) NOT NULL,
  request_id  BIGINT   NOT NULL,
  wave_no     INT      NOT NULL,
  radius_m    INT      NOT NULL,
  started_at  DATETIME NOT NULL,
  finished_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_wave_uuid (uuid),
  UNIQUE KEY uk_wave_no (request_id, wave_no),
  CONSTRAINT fk_wave_request FOREIGN KEY (request_id) REFERENCES consultation_request (id)
) ENGINE=InnoDB COMMENT='반경을 넓혀 가며 다시 부르는 차수';

CREATE TABLE match_offer (
  id            BIGINT        NOT NULL AUTO_INCREMENT,
  uuid          CHAR(36)      NOT NULL,
  request_id    BIGINT        NOT NULL,
  wave_id       BIGINT        NOT NULL,
  vet_uuid      CHAR(36)      NOT NULL,
  hospital_uuid CHAR(36)      NOT NULL,
  distance_m    INT           NOT NULL,
  score         DECIMAL(6,2)  NOT NULL,
  status        VARCHAR(20)   NOT NULL,
  offered_at    DATETIME      NOT NULL,
  respond_by    DATETIME      NOT NULL,
  responded_at  DATETIME      NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_offer_uuid (uuid),
  UNIQUE KEY uk_offer_vet (request_id, vet_uuid),
  KEY idx_offer_inbox (vet_uuid, status, offered_at),
  KEY idx_offer_request (request_id, status),
  CONSTRAINT fk_offer_request FOREIGN KEY (request_id) REFERENCES consultation_request (id),
  CONSTRAINT fk_offer_wave FOREIGN KEY (wave_id) REFERENCES match_wave (id),
  CONSTRAINT chk_offer_status CHECK (status IN ('OFFERED', 'ACCEPTED', 'DECLINED', 'EXPIRED', 'SUPERSEDED'))
) ENGINE=InnoDB COMMENT='수의사 앱에 뜨는 콜 카드. 한 명이 수락하면 나머지는 SUPERSEDED';

CREATE TABLE outbox (
  id             BIGINT       NOT NULL AUTO_INCREMENT,
  event_id       CHAR(36)     NOT NULL,
  event_type     VARCHAR(100) NOT NULL,
  aggregate_uuid CHAR(36)     NOT NULL,
  payload        JSON         NOT NULL,
  occurred_at    DATETIME(6)  NOT NULL,
  published_at   DATETIME(6)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_outbox_event (event_id),
  KEY idx_outbox_unpublished (published_at, id)
) ENGINE=InnoDB COMMENT='matching 아웃박스. 토픽 matching.request.v1, matching.offer.v1';

INSERT INTO consultation_request (
  uuid, caregiver_uuid, pet_uuid, medical_subject_uuid, channel, is_emergency, status,
  origin_lat, origin_lng, geohash, region, si, gu, search_radius_m, symptom_memo,
  requested_at, expire_at, assigned_vet_uuid, assigned_hospital_uuid, assigned_at
) VALUES (
  'rq000000-0000-4000-8000-000000000001',
  'a1000000-0000-4000-8000-000000000001',
  'p1000000-0000-4000-8000-000000000001',
  'ms000000-0000-4000-8000-000000000001',
  'VIDEO', 1, 'ASSIGNED',
  37.497900, 127.028100, 'wydm8', '서울', '서울', '강남구', 3000, '지금 구토가 멈추지 않습니다',
  '2026-11-23 14:00:00', '2026-11-23 14:03:00',
  'v1000000-0000-4000-8000-000000000001',
  'h1000000-0000-4000-8000-000000000001',
  '2026-11-23 14:00:18'
);

INSERT INTO request_symptom (request_id, symptom_uuid)
SELECT id, 'sy000000-0000-4000-8000-000000000001' FROM consultation_request
WHERE uuid = 'rq000000-0000-4000-8000-000000000001';

INSERT INTO match_wave (uuid, request_id, wave_no, radius_m, started_at, finished_at)
SELECT 'mw000000-0000-4000-8000-000000000001', id, 1, 3000, '2026-11-23 14:00:00', '2026-11-23 14:00:18'
FROM consultation_request WHERE uuid = 'rq000000-0000-4000-8000-000000000001';

INSERT INTO match_offer (uuid, request_id, wave_id, vet_uuid, hospital_uuid, distance_m, score, status, offered_at, respond_by, responded_at)
SELECT 'mo000000-0000-4000-8000-000000000001', r.id, w.id,
       'v1000000-0000-4000-8000-000000000001', 'h1000000-0000-4000-8000-000000000001',
       480, 96.50, 'ACCEPTED', '2026-11-23 14:00:01', '2026-11-23 14:00:21', '2026-11-23 14:00:18'
FROM consultation_request r JOIN match_wave w ON w.request_id = r.id
WHERE r.uuid = 'rq000000-0000-4000-8000-000000000001';

INSERT INTO outbox (event_id, event_type, aggregate_uuid, payload, occurred_at) VALUES
('e1000000-0000-4000-8000-000000000301', 'MatchingRequestCreated', 'rq000000-0000-4000-8000-000000000001',
 JSON_OBJECT('request_uuid', 'rq000000-0000-4000-8000-000000000001', 'channel', 'VIDEO', 'is_emergency', 1, 'region', '서울'),
 '2026-11-23 14:00:00.000000'),
('e1000000-0000-4000-8000-000000000302', 'MatchOfferAccepted', 'mo000000-0000-4000-8000-000000000001',
 JSON_OBJECT('offer_uuid', 'mo000000-0000-4000-8000-000000000001', 'request_uuid', 'rq000000-0000-4000-8000-000000000001', 'vet_uuid', 'v1000000-0000-4000-8000-000000000001'),
 '2026-11-23 14:00:18.000000');

-- ---------------------------------------------------------------------------
-- care: 수락 이후의 상담 방, 채팅 방, 화상 방
-- ---------------------------------------------------------------------------
USE svc_care;

ALTER TABLE consultation
  ADD COLUMN request_uuid CHAR(36) NULL COMMENT 'matching 호출 uuid' AFTER uuid,
  ADD COLUMN hospital_uuid CHAR(36) NULL COMMENT '배정 병원 uuid' AFTER vet_uuid,
  ADD KEY idx_consult_request (request_uuid),
  ADD KEY idx_consult_hospital (hospital_uuid, status);

CREATE TABLE chat_room (
  id               BIGINT      NOT NULL AUTO_INCREMENT,
  uuid             CHAR(36)    NOT NULL,
  consultation_id  BIGINT      NOT NULL,
  status           VARCHAR(20) NOT NULL,
  created_at       DATETIME    NOT NULL,
  closed_at        DATETIME    NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_chat_room_uuid (uuid),
  UNIQUE KEY uk_chat_room_consult (consultation_id),
  CONSTRAINT fk_chat_room_consult FOREIGN KEY (consultation_id) REFERENCES consultation (id),
  CONSTRAINT chk_chat_room_status CHECK (status IN ('OPEN', 'CLOSED'))
) ENGINE=InnoDB COMMENT='채팅 방 메타. 메시지 본문은 MongoDB chat_messages';

CREATE TABLE consultation_participant (
  consultation_id   BIGINT      NOT NULL,
  participant_uuid  CHAR(36)    NOT NULL,
  participant_role  VARCHAR(20) NOT NULL,
  joined_at         DATETIME    NOT NULL,
  left_at           DATETIME    NULL,
  PRIMARY KEY (consultation_id, participant_uuid),
  CONSTRAINT fk_participant_consult FOREIGN KEY (consultation_id) REFERENCES consultation (id),
  CONSTRAINT chk_participant_role CHECK (participant_role IN ('CAREGIVER', 'VETERINARIAN'))
) ENGINE=InnoDB COMMENT='상담 참여자 중계';

CREATE TABLE video_session (
  id               BIGINT      NOT NULL AUTO_INCREMENT,
  uuid             CHAR(36)    NOT NULL,
  consultation_id  BIGINT      NOT NULL,
  provider         VARCHAR(20) NOT NULL,
  room_key         VARCHAR(80) NOT NULL,
  status           VARCHAR(20) NOT NULL,
  started_at       DATETIME    NULL,
  ended_at         DATETIME    NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_video_uuid (uuid),
  UNIQUE KEY uk_video_room (room_key),
  KEY idx_video_consult (consultation_id, status),
  CONSTRAINT fk_video_consult FOREIGN KEY (consultation_id) REFERENCES consultation (id),
  CONSTRAINT chk_video_provider CHECK (provider IN ('LIVEKIT', 'WEBRTC')),
  CONSTRAINT chk_video_status CHECK (status IN ('CREATED', 'LIVE', 'ENDED'))
) ENGINE=InnoDB COMMENT='화상 방 메타. 입장 품질 로그는 MongoDB video_events';

CREATE TABLE video_participant (
  id                 BIGINT      NOT NULL AUTO_INCREMENT,
  video_session_id   BIGINT      NOT NULL,
  participant_uuid   CHAR(36)    NOT NULL,
  participant_role   VARCHAR(20) NOT NULL,
  joined_at          DATETIME    NULL,
  left_at            DATETIME    NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_video_participant (video_session_id, participant_uuid),
  CONSTRAINT fk_video_participant_session FOREIGN KEY (video_session_id) REFERENCES video_session (id),
  CONSTRAINT chk_video_participant_role CHECK (participant_role IN ('CAREGIVER', 'VETERINARIAN'))
) ENGINE=InnoDB COMMENT='화상 참여자';

INSERT INTO consultation (
  uuid, request_uuid, caregiver_uuid, pet_uuid, vet_uuid, hospital_uuid, medical_subject_id,
  status, consult_type, is_emergency, content, summary, created_at, accepted_at
)
SELECT 'c1000000-0000-4000-8000-000000000003',
       'rq000000-0000-4000-8000-000000000001',
       'a1000000-0000-4000-8000-000000000001',
       'p1000000-0000-4000-8000-000000000001',
       'v1000000-0000-4000-8000-000000000001',
       'h1000000-0000-4000-8000-000000000001',
       id, 'IN_PROGRESS', 'VIDEO', 1, '실시간 구토', '지역 매칭된 화상 상담',
       '2026-11-23 14:00:00', '2026-11-23 14:00:18'
FROM medical_subject WHERE name = '내과';

INSERT INTO consultation_symptom (uuid, consultation_id, symptom_id)
SELECT 'cs000000-0000-4000-8000-000000000003', c.id, s.id
FROM consultation c JOIN symptom s
WHERE c.uuid = 'c1000000-0000-4000-8000-000000000003' AND s.name = '구토';

INSERT INTO consultation_participant (consultation_id, participant_uuid, participant_role, joined_at)
SELECT id, 'a1000000-0000-4000-8000-000000000001', 'CAREGIVER', '2026-11-23 14:00:18' FROM consultation WHERE uuid = 'c1000000-0000-4000-8000-000000000003';
INSERT INTO consultation_participant (consultation_id, participant_uuid, participant_role, joined_at)
SELECT id, 'v1000000-0000-4000-8000-000000000001', 'VETERINARIAN', '2026-11-23 14:00:18' FROM consultation WHERE uuid = 'c1000000-0000-4000-8000-000000000003';

INSERT INTO chat_room (uuid, consultation_id, status, created_at)
SELECT 'cr000000-0000-4000-8000-000000000001', id, 'OPEN', '2026-11-23 14:00:18'
FROM consultation WHERE uuid = 'c1000000-0000-4000-8000-000000000003';

INSERT INTO video_session (uuid, consultation_id, provider, room_key, status, started_at)
SELECT 'vs000000-0000-4000-8000-000000000001', id, 'LIVEKIT', 'consult-rq000000-0001', 'LIVE', '2026-11-23 14:00:25'
FROM consultation WHERE uuid = 'c1000000-0000-4000-8000-000000000003';

INSERT INTO video_participant (video_session_id, participant_uuid, participant_role, joined_at)
SELECT id, 'a1000000-0000-4000-8000-000000000001', 'CAREGIVER', '2026-11-23 14:00:26' FROM video_session WHERE uuid = 'vs000000-0000-4000-8000-000000000001';
INSERT INTO video_participant (video_session_id, participant_uuid, participant_role, joined_at)
SELECT id, 'v1000000-0000-4000-8000-000000000001', 'VETERINARIAN', '2026-11-23 14:00:28' FROM video_session WHERE uuid = 'vs000000-0000-4000-8000-000000000001';

INSERT INTO outbox (event_id, event_type, aggregate_uuid, payload, occurred_at) VALUES
('e1000000-0000-4000-8000-000000000401', 'ConsultationSessionStarted', 'c1000000-0000-4000-8000-000000000003',
 JSON_OBJECT('consultation_uuid', 'c1000000-0000-4000-8000-000000000003', 'request_uuid', 'rq000000-0000-4000-8000-000000000001', 'channel', 'VIDEO'),
 '2026-11-23 14:00:18.000000');

-- ---------------------------------------------------------------------------
-- 조회 모델: 운영 화면의 호출 목록과 일별 매칭 집계
-- ---------------------------------------------------------------------------
USE vet_query;

CREATE TABLE q_match_request (
  request_uuid           CHAR(36)     NOT NULL,
  status                 VARCHAR(20)  NOT NULL,
  channel                VARCHAR(20)  NOT NULL,
  is_emergency           TINYINT(1)   NOT NULL,
  region                 VARCHAR(50)  NOT NULL,
  gu                     VARCHAR(50)  NOT NULL,
  origin_lat             DECIMAL(9,6) NOT NULL,
  origin_lng             DECIMAL(9,6) NOT NULL,
  caregiver_nickname     VARCHAR(50)  NOT NULL,
  pet_name               VARCHAR(50)  NOT NULL,
  subject_name           VARCHAR(100) NOT NULL,
  assigned_vet_name      VARCHAR(50)  NULL,
  assigned_hospital_name VARCHAR(100) NULL,
  distance_m             INT          NULL,
  requested_at           DATETIME     NOT NULL,
  assigned_at            DATETIME     NULL,
  PRIMARY KEY (request_uuid),
  KEY idx_q_match_status (status, requested_at),
  KEY idx_q_match_region (region, is_emergency, status, requested_at)
) ENGINE=InnoDB COMMENT='호출 운영 목록. 후보 반경 검색은 MongoDB';

CREATE TABLE q_vet_on_duty (
  vet_uuid         CHAR(36)     NOT NULL,
  vet_name         VARCHAR(50)  NOT NULL,
  hospital_uuid    CHAR(36)     NOT NULL,
  hospital_name    VARCHAR(100) NOT NULL,
  region           VARCHAR(50)  NOT NULL,
  accept_chat      TINYINT(1)   NOT NULL,
  accept_video     TINYINT(1)   NOT NULL,
  service_radius_m INT          NOT NULL,
  origin_lat       DECIMAL(9,6) NOT NULL,
  origin_lng       DECIMAL(9,6) NOT NULL,
  started_at       DATETIME     NOT NULL,
  PRIMARY KEY (vet_uuid),
  KEY idx_q_duty_region (region, accept_video, accept_chat)
) ENGINE=InnoDB COMMENT='출근 중 수의사. 하트비트 좌표는 MongoDB가 최신';

CREATE TABLE agg_match_daily (
  stat_date      DATE        NOT NULL,
  region         VARCHAR(50) NOT NULL,
  channel        VARCHAR(20) NOT NULL,
  status         VARCHAR(20) NOT NULL,
  is_emergency   TINYINT(1)  NOT NULL,
  request_count  INT         NOT NULL,
  avg_match_sec  INT         NULL,
  PRIMARY KEY (stat_date, region, channel, status, is_emergency)
) ENGINE=InnoDB COMMENT='일별 호출 건수와 평균 배정 초';

INSERT INTO q_match_request (
  request_uuid, status, channel, is_emergency, region, gu, origin_lat, origin_lng,
  caregiver_nickname, pet_name, subject_name, assigned_vet_name, assigned_hospital_name,
  distance_m, requested_at, assigned_at
) VALUES (
  'rq000000-0000-4000-8000-000000000001', 'ASSIGNED', 'VIDEO', 1, '서울', '강남구', 37.497900, 127.028100,
  '민호', '콩이', '내과', '김수의', '강남동물의료센터', 480, '2026-11-23 14:00:00', '2026-11-23 14:00:18'
);

INSERT INTO q_vet_on_duty (vet_uuid, vet_name, hospital_uuid, hospital_name, region, accept_chat, accept_video, service_radius_m, origin_lat, origin_lng, started_at) VALUES
('v1000000-0000-4000-8000-000000000001', '김수의', 'h1000000-0000-4000-8000-000000000001', '강남동물의료센터', '서울', 1, 1, 5000, 37.501274, 127.026382, '2026-11-23 09:00:00'),
('v1000000-0000-4000-8000-000000000002', '박수의', 'h1000000-0000-4000-8000-000000000002', '해운대동물병원', '부산', 1, 1, 4000, 35.163112, 129.163534, '2026-11-23 09:05:00');

INSERT INTO agg_match_daily (stat_date, region, channel, status, is_emergency, request_count, avg_match_sec) VALUES
('2026-11-23', '서울', 'VIDEO', 'ASSIGNED', 1, 1, 18);

INSERT INTO q_consultation (
  consultation_uuid, status, consult_type, is_emergency, summary,
  caregiver_uuid, caregiver_nickname, pet_uuid, pet_name, species_name,
  vet_uuid, vet_name, subject_name, hospital_uuid, hospital_name, region,
  created_at, accepted_at, completed_at
) VALUES (
  'c1000000-0000-4000-8000-000000000003', 'IN_PROGRESS', 'VIDEO', 1, '지역 매칭된 화상 상담',
  'a1000000-0000-4000-8000-000000000001', '민호', 'p1000000-0000-4000-8000-000000000001', '콩이', '개',
  'v1000000-0000-4000-8000-000000000001', '김수의', '내과', 'h1000000-0000-4000-8000-000000000001', '강남동물의료센터', '서울',
  '2026-11-23 14:00:00', '2026-11-23 14:00:18', NULL
);

-- ---------------------------------------------------------------------------
-- 계정
-- ---------------------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE, DELETE ON svc_platform.* TO 'vet_command'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON svc_platform.* TO 'vet_command'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON svc_matching.* TO 'vet_command'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON svc_matching.* TO 'vet_command'@'localhost';
FLUSH PRIVILEGES;
