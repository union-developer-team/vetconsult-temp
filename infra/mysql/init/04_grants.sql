-- 앱 계정은 용도가 고정된다.
-- vet_command   : 쓰기 스키마만
-- vet_projector : 조회 스키마에만 적재
-- vet_reader    : 조회 스키마 SELECT 만

CREATE USER IF NOT EXISTS 'vet_command'@'%' IDENTIFIED BY 'vet_command';
CREATE USER IF NOT EXISTS 'vet_command'@'localhost' IDENTIFIED BY 'vet_command';
CREATE USER IF NOT EXISTS 'vet_projector'@'%' IDENTIFIED BY 'vet_projector';
CREATE USER IF NOT EXISTS 'vet_projector'@'localhost' IDENTIFIED BY 'vet_projector';
CREATE USER IF NOT EXISTS 'vet_reader'@'%' IDENTIFIED BY 'vet_reader';
CREATE USER IF NOT EXISTS 'vet_reader'@'localhost' IDENTIFIED BY 'vet_reader';

GRANT SELECT, INSERT, UPDATE, DELETE ON svc_identity.* TO 'vet_command'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON svc_clinic.* TO 'vet_command'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON svc_pet.* TO 'vet_command'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON svc_care.* TO 'vet_command'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON svc_community.* TO 'vet_command'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON svc_moderation.* TO 'vet_command'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON svc_media.* TO 'vet_command'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON svc_notification.* TO 'vet_command'@'%';

GRANT SELECT, INSERT, UPDATE, DELETE ON svc_identity.* TO 'vet_command'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON svc_clinic.* TO 'vet_command'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON svc_pet.* TO 'vet_command'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON svc_care.* TO 'vet_command'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON svc_community.* TO 'vet_command'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON svc_moderation.* TO 'vet_command'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON svc_media.* TO 'vet_command'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON svc_notification.* TO 'vet_command'@'localhost';

GRANT SELECT, INSERT, UPDATE, DELETE ON vet_query.* TO 'vet_projector'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON vet_query.* TO 'vet_projector'@'localhost';

GRANT SELECT ON vet_query.* TO 'vet_reader'@'%';
GRANT SELECT ON vet_query.* TO 'vet_reader'@'localhost';

FLUSH PRIVILEGES;
