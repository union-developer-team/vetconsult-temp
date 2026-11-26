package com.louiekury.matching.wave.application.port.out;

import com.louiekury.matching.wave.domain.MatchWave;

public interface SaveMatchWavePort {

    /**
     * 저장 후 생성된 id가 채워진 MatchWave를 반환한다.
     */
    MatchWave save(MatchWave wave);
}
