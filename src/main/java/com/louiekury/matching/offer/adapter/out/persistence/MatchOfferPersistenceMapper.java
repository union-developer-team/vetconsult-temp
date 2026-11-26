package com.louiekury.matching.offer.adapter.out.persistence;

import com.louiekury.matching.offer.domain.MatchOffer;
import com.louiekury.matching.offer.domain.MatchOfferStatus;

final class MatchOfferPersistenceMapper {

    private MatchOfferPersistenceMapper() {
    }

    static MatchOfferJpaEntity toNewEntity(MatchOffer offer) {
        return MatchOfferJpaEntity.newOffer(
            offer.getUuid(),
            offer.getRequestId(),
            offer.getWaveId(),
            offer.getVetUuid(),
            offer.getHospitalUuid(),
            offer.getDistanceM(),
            offer.getScore(),
            offer.getStatus().name(),
            offer.getOfferedAt(),
            offer.getRespondBy(),
            offer.getRespondedAt()
        );
    }

    static MatchOffer toDomain(MatchOfferJpaEntity entity) {
        return MatchOffer.restore(
            entity.getId(),
            entity.getUuid(),
            entity.getRequestId(),
            entity.getWaveId(),
            entity.getVetUuid(),
            entity.getHospitalUuid(),
            entity.getDistanceM(),
            entity.getScore(),
            MatchOfferStatus.valueOf(entity.getStatus()),
            entity.getOfferedAt(),
            entity.getRespondBy(),
            entity.getRespondedAt()
        );
    }
}
