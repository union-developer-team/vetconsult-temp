-- DEV 검증용 스텁 호출 1건 (REQUESTED)
-- 대상: svc_matching.consultation_request
USE svc_matching;

INSERT INTO consultation_request (
  uuid,
  caregiver_uuid,
  pet_uuid,
  medical_subject_uuid,
  channel,
  is_emergency,
  status,
  origin_lat,
  origin_lng,
  geohash,
  region,
  si,
  gu,
  search_radius_m,
  symptom_memo,
  requested_at,
  expire_at,
  assigned_vet_uuid,
  assigned_hospital_uuid,
  assigned_at
) VALUES (
  'rq000000-0000-4000-8000-00000000stub',
  'a1000000-0000-4000-8000-000000000001',
  'p1000000-0000-4000-8000-000000000001',
  'ms000000-0000-4000-8000-000000000001',
  'CHAT',
  0,
  'REQUESTED',
  37.497900,
  127.028100,
  'wydm9',
  '서울',
  '서울특별시',
  '강남구',
  3000,
  '스텁 매칭 상태 전이 테스트',
  NOW(),
  DATE_ADD(NOW(), INTERVAL 10 MINUTE),
  NULL,
  NULL,
  NULL
)
ON DUPLICATE KEY UPDATE
  status = 'REQUESTED',
  assigned_vet_uuid = NULL,
  assigned_hospital_uuid = NULL,
  assigned_at = NULL,
  requested_at = NOW(),
  expire_at = DATE_ADD(NOW(), INTERVAL 10 MINUTE);
