-- 쓰기 모델. 서비스마다 스키마를 나누고, 스키마 밖은 UUID 값만 저장한다.
-- 애그리거트 내부 자식과 같은 스키마의 기준정보만 FK를 둔다.
-- BIGINT id 는 스키마 안 대리키다. 이벤트와 조회 모델에는 uuid 만 나간다.

SET NAMES utf8mb4;

CREATE DATABASE IF NOT EXISTS svc_identity    DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE DATABASE IF NOT EXISTS svc_clinic      DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE DATABASE IF NOT EXISTS svc_pet         DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE DATABASE IF NOT EXISTS svc_care        DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE DATABASE IF NOT EXISTS svc_community   DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE DATABASE IF NOT EXISTS svc_moderation  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE DATABASE IF NOT EXISTS svc_media       DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE DATABASE IF NOT EXISTS svc_notification DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

-- ---------------------------------------------------------------------------
-- identity
-- ---------------------------------------------------------------------------
USE svc_identity;

CREATE TABLE account (
  id             BIGINT       NOT NULL AUTO_INCREMENT,
  uuid           CHAR(36)     NOT NULL,
  status         VARCHAR(20)  NOT NULL,
  name           VARCHAR(100) NOT NULL,
  phone_number   VARCHAR(30)  NOT NULL,
  gender         VARCHAR(20)  NOT NULL,
  birth_date     DATE         NOT NULL,
  address        VARCHAR(255) NOT NULL,
  email          VARCHAR(254) NOT NULL,
  terms_agreed   TINYINT(1)   NOT NULL,
  created_at     DATETIME     NOT NULL,
  updated_at     DATETIME     NOT NULL,
  deleted_at     DATETIME     NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_account_uuid (uuid),
  UNIQUE KEY uk_account_email (email),
  KEY idx_account_status_created (status, created_at),
  KEY idx_account_phone (phone_number),
  CONSTRAINT chk_account_status CHECK (status IN ('PENDING', 'ACTIVE', 'WITHDRAWN', 'SUSPENDED')),
  CONSTRAINT chk_account_gender CHECK (gender IN ('MALE', 'FEMALE', 'UNKNOWN'))
) ENGINE=InnoDB COMMENT='앱 사용자 계정';

CREATE TABLE login_credential (
  id            BIGINT       NOT NULL AUTO_INCREMENT,
  account_id    BIGINT       NOT NULL,
  login_id      VARCHAR(100) NOT NULL,
  password_hash VARCHAR(255) NULL,
  created_at    DATETIME     NOT NULL,
  updated_at    DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_login_account (account_id),
  UNIQUE KEY uk_login_id (login_id),
  CONSTRAINT fk_login_account FOREIGN KEY (account_id) REFERENCES account (id)
) ENGINE=InnoDB COMMENT='계정 자격증명. 수의사 uuid 를 두지 않는다';

CREATE TABLE social_auth (
  id          BIGINT       NOT NULL AUTO_INCREMENT,
  account_id  BIGINT       NOT NULL,
  provider    VARCHAR(30)  NOT NULL,
  provider_id VARCHAR(191) NOT NULL,
  created_at  DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_social_provider (provider, provider_id),
  KEY idx_social_account (account_id),
  CONSTRAINT fk_social_account FOREIGN KEY (account_id) REFERENCES account (id)
) ENGINE=InnoDB COMMENT='소셜 인증';

CREATE TABLE login_history (
  id               BIGINT      NOT NULL AUTO_INCREMENT,
  account_id       BIGINT      NOT NULL,
  authenticated_at DATETIME    NOT NULL,
  login_type       VARCHAR(30) NOT NULL,
  PRIMARY KEY (id),
  KEY idx_login_history_account_at (account_id, authenticated_at),
  CONSTRAINT fk_login_history_account FOREIGN KEY (account_id) REFERENCES account (id)
) ENGINE=InnoDB COMMENT='로그인 감사 로그';

CREATE TABLE user_profile (
  id         BIGINT       NOT NULL AUTO_INCREMENT,
  account_id BIGINT       NOT NULL,
  nickname   VARCHAR(50)  NOT NULL,
  user_type  VARCHAR(20)  NOT NULL,
  created_at DATETIME     NOT NULL,
  updated_at DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_profile_account (account_id),
  UNIQUE KEY uk_profile_nickname (nickname),
  KEY idx_profile_type (user_type, nickname),
  CONSTRAINT fk_profile_account FOREIGN KEY (account_id) REFERENCES account (id),
  CONSTRAINT chk_profile_type CHECK (user_type IN ('CAREGIVER', 'VETERINARIAN'))
) ENGINE=InnoDB COMMENT='닉네임과 사용자 유형';

CREATE TABLE admin_account (
  id             BIGINT       NOT NULL AUTO_INCREMENT,
  uuid           CHAR(36)     NOT NULL,
  name           VARCHAR(100) NOT NULL,
  phone_number   VARCHAR(30)  NULL,
  email          VARCHAR(254) NULL,
  is_super_admin TINYINT(1)   NOT NULL DEFAULT 0,
  status         VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE',
  created_at     DATETIME     NOT NULL,
  updated_at     DATETIME     NOT NULL,
  deleted_at     DATETIME     NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_admin_uuid (uuid),
  KEY idx_admin_status (status, created_at),
  CONSTRAINT chk_admin_status CHECK (status IN ('ACTIVE', 'SUSPENDED'))
) ENGINE=InnoDB COMMENT='백오피스 관리자';

CREATE TABLE admin_login (
  id              BIGINT       NOT NULL AUTO_INCREMENT,
  admin_account_id BIGINT      NOT NULL,
  login_id        VARCHAR(100) NOT NULL,
  password_hash   VARCHAR(255) NOT NULL,
  created_at      DATETIME     NOT NULL,
  updated_at      DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_admin_login_account (admin_account_id),
  UNIQUE KEY uk_admin_login_id (login_id),
  CONSTRAINT fk_admin_login_account FOREIGN KEY (admin_account_id) REFERENCES admin_account (id)
) ENGINE=InnoDB COMMENT='관리자 자격증명';

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
) ENGINE=InnoDB COMMENT='identity 트랜잭셔널 아웃박스';

-- ---------------------------------------------------------------------------
-- clinic
-- ---------------------------------------------------------------------------
USE svc_clinic;

CREATE TABLE hospital (
  id            BIGINT       NOT NULL AUTO_INCREMENT,
  uuid          CHAR(36)     NOT NULL,
  region        VARCHAR(50)  NULL,
  si            VARCHAR(50)  NULL,
  gun           VARCHAR(50)  NULL,
  gu            VARCHAR(50)  NULL,
  name          VARCHAR(100) NOT NULL,
  zip_code      VARCHAR(10)  NULL,
  road_address  VARCHAR(255) NULL,
  lot_address   VARCHAR(255) NULL,
  tel           VARCHAR(20)  NULL,
  mgmt_no       VARCHAR(50)  NULL,
  licensed_at   DATE         NULL,
  business_no   VARCHAR(20)  NULL,
  homepage_url  VARCHAR(500) NULL,
  logo_url      VARCHAR(500) NULL,
  remark        VARCHAR(500) NULL,
  created_at    DATETIME     NOT NULL,
  updated_at    DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_hospital_uuid (uuid),
  KEY idx_hospital_region (region, si, gu, name),
  KEY idx_hospital_name (name)
) ENGINE=InnoDB COMMENT='동물병원';

CREATE TABLE hospital_hours (
  id          BIGINT     NOT NULL AUTO_INCREMENT,
  uuid        CHAR(36)   NOT NULL,
  hospital_id BIGINT     NOT NULL,
  day_of_week TINYINT    NOT NULL,
  is_closed   TINYINT(1) NOT NULL,
  open_time   TIME       NULL,
  close_time  TIME       NULL,
  break_start TIME       NULL,
  break_end   TIME       NULL,
  updated_at  DATETIME   NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_hours_uuid (uuid),
  UNIQUE KEY uk_hours_day (hospital_id, day_of_week),
  CONSTRAINT fk_hours_hospital FOREIGN KEY (hospital_id) REFERENCES hospital (id),
  CONSTRAINT chk_hours_dow CHECK (day_of_week BETWEEN 1 AND 7)
) ENGINE=InnoDB COMMENT='병원 요일 영업. 1=월 7=일. 병원 애그리거트 자식';

CREATE TABLE veterinarian (
  id            BIGINT       NOT NULL AUTO_INCREMENT,
  uuid          CHAR(36)     NOT NULL,
  account_uuid  CHAR(36)     NOT NULL,
  name          VARCHAR(50)  NOT NULL,
  major         VARCHAR(100) NOT NULL,
  specialty     VARCHAR(100) NOT NULL,
  license_no    VARCHAR(100) NOT NULL,
  is_available  TINYINT(1)   NOT NULL,
  status        VARCHAR(20)  NOT NULL,
  status_reason VARCHAR(255) NULL,
  created_at    DATETIME     NOT NULL,
  updated_at    DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_vet_uuid (uuid),
  UNIQUE KEY uk_vet_account (account_uuid),
  UNIQUE KEY uk_vet_license (license_no),
  KEY idx_vet_status_available (status, is_available, name),
  CONSTRAINT chk_vet_status CHECK (status IN ('ACTIVE', 'SUSPENDED', 'RESTRICTED'))
) ENGINE=InnoDB COMMENT='수의사. 병원 키는 두지 않는다';

CREATE TABLE vet_hospital_affiliation (
  id         BIGINT   NOT NULL AUTO_INCREMENT,
  uuid       CHAR(36) NOT NULL,
  vet_id     BIGINT   NOT NULL,
  hospital_id BIGINT  NOT NULL,
  started_at DATETIME NOT NULL,
  ended_at   DATETIME NULL,
  current_flag TINYINT AS (IF(ended_at IS NULL, 1, NULL)) STORED,
  PRIMARY KEY (id),
  UNIQUE KEY uk_affiliation_uuid (uuid),
  UNIQUE KEY uk_vet_one_current (vet_id, current_flag),
  KEY idx_affiliation_hospital_open (hospital_id, ended_at),
  CONSTRAINT fk_affiliation_vet FOREIGN KEY (vet_id) REFERENCES veterinarian (id),
  CONSTRAINT fk_affiliation_hospital FOREIGN KEY (hospital_id) REFERENCES hospital (id)
) ENGINE=InnoDB COMMENT='수의사-병원 소속 이력. 현재 소속은 ended_at IS NULL';

CREATE TABLE hospital_admin (
  id          BIGINT   NOT NULL AUTO_INCREMENT,
  uuid        CHAR(36) NOT NULL,
  admin_uuid  CHAR(36) NOT NULL,
  hospital_id BIGINT   NOT NULL,
  assigned_at DATETIME NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_hospital_admin_uuid (uuid),
  UNIQUE KEY uk_hospital_admin_pair (admin_uuid, hospital_id),
  KEY idx_hospital_admin_hospital (hospital_id),
  CONSTRAINT fk_hospital_admin_hospital FOREIGN KEY (hospital_id) REFERENCES hospital (id)
) ENGINE=InnoDB COMMENT='관리자-병원 배정. admin_uuid 는 identity 값이며 FK 없음';

CREATE TABLE vet_weekday_off (
  id          BIGINT   NOT NULL AUTO_INCREMENT,
  uuid        CHAR(36) NOT NULL,
  vet_id      BIGINT   NOT NULL,
  day_of_week TINYINT  NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_vet_off_uuid (uuid),
  UNIQUE KEY uk_vet_off_day (vet_id, day_of_week),
  CONSTRAINT fk_vet_off_vet FOREIGN KEY (vet_id) REFERENCES veterinarian (id),
  CONSTRAINT chk_vet_off_dow CHECK (day_of_week BETWEEN 1 AND 7)
) ENGINE=InnoDB COMMENT='수의사 반복 휴무 요일. 병원 휴무와 별개';

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
) ENGINE=InnoDB COMMENT='clinic 트랜잭셔널 아웃박스';

-- ---------------------------------------------------------------------------
-- pet
-- ---------------------------------------------------------------------------
USE svc_pet;

CREATE TABLE species (
  id   BIGINT      NOT NULL AUTO_INCREMENT,
  uuid CHAR(36)    NOT NULL,
  name VARCHAR(50) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_species_uuid (uuid),
  UNIQUE KEY uk_species_name (name)
) ENGINE=InnoDB COMMENT='종';

CREATE TABLE breed (
  id         BIGINT      NOT NULL AUTO_INCREMENT,
  uuid       CHAR(36)    NOT NULL,
  species_id BIGINT      NOT NULL,
  name       VARCHAR(50) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_breed_uuid (uuid),
  UNIQUE KEY uk_breed_name (species_id, name),
  CONSTRAINT fk_breed_species FOREIGN KEY (species_id) REFERENCES species (id)
) ENGINE=InnoDB COMMENT='품종';

CREATE TABLE pet (
  id           BIGINT       NOT NULL AUTO_INCREMENT,
  uuid         CHAR(36)     NOT NULL,
  breed_id     BIGINT       NOT NULL,
  name         VARCHAR(50)  NOT NULL,
  birth_date   DATE         NULL,
  weight_kg    DECIMAL(5,2) NULL,
  sex          VARCHAR(10)  NOT NULL,
  is_neutered  TINYINT(1)   NULL,
  neutered_at  DATETIME     NULL,
  status       VARCHAR(20)  NOT NULL,
  created_at   DATETIME     NOT NULL,
  updated_at   DATETIME     NOT NULL,
  deleted_at   DATETIME     NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_pet_uuid (uuid),
  KEY idx_pet_breed_status (breed_id, status, name),
  KEY idx_pet_name (name),
  CONSTRAINT fk_pet_breed FOREIGN KEY (breed_id) REFERENCES breed (id),
  CONSTRAINT chk_pet_sex CHECK (sex IN ('MALE', 'FEMALE', 'UNKNOWN')),
  CONSTRAINT chk_pet_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'DECEASED'))
) ENGINE=InnoDB COMMENT='반려동물. 보호자 키는 중계 테이블에만 있다';

CREATE TABLE caregiver_pet (
  caregiver_uuid CHAR(36) NOT NULL,
  pet_id         BIGINT   NOT NULL,
  linked_at      DATETIME NOT NULL,
  PRIMARY KEY (caregiver_uuid, pet_id),
  KEY idx_caregiver_pet_pet (pet_id),
  CONSTRAINT fk_caregiver_pet_pet FOREIGN KEY (pet_id) REFERENCES pet (id)
) ENGINE=InnoDB COMMENT='보호자-반려동물. caregiver_uuid 는 identity 값이며 FK 없음';

CREATE TABLE vaccine (
  id         BIGINT       NOT NULL AUTO_INCREMENT,
  uuid       CHAR(36)     NOT NULL,
  name       VARCHAR(100) NOT NULL,
  created_at DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_vaccine_uuid (uuid),
  UNIQUE KEY uk_vaccine_name (name)
) ENGINE=InnoDB COMMENT='접종 카탈로그';

CREATE TABLE pet_vaccination (
  id          BIGINT   NOT NULL AUTO_INCREMENT,
  uuid        CHAR(36) NOT NULL,
  pet_id      BIGINT   NOT NULL,
  vaccine_id  BIGINT   NOT NULL,
  evented_at  DATETIME NOT NULL,
  created_at  DATETIME NOT NULL,
  updated_at  DATETIME NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_vaccination_uuid (uuid),
  KEY idx_vaccination_pet_at (pet_id, evented_at),
  KEY idx_vaccination_vaccine (vaccine_id, evented_at),
  CONSTRAINT fk_vaccination_pet FOREIGN KEY (pet_id) REFERENCES pet (id),
  CONSTRAINT fk_vaccination_vaccine FOREIGN KEY (vaccine_id) REFERENCES vaccine (id)
) ENGINE=InnoDB COMMENT='접종 이력. 펫과 접종명의 기능 중계';

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
) ENGINE=InnoDB COMMENT='pet 트랜잭셔널 아웃박스';

-- ---------------------------------------------------------------------------
-- care
-- ---------------------------------------------------------------------------
USE svc_care;

CREATE TABLE medical_subject (
  id   BIGINT       NOT NULL AUTO_INCREMENT,
  uuid CHAR(36)     NOT NULL,
  name VARCHAR(100) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_subject_uuid (uuid),
  UNIQUE KEY uk_subject_name (name)
) ENGINE=InnoDB COMMENT='진료과목';

CREATE TABLE symptom (
  id   BIGINT       NOT NULL AUTO_INCREMENT,
  uuid CHAR(36)     NOT NULL,
  name VARCHAR(100) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_symptom_uuid (uuid),
  UNIQUE KEY uk_symptom_name (name)
) ENGINE=InnoDB COMMENT='증상 카탈로그';

CREATE TABLE visit_slot (
  id            BIGINT      NOT NULL AUTO_INCREMENT,
  uuid          CHAR(36)    NOT NULL,
  hospital_uuid CHAR(36)    NOT NULL,
  vet_uuid      CHAR(36)    NULL,
  vet_key       CHAR(36)    AS (IFNULL(vet_uuid, '')) STORED,
  slot_date     DATE        NOT NULL,
  start_time    TIME        NOT NULL,
  end_time      TIME        NOT NULL,
  status        VARCHAR(20) NOT NULL,
  created_at    DATETIME    NOT NULL,
  updated_at    DATETIME    NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_slot_uuid (uuid),
  UNIQUE KEY uk_slot_inventory (hospital_uuid, slot_date, start_time, vet_key),
  KEY idx_slot_hospital_date_status (hospital_uuid, slot_date, status),
  KEY idx_slot_vet_date (vet_uuid, slot_date, status),
  CONSTRAINT chk_slot_status CHECK (status IN ('OPEN', 'HELD', 'BOOKED', 'CLOSED'))
) ENGINE=InnoDB COMMENT='내원 슬롯 재고. 병원/수의사 uuid 는 clinic 값이며 FK 없음';

CREATE TABLE consultation (
  id                  BIGINT       NOT NULL AUTO_INCREMENT,
  uuid                CHAR(36)     NOT NULL,
  caregiver_uuid      CHAR(36)     NOT NULL,
  pet_uuid            CHAR(36)     NOT NULL,
  vet_uuid            CHAR(36)     NULL,
  medical_subject_id  BIGINT       NOT NULL,
  status              VARCHAR(20)  NOT NULL,
  consult_type        VARCHAR(20)  NOT NULL,
  is_emergency        TINYINT(1)   NOT NULL,
  content             TEXT         NULL,
  clinical_note       TEXT         NULL,
  summary             TEXT         NULL,
  recommendation      VARCHAR(255) NULL,
  created_at          DATETIME     NOT NULL,
  accepted_at         DATETIME     NULL,
  completed_at        DATETIME     NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_consultation_uuid (uuid),
  KEY idx_consult_status_created (status, created_at),
  KEY idx_consult_vet_status (vet_uuid, status, created_at),
  KEY idx_consult_caregiver_created (caregiver_uuid, created_at),
  KEY idx_consult_pet_created (pet_uuid, created_at),
  KEY idx_consult_emergency_status (is_emergency, status, created_at),
  CONSTRAINT fk_consult_subject FOREIGN KEY (medical_subject_id) REFERENCES medical_subject (id),
  CONSTRAINT chk_consult_status CHECK (status IN ('REQUESTED', 'IN_PROGRESS', 'COMPLETED', 'REJECTED')),
  CONSTRAINT chk_consult_type CHECK (consult_type IN ('CHAT', 'CALL', 'VIDEO'))
) ENGINE=InnoDB COMMENT='실시간상담. 보호자/펫/수의사 uuid 는 값';

CREATE TABLE consultation_symptom (
  id               BIGINT   NOT NULL AUTO_INCREMENT,
  uuid             CHAR(36) NOT NULL,
  consultation_id  BIGINT   NOT NULL,
  symptom_id       BIGINT   NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_consult_symptom_uuid (uuid),
  UNIQUE KEY uk_consult_symptom_pair (consultation_id, symptom_id),
  KEY idx_consult_symptom_symptom (symptom_id, consultation_id),
  CONSTRAINT fk_consult_symptom_consult FOREIGN KEY (consultation_id) REFERENCES consultation (id),
  CONSTRAINT fk_consult_symptom_symptom FOREIGN KEY (symptom_id) REFERENCES symptom (id)
) ENGINE=InnoDB COMMENT='상담-증상 N:M';

CREATE TABLE visit_reservation (
  id                 BIGINT       NOT NULL AUTO_INCREMENT,
  uuid               CHAR(36)     NOT NULL,
  hospital_uuid      CHAR(36)     NOT NULL,
  caregiver_uuid     CHAR(36)     NOT NULL,
  pet_uuid           CHAR(36)     NOT NULL,
  medical_subject_id BIGINT       NOT NULL,
  visit_slot_id      BIGINT       NOT NULL,
  status             VARCHAR(20)  NOT NULL,
  hoped_visit_date   DATE         NOT NULL,
  hoped_start_time   TIME         NOT NULL,
  symptom_memo       VARCHAR(200) NULL,
  created_at         DATETIME     NOT NULL,
  accepted_at        DATETIME     NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_reservation_uuid (uuid),
  UNIQUE KEY uk_reservation_slot (visit_slot_id),
  KEY idx_reservation_status_date (status, hoped_visit_date, hospital_uuid),
  KEY idx_reservation_hospital_date (hospital_uuid, hoped_visit_date, status),
  KEY idx_reservation_caregiver_date (caregiver_uuid, hoped_visit_date),
  KEY idx_reservation_pet_date (pet_uuid, hoped_visit_date),
  CONSTRAINT fk_reservation_subject FOREIGN KEY (medical_subject_id) REFERENCES medical_subject (id),
  CONSTRAINT fk_reservation_slot FOREIGN KEY (visit_slot_id) REFERENCES visit_slot (id),
  CONSTRAINT chk_reservation_status CHECK (status IN ('PENDING', 'CONFIRMED', 'REJECTED', 'CANCELLED'))
) ENGINE=InnoDB COMMENT='내원예약. 희망 일시는 예약 값이고 슬롯은 재고 점유';

CREATE TABLE visit_reservation_symptom (
  id                   BIGINT   NOT NULL AUTO_INCREMENT,
  uuid                 CHAR(36) NOT NULL,
  visit_reservation_id BIGINT   NOT NULL,
  symptom_id           BIGINT   NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_reservation_symptom_uuid (uuid),
  UNIQUE KEY uk_reservation_symptom_pair (visit_reservation_id, symptom_id),
  KEY idx_reservation_symptom_symptom (symptom_id, visit_reservation_id),
  CONSTRAINT fk_reservation_symptom_reservation FOREIGN KEY (visit_reservation_id) REFERENCES visit_reservation (id),
  CONSTRAINT fk_reservation_symptom_symptom FOREIGN KEY (symptom_id) REFERENCES symptom (id)
) ENGINE=InnoDB COMMENT='예약-증상 N:M';

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
) ENGINE=InnoDB COMMENT='care 트랜잭셔널 아웃박스';

-- ---------------------------------------------------------------------------
-- community
-- ---------------------------------------------------------------------------
USE svc_community;

CREATE TABLE board (
  id   BIGINT       NOT NULL AUTO_INCREMENT,
  uuid CHAR(36)     NOT NULL,
  name VARCHAR(100) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_board_uuid (uuid),
  UNIQUE KEY uk_board_name (name)
) ENGINE=InnoDB COMMENT='게시판';

CREATE TABLE category (
  id   BIGINT       NOT NULL AUTO_INCREMENT,
  uuid CHAR(36)     NOT NULL,
  name VARCHAR(100) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_category_uuid (uuid),
  UNIQUE KEY uk_category_name (name)
) ENGINE=InnoDB COMMENT='글 카테고리';

CREATE TABLE post (
  id          BIGINT       NOT NULL AUTO_INCREMENT,
  uuid        CHAR(36)     NOT NULL,
  board_id    BIGINT       NOT NULL,
  category_id BIGINT       NOT NULL,
  author_uuid CHAR(36)     NOT NULL,
  title       VARCHAR(200) NOT NULL,
  content     TEXT         NOT NULL,
  created_at  DATETIME     NOT NULL,
  updated_at  DATETIME     NULL,
  deleted_at  DATETIME     NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_post_uuid (uuid),
  KEY idx_post_board_created (board_id, created_at),
  KEY idx_post_category_created (category_id, created_at),
  KEY idx_post_author_created (author_uuid, created_at),
  CONSTRAINT fk_post_board FOREIGN KEY (board_id) REFERENCES board (id),
  CONSTRAINT fk_post_category FOREIGN KEY (category_id) REFERENCES category (id)
) ENGINE=InnoDB COMMENT='게시글. 좋아요/조회 수는 두지 않는다';

CREATE TABLE post_comment (
  id                BIGINT       NOT NULL AUTO_INCREMENT,
  uuid              CHAR(36)     NOT NULL,
  post_id           BIGINT       NOT NULL,
  parent_comment_id BIGINT       NULL,
  author_uuid       CHAR(36)     NOT NULL,
  depth             TINYINT      NOT NULL,
  content           VARCHAR(2000) NOT NULL,
  created_at        DATETIME     NOT NULL,
  updated_at        DATETIME     NULL,
  deleted_at        DATETIME     NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_comment_uuid (uuid),
  KEY idx_comment_post_depth_created (post_id, depth, created_at),
  KEY idx_comment_author_created (author_uuid, created_at),
  CONSTRAINT fk_comment_post FOREIGN KEY (post_id) REFERENCES post (id),
  CONSTRAINT fk_comment_parent FOREIGN KEY (parent_comment_id) REFERENCES post_comment (id)
) ENGINE=InnoDB COMMENT='댓글. 작성자는 uuid 값';

CREATE TABLE post_like (
  id         BIGINT      NOT NULL AUTO_INCREMENT,
  post_id    BIGINT      NOT NULL,
  actor_uuid CHAR(36)    NOT NULL,
  actor_role VARCHAR(20) NOT NULL,
  created_at DATETIME    NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_post_like (post_id, actor_uuid),
  KEY idx_post_like_actor (actor_uuid, created_at),
  CONSTRAINT fk_post_like_post FOREIGN KEY (post_id) REFERENCES post (id),
  CONSTRAINT chk_post_like_role CHECK (actor_role IN ('CAREGIVER', 'VETERINARIAN'))
) ENGINE=InnoDB COMMENT='게시글 좋아요 중계';

CREATE TABLE comment_like (
  id         BIGINT      NOT NULL AUTO_INCREMENT,
  comment_id BIGINT      NOT NULL,
  actor_uuid CHAR(36)    NOT NULL,
  actor_role VARCHAR(20) NOT NULL,
  created_at DATETIME    NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_comment_like (comment_id, actor_uuid),
  KEY idx_comment_like_actor (actor_uuid, created_at),
  CONSTRAINT fk_comment_like_comment FOREIGN KEY (comment_id) REFERENCES post_comment (id),
  CONSTRAINT chk_comment_like_role CHECK (actor_role IN ('CAREGIVER', 'VETERINARIAN'))
) ENGINE=InnoDB COMMENT='댓글 좋아요 중계';

CREATE TABLE follow (
  follower_uuid  CHAR(36) NOT NULL,
  following_uuid CHAR(36) NOT NULL,
  created_at     DATETIME NOT NULL,
  PRIMARY KEY (follower_uuid, following_uuid),
  KEY idx_follow_following (following_uuid, created_at)
) ENGINE=InnoDB COMMENT='팔로우 중계. 양쪽 모두 identity uuid';

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
) ENGINE=InnoDB COMMENT='community 트랜잭셔널 아웃박스';

-- ---------------------------------------------------------------------------
-- moderation
-- ---------------------------------------------------------------------------
USE svc_moderation;

CREATE TABLE report_reason (
  id          BIGINT       NOT NULL AUTO_INCREMENT,
  uuid        CHAR(36)     NOT NULL,
  target_type VARCHAR(30)  NOT NULL,
  code        VARCHAR(50)  NOT NULL,
  name        VARCHAR(100) NOT NULL,
  active      TINYINT(1)   NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_reason_uuid (uuid),
  UNIQUE KEY uk_reason_code (target_type, code),
  KEY idx_reason_active (target_type, active)
) ENGINE=InnoDB COMMENT='신고 사유 코드';

CREATE TABLE report (
  id                   BIGINT       NOT NULL AUTO_INCREMENT,
  uuid                 CHAR(36)     NOT NULL,
  reporter_uuid        CHAR(36)     NOT NULL,
  reporter_type        VARCHAR(20)  NOT NULL,
  target_uuid          CHAR(36)     NOT NULL,
  target_type          VARCHAR(30)  NOT NULL,
  content              VARCHAR(2000) NOT NULL,
  status               VARCHAR(20)  NOT NULL,
  reviewer_admin_uuid  CHAR(36)     NULL,
  resolution_note      VARCHAR(2000) NULL,
  created_at           DATETIME     NOT NULL,
  reviewed_at          DATETIME     NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_report_uuid (uuid),
  KEY idx_report_status_created (status, created_at),
  KEY idx_report_target (target_type, target_uuid),
  KEY idx_report_reporter (reporter_uuid, created_at),
  CONSTRAINT chk_report_reporter CHECK (reporter_type IN ('CAREGIVER', 'VETERINARIAN')),
  CONSTRAINT chk_report_target CHECK (target_type IN ('CAREGIVER', 'VETERINARIAN', 'POST', 'COMMENT')),
  CONSTRAINT chk_report_status CHECK (status IN ('RECEIVED', 'IN_PROGRESS', 'COMPLETED'))
) ENGINE=InnoDB COMMENT='신고. 대상은 type + uuid 이며 FK 없음';

CREATE TABLE report_reason_pick (
  id               BIGINT NOT NULL AUTO_INCREMENT,
  report_id        BIGINT NOT NULL,
  report_reason_id BIGINT NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_report_reason_pick (report_id, report_reason_id),
  KEY idx_report_reason_pick_reason (report_reason_id),
  CONSTRAINT fk_pick_report FOREIGN KEY (report_id) REFERENCES report (id),
  CONSTRAINT fk_pick_reason FOREIGN KEY (report_reason_id) REFERENCES report_reason (id)
) ENGINE=InnoDB COMMENT='신고-사유 N:M';

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
) ENGINE=InnoDB COMMENT='moderation 트랜잭셔널 아웃박스';

-- ---------------------------------------------------------------------------
-- media
-- ---------------------------------------------------------------------------
USE svc_media;

CREATE TABLE media (
  id           BIGINT       NOT NULL AUTO_INCREMENT,
  uuid         CHAR(36)     NOT NULL,
  uploader_uuid CHAR(36)    NOT NULL,
  file_name    VARCHAR(255) NOT NULL,
  content_type VARCHAR(100) NOT NULL,
  object_key   VARCHAR(500) NOT NULL,
  file_size    BIGINT       NOT NULL,
  deleted_at   DATETIME     NULL,
  created_at   DATETIME     NOT NULL,
  updated_at   DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_media_uuid (uuid),
  UNIQUE KEY uk_media_object (object_key),
  KEY idx_media_uploader_created (uploader_uuid, created_at)
) ENGINE=InnoDB COMMENT='파일 원본';

CREATE TABLE media_attachment (
  id          BIGINT      NOT NULL AUTO_INCREMENT,
  uuid        CHAR(36)    NOT NULL,
  media_id    BIGINT      NOT NULL,
  target_type VARCHAR(30) NOT NULL,
  target_uuid CHAR(36)    NOT NULL,
  created_at  DATETIME    NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_attachment_uuid (uuid),
  UNIQUE KEY uk_attachment_target (media_id, target_type, target_uuid),
  KEY idx_attachment_target (target_type, target_uuid),
  CONSTRAINT fk_attachment_media FOREIGN KEY (media_id) REFERENCES media (id),
  CONSTRAINT chk_attachment_target CHECK (target_type IN ('PROFILE', 'POST', 'PET', 'CONSULTATION'))
) ENGINE=InnoDB COMMENT='첨부 중계. 대상 서비스 행을 FK 로 잡지 않는다';

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
) ENGINE=InnoDB COMMENT='media 트랜잭셔널 아웃박스';

-- ---------------------------------------------------------------------------
-- notification
-- ---------------------------------------------------------------------------
USE svc_notification;

CREATE TABLE notification (
  id              BIGINT       NOT NULL AUTO_INCREMENT,
  uuid            CHAR(36)     NOT NULL,
  recipient_uuid  CHAR(36)     NOT NULL,
  actor_uuid      CHAR(36)     NOT NULL,
  event_id        CHAR(36)     NOT NULL,
  type            VARCHAR(30)  NOT NULL,
  title           VARCHAR(200) NOT NULL,
  content         VARCHAR(500) NOT NULL,
  target_type     VARCHAR(30)  NOT NULL,
  target_uuid     CHAR(36)     NOT NULL,
  read_at         DATETIME     NULL,
  created_at      DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_notification_uuid (uuid),
  UNIQUE KEY uk_notification_event (recipient_uuid, event_id),
  KEY idx_notification_inbox (recipient_uuid, read_at, created_at),
  CONSTRAINT chk_notification_type CHECK (type IN ('COMMENT', 'REPLY', 'FOLLOW', 'RESERVATION', 'CONSULTATION'))
) ENGINE=InnoDB COMMENT='알림 수신함. 생산자 테이블 FK 없음. event_id 로 멱등';

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
) ENGINE=InnoDB COMMENT='notification 트랜잭셔널 아웃박스';
