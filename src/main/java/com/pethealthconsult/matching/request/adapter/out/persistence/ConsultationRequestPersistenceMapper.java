package com.pethealthconsult.matching.request.adapter.out.persistence;

import com.pethealthconsult.matching.request.domain.ConsultationRequest;
import com.pethealthconsult.matching.request.domain.ConsultationRequestStatus;

final class ConsultationRequestPersistenceMapper {

    private ConsultationRequestPersistenceMapper() {
    }

    static ConsultationRequest toDomain(ConsultationRequestJpaEntity entity) {
        return ConsultationRequest.restore(
            entity.getId(),
            entity.getUuid(),
            entity.getCaregiverUuid(),
            entity.getPetUuid(),
            entity.getMedicalSubjectUuid(),
            entity.getChannel(),
            entity.isEmergency(),
            ConsultationRequestStatus.valueOf(entity.getStatus()),
            entity.getOriginLat(),
            entity.getOriginLng(),
            entity.getGeohash(),
            entity.getRegion(),
            entity.getSi(),
            entity.getGu(),
            entity.getSearchRadiusM(),
            entity.getSymptomMemo(),
            entity.getRequestedAt(),
            entity.getExpireAt(),
            entity.getAssignedVetUuid(),
            entity.getAssignedHospitalUuid(),
            entity.getAssignedAt()
        );
    }

    static void applyDomain(ConsultationRequestJpaEntity entity, ConsultationRequest request) {
        entity.applyStatus(request.getStatus().name());
    }
}
