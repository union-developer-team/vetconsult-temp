-- 조회 모델이 이벤트 소비 이후와 같도록 맞춘 샘플.
-- 쓰기 행과 vet_query 행의 이름, 상태, 건수가 일치한다.

SET NAMES utf8mb4;

-- identity -------------------------------------------------------------------
USE svc_identity;

INSERT INTO account (uuid, status, name, phone_number, gender, birth_date, address, email, terms_agreed, created_at, updated_at) VALUES
('a1000000-0000-4000-8000-000000000001', 'ACTIVE', '이민호', '010-1000-0001', 'MALE',   '1992-03-11', '서울특별시 강남구', 'minho@example.com', 1, '2026-11-01 09:00:00', '2026-11-01 09:00:00'),
('a1000000-0000-4000-8000-000000000002', 'ACTIVE', '최서연', '010-1000-0002', 'FEMALE', '1995-07-21', '부산광역시 해운대구', 'seoyeon@example.com', 1, '2026-11-01 09:10:00', '2026-11-01 09:10:00'),
('a1000000-0000-4000-8000-000000000003', 'ACTIVE', '김수의', '010-2000-0001', 'MALE',   '1984-01-09', '서울특별시 강남구', 'kimvet@example.com', 1, '2026-11-01 09:20:00', '2026-11-01 09:20:00'),
('a1000000-0000-4000-8000-000000000004', 'ACTIVE', '박수의', '010-2000-0002', 'FEMALE', '1988-12-02', '부산광역시 해운대구', 'parkvet@example.com', 1, '2026-11-01 09:30:00', '2026-11-01 09:30:00');

INSERT INTO login_credential (account_id, login_id, password_hash, created_at, updated_at)
SELECT id, CASE uuid
    WHEN 'a1000000-0000-4000-8000-000000000001' THEN 'minho'
    WHEN 'a1000000-0000-4000-8000-000000000002' THEN 'seoyeon'
    WHEN 'a1000000-0000-4000-8000-000000000003' THEN 'kimvet'
    ELSE 'parkvet' END,
  '$2a$10$seed.hash.not.for.login', '2026-11-01 09:00:00', '2026-11-01 09:00:00'
FROM account;

INSERT INTO user_profile (account_id, nickname, user_type, created_at, updated_at)
SELECT id,
  CASE uuid
    WHEN 'a1000000-0000-4000-8000-000000000001' THEN '민호'
    WHEN 'a1000000-0000-4000-8000-000000000002' THEN '서연'
    WHEN 'a1000000-0000-4000-8000-000000000003' THEN '김수의'
    ELSE '박수의' END,
  CASE WHEN uuid IN ('a1000000-0000-4000-8000-000000000003', 'a1000000-0000-4000-8000-000000000004') THEN 'VETERINARIAN' ELSE 'CAREGIVER' END,
  created_at, updated_at
FROM account;

INSERT INTO social_auth (account_id, provider, provider_id, created_at)
SELECT id, 'KAKAO', 'kakao-minho', created_at FROM account WHERE uuid = 'a1000000-0000-4000-8000-000000000001';

INSERT INTO login_history (account_id, authenticated_at, login_type)
SELECT id, '2026-11-20 08:00:00', 'PASSWORD' FROM account WHERE uuid = 'a1000000-0000-4000-8000-000000000001';

INSERT INTO admin_account (uuid, name, phone_number, email, is_super_admin, status, created_at, updated_at) VALUES
('ad000000-0000-4000-8000-000000000001', '총관리자', '010-9000-0001', 'admin@example.com', 1, 'ACTIVE', '2026-11-01 08:00:00', '2026-11-01 08:00:00');

INSERT INTO admin_login (admin_account_id, login_id, password_hash, created_at, updated_at)
SELECT id, 'superadmin', '$2a$10$seed.admin.hash', created_at, updated_at FROM admin_account;

INSERT INTO outbox (event_id, event_type, aggregate_uuid, payload, occurred_at) VALUES
('e1000000-0000-4000-8000-000000000001', 'AccountRegistered', 'a1000000-0000-4000-8000-000000000001',
 JSON_OBJECT('account_uuid', 'a1000000-0000-4000-8000-000000000001', 'status', 'ACTIVE'), '2026-11-01 09:00:00.000000');

-- clinic ---------------------------------------------------------------------
USE svc_clinic;

INSERT INTO hospital (uuid, region, si, gun, gu, name, zip_code, road_address, lot_address, tel, licensed_at, business_no, created_at, updated_at) VALUES
('h1000000-0000-4000-8000-000000000001', '서울', '서울', '', '강남구', '강남동물의료센터', '06123', '서울특별시 강남구 테헤란로 1', '서울특별시 강남구 역삼동 1', '02-111-0001', '2018-04-01', '123-45-67890', '2026-11-01 10:00:00', '2026-11-01 10:00:00'),
('h1000000-0000-4000-8000-000000000002', '부산', '부산', '', '해운대구', '해운대동물병원', '48094', '부산광역시 해운대구 해운대로 2', '부산광역시 해운대구 우동 2', '051-222-0002', '2016-09-15', '234-56-78901', '2026-11-01 10:10:00', '2026-11-01 10:10:00');

INSERT INTO hospital_hours (uuid, hospital_id, day_of_week, is_closed, open_time, close_time, break_start, break_end, updated_at)
SELECT CONCAT('hh000000-0000-4000-8000-', LPAD(h.n * 10 + d.day_of_week, 12, '0')),
       h.id, d.day_of_week,
       IF(h.n = 1 AND d.day_of_week = 7, 1, 0),
       IF(h.n = 1 AND d.day_of_week = 7, NULL, '09:00:00'),
       IF(h.n = 1 AND d.day_of_week = 7, NULL, '18:00:00'),
       IF(h.n = 1 AND d.day_of_week = 7, NULL, '13:00:00'),
       IF(h.n = 1 AND d.day_of_week = 7, NULL, '14:00:00'),
       '2026-11-01 10:00:00'
FROM (SELECT id, IF(uuid LIKE '%0001', 1, 2) AS n FROM hospital) h
JOIN (
  SELECT 1 AS day_of_week UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL
  SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
) d;

INSERT INTO veterinarian (uuid, account_uuid, name, major, specialty, license_no, is_available, status, created_at, updated_at) VALUES
('v1000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000003', '김수의', '내과', '내과', 'VET-2020-0001', 1, 'ACTIVE', '2026-11-01 11:00:00', '2026-11-01 11:00:00'),
('v1000000-0000-4000-8000-000000000002', 'a1000000-0000-4000-8000-000000000004', '박수의', '피부과', '피부과', 'VET-2019-0002', 1, 'ACTIVE', '2026-11-01 11:10:00', '2026-11-01 11:10:00');

INSERT INTO vet_hospital_affiliation (uuid, vet_id, hospital_id, started_at)
SELECT 'af000000-0000-4000-8000-000000000001', v.id, h.id, '2026-11-01 11:00:00'
FROM veterinarian v JOIN hospital h
WHERE v.uuid = 'v1000000-0000-4000-8000-000000000001' AND h.uuid = 'h1000000-0000-4000-8000-000000000001';

INSERT INTO vet_hospital_affiliation (uuid, vet_id, hospital_id, started_at)
SELECT 'af000000-0000-4000-8000-000000000002', v.id, h.id, '2026-11-01 11:10:00'
FROM veterinarian v JOIN hospital h
WHERE v.uuid = 'v1000000-0000-4000-8000-000000000002' AND h.uuid = 'h1000000-0000-4000-8000-000000000002';

INSERT INTO vet_weekday_off (uuid, vet_id, day_of_week)
SELECT 'vo000000-0000-4000-8000-000000000001', id, 7 FROM veterinarian WHERE uuid = 'v1000000-0000-4000-8000-000000000001';

INSERT INTO vet_weekday_off (uuid, vet_id, day_of_week)
SELECT 'vo000000-0000-4000-8000-000000000002', id, 3 FROM veterinarian WHERE uuid = 'v1000000-0000-4000-8000-000000000002';

INSERT INTO hospital_admin (uuid, admin_uuid, hospital_id, assigned_at)
SELECT 'ha000000-0000-4000-8000-000000000001', 'ad000000-0000-4000-8000-000000000001', id, '2026-11-01 12:00:00'
FROM hospital WHERE uuid = 'h1000000-0000-4000-8000-000000000001';

-- pet ------------------------------------------------------------------------
USE svc_pet;

INSERT INTO species (uuid, name) VALUES
('s1000000-0000-4000-8000-000000000001', '개'),
('s1000000-0000-4000-8000-000000000002', '고양이');

INSERT INTO breed (uuid, species_id, name)
SELECT 'b1000000-0000-4000-8000-000000000001', id, '말티즈' FROM species WHERE name = '개';
INSERT INTO breed (uuid, species_id, name)
SELECT 'b1000000-0000-4000-8000-000000000002', id, '코리안숏헤어' FROM species WHERE name = '고양이';

INSERT INTO pet (uuid, breed_id, name, birth_date, weight_kg, sex, is_neutered, status, created_at, updated_at)
SELECT 'p1000000-0000-4000-8000-000000000001', id, '콩이', '2022-05-02', 3.40, 'MALE', 1, 'ACTIVE', '2026-11-02 10:00:00', '2026-11-02 10:00:00'
FROM breed WHERE name = '말티즈';
INSERT INTO pet (uuid, breed_id, name, birth_date, weight_kg, sex, is_neutered, status, created_at, updated_at)
SELECT 'p1000000-0000-4000-8000-000000000002', id, '나비', '2023-08-19', 4.10, 'FEMALE', 0, 'ACTIVE', '2026-11-02 10:10:00', '2026-11-02 10:10:00'
FROM breed WHERE name = '코리안숏헤어';

INSERT INTO caregiver_pet (caregiver_uuid, pet_id, linked_at)
SELECT 'a1000000-0000-4000-8000-000000000001', id, '2026-11-02 10:00:00' FROM pet WHERE uuid = 'p1000000-0000-4000-8000-000000000001';
INSERT INTO caregiver_pet (caregiver_uuid, pet_id, linked_at)
SELECT 'a1000000-0000-4000-8000-000000000002', id, '2026-11-02 10:10:00' FROM pet WHERE uuid = 'p1000000-0000-4000-8000-000000000002';

INSERT INTO vaccine (uuid, name, created_at) VALUES
('vc000000-0000-4000-8000-000000000001', '종합백신', '2026-11-02 11:00:00');

INSERT INTO pet_vaccination (uuid, pet_id, vaccine_id, evented_at, created_at, updated_at)
SELECT 'pv000000-0000-4000-8000-000000000001', p.id, v.id, '2026-10-01 15:00:00', '2026-10-01 15:10:00', '2026-10-01 15:10:00'
FROM pet p JOIN vaccine v
WHERE p.uuid = 'p1000000-0000-4000-8000-000000000001' AND v.uuid = 'vc000000-0000-4000-8000-000000000001';

-- care -----------------------------------------------------------------------
USE svc_care;

INSERT INTO medical_subject (uuid, name) VALUES
('ms000000-0000-4000-8000-000000000001', '내과'),
('ms000000-0000-4000-8000-000000000002', '피부과');

INSERT INTO symptom (uuid, name) VALUES
('sy000000-0000-4000-8000-000000000001', '구토'),
('sy000000-0000-4000-8000-000000000002', '설사'),
('sy000000-0000-4000-8000-000000000003', '피부소양');

INSERT INTO visit_slot (uuid, hospital_uuid, vet_uuid, slot_date, start_time, end_time, status, created_at, updated_at) VALUES
('sl000000-0000-4000-8000-000000000001', 'h1000000-0000-4000-8000-000000000001', 'v1000000-0000-4000-8000-000000000001', '2026-11-20', '10:00:00', '10:30:00', 'BOOKED', '2026-11-19 09:00:00', '2026-11-19 12:00:00'),
('sl000000-0000-4000-8000-000000000002', 'h1000000-0000-4000-8000-000000000001', 'v1000000-0000-4000-8000-000000000001', '2026-11-20', '10:30:00', '11:00:00', 'HELD',   '2026-11-19 09:00:00', '2026-11-19 12:10:00'),
('sl000000-0000-4000-8000-000000000003', 'h1000000-0000-4000-8000-000000000002', 'v1000000-0000-4000-8000-000000000002', '2026-11-20', '15:00:00', '15:30:00', 'BOOKED', '2026-11-19 09:00:00', '2026-11-19 13:00:00');

INSERT INTO consultation (uuid, caregiver_uuid, pet_uuid, vet_uuid, medical_subject_id, status, consult_type, is_emergency, content, clinical_note, summary, recommendation, created_at, accepted_at, completed_at)
SELECT 'c1000000-0000-4000-8000-000000000001',
       'a1000000-0000-4000-8000-000000000001', 'p1000000-0000-4000-8000-000000000001', 'v1000000-0000-4000-8000-000000000001',
       id, 'COMPLETED', 'CHAT', 1, '말티즈가 구토를 반복합니다', '탈수 소견', '급성 구토', '내원 권고',
       '2026-11-20 09:00:00', '2026-11-20 09:05:00', '2026-11-20 09:40:00'
FROM medical_subject WHERE name = '내과';

INSERT INTO consultation (uuid, caregiver_uuid, pet_uuid, vet_uuid, medical_subject_id, status, consult_type, is_emergency, content, summary, created_at)
SELECT 'c1000000-0000-4000-8000-000000000002',
       'a1000000-0000-4000-8000-000000000002', 'p1000000-0000-4000-8000-000000000002', 'v1000000-0000-4000-8000-000000000002',
       id, 'REQUESTED', 'VIDEO', 0, '고양이가 계속 긁습니다', '피부 소양 상담 대기',
       '2026-11-21 18:00:00'
FROM medical_subject WHERE name = '피부과';

INSERT INTO consultation_symptom (uuid, consultation_id, symptom_id)
SELECT 'cs000000-0000-4000-8000-000000000001', c.id, s.id
FROM consultation c JOIN symptom s
WHERE c.uuid = 'c1000000-0000-4000-8000-000000000001' AND s.name = '구토';

INSERT INTO consultation_symptom (uuid, consultation_id, symptom_id)
SELECT 'cs000000-0000-4000-8000-000000000002', c.id, s.id
FROM consultation c JOIN symptom s
WHERE c.uuid = 'c1000000-0000-4000-8000-000000000002' AND s.name = '피부소양';

INSERT INTO visit_reservation (uuid, hospital_uuid, caregiver_uuid, pet_uuid, medical_subject_id, visit_slot_id, status, hoped_visit_date, hoped_start_time, symptom_memo, created_at, accepted_at)
SELECT 'r1000000-0000-4000-8000-000000000001', 'h1000000-0000-4000-8000-000000000001',
       'a1000000-0000-4000-8000-000000000001', 'p1000000-0000-4000-8000-000000000001',
       m.id, sl.id, 'CONFIRMED', '2026-11-20', '10:00:00', '새벽부터 구토', '2026-11-19 12:00:00', '2026-11-19 12:30:00'
FROM medical_subject m JOIN visit_slot sl
WHERE m.name = '내과' AND sl.uuid = 'sl000000-0000-4000-8000-000000000001';

INSERT INTO visit_reservation (uuid, hospital_uuid, caregiver_uuid, pet_uuid, medical_subject_id, visit_slot_id, status, hoped_visit_date, hoped_start_time, symptom_memo, created_at)
SELECT 'r1000000-0000-4000-8000-000000000002', 'h1000000-0000-4000-8000-000000000001',
       'a1000000-0000-4000-8000-000000000001', 'p1000000-0000-4000-8000-000000000001',
       m.id, sl.id, 'PENDING', '2026-11-20', '10:30:00', '구토 이후 설사', '2026-11-19 12:10:00'
FROM medical_subject m JOIN visit_slot sl
WHERE m.name = '내과' AND sl.uuid = 'sl000000-0000-4000-8000-000000000002';

INSERT INTO visit_reservation (uuid, hospital_uuid, caregiver_uuid, pet_uuid, medical_subject_id, visit_slot_id, status, hoped_visit_date, hoped_start_time, symptom_memo, created_at, accepted_at)
SELECT 'r1000000-0000-4000-8000-000000000003', 'h1000000-0000-4000-8000-000000000002',
       'a1000000-0000-4000-8000-000000000002', 'p1000000-0000-4000-8000-000000000002',
       m.id, sl.id, 'CONFIRMED', '2026-11-20', '15:00:00', '피부 소양', '2026-11-19 13:00:00', '2026-11-19 13:20:00'
FROM medical_subject m JOIN visit_slot sl
WHERE m.name = '피부과' AND sl.uuid = 'sl000000-0000-4000-8000-000000000003';

INSERT INTO visit_reservation_symptom (uuid, visit_reservation_id, symptom_id)
SELECT 'rs000000-0000-4000-8000-000000000001', r.id, s.id
FROM visit_reservation r JOIN symptom s
WHERE r.uuid = 'r1000000-0000-4000-8000-000000000001' AND s.name = '구토';
INSERT INTO visit_reservation_symptom (uuid, visit_reservation_id, symptom_id)
SELECT 'rs000000-0000-4000-8000-000000000002', r.id, s.id
FROM visit_reservation r JOIN symptom s
WHERE r.uuid = 'r1000000-0000-4000-8000-000000000002' AND s.name = '설사';
INSERT INTO visit_reservation_symptom (uuid, visit_reservation_id, symptom_id)
SELECT 'rs000000-0000-4000-8000-000000000003', r.id, s.id
FROM visit_reservation r JOIN symptom s
WHERE r.uuid = 'r1000000-0000-4000-8000-000000000003' AND s.name = '피부소양';

-- community ------------------------------------------------------------------
USE svc_community;

INSERT INTO board (uuid, name) VALUES ('bd000000-0000-4000-8000-000000000001', '자유');
INSERT INTO category (uuid, name) VALUES ('ct000000-0000-4000-8000-000000000001', '건강');

INSERT INTO post (uuid, board_id, category_id, author_uuid, title, content, created_at)
SELECT 'po000000-0000-4000-8000-000000000001', b.id, c.id,
       'a1000000-0000-4000-8000-000000000001',
       '강아지 구토 대처', '말티즈가 구토를 해서 내과 상담을 받았습니다', '2026-11-22 11:00:00'
FROM board b JOIN category c;

INSERT INTO post (uuid, board_id, category_id, author_uuid, title, content, created_at)
SELECT 'po000000-0000-4000-8000-000000000002', b.id, c.id,
       'a1000000-0000-4000-8000-000000000002',
       '고양이 예방접종', '코리안숏헤어 종합백신 일정을 정리했습니다', '2026-11-22 15:00:00'
FROM board b JOIN category c;

INSERT INTO post_comment (uuid, post_id, author_uuid, depth, content, created_at)
SELECT 'cm000000-0000-4000-8000-000000000001', id, 'a1000000-0000-4000-8000-000000000002', 0,
       '저희 아이도 구토 후에 내원했습니다', '2026-11-22 12:00:00'
FROM post WHERE uuid = 'po000000-0000-4000-8000-000000000001';

INSERT INTO post_like (post_id, actor_uuid, actor_role, created_at)
SELECT id, 'a1000000-0000-4000-8000-000000000002', 'CAREGIVER', '2026-11-22 12:05:00'
FROM post WHERE uuid = 'po000000-0000-4000-8000-000000000001';

INSERT INTO follow (follower_uuid, following_uuid, created_at) VALUES
('a1000000-0000-4000-8000-000000000002', 'a1000000-0000-4000-8000-000000000001', '2026-11-22 12:10:00');

-- moderation -----------------------------------------------------------------
USE svc_moderation;

INSERT INTO report_reason (uuid, target_type, code, name, active) VALUES
('rr000000-0000-4000-8000-000000000001', 'POST', 'SPAM', '스팸', 1),
('rr000000-0000-4000-8000-000000000002', 'POST', 'ABUSE', '욕설', 1);

INSERT INTO report (uuid, reporter_uuid, reporter_type, target_uuid, target_type, content, status, created_at) VALUES
('rp000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', 'CAREGIVER',
 'po000000-0000-4000-8000-000000000002', 'POST', '광고성 접종 글처럼 보입니다', 'RECEIVED', '2026-11-22 16:00:00');

INSERT INTO report_reason_pick (report_id, report_reason_id)
SELECT r.id, rr.id FROM report r JOIN report_reason rr
WHERE r.uuid = 'rp000000-0000-4000-8000-000000000001' AND rr.code = 'SPAM';

-- media ----------------------------------------------------------------------
USE svc_media;

INSERT INTO media (uuid, uploader_uuid, file_name, content_type, object_key, file_size, created_at, updated_at) VALUES
('md000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', 'kong.jpg', 'image/jpeg', 'pet/kong.jpg', 120034, '2026-11-02 10:20:00', '2026-11-02 10:20:00');

INSERT INTO media_attachment (uuid, media_id, target_type, target_uuid, created_at)
SELECT 'ma000000-0000-4000-8000-000000000001', id, 'PET', 'p1000000-0000-4000-8000-000000000001', '2026-11-02 10:21:00'
FROM media WHERE uuid = 'md000000-0000-4000-8000-000000000001';

-- notification ---------------------------------------------------------------
USE svc_notification;

INSERT INTO notification (uuid, recipient_uuid, actor_uuid, event_id, type, title, content, target_type, target_uuid, created_at) VALUES
('nt000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000002',
 'e1000000-0000-4000-8000-000000000090', 'COMMENT', '댓글이 달렸습니다', '서연님이 구토 글에 댓글을 남겼습니다',
 'POST', 'po000000-0000-4000-8000-000000000001', '2026-11-22 12:00:00');

-- vet_query : 위 사실의 조회 사본 ------------------------------------------------
USE vet_query;

INSERT INTO processed_event (event_id, event_type, processed_at) VALUES
('e1000000-0000-4000-8000-000000000001', 'AccountRegistered', '2026-11-01 09:00:01.000000');

INSERT INTO q_profile (account_uuid, nickname, user_type, status, name) VALUES
('a1000000-0000-4000-8000-000000000001', '민호', 'CAREGIVER', 'ACTIVE', '이민호'),
('a1000000-0000-4000-8000-000000000002', '서연', 'CAREGIVER', 'ACTIVE', '최서연'),
('a1000000-0000-4000-8000-000000000003', '김수의', 'VETERINARIAN', 'ACTIVE', '김수의'),
('a1000000-0000-4000-8000-000000000004', '박수의', 'VETERINARIAN', 'ACTIVE', '박수의');

INSERT INTO q_hospital (hospital_uuid, region, si, gun, gu, name, road_address, lot_address, tel) VALUES
('h1000000-0000-4000-8000-000000000001', '서울', '서울', '', '강남구', '강남동물의료센터', '서울특별시 강남구 테헤란로 1', '서울특별시 강남구 역삼동 1', '02-111-0001'),
('h1000000-0000-4000-8000-000000000002', '부산', '부산', '', '해운대구', '해운대동물병원', '부산광역시 해운대구 해운대로 2', '부산광역시 해운대구 우동 2', '051-222-0002');

INSERT INTO q_hospital_hours (hospital_uuid, day_of_week, is_closed, open_time, close_time)
SELECT h.hospital_uuid, d.day_of_week,
       IF(h.hospital_uuid = 'h1000000-0000-4000-8000-000000000001' AND d.day_of_week = 7, 1, 0),
       IF(h.hospital_uuid = 'h1000000-0000-4000-8000-000000000001' AND d.day_of_week = 7, NULL, '09:00:00'),
       IF(h.hospital_uuid = 'h1000000-0000-4000-8000-000000000001' AND d.day_of_week = 7, NULL, '18:00:00')
FROM q_hospital h
JOIN (
  SELECT 1 AS day_of_week UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL
  SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
) d;

INSERT INTO q_vet (vet_uuid, account_uuid, name, major, specialty, is_available, status, hospital_uuid, hospital_name, region, si, gu) VALUES
('v1000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000003', '김수의', '내과', '내과', 1, 'ACTIVE', 'h1000000-0000-4000-8000-000000000001', '강남동물의료센터', '서울', '서울', '강남구'),
('v1000000-0000-4000-8000-000000000002', 'a1000000-0000-4000-8000-000000000004', '박수의', '피부과', '피부과', 1, 'ACTIVE', 'h1000000-0000-4000-8000-000000000002', '해운대동물병원', '부산', '부산', '해운대구');

INSERT INTO q_vet_weekday_off (vet_uuid, day_of_week) VALUES
('v1000000-0000-4000-8000-000000000001', 7),
('v1000000-0000-4000-8000-000000000002', 3);

INSERT INTO q_pet (pet_uuid, caregiver_uuid, caregiver_nickname, name, species_name, breed_name, sex, birth_date, weight_kg, is_neutered, status) VALUES
('p1000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', '민호', '콩이', '개', '말티즈', 'MALE', '2022-05-02', 3.40, 1, 'ACTIVE'),
('p1000000-0000-4000-8000-000000000002', 'a1000000-0000-4000-8000-000000000002', '서연', '나비', '고양이', '코리안숏헤어', 'FEMALE', '2023-08-19', 4.10, 0, 'ACTIVE');

INSERT INTO q_visit_reservation (
  reservation_uuid, status, hoped_visit_date, hoped_start_time, symptom_memo,
  hospital_uuid, hospital_name, region, si, gu, subject_name,
  slot_uuid, slot_start, slot_end,
  caregiver_uuid, caregiver_nickname, pet_uuid, pet_name, species_name, breed_name, created_at
) VALUES
('r1000000-0000-4000-8000-000000000001', 'CONFIRMED', '2026-11-20', '10:00:00', '새벽부터 구토',
 'h1000000-0000-4000-8000-000000000001', '강남동물의료센터', '서울', '서울', '강남구', '내과',
 'sl000000-0000-4000-8000-000000000001', '10:00:00', '10:30:00',
 'a1000000-0000-4000-8000-000000000001', '민호', 'p1000000-0000-4000-8000-000000000001', '콩이', '개', '말티즈', '2026-11-19 12:00:00'),
('r1000000-0000-4000-8000-000000000002', 'PENDING', '2026-11-20', '10:30:00', '구토 이후 설사',
 'h1000000-0000-4000-8000-000000000001', '강남동물의료센터', '서울', '서울', '강남구', '내과',
 'sl000000-0000-4000-8000-000000000002', '10:30:00', '11:00:00',
 'a1000000-0000-4000-8000-000000000001', '민호', 'p1000000-0000-4000-8000-000000000001', '콩이', '개', '말티즈', '2026-11-19 12:10:00'),
('r1000000-0000-4000-8000-000000000003', 'CONFIRMED', '2026-11-20', '15:00:00', '피부 소양',
 'h1000000-0000-4000-8000-000000000002', '해운대동물병원', '부산', '부산', '해운대구', '피부과',
 'sl000000-0000-4000-8000-000000000003', '15:00:00', '15:30:00',
 'a1000000-0000-4000-8000-000000000002', '서연', 'p1000000-0000-4000-8000-000000000002', '나비', '고양이', '코리안숏헤어', '2026-11-19 13:00:00');

INSERT INTO q_visit_symptom (reservation_uuid, symptom_uuid, symptom_name) VALUES
('r1000000-0000-4000-8000-000000000001', 'sy000000-0000-4000-8000-000000000001', '구토'),
('r1000000-0000-4000-8000-000000000002', 'sy000000-0000-4000-8000-000000000002', '설사'),
('r1000000-0000-4000-8000-000000000003', 'sy000000-0000-4000-8000-000000000003', '피부소양');

INSERT INTO q_consultation (
  consultation_uuid, status, consult_type, is_emergency, summary,
  caregiver_uuid, caregiver_nickname, pet_uuid, pet_name, species_name,
  vet_uuid, vet_name, subject_name, hospital_uuid, hospital_name, region,
  created_at, accepted_at, completed_at
) VALUES
('c1000000-0000-4000-8000-000000000001', 'COMPLETED', 'CHAT', 1, '급성 구토',
 'a1000000-0000-4000-8000-000000000001', '민호', 'p1000000-0000-4000-8000-000000000001', '콩이', '개',
 'v1000000-0000-4000-8000-000000000001', '김수의', '내과', 'h1000000-0000-4000-8000-000000000001', '강남동물의료센터', '서울',
 '2026-11-20 09:00:00', '2026-11-20 09:05:00', '2026-11-20 09:40:00'),
('c1000000-0000-4000-8000-000000000002', 'REQUESTED', 'VIDEO', 0, '피부 소양 상담 대기',
 'a1000000-0000-4000-8000-000000000002', '서연', 'p1000000-0000-4000-8000-000000000002', '나비', '고양이',
 'v1000000-0000-4000-8000-000000000002', '박수의', '피부과', 'h1000000-0000-4000-8000-000000000002', '해운대동물병원', '부산',
 '2026-11-21 18:00:00', NULL, NULL);

INSERT INTO q_consultation_symptom (consultation_uuid, symptom_uuid, symptom_name) VALUES
('c1000000-0000-4000-8000-000000000001', 'sy000000-0000-4000-8000-000000000001', '구토'),
('c1000000-0000-4000-8000-000000000002', 'sy000000-0000-4000-8000-000000000003', '피부소양');

INSERT INTO q_post (post_uuid, board_name, category_name, author_uuid, author_nickname, author_type, title, content, like_count, comment_count, created_at) VALUES
('po000000-0000-4000-8000-000000000001', '자유', '건강', 'a1000000-0000-4000-8000-000000000001', '민호', 'CAREGIVER', '강아지 구토 대처', '말티즈가 구토를 해서 내과 상담을 받았습니다', 1, 1, '2026-11-22 11:00:00'),
('po000000-0000-4000-8000-000000000002', '자유', '건강', 'a1000000-0000-4000-8000-000000000002', '서연', 'CAREGIVER', '고양이 예방접종', '코리안숏헤어 종합백신 일정을 정리했습니다', 0, 0, '2026-11-22 15:00:00');

INSERT INTO q_report (report_uuid, status, reporter_type, reporter_uuid, target_type, target_uuid, reason_codes, created_at) VALUES
('rp000000-0000-4000-8000-000000000001', 'RECEIVED', 'CAREGIVER', 'a1000000-0000-4000-8000-000000000001', 'POST', 'po000000-0000-4000-8000-000000000002', 'SPAM', '2026-11-22 16:00:00');

INSERT INTO q_notification (notification_uuid, recipient_uuid, type, title, read_at, created_at) VALUES
('nt000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', 'COMMENT', '댓글이 달렸습니다', NULL, '2026-11-22 12:00:00');

INSERT INTO agg_visit_daily (stat_date, hospital_uuid, hospital_name, region, status, reservation_count) VALUES
('2026-11-20', 'h1000000-0000-4000-8000-000000000001', '강남동물의료센터', '서울', 'CONFIRMED', 1),
('2026-11-20', 'h1000000-0000-4000-8000-000000000001', '강남동물의료센터', '서울', 'PENDING', 1),
('2026-11-20', 'h1000000-0000-4000-8000-000000000002', '해운대동물병원', '부산', 'CONFIRMED', 1);

INSERT INTO agg_consultation_daily (stat_date, subject_name, status, is_emergency, consultation_count) VALUES
('2026-11-20', '내과', 'COMPLETED', 1, 1),
('2026-11-21', '피부과', 'REQUESTED', 0, 1);

INSERT INTO agg_community_daily (stat_date, board_name, post_count, comment_count, like_count) VALUES
('2026-11-22', '자유', 2, 1, 1);
