package com.louiekury.matching.wave.adapter.out.persistence;

import com.louiekury.matching.wave.domain.MatchWave;

final class MatchWavePersistenceMapper {

    private MatchWavePersistenceMapper() {
    }

    static MatchWaveJpaEntity toNewEntity(MatchWave wave) {
        return MatchWaveJpaEntity.newWave(
            wave.getUuid(),
            wave.getRequestId(),
            wave.getWaveNo(),
            wave.getRadiusM(),
            wave.getStartedAt(),
            wave.getFinishedAt()
        );
    }

    static MatchWave toDomain(MatchWaveJpaEntity entity) {
        return MatchWave.restore(
            entity.getId(),
            entity.getUuid(),
            entity.getRequestId(),
            entity.getWaveNo(),
            entity.getRadiusM(),
            entity.getStartedAt(),
            entity.getFinishedAt()
        );
    }
}
