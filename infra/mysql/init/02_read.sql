-- 읽기 전용 조회 모델. 화면의 검색, 필터, 집계는 이 스키마만 읽는다.
-- 행은 각 서비스 outbox 이벤트를 소비해 맞춘다. 서비스 스키마와 조인하지 않는다.
-- 한글 검색은 ngram(토큰 2자) FULLTEXT 를 쓴다. 한 글자 검색은 인덱스를 타지 않는다.
-- 집계 화면은 agg_* 를 날짜 키로 읽고, 목록 화면은 q_* 의 복합 인덱스를 탄다.

SET NAMES utf8mb4;

CREATE DATABASE IF NOT EXISTS vet_query DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE vet_query;

CREATE TABLE processed_event (
  event_id     CHAR(36)     NOT NULL,
  event_type   VARCHAR(100) NOT NULL,
  processed_at DATETIME(6)  NOT NULL,
  PRIMARY KEY (event_id)
) ENGINE=InnoDB COMMENT='프로젝터 멱등 키';

CREATE TABLE q_profile (
  account_uuid CHAR(36)     NOT NULL,
  nickname     VARCHAR(50)  NOT NULL,
  user_type    VARCHAR(20)  NOT NULL,
  status       VARCHAR(20)  NOT NULL,
  name         VARCHAR(100) NOT NULL,
  PRIMARY KEY (account_uuid),
  UNIQUE KEY uk_q_profile_nickname (nickname),
  KEY idx_q_profile_type_status (user_type, status, nickname),
  FULLTEXT KEY ft_q_profile_name (nickname, name) WITH PARSER ngram
) ENGINE=InnoDB COMMENT='사용자 검색. 닉네임/이름';

CREATE TABLE q_hospital (
  hospital_uuid CHAR(36)     NOT NULL,
  region        VARCHAR(50)  NOT NULL,
  si            VARCHAR(50)  NOT NULL,
  gun           VARCHAR(50)  NOT NULL,
  gu            VARCHAR(50)  NOT NULL,
  name          VARCHAR(100) NOT NULL,
  road_address  VARCHAR(255) NOT NULL,
  lot_address   VARCHAR(255) NOT NULL,
  tel           VARCHAR(20)  NULL,
  PRIMARY KEY (hospital_uuid),
  KEY idx_q_hospital_region_name (region, si, gu, name),
  FULLTEXT KEY ft_q_hospital (name, road_address, lot_address) WITH PARSER ngram
) ENGINE=InnoDB COMMENT='병원 지역 필터 + 이름/주소 검색';

CREATE TABLE q_hospital_hours (
  hospital_uuid CHAR(36)   NOT NULL,
  day_of_week   TINYINT    NOT NULL,
  is_closed     TINYINT(1) NOT NULL,
  open_time     TIME       NULL,
  close_time    TIME       NULL,
  PRIMARY KEY (hospital_uuid, day_of_week),
  KEY idx_q_hours_open (day_of_week, is_closed, hospital_uuid)
) ENGINE=InnoDB COMMENT='요일 영업 필터. 1=월 7=일';

CREATE TABLE q_vet (
  vet_uuid       CHAR(36)     NOT NULL,
  account_uuid   CHAR(36)     NOT NULL,
  name           VARCHAR(50)  NOT NULL,
  major          VARCHAR(100) NOT NULL,
  specialty      VARCHAR(100) NOT NULL,
  is_available   TINYINT(1)   NOT NULL,
  status         VARCHAR(20)  NOT NULL,
  hospital_uuid  CHAR(36)     NOT NULL,
  hospital_name  VARCHAR(100) NOT NULL,
  region         VARCHAR(50)  NOT NULL,
  si             VARCHAR(50)  NOT NULL,
  gu             VARCHAR(50)  NOT NULL,
  PRIMARY KEY (vet_uuid),
  KEY idx_q_vet_place (region, si, gu, status, is_available),
  KEY idx_q_vet_hospital (hospital_uuid, status, is_available),
  KEY idx_q_vet_specialty (specialty, status, is_available),
  FULLTEXT KEY ft_q_vet (name, major, specialty, hospital_name) WITH PARSER ngram
) ENGINE=InnoDB COMMENT='현재 소속 기준 수의사 한 행. 소속 이력은 쓰지 않는다';

CREATE TABLE q_vet_weekday_off (
  vet_uuid    CHAR(36) NOT NULL,
  day_of_week TINYINT  NOT NULL,
  PRIMARY KEY (day_of_week, vet_uuid),
  KEY idx_q_vet_off_vet (vet_uuid, day_of_week)
) ENGINE=InnoDB COMMENT='휴무 요일 제외 필터. NOT EXISTS 용';

CREATE TABLE q_pet (
  pet_uuid            CHAR(36)     NOT NULL,
  caregiver_uuid      CHAR(36)     NOT NULL,
  caregiver_nickname  VARCHAR(50)  NOT NULL,
  name                VARCHAR(50)  NOT NULL,
  species_name        VARCHAR(50)  NOT NULL,
  breed_name          VARCHAR(50)  NOT NULL,
  sex                 VARCHAR(10)  NOT NULL,
  birth_date          DATE         NULL,
  weight_kg           DECIMAL(5,2) NULL,
  is_neutered         TINYINT(1)   NULL,
  status              VARCHAR(20)  NOT NULL,
  PRIMARY KEY (pet_uuid, caregiver_uuid),
  KEY idx_q_pet_caregiver (caregiver_uuid, status, name),
  KEY idx_q_pet_species (species_name, breed_name, status),
  FULLTEXT KEY ft_q_pet (name, breed_name, species_name, caregiver_nickname) WITH PARSER ngram
) ENGINE=InnoDB COMMENT='펫 카드. 보호자 연결마다 한 행';

CREATE TABLE q_visit_reservation (
  reservation_uuid   CHAR(36)     NOT NULL,
  status             VARCHAR(20)  NOT NULL,
  hoped_visit_date   DATE         NOT NULL,
  hoped_start_time   TIME         NOT NULL,
  symptom_memo       VARCHAR(200) NULL,
  hospital_uuid      CHAR(36)     NOT NULL,
  hospital_name      VARCHAR(100) NOT NULL,
  region             VARCHAR(50)  NOT NULL,
  si                 VARCHAR(50)  NOT NULL,
  gu                 VARCHAR(50)  NOT NULL,
  subject_name       VARCHAR(100) NOT NULL,
  slot_uuid          CHAR(36)     NOT NULL,
  slot_start         TIME         NOT NULL,
  slot_end           TIME         NOT NULL,
  caregiver_uuid     CHAR(36)     NOT NULL,
  caregiver_nickname VARCHAR(50)  NOT NULL,
  pet_uuid           CHAR(36)     NOT NULL,
  pet_name           VARCHAR(50)  NOT NULL,
  species_name       VARCHAR(50)  NOT NULL,
  breed_name         VARCHAR(50)  NOT NULL,
  created_at         DATETIME     NOT NULL,
  PRIMARY KEY (reservation_uuid),
  KEY idx_q_visit_status_date_hospital (status, hoped_visit_date, hospital_uuid),
  KEY idx_q_visit_hospital_date (hospital_uuid, hoped_visit_date, status),
  KEY idx_q_visit_region_date (region, hoped_visit_date, status),
  KEY idx_q_visit_caregiver_date (caregiver_uuid, hoped_visit_date),
  KEY idx_q_visit_pet_date (pet_uuid, hoped_visit_date),
  KEY idx_q_visit_agg (hoped_visit_date, hospital_uuid, status)
) ENGINE=InnoDB COMMENT='예약 목록. 필터 컬럼을 평탄화';

CREATE TABLE q_visit_symptom (
  reservation_uuid CHAR(36)     NOT NULL,
  symptom_uuid     CHAR(36)     NOT NULL,
  symptom_name     VARCHAR(100) NOT NULL,
  PRIMARY KEY (symptom_uuid, reservation_uuid),
  KEY idx_q_visit_symptom_reservation (reservation_uuid),
  KEY idx_q_visit_symptom_name (symptom_name, reservation_uuid)
) ENGINE=InnoDB COMMENT='예약 증상 필터. 이름 조건은 이 인덱스를 탄다';

CREATE TABLE q_consultation (
  consultation_uuid  CHAR(36)     NOT NULL,
  status             VARCHAR(20)  NOT NULL,
  consult_type       VARCHAR(20)  NOT NULL,
  is_emergency       TINYINT(1)   NOT NULL,
  summary            VARCHAR(500) NULL,
  caregiver_uuid     CHAR(36)     NOT NULL,
  caregiver_nickname VARCHAR(50)  NOT NULL,
  pet_uuid           CHAR(36)     NOT NULL,
  pet_name           VARCHAR(50)  NOT NULL,
  species_name       VARCHAR(50)  NOT NULL,
  vet_uuid           CHAR(36)     NULL,
  vet_name           VARCHAR(50)  NULL,
  subject_name       VARCHAR(100) NOT NULL,
  hospital_uuid      CHAR(36)     NULL,
  hospital_name      VARCHAR(100) NULL,
  region             VARCHAR(50)  NULL,
  created_at         DATETIME     NOT NULL,
  accepted_at        DATETIME     NULL,
  completed_at       DATETIME     NULL,
  PRIMARY KEY (consultation_uuid),
  KEY idx_q_consult_status_created (status, created_at),
  KEY idx_q_consult_emergency (is_emergency, status, region, created_at),
  KEY idx_q_consult_vet (vet_uuid, status, created_at),
  KEY idx_q_consult_caregiver (caregiver_uuid, created_at),
  KEY idx_q_consult_subject (subject_name, status, created_at),
  KEY idx_q_consult_agg (created_at, subject_name, status, is_emergency),
  FULLTEXT KEY ft_q_consult (summary, pet_name, vet_name, subject_name) WITH PARSER ngram
) ENGINE=InnoDB COMMENT='상담 목록. 지역/응급/상태/과목을 한 테이블에서 필터';

CREATE TABLE q_consultation_symptom (
  consultation_uuid CHAR(36)     NOT NULL,
  symptom_uuid      CHAR(36)     NOT NULL,
  symptom_name      VARCHAR(100) NOT NULL,
  PRIMARY KEY (symptom_uuid, consultation_uuid),
  KEY idx_q_consult_symptom_consultation (consultation_uuid),
  KEY idx_q_consult_symptom_name (symptom_name, consultation_uuid)
) ENGINE=InnoDB COMMENT='상담 증상 필터';

CREATE TABLE q_post (
  post_uuid          CHAR(36)     NOT NULL,
  board_name         VARCHAR(100) NOT NULL,
  category_name      VARCHAR(100) NOT NULL,
  author_uuid        CHAR(36)     NOT NULL,
  author_nickname    VARCHAR(50)  NOT NULL,
  author_type        VARCHAR(20)  NOT NULL,
  title              VARCHAR(200) NOT NULL,
  content            TEXT         NOT NULL,
  like_count         INT          NOT NULL,
  comment_count      INT          NOT NULL,
  created_at         DATETIME     NOT NULL,
  PRIMARY KEY (post_uuid),
  KEY idx_q_post_board_created (board_name, created_at),
  KEY idx_q_post_category_created (category_name, created_at),
  KEY idx_q_post_author_created (author_uuid, created_at),
  FULLTEXT KEY ft_q_post (title, content) WITH PARSER ngram
) ENGINE=InnoDB COMMENT='피드. 카운터는 좋아요/댓글 이벤트의 조회값';

CREATE TABLE q_report (
  report_uuid     CHAR(36)      NOT NULL,
  status          VARCHAR(20)   NOT NULL,
  reporter_type   VARCHAR(20)   NOT NULL,
  reporter_uuid   CHAR(36)      NOT NULL,
  target_type     VARCHAR(30)   NOT NULL,
  target_uuid     CHAR(36)      NOT NULL,
  reason_codes    VARCHAR(255)  NOT NULL,
  created_at      DATETIME      NOT NULL,
  reviewed_at     DATETIME      NULL,
  PRIMARY KEY (report_uuid),
  KEY idx_q_report_queue (status, target_type, created_at),
  KEY idx_q_report_target (target_type, target_uuid),
  KEY idx_q_report_reporter (reporter_uuid, created_at)
) ENGINE=InnoDB COMMENT='신고 큐. reason_codes 는 표시용이고 필터 키는 status+target_type';

CREATE TABLE q_notification (
  notification_uuid CHAR(36)     NOT NULL,
  recipient_uuid    CHAR(36)     NOT NULL,
  type              VARCHAR(30)  NOT NULL,
  title             VARCHAR(200) NOT NULL,
  read_at           DATETIME     NULL,
  created_at        DATETIME     NOT NULL,
  is_unread         TINYINT      AS (IF(read_at IS NULL, 1, 0)) STORED,
  PRIMARY KEY (notification_uuid),
  KEY idx_q_notification_inbox (recipient_uuid, is_unread, created_at),
  KEY idx_q_notification_type (recipient_uuid, type, created_at)
) ENGINE=InnoDB COMMENT='수신함. 미읽음은 is_unread=1';

CREATE TABLE agg_visit_daily (
  stat_date          DATE         NOT NULL,
  hospital_uuid      CHAR(36)     NOT NULL,
  hospital_name      VARCHAR(100) NOT NULL,
  region             VARCHAR(50)  NOT NULL,
  status             VARCHAR(20)  NOT NULL,
  reservation_count  INT          NOT NULL,
  PRIMARY KEY (stat_date, hospital_uuid, status),
  KEY idx_agg_visit_region (stat_date, region, status)
) ENGINE=InnoDB COMMENT='일별 병원 예약 건수. 목록 테이블을 스캔하지 않는다';

CREATE TABLE agg_consultation_daily (
  stat_date           DATE         NOT NULL,
  subject_name        VARCHAR(100) NOT NULL,
  status              VARCHAR(20)  NOT NULL,
  is_emergency        TINYINT(1)   NOT NULL,
  consultation_count  INT          NOT NULL,
  PRIMARY KEY (stat_date, subject_name, status, is_emergency),
  KEY idx_agg_consult_status (stat_date, status, is_emergency)
) ENGINE=InnoDB COMMENT='일별 상담 건수. 과목/상태/응급';

CREATE TABLE agg_community_daily (
  stat_date     DATE         NOT NULL,
  board_name    VARCHAR(100) NOT NULL,
  post_count    INT          NOT NULL,
  comment_count INT          NOT NULL,
  like_count    INT          NOT NULL,
  PRIMARY KEY (stat_date, board_name)
) ENGINE=InnoDB COMMENT='일별 게시판 활동 건수';
