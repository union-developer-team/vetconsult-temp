package com.pethealthconsult.matching.wave.application.port.out;

import com.pethealthconsult.matching.wave.application.model.MatchRequestSnapshot;
import java.util.Optional;

public interface LoadMatchRequestPort {

    Optional<MatchRequestSnapshot> findByUuid(String requestUuid);
}
