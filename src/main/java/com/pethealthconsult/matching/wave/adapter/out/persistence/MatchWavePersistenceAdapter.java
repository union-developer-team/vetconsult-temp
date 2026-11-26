package com.pethealthconsult.matching.wave.adapter.out.persistence;

import com.pethealthconsult.matching.wave.application.port.out.SaveMatchWavePort;
import com.pethealthconsult.matching.wave.domain.MatchWave;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class MatchWavePersistenceAdapter implements SaveMatchWavePort {

    private final MatchWaveJpaRepository matchWaveJpaRepository;

    @Override
    public MatchWave save(MatchWave wave) {
        MatchWaveJpaEntity saved = matchWaveJpaRepository.save(
            MatchWavePersistenceMapper.toNewEntity(wave)
        );
        return MatchWavePersistenceMapper.toDomain(saved);
    }
}
