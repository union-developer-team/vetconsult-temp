package com.louiekury.matching.wave.application.port.out;

import com.louiekury.matching.wave.application.model.MatchRequestSnapshot;
import java.util.Optional;

public interface LoadMatchRequestPort {

    Optional<MatchRequestSnapshot> findByUuid(String requestUuid);
}
